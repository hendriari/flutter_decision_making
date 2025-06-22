import 'ahp_result_detail_dto.dart';

class AhpResultDto {
  final List<AhpResultDetailDto> results;
  final bool isConsistentCriteria;
  final double consistencyCriteriaRatio;
  final bool isConsistentAlternative;
  final double consistencyAlternativeRatio;
  final String? note;

  AhpResultDto({
    required this.results,
    required this.isConsistentCriteria,
    required this.consistencyCriteriaRatio,
    required this.isConsistentAlternative,
    required this.consistencyAlternativeRatio,
    this.note,
  });

  factory AhpResultDto.fromMap(Map<String, dynamic> map) {
    return AhpResultDto(
      results: List<Map<String, dynamic>>.from(map['results'])
          .map((e) => AhpResultDetailDto.fromMap(e))
          .toList(),
      isConsistentCriteria: map['is_consistent_criteria'],
      consistencyCriteriaRatio:
          (map['consistency_criteria_ratio'] as num).toDouble(),
      isConsistentAlternative: map['is_consistent_alternative'],
      consistencyAlternativeRatio:
          (map['consistency_alternative_ratio'] as num).toDouble(),
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'results': results.map((e) => e.toMap()).toList(),
      'is_consistent_criteria': isConsistentCriteria,
      'consistency_criteria_ratio': consistencyCriteriaRatio,
      'is_consistent_alternative': isConsistentAlternative,
      'consistency_alternative_ratio': consistencyAlternativeRatio,
      'note': note,
    };
  }
}
