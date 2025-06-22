import 'dart:developer' as dev;

import 'package:flutter_decision_making/core/decision_making_helper.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_item.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_result.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/consistency_ratio.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/hierarchy.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/identification.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_alternative_input.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_comparison_input.dart';

abstract class AhpLocalDatasource {
  /// TO IDENTIFICATION CRITERIA AND ALTERNATIVE
  Future<Identification> identification(
    List<AhpItem> criteria,
    List<AhpItem> alternative,
  );

  /// TO GENERATE HIERARCHY STRUCTURE
  Future<List<Hierarchy>> generateHierarchy(
    List<AhpItem> criteria,
    List<AhpItem> alternative,
  );

  /// TO GENERATE PAIRWISE INPUTS
  Future<List<PairwiseComparisonInput>> generatePairwiseCriteria(
    List<AhpItem> criteria,
  );

  Future<List<PairwiseAlternativeInput>> generatePairwiseAlternative(
    List<Hierarchy> nodes,
  );

  /// TO GENERATE RESULT PAIRWISE MATRIX CRITERIA
  Future<List<List<double>>> generateResultPairwiseMatrixCriteria(
      List<AhpItem> items, List<PairwiseComparisonInput> inputs);

  /// TO GENERATE RESULT PAIRWISE MATRIX ALTERNATIVE
  Future<List<List<double>>> generateResultPairwiseMatrixAlternative(
      List<AhpItem> items, List<PairwiseAlternativeInput> inputs);

  /// TO CALCULATE EIGEN VECTOR CRITERIA
  Future<List<double>> calculateEigenVectorCriteria(List<List<double>> matrix);

  /// TO CALCULATE EIGEN VECTOR ALTERNATIVE
  Future<List<double>> calculateEigenVectorAlternative(
      List<List<double>> matrix);

  /// TO CALCULATE AHP RESULT
  Future<ConsistencyRatio> checkConsistencyRatio(
    List<List<double>> matrix,
    List<double> priorityVector,
    String source,
  );

  /// GET RESULT AHP
  Future<AhpResult> getFinalScore(
    List<double> eigenVectorCriteria,
    List<List<double>> eigenVectorsAlternative,
    List<AhpItem> alternatives,
    ConsistencyRatio consistencyCriteria,
    List<ConsistencyRatio> consistencyAlternatives,
  );
}

class AhpLocalDatasourceImpl extends AhpLocalDatasource {
  final DecisionMakingHelper _helper;
  final Stopwatch _stopwatch;

  AhpLocalDatasourceImpl({
    DecisionMakingHelper? helper,
    Stopwatch? stopwatch,
  })  : _helper = helper ?? DecisionMakingHelper(),
        _stopwatch = stopwatch ?? Stopwatch();

  /// VALIDATE UNIQUE ID
  static void _validateUniqueId<T>(List<T> items, String Function(T) getId) {
    final seen = <String>{};
    for (var e in items) {
      final id = getId(e);
      if (seen.contains(id)) {
        throw ArgumentError('Duplicate id found');
      }
      seen.add(id);
    }
  }

  /// START DEV PERFORMANCE PROFILING
  void _startPerformanceProfiling(String name) {
    dev.log("🔄 start $name..");
    dev.Timeline.startSync(name);
    _stopwatch.start();
  }

  /// END DEV PERFORMANCE PROFILING
  void _endPerformanceProfiling(String name) {
    dev.Timeline.finishSync();
    _stopwatch.stop();
    dev.log(
        "🏁 $name has been execute - duration : ${_stopwatch.elapsedMilliseconds} ms");
  }

  @override
  Future<List<Hierarchy>> generateHierarchy(
      List<AhpItem> criteria, List<AhpItem> alternative) async  {
    // TODO: implement generateHierarchy
    throw UnimplementedError();
  }

  @override
  Future<List<PairwiseComparisonInput>> generatePairwiseCriteria(
      List<AhpItem> criteria) {
    // TODO: implement generatePairwiseCriteria
    throw UnimplementedError();
  }

  @override
  Future<List<PairwiseAlternativeInput>> generatePairwiseAlternative(
      List<Hierarchy> nodes) {
    // TODO: implement generatePairwiseAlternative
    throw UnimplementedError();
  }

  @override
  Future<List<List<double>>> generateResultPairwiseMatrixCriteria(
      List<AhpItem> items, List<PairwiseComparisonInput> inputs) {
    // TODO: implement generateResultPairwiseMatrixCriteria
    throw UnimplementedError();
  }

  @override
  Future<List<List<double>>> generateResultPairwiseMatrixAlternative(
      List<AhpItem> items, List<PairwiseAlternativeInput> inputs) {
    // TODO: implement generateResultPairwiseMatrixAlternative
    throw UnimplementedError();
  }

  @override
  Future<List<double>> calculateEigenVectorCriteria(List<List<double>> matrix) {
    // TODO: implement calculateEigenVectorCriteria
    throw UnimplementedError();
  }

  @override
  Future<List<double>> calculateEigenVectorAlternative(
      List<List<double>> matrix) {
    // TODO: implement calculateEigenVectorAlternative
    throw UnimplementedError();
  }

  @override
  Future<ConsistencyRatio> checkConsistencyRatio(
      List<List<double>> matrix, List<double> priorityVector, String source) {
    // TODO: implement checkConsistencyRatio
    throw UnimplementedError();
  }

  @override
  Future<AhpResult> getFinalScore(
      List<double> eigenVectorCriteria,
      List<List<double>> eigenVectorsAlternative,
      List<AhpItem> alternatives,
      ConsistencyRatio consistencyCriteria,
      List<ConsistencyRatio> consistencyAlternatives) {
    // TODO: implement getFinalScore
    throw UnimplementedError();
  }

  @override
  Future<Identification> identification(
      List<AhpItem> criteria, List<AhpItem> alternative) {
    // TODO: implement identification
    throw UnimplementedError();
  }
}
