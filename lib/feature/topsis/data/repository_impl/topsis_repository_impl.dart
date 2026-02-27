import 'package:flutter_decision_making/core/shared/entity/weighted_decision_alternative.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_criteria.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_result.dart';
import 'package:flutter_decision_making/feature/topsis/data/datasource/topsis_local_datasource.dart';
import 'package:flutter_decision_making/feature/topsis/domain/entities/topsis_raw_matrix.dart';
import 'package:flutter_decision_making/feature/topsis/domain/repository/topsis_repository.dart';

class TopsisRepositoryImpl implements TopsisRepository {
  final TopsisLocalDatasource _localDatasource;

  TopsisRepositoryImpl(this._localDatasource);

  @override
  Future<TopsisRawMatrix> generateTopsisMatrix({
    required List<WeightedDecisionAlternative> listAlternative,
    required List<WeightedDecisionCriteria> listCriteria,
  }) async {
    return await _localDatasource.generateTopsisMatrix(
        listAlternative: listAlternative, listCriteria: listCriteria);
  }

  @override
  Future<List<WeightedDecisionResult>> calculateTopsisResult({
    required TopsisRawMatrix rawMatrix,
  }) async {
    return await _localDatasource.calculateResult(rawMatrix: rawMatrix);
  }

  @override
  Future<List<WeightedDecisionResult>> calculateTopsisResultWithExistingMatrix(
      {required TopsisRawMatrix rawMatrix}) async {
    // TODO: implement calculateTopsisResultWithExistingMatrix
    throw UnimplementedError();
  }
}
