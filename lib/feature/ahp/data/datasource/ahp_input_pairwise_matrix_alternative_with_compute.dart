import 'dart:math';
import 'package:flutter_decision_making/core/decision_making_performance_profiling.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_hierarchy_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/pairwise_comparison_alternative_input_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/pairwise_comparison_input_dto.dart';

/// Generates pairwise comparison input templates for alternatives under each criterion.
///
/// In AHP, after comparing criteria against each other, we must also compare
/// alternatives under each criterion. This function creates all the necessary
/// pairwise comparison templates that users will fill in later.
///
/// **Purpose:**
/// Creates structured comparison templates where users can specify:
/// - Which alternative is preferred
/// - By how much (using Saaty's 1-9 scale)
///
/// **Algorithm:**
/// For each criterion in the hierarchy:
/// 1. Extract all alternatives under that criterion
/// 2. Generate all unique pairs (i, j) where i < j
/// 3. Create comparison template for each pair
/// 4. Assign unique IDs to each comparison
///
/// **Pairwise Combinations:**
/// For n alternatives, generates n(n-1)/2 comparisons per criterion.
///
/// Examples:
/// - 3 alternatives: 3 comparisons (A-B, A-C, B-C)
/// - 4 alternatives: 6 comparisons (A-B, A-C, A-D, B-C, B-D, C-D)
/// - 5 alternatives: 10 comparisons
///
/// **Parameters:**
/// - [data]: Map containing:
///   - 'data': List of hierarchy nodes (`List<Map<String, dynamic>>`)
///             Each node contains a criterion and its alternatives
///
/// **Returns:**
/// List of Maps representing PairwiseAlternativeInputDto objects.
/// Each contains:
/// - criterion: The criterion being evaluated
/// - alternative: List of pairwise comparisons for alternatives under that criterion
///
/// Each comparison template includes:
/// - id: Unique identifier
/// - left: First alternative in the pair
/// - right: Second alternative in the pair
/// - preferenceValue: null (to be filled by user)
/// - isLeftMoreImportant: null (to be filled by user)
///
/// **Throws:**
/// - [Exception] if generation fails
///
/// **Example:**
/// ```dart
/// // Input: 2 criteria, each with 3 alternatives
/// final hierarchyData = [
///   {
///     'criteria': {'id': 'c1', 'name': 'Cost'},
///     'alternative': [
///       {'id': 'a1', 'name': 'Option A'},
///       {'id': 'a2', 'name': 'Option B'},
///       {'id': 'a3', 'name': 'Option C'}
///     ]
///   },
///   // ... more criteria
/// ];
///
/// final result = await generateInputPairwiseAlternative({
///   'data': hierarchyData
/// });
///
/// // Output: For each criterion, 3 comparisons:
/// // Criterion "Cost":
/// //   - Compare A vs B (to be filled)
/// //   - Compare A vs C (to be filled)
/// //   - Compare B vs C (to be filled)
/// ```
///
/// **User Workflow:**
/// 1. System generates templates (this function)
/// 2. User fills in comparison values:
///    - Selects which alternative is preferred
///    - Assigns importance value (1-9 scale)
/// 3. System processes filled comparisons to generate results
///
/// **ID Generation:**
/// Each comparison gets a unique ID combining:
/// - Pair indices (i, j)
/// - Current timestamp in microseconds
/// - Random number (0-99999)
///
/// This ensures uniqueness even in concurrent operations.
///
/// **Performance:**
/// - Time complexity: O(m × n²) where m = criteria, n = alternatives
/// - Space complexity: O(m × n²) for storing all comparisons
/// - For large datasets, this can generate many comparisons:
///   * 5 criteria × 10 alternatives = 5 × 45 = 225 comparisons
///   * 10 criteria × 8 alternatives = 10 × 28 = 280 comparisons
Future<List<Map<String, dynamic>>> generateInputPairwiseAlternative(
  Map<String, dynamic> data,
) async {
  startPerformanceProfiling('generate pairwise alternative');

  try {
    final rawList = List<Map<String, dynamic>>.from(data['data'] ?? []);

    final dtoList = rawList.map((e) => AhpHierarchyDto.fromMap(e)).toList();

    final result = <PairwiseAlternativeInputDto>[];

    for (var dto in dtoList) {
      final alternative = dto.alternative;
      final pairwise = <PairwiseComparisonInputDto>[];

      // Generate all unique pairwise combinations
      for (int i = 0; i < alternative.length; i++) {
        for (int j = i + 1; j < alternative.length; j++) {
          pairwise.add(
            PairwiseComparisonInputDto(
              id: '${i}_${j}_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(100000)}',
              left: alternative[i],
              right: alternative[j],
              preferenceValue: null,
              isLeftMoreImportant: null,
            ),
          );
        }
      }

      result.add(
        PairwiseAlternativeInputDto(
          criteria: dto.criteria,
          alternative: pairwise,
        ),
      );
    }
    return result.map((e) => e.toMap()).toList();
  } catch (e) {
    throw Exception('Failed generate pairwise alternative: $e');
  } finally {
    endPerformanceProfiling('generate pairwise alternative');
  }
}
