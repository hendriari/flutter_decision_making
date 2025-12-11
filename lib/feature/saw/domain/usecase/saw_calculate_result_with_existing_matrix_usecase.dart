import 'package:flutter_decision_making/feature/saw/domain/entities/saw_matrix.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_result.dart';
import 'package:flutter_decision_making/feature/saw/domain/repository/saw_repository.dart';

class SawCalculateResultWithExistingMatrixUsecase {
  final SawRepository _repository;

  SawCalculateResultWithExistingMatrixUsecase(this._repository);

  Future<List<SawResult>> execute({required List<SawMatrix> sawMatrix}) async =>
      await _repository.calculateResultWithExistingMatrix(sawMatrix: sawMatrix);
}
