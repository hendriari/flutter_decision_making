import 'package:decision_making_core/decision_making_core.dart';
import 'package:flutter_decision_making/core/decision_making_performance_profiling.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_consistency_ratio_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_item_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/mapper/ahp_result_mapper.dart';
import 'package:flutter_decision_making/feature/ahp/data/mapper/ahp_item_mapper.dart';
import 'package:flutter_decision_making/feature/ahp/data/mapper/ahp_consistency_ratio_mapper.dart';

/// Calculates the final AHP scores for all alternatives.
///
/// This is the culminating step in the AHP process where criteria weights
/// are combined with alternative priorities to produce final decision scores.
///
/// **AHP Final Score Formula:**
/// ```
/// Score(alternative_i) = Σ (weight_criteria_j × priority_alternative_i_under_criteria_j)
/// ```
///
/// For each alternative, we multiply:
/// - The weight of each criterion (from criteria eigenvector)
/// - By the alternative's priority under that criterion (from alternative eigenvector)
///
/// Then sum across all criteria to get the final score.
///
/// **Process Flow:**
///
/// 1. **Extract and validate input data**
///    - Criteria weights (eigenvector)
///    - Alternative priorities for each criterion (eigenvectors)
///    - Alternative definitions
///    - Consistency ratio data
///
/// 2. **Calculate weighted scores**
///    - For each alternative:
///      - For each criterion:
///        - Multiply criterion weight × alternative priority
///      - Sum all weighted priorities
///
/// 3. **Generate results with consistency checks**
///    - Create result objects with scores
///    - Sort alternatives by score (highest first)
///    - Include consistency validation
///    - Generate warning notes if inconsistent
///
/// **Parameters:**
/// - [data]: Map containing:
///   - 'eigen_vector_criteria': Weights for each criterion (`List<double>`)
///   - 'eigen_vector_alternative': Priority vectors for alternatives under each criterion (`List<List<double>>`)
///   - 'alternative_raw': List of alternative definitions (`List<dynamic>`)
///   - 'consistency_criteria_raw': Consistency data for criteria (Map)
///   - 'consistency_alternative_raw': Consistency data for alternatives (`List<dynamic>`)
///
/// **Returns:**
/// Map representing AhpResultDto containing:
/// - 'results': Sorted list of alternatives with their final scores
/// - 'isConsistentCriteria': Boolean indicating criteria consistency
/// - 'consistencyCriteriaRatio': CR value for criteria
/// - 'isConsistentAlternative': Boolean for worst alternative consistency
/// - 'consistencyAlternativeRatio': Highest CR among alternatives
/// - 'note': Warning message if any inconsistencies detected (null if all consistent)
///
/// **Throws:**
/// - [Exception] if alternative matrix is empty
/// - [Exception] if calculation fails
///
/// **Consistency Validation:**
/// The function checks if:
/// - Criteria comparisons are consistent (CR ≤ 0.1)
/// - All alternative comparisons are consistent (CR ≤ 0.1 for each criterion)
///
/// If inconsistencies are detected, a detailed note is generated explaining:
/// - Which comparisons are inconsistent
/// - Their CR values
/// - Recommendation to revise assessments
///
/// **Example:**
/// ```dart
/// final data = {
///   'eigen_vector_criteria': [0.5, 0.3, 0.2], // 3 criteria weights
///   'eigen_vector_alternative': [
///     [0.6, 0.3, 0.1], // Priorities under criterion 1
///     [0.2, 0.5, 0.3], // Priorities under criterion 2
///     [0.4, 0.4, 0.2], // Priorities under criterion 3
///   ],
///   'alternative_raw': [...], // 3 alternatives
///   'consistency_criteria_raw': {...},
///   'consistency_alternative_raw': [...]
/// };
///
/// final result = await ahpFinalScore(data);
///
/// // Final scores calculation:
/// // Alt1 = 0.5×0.6 + 0.3×0.2 + 0.2×0.4 = 0.3 + 0.06 + 0.08 = 0.44
/// // Alt2 = 0.5×0.3 + 0.3×0.5 + 0.2×0.4 = 0.15 + 0.15 + 0.08 = 0.38
/// // Alt3 = 0.5×0.1 + 0.3×0.3 + 0.2×0.2 = 0.05 + 0.09 + 0.04 = 0.18
/// //
/// // Ranking: Alt1 (0.44) > Alt2 (0.38) > Alt3 (0.18)
/// ```
///
/// **Output Interpretation:**
/// - Scores are normalized and sum to 1.0
/// - Higher score = better alternative based on all criteria
/// - Scores represent relative preference strength
/// - Consistency ratios validate the reliability of results
///
/// **Performance:**
/// - Time complexity: O(n × m) where n = alternatives, m = criteria
/// - Space complexity: O(n) for storing results
Future<Map<String, dynamic>> ahpFinalScore(Map<String, dynamic> data) async {
  startPerformanceProfiling('calculate final score..');
  try {
    final eigenVectorsAlternativeRaw =
        data['eigen_vector_alternative'] as List<dynamic>;
    final alternativesRaw = data['alternative_raw'] as List<dynamic>;
    final consistencyCriteriaRaw = data['consistency_criteria_raw'];
    final consistencyAlternativesRaw =
        data['consistency_alternative_raw'] as List<dynamic>;

    List<double> eigenVectorCriteria = data['eigen_vector_criteria'];
    List<List<double>> eigenVectorsAlternative = eigenVectorsAlternativeRaw
        .map((row) => (row as List<dynamic>).map((e) => e as double).toList())
        .toList();
    List<AhpItemDto> alternatives =
        alternativesRaw.map((e) => AhpItemDto.fromMap(e)).toList();
    final consistencyCriteria =
        AhpConsistencyRatioDto.fromMap(consistencyCriteriaRaw);
    List<AhpConsistencyRatioDto> consistencyAlternatives =
        consistencyAlternativesRaw
            .map((e) => AhpConsistencyRatioDto.fromMap(e))
            .toList();

    if (eigenVectorsAlternative.isEmpty ||
        eigenVectorsAlternative.first.isEmpty) {
      throw DecisionInputException('Alternative matrix is empty.');
    }

    final finalResult = AhpCalculator.calculateFinalScore(
      eigenVectorCriteria: eigenVectorCriteria,
      eigenVectorsAlternative: eigenVectorsAlternative,
      alternatives: alternatives.map((e) => e.toEntity()).toList(),
      consistencyCriteria: consistencyCriteria.toEntity(),
      consistencyAlternatives:
          consistencyAlternatives.map((e) => e.toEntity()).toList(),
    );

    return AhpResultMapper.fromEntity(finalResult).toMap();
  } catch (e) {
    if (e is DecisionInputException) rethrow;
    throw Exception('Failed calculate final score: $e');
  } finally {
    endPerformanceProfiling('calculate final score');
  }
}
