import 'package:flutter_decision_making/core/shared/entity/weighted_decision_criteria.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_matrix.dart';

/// CALCULATE SESSION
class TopsisSession {
  final List<WeightedDecisionCriteria> criterias;
  final List<WeightedDecisionMatrix> matrixs;

  TopsisSession({
    required this.criterias,
    required this.matrixs,
  });
}
