import 'package:flutter_decision_making/core/shared/entity/weighted_decision_alternative.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_criteria.dart';
import 'package:flutter_decision_making/feature/topsis/domain/entities/topsis_raw_matrix.dart';
import 'package:flutter_decision_making/feature/topsis/domain/repository/topsis_repository.dart';

class GenerateTopsisMatrixUsecase {
  final TopsisRepository _repository;

  GenerateTopsisMatrixUsecase(this._repository);

  Future<TopsisRawMatrix> execute({
    required List<WeightedDecisionAlternative> listAlternative,
    required List<WeightedDecisionCriteria> listCriteria,
  }) async =>
      await _repository.generateTopsisMatrix(
        listAlternative: listAlternative,
        listCriteria: listCriteria,
      );
}
