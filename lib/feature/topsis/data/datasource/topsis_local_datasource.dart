import 'package:flutter_decision_making/core/shared/entity/weighted_decision_alternative.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_criteria.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_result.dart';
import 'package:flutter_decision_making/feature/topsis/domain/entities/topsis_raw_matrix.dart';

abstract interface class TopsisLocalDatasource {
  Future<TopsisRawMatrix> generateTopsisMatrix({
    required List<WeightedDecisionAlternative> listAlternative,
    required List<WeightedDecisionCriteria> listCriteria,
  });

  Future<List<WeightedDecisionResult>> calculateResult({
    required TopsisRawMatrix rawMatrix,
  });
}
