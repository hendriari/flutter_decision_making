import 'package:flutter_decision_making/core/shared/entity/weighted_decision_result.dart';
import 'package:flutter_decision_making/feature/topsis/domain/entities/topsis_raw_matrix.dart';
import 'package:flutter_decision_making/feature/topsis/domain/repository/topsis_repository.dart';

class CalculateTopsisResultWithExistingMatrixUsecase {
  final TopsisRepository _repository;

  CalculateTopsisResultWithExistingMatrixUsecase(this._repository);

  Future<List<WeightedDecisionResult>> execute({
    required TopsisRawMatrix rawMatrix,
    bool useIsolate = false,
  }) async =>
      await _repository.calculateResultWithExistingMatrix(
        rawMatrix: rawMatrix,
        useIsolate: useIsolate,
      );
}
