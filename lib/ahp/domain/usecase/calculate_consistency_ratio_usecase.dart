import 'package:flutter_decision_making/ahp/domain/repository/decision_making_repository.dart';

class CalculateConsistencyRatioUsecase {
  final DecisionMakingRepository _decisionMakingRepository;

  CalculateConsistencyRatioUsecase(this._decisionMakingRepository);

  Future<double> execute(List<List<double>> matrix, List<double> priorityVector,
          String source) async =>
      await _decisionMakingRepository.calculateConsistencyRatio(
          matrix, priorityVector, source);
}
