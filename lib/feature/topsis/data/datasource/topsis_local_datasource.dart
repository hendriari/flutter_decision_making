import 'package:flutter/foundation.dart';
import 'package:flutter_decision_making/core/decision_making_enums.dart';
import 'package:flutter_decision_making/core/decision_making_helper.dart';
import 'package:flutter_decision_making/core/decision_making_performance_profiling.dart';
import 'package:flutter_decision_making/core/isolate/decision_isolate_main.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_alternative.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_criteria.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_matrix.dart';
import 'package:flutter_decision_making/core/shared/interface/weighted_decision_matrix_mixin.dart';

abstract interface class TopsisLocalDatasource {
  Future<List<WeightedDecisionMatrix>> generateTopsisMatrix({
    required List<WeightedDecisionAlternative> listAlternative,
    required List<WeightedDecisionCriteria> listCriteria,
  });
}

class TopsisLocalDatasourceImpl
    with WeightedDecisionMatrixInterface
    implements TopsisLocalDatasource {
  final DecisionMakingHelper _helper;
  final DecisionIsolateMain _isolate;

  @override
  DecisionMakingHelper get helper => _helper;

  @override
  DecisionIsolateMain get isolate => _isolate;

  TopsisLocalDatasourceImpl({
    DecisionMakingHelper? helper,
    DecisionIsolateMain? isolate,
    Stopwatch? stopwatch,
  })  : _helper = helper ?? DecisionMakingHelper(),
        _isolate = isolate ?? DecisionIsolateMain();

  @override
  Future<List<WeightedDecisionMatrix>> generateTopsisMatrix({
    required List<WeightedDecisionAlternative> listAlternative,
    required List<WeightedDecisionCriteria> listCriteria,
  }) async {
    startPerformanceProfiling('Generate TOPSIS pairwise matrix');
    try {
      validateInputs(listAlternative, listCriteria);

      final normalizedCriteria = normalizeCriteriaWeights(listCriteria);
      final updateAlternative = ensureIdsForAlternatives(listAlternative);
      final updateCriteria = ensureIdsForCriteria(normalizedCriteria);

      List<WeightedDecisionMatrix> result = [];
      final canUseIsolate = !kIsWeb &&
          (updateAlternative.length > 80 || updateCriteria.length > 25);

      if (canUseIsolate) {
        result = await generateMatrixWithIsolate(
          DecisionAlgorithm.topsis,
          TopsisProcessingIsolateCommand.generateMatrix,
          updateAlternative,
          updateCriteria,
        );
      } else {
        result = generateMatrixDirectly(updateAlternative, updateCriteria);
      }

      return result;
    } catch (e, s) {
      debugPrint('TOPSIS Matrix Error: $e\n$s');
      rethrow;
    } finally {
      endPerformanceProfiling('Generate TOPSIS pairwise matrix');
    }
  }
}
