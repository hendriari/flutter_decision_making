import 'package:flutter_decision_making/core/decision_making_performance_profiling.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_consistency_ratio_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_item_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_result_detail_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_result_dto.dart';

/// AHP FINAL SCORE ISOLATED
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

    List<double> result = List.filled(altCount, 0.0);

    for (int i = 0; i < altCount; i++) {
      for (int j = 0; j < criteriaCount; j++) {
        result[i] += eigenVectorCriteria[j] * eigenVectorsAlternative[j][i];
      }
    }

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

    final alternativesConsistency = consistencyAlternatives
      ..sort((a, b) => b.ratio.compareTo(a.ratio));

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
