import 'package:flutter_decision_making/core/shared/entity/weighted_decision_alternative.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_criteria.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_matrix.dart';
import 'package:flutter_decision_making/feature/saw/domain/repository/saw_repository.dart';

class SawGenerateMatrixUsecase {
  final SawRepository _sawRepository;

  SawGenerateMatrixUsecase(this._sawRepository);

  Future<List<WeightedDecisionMatrix>> execute({
    required List<WeightedDecisionAlternative> listAlternative,
    required List<WeightedDecisionCriteria> listCriteria,
  }) async =>
      await _sawRepository.generateSawMatrix(
        listAlternative: listAlternative,
        listCriteria: listCriteria,
      );
}
