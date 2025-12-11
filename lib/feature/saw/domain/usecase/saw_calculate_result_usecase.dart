import 'package:flutter_decision_making/feature/saw/domain/entities/saw_matrix.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_result.dart';
import 'package:flutter_decision_making/feature/saw/domain/repository/saw_repository.dart';

class SawCalculateResultUsecase {
  final SawRepository _repository;

  SawCalculateResultUsecase(this._repository);

  Future<List<SawResult>> execute({
    required List<SawMatrix> matrix,
  }) async =>
      await _repository.calculateSawResult(matrix: matrix);
}
