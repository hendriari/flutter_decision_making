import 'package:flutter_decision_making/core/decision_making_performance_profiling.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_consistency_ratio_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_item_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_result_detail_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_result_dto.dart';

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
      throw Exception('Alternative matrix is empty.');
    }

    final int altCount = eigenVectorsAlternative.first.length;
    final int criteriaCount = eigenVectorCriteria.length;

    // Calculate final scores: Σ(criteria_weight × alternative_priority)
    List<double> result = List.filled(altCount, 0.0);

    for (int i = 0; i < altCount; i++) {
      for (int j = 0; j < criteriaCount; j++) {
        result[i] += eigenVectorCriteria[j] * eigenVectorsAlternative[j][i];
      }
    }

    // Build detailed result objects
    final ahpResultDetail = <AhpResultDetailDto>[];

    for (int i = 0; i < altCount; i++) {
      ahpResultDetail.add(
        AhpResultDetailDto(
          id: alternatives[i].id,
          name: alternatives[i].name,
          value: result[i],
        ),
      );
    }

    // Find the worst consistency ratio among alternatives
    final alternativesConsistency = consistencyAlternatives
      ..sort((a, b) => b.ratio.compareTo(a.ratio));

    // Generate warning note if any inconsistencies detected
    String? note = !consistencyCriteria.isConsistent ||
            consistencyAlternatives.any((e) => e.isConsistent == false)
        ? '''
Thank you for completing the assessment process. Based on the consistency check, the resulting Consistency Ratio (CR) exceeds the acceptable threshold of 0.1.
As a result, the current assessment does not meet the expected level of consistency and therefore cannot yet be considered valid.
We recommend reviewing and revising the assessment to ensure that the resulting analysis is more accurate and reliable for decision-making.
Detail:
${!consistencyCriteria.isConsistent ? '* inconsistency on criteria' : ''}
${consistencyAlternatives.any((e) => e.isConsistent == false) ? '* Inconsistency on alternatives per criteria:\n${consistencyAlternatives.where((e) => !e.isConsistent).map((e) => '- ${e.source}: ${e.ratio}').join('\n')}' : ''}
'''
        : null;

    // Build final result with sorted alternatives and consistency info
    final ahpResult = AhpResultDto(
      results: ahpResultDetail..sort((a, b) => b.value.compareTo(a.value)),
      isConsistentCriteria: consistencyCriteria.isConsistent,
      consistencyCriteriaRatio: consistencyCriteria.ratio,
      isConsistentAlternative: alternativesConsistency[0].isConsistent,
      consistencyAlternativeRatio: alternativesConsistency[0].ratio,
      note: note,
    );

    return ahpResult.toMap();
  } catch (e) {
    throw Exception('Failed calculate final score: $e');
  } finally {
    endPerformanceProfiling('calculate final score');
  }
}
