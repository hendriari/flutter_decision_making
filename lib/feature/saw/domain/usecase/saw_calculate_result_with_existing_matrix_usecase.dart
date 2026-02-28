import 'package:flutter_decision_making/core/shared/entity/weighted_decision_matrix.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_result.dart';
import 'package:flutter_decision_making/feature/saw/domain/repository/saw_repository.dart';

class SawCalculateResultWithExistingMatrixUsecase {
  final SawRepository _repository;

  SawCalculateResultWithExistingMatrixUsecase(this._repository);

  Future<List<WeightedDecisionResult>> execute({required List<WeightedDecisionMatrix> sawMatrix}) async =>
      await _repository.calculateResultWithExistingMatrix(sawMatrix: sawMatrix);
}
