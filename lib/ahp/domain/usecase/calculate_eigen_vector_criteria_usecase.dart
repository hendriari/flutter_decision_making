import 'package:flutter_decision_making/ahp/domain/repository/decision_making_repository.dart';

class CalculateEigenVectorCriteriaUsecase {
  final DecisionMakingRepository _decisionMakingRepository;

  CalculateEigenVectorCriteriaUsecase(this._decisionMakingRepository);

  Future<List<double>> execute(List<List<double>> matrix) async =>
      await _decisionMakingRepository.calculateEigenVectorCriteria(matrix);
}
