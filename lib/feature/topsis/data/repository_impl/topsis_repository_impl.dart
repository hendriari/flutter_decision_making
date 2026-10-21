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
    bool useIsolate = false,
  }) async {
    return await _localDatasource.generateTopsisMatrix(
      listAlternative: listAlternative,
      listCriteria: listCriteria,
      useIsolate: useIsolate,
    );
  }

  @override
  Future<List<WeightedDecisionResult>> calculateResult({
    required TopsisRawMatrix rawMatrix,
    bool useIsolate = false,
  }) async {
    return await _localDatasource.calculateResult(
      rawMatrix: rawMatrix,
      useIsolate: useIsolate,
    );
  }

  @override
  Future<List<WeightedDecisionResult>> calculateResultWithExistingMatrix({
    required TopsisRawMatrix rawMatrix,
    bool useIsolate = false,
  }) async {
    return await _localDatasource.calculateResultWithExistingMatrix(
      rawMatrix: rawMatrix,
      useIsolate: useIsolate,
    );
  }
}
