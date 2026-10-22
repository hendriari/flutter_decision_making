import '../common/weighted_decision_criteria.dart';
import '../common/weighted_decision_matrix.dart';

/// Container holding the criteria list and raw decision matrix for TOPSIS calculation.
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
