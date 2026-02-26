import 'package:flutter_decision_making/feature/saw/data/datasource/saw_local_datasource.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_alternative.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_criteria.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_matrix.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_result.dart';
import 'package:flutter_decision_making/feature/saw/domain/repository/saw_repository.dart';

class SawRepositoryImpl extends SawRepository {
  final SawLocalDatasource _localDatasource;

  SawRepositoryImpl(this._localDatasource);

  @override
  Future<List<WeightedDecisionMatrix>> generateSawMatrix({
    required List<WeightedDecisionAlternative> listAlternative,
    required List<WeightedDecisionCriteria> listCriteria,
  }) async {
    return await _localDatasource.generateSawMatrix(
      listAlternative: listAlternative,
      listCriteria: listCriteria,
    );
  }

  @override
  Future<List<WeightedDecisionResult>> calculateSawResult(
      {required List<WeightedDecisionMatrix> matrix}) async {
    return await _localDatasource.calculateSawResult(matrix: matrix);
  }

  @override
  Future<List<WeightedDecisionResult>> calculateResultWithExistingMatrix(
      {required List<WeightedDecisionMatrix> sawMatrix}) async {
    return await _localDatasource.calculateResultWithExistingMatrix(
      matrix: sawMatrix,
    );
  }
}
