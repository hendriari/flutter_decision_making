import 'package:decision_making_core/decision_making_core.dart';
import 'package:flutter_decision_making/core/decision_making_performance_profiling.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_item_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/pairwise_comparison_alternative_input_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/mapper/ahp_item_mapper.dart';
import 'package:flutter_decision_making/feature/ahp/data/mapper/pairwise_comparison_input_mapper.dart';

/// Generates the pairwise comparison matrix for alternatives under a criterion.
///
/// This function converts user-provided pairwise comparisons into a complete
/// square matrix that can be used for eigenvector calculation. The matrix
/// represents the relative preferences between all alternatives.
///
/// **Matrix Properties:**
/// - **Square matrix**: n×n where n is the number of alternatives
/// - **Reciprocal**: If matrix[i][j] = x, then matrix[j][i] = 1/x
/// - **Diagonal is 1**: matrix[i][i] = 1 (alternative compared to itself)
/// - **Positive values**: All elements are positive real numbers
///
/// **Saaty's Scale (1-9):**
/// - 1: Equal importance
/// - 3: Moderate importance of one over another
/// - 5: Strong importance
/// - 7: Very strong importance
/// - 9: Extreme importance
/// - 2,4,6,8: Intermediate values
/// - Reciprocals (1/2, 1/3, etc.): When the second element is more important
///
/// **Matrix Construction Algorithm:**
///
/// 1. **Initialize matrix**: Create n×n matrix filled with 1.0 (diagonal values)
///
/// 2. **Build index map**: Map alternative IDs to matrix row/column indices
///
/// 3. **Process each comparison**:
///    - Get indices i and j for the compared alternatives
///    - Get preference value and direction from user input
///    - If left is more important:
///      * matrix[i][j] = value
///      * matrix[j][i] = 1/value
///    - If right is more important:
///      * matrix[i][j] = 1/value
///      * matrix[j][i] = value
///
/// **Parameters:**
/// - [data]: Map containing:
///   - 'items': List of alternative items (`List<Map<String, dynamic>>`)
///   - 'inputs': List of pairwise comparison inputs (`List<Map<String, dynamic>>`)
///               Should contain exactly one PairwiseAlternativeInputDto
///
/// **Returns:**
/// A square matrix (`List<List<double>>`) representing all pairwise comparisons.
///
/// **Throws:**
/// - [ArgumentError] if alternative list is empty
/// - [Exception] if any alternative is missing an ID
/// - [Exception] if an alternative reference is not found in the list
/// - [Exception] if any comparison value is zero or negative
///
/// **Example:**
/// ```dart
/// // 3 alternatives: A, B, C
/// // User comparisons:
/// // - A vs B: A is 3x more important
/// // - A vs C: A is 5x more important
/// // - B vs C: B is 2x more important
///
/// final items = [
///   {'id': 'a', 'name': 'Alternative A'},
///   {'id': 'b', 'name': 'Alternative B'},
///   {'id': 'c', 'name': 'Alternative C'}
/// ];
///
/// final inputs = [{
///   'alternative': [
///     {'left': {...A}, 'right': {...B}, 'preferenceValue': 3, 'isLeftMoreImportant': true},
///     {'left': {...A}, 'right': {...C}, 'preferenceValue': 5, 'isLeftMoreImportant': true},
///     {'left': {...B}, 'right': {...C}, 'preferenceValue': 2, 'isLeftMoreImportant': true}
///   ]
/// }];
///
/// final matrix = await ahpGenerateResultPairwiseMatrixAlternative({
///   'items': items,
///   'inputs': inputs
/// });
///
/// // Resulting matrix:
/// // [
/// //   [1.0,  3.0,  5.0],  // A compared to A, B, C
/// //   [0.33, 1.0,  2.0],  // B compared to A, B, C
/// //   [0.2,  0.5,  1.0]   // C compared to A, B, C
/// // ]
/// ```
///
/// **Special Case:**
/// If the inputs list is empty, returns an identity matrix (all 1.0)
/// indicating no preferences have been specified.
///
/// **Matrix Interpretation:**
/// - matrix[i][j] = 5: Alternative i is 5x more preferred than alternative j
/// - matrix[i][j] = 0.5: Alternative i is half as preferred as alternative j
/// - matrix[i][j] = 1: Alternatives i and j are equally preferred
///
/// **Performance:**
/// - Time complexity: O(n² + c) where n = alternatives, c = comparisons
/// - Space complexity: O(n²) for the matrix
/// - Typical case: c = n(n-1)/2 (all pairwise combinations)
Future<List<List<double>>> ahpGenerateResultPairwiseMatrixAlternative(
    Map<String, dynamic> data) async {
  startPerformanceProfiling('generate pairwise matrix alternative');
  try {
    final itemsRaw = List<Map<String, dynamic>>.from(data['items']);
    final inputsRaw = List<Map<String, dynamic>>.from(data['inputs']);

    final itemDto = itemsRaw.map((e) => AhpItemDto.fromMap(e)).toList();
    final inputsDto =
        inputsRaw.map((e) => PairwiseAlternativeInputDto.fromMap(e)).toList();

    if (itemDto.isEmpty) {
      throw ArgumentError('Alternative list is empty');
    }

    final pairwise = inputsDto.isEmpty
        ? <PairwiseComparisonInput>[]
        : inputsDto.first.alternative.map((e) => e.toEntity()).toList();

    return AhpCalculator.generateResultPairwiseMatrixAlternative(
      itemDto.map((e) => e.toEntity()).toList(),
      pairwise,
    );
  } finally {
    endPerformanceProfiling('generate pairwise matrix alternative');
  }
}
