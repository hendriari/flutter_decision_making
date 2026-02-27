import 'package:flutter_decision_making/core/shared/entity/weighted_decision_result.dart';
import 'package:flutter_decision_making/feature/topsis/domain/entities/topsis_raw_matrix.dart';
import 'package:flutter_decision_making/feature/topsis/domain/repository/topsis_repository.dart';

class CalculateTopsisResultUsecase {
  final TopsisRepository _repository;

  CalculateTopsisResultUsecase(this._repository);

  Future<List<WeightedDecisionResult>> execute({
    required TopsisRawMatrix rawMatrix,
  }) async =>
      await _repository.calculateTopsisResult(
        rawMatrix: rawMatrix,
      );
}
