import 'package:flutter_decision_making/core/shared/entity/weighted_decision_alternative.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_criteria.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_matrix.dart';
import 'package:flutter_decision_making/feature/topsis/domain/repository/topsis_repository.dart';

class GenerateTopsisMatrixUsecase {
  final TopsisRepository _repository;

  GenerateTopsisMatrixUsecase(this._repository);

  Future<List<WeightedDecisionMatrix>> execute({
    required List<WeightedDecisionAlternative> listAlternative,
    required List<WeightedDecisionCriteria> listCriteria,
  }) async =>
      _repository.generateSawMatrix(
          listAlternative: listAlternative, listCriteria: listCriteria);
}
