import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_result_detail.dart';

/// AHP RESULT ENTITIES
class AhpResult {
  final List<AhpResultDetail> results;
  final bool isConsistentCriteria;
  final double consistencyCriteriaRatio;
  final bool isConsistentAlternative;
  final double consistencyAlternativeRatio;
  final String? note;

  AhpResult({
    required this.results,
    required this.isConsistentCriteria,
    required this.consistencyCriteriaRatio,
    required this.isConsistentAlternative,
    required this.consistencyAlternativeRatio,
    this.note,
  });
}
