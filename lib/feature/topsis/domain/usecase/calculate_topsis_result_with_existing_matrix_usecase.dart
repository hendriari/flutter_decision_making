import 'package:flutter_decision_making/feature/topsis/domain/entities/topsis_raw_matrix.dart';
import 'package:flutter_decision_making/feature/topsis/domain/repository/topsis_repository.dart';
import 'package:flutter_decision_making/flutter_decision_making.dart';

class CalculateTopsisResultWithExistingMatrixUsecase {
  final TopsisRepository _repository;

  CalculateTopsisResultWithExistingMatrixUsecase(this._repository);

  Future<List<WeightedDecisionResult>> execute({
    required TopsisRawMatrix rawMatrix,
  }) async =>
      await _repository.calculateResultWithExistingMatrix(rawMatrix: rawMatrix);
}
