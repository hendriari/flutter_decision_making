import 'package:flutter_decision_making/core/decision_making_performance_profiling.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_item_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/pairwise_comparison_input_dto.dart';

/// Generates the pairwise comparison matrix for criteria in AHP.
///
/// This function transforms user-provided pairwise comparisons of decision criteria
/// into a complete reciprocal matrix. This matrix is fundamental to AHP as it
/// represents the relative importance of each criterion to the decision goal.
///
/// **Matrix Characteristics:**
///
/// 1. **Reciprocal Matrix**:
///    - If matrix[i][j] = x, then matrix[j][i] = 1/x
///    - This ensures mathematical consistency
///
/// 2. **Positive Elements**:
///    - All values must be positive (typically 1/9 to 9)
///    - Zero or negative values are invalid
///
/// 3. **Unity Diagonal**:
///    - matrix[i][i] = 1 for all i
///    - Each criterion compared to itself is equal
///
/// 4. **Symmetric Structure**:
///    - The matrix is symmetric around the reciprocal relationship
///    - Only n(n-1)/2 comparisons needed for n criteria
///
/// **Saaty's Fundamental Scale:**
///
/// | Value | Meaning                              | Example                        |
/// |-------|--------------------------------------|--------------------------------|
/// | 1     | Equal importance                     | Cost = Quality                 |
/// | 3     | Moderate importance of one over other| Quality > Cost (moderate)      |
/// | 5     | Strong importance                    | Quality >> Cost                |
/// | 7     | Very strong importance               | Safety >>> Cost                |
/// | 9     | Extreme importance                   | Safety >>>> Aesthetics         |
/// | 2,4,6,8| Intermediate values                 | Between adjacent judgments     |
/// | 1/3-1/9| Reciprocals                         | When second element dominates  |
///
/// **Construction Process:**
///
/// 1. **Initialize**: Create n×n matrix with all diagonal elements = 1.0
///
/// 2. **Map IDs**: Build lookup table mapping criterion IDs to matrix indices
///
/// 3. **Fill Comparisons**:
///    - For each user comparison (A vs B with value x):
///      * If A is more important: matrix[A][B] = x, matrix[B][A] = 1/x
///      * If B is more important: matrix[A][B] = 1/x, matrix[B][A] = x
///
/// **Parameters:**
/// - [data]: Map containing:
///   - 'items': List of criteria definitions (`List<Map<String, dynamic>>`)
///   - 'inputs': List of pairwise comparison inputs (`List<Map<String, dynamic>>`)
///
/// **Returns:**
/// Square matrix (`List<List<double>>`) where matrix[i][j] represents
/// how much criterion i is preferred over criterion j.
///
/// **Throws:**
/// - [Exception] if any item is missing an ID
/// - [Exception] if a referenced criterion is not found in the items list
/// - [Exception] if any comparison value is zero or negative
///
/// **Example:**
/// ```dart
/// // Decision: Choose a car
/// // Criteria: Cost, Safety, Fuel Efficiency
///
/// final items = [
///   {'id': 'c1', 'name': 'Cost'},
///   {'id': 'c2', 'name': 'Safety'},
///   {'id': 'c3', 'name': 'Fuel Efficiency'}
/// ];
///
/// // User judgments:
/// // - Safety is 3x more important than Cost
/// // - Safety is 5x more important than Fuel Efficiency
/// // - Cost is 2x more important than Fuel Efficiency
///
/// final inputs = [
///   {
///     'left': {...Cost},
///     'right': {...Safety},
///     'preferenceValue': 3,
///     'isLeftMoreImportant': false  // Safety more important
///   },
///   {
///     'left': {...Safety},
///     'right': {...FuelEff},
///     'preferenceValue': 5,
///     'isLeftMoreImportant': true  // Safety more important
///   },
///   {
///     'left': {...Cost},
///     'right': {...FuelEff},
///     'preferenceValue': 2,
///     'isLeftMoreImportant': true  // Cost more important
///   }
/// ];
///
/// final matrix = await ahpGenerateResultPairwiseMatrixCriteria({
///   'items': items,
///   'inputs': inputs
/// });
///
/// // Resulting matrix:
/// //           Cost   Safety  FuelEff
/// // Cost   [ 1.0,   0.33,   2.0   ]
/// // Safety [ 3.0,   1.0,    5.0   ]
/// // FuelEff[ 0.5,   0.2,    1.0   ]
/// ```
///
/// **Matrix Reading:**
/// - Row represents "this criterion"
/// - Column represents "compared to that criterion"
/// - matrix[Safety][Cost] = 3.0 means "Safety is 3x more important than Cost"
/// - matrix[Cost][Safety] = 0.33 means "Cost is 1/3 as important as Safety"
///
/// **Next Steps:**
/// After generating this matrix:
/// 1. Calculate eigenvector (priority weights)
/// 2. Check consistency ratio
/// 3. Use weights in final score calculation
///
/// **Performance:**
/// - Time complexity: O(n² + c) where n = criteria, c = comparisons
/// - Space complexity: O(n²) for the matrix
/// - Typical case: c = n(n-1)/2 (all pairs compared)
Future<List<List<double>>> ahpGenerateResultPairwiseMatrixCriteria(
    Map<String, dynamic> data) async {
  startPerformanceProfiling('generate result pairwise matrix criteria');

  try {
    final itemsRaw = List<Map<String, dynamic>>.from(data['items']);
    final inputsRaw = List<Map<String, dynamic>>.from(data['inputs']);

    final inputsDto =
        inputsRaw.map((e) => PairwiseComparisonInputDto.fromMap(e)).toList();
    final itemDto = itemsRaw.map((e) => AhpItemDto.fromMap(e)).toList();

    // Initialize matrix with identity (diagonal = 1.0)
    final matrix = List.generate(
      itemDto.length,
      (_) => List.filled(itemDto.length, 1.0),
    );

    // Build ID-to-index mapping for quick lookups
    final itemIndexMap = <String, int>{};
    for (int index = 0; index < itemDto.length; index++) {
      final id = itemDto[index].id;
      if (id == null || id.isEmpty) {
        throw Exception('Item with missing ID found');
      }
      itemIndexMap[id] = index;
    }

    // Process each pairwise comparison
    for (final e in inputsDto) {
      final i = itemIndexMap[e.left.id];
      final j = itemIndexMap[e.right.id];
      final value = e.preferenceValue?.toDouble() ?? 1.0;

      if (i == null || j == null) {
        throw Exception('One or both items not found in the list');
      }

      if (value <= 0) {
        throw Exception('Comparison value must be greater than zero');
      }

      // Assign values based on importance direction
      if (e.isLeftMoreImportant == true) {
        matrix[i][j] = value;
        matrix[j][i] = 1 / value;
      } else {
        matrix[i][j] = 1 / value;
        matrix[j][i] = value;
      }
    }

    return matrix;
  } finally {
    endPerformanceProfiling('generate result pairwise matrix criteria');
  }
}
