import 'package:flutter_decision_making/core/shared/entity/weighted_decision_alternative.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_criteria.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_matrix.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_result.dart';

abstract class SawRepository {
  Future<List<WeightedDecisionMatrix>> generateSawMatrix({
    required List<WeightedDecisionAlternative> listAlternative,
    required List<WeightedDecisionCriteria> listCriteria,
  });

  Future<List<WeightedDecisionResult>> calculateSawResult({
    required List<WeightedDecisionMatrix> matrix,
  });

  Future<List<WeightedDecisionResult>> calculateResultWithExistingMatrix({
    required List<WeightedDecisionMatrix> sawMatrix,
  });
}
