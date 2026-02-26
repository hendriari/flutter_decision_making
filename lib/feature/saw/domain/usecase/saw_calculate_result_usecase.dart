import 'package:flutter_decision_making/core/shared/entity/weighted_decision_matrix.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_result.dart';
import 'package:flutter_decision_making/feature/saw/domain/repository/saw_repository.dart';

class SawCalculateResultUsecase {
  final SawRepository _repository;

  SawCalculateResultUsecase(this._repository);

  Future<List<WeightedDecisionResult>> execute({
    required List<WeightedDecisionMatrix> matrix,
  }) async =>
      await _repository.calculateSawResult(matrix: matrix);
}
