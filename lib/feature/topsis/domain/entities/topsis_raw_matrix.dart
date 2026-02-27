import 'package:flutter_decision_making/core/shared/entity/weighted_decision_criteria.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_matrix.dart';

/// CALCULATE SESSION
class TopsisRawMatrix {
  final List<WeightedDecisionCriteria> criterias;
  final List<WeightedDecisionMatrix> matrixs;

  TopsisRawMatrix({
    required this.criterias,
    required this.matrixs,
  });

  TopsisRawMatrix copyWith({
    List<WeightedDecisionCriteria>? criterias,
    List<WeightedDecisionMatrix>? matrixs,
  }) {
    return TopsisRawMatrix(
      criterias: criterias ?? this.criterias,
      matrixs: matrixs ?? this.matrixs,
    );
  }
}
