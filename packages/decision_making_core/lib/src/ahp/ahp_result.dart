import 'ahp_result_detail.dart';

/// AHP RESULT ENTITIES
class AhpResult {
  final List<AhpResultDetail>? results;
  final bool? isConsistentCriteria;
  final double? consistencyCriteriaRatio;
  final bool? isConsistentAlternative;
  final double? consistencyAlternativeRatio;
  final String? note;

  AhpResult({
    this.results,
    this.isConsistentCriteria,
    this.consistencyCriteriaRatio,
    this.isConsistentAlternative,
    this.consistencyAlternativeRatio,
    this.note,
  });
}
