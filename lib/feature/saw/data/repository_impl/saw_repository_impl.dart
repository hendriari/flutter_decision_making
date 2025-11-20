import 'package:flutter_decision_making/feature/saw/data/datasource/saw_local_datasource.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_alternative.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_criteria.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_matrix.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_result.dart';
import 'package:flutter_decision_making/feature/saw/domain/repository/saw_repository.dart';

class SawRepositoryImpl extends SawRepository {
  final SawLocalDatasource _localDatasource;

  SawRepositoryImpl(this._localDatasource);

  @override
  Future<List<SawMatrix>> generateSawMatrix({
    required List<SawAlternative> listAlternative,
    required List<SawCriteria> listCriteria,
  }) async {
    return await _localDatasource.generateSawMatrix(
      listAlternative: listAlternative,
      listCriteria: listCriteria,
    );
  }

  @override
  Future<List<SawResult>> calculateSawResult(
      {required List<SawMatrix> matrix}) async {
    return await _localDatasource.calculateSawResult(matrix: matrix);
  }

  @override
  Future<List<SawResult>> calculateResultWithExistingMatrix(
      {required List<SawMatrix> sawMatrix}) async {
    return await _localDatasource.calculateResultWithExistingMatrix(
      matrix: sawMatrix,
    );
  }
}
