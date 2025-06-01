import 'package:flutter_decision_making/ahp/domain/repository/decision_making_repository.dart';

class CheckConsistencyRatioUsecase {
  final DecisionMakingRepository _decisionMakingRepository;

  CheckConsistencyRatioUsecase(this._decisionMakingRepository);

  Future<double> execute(List<List<double>> matrix, List<double> priorityVector,
          String source) async =>
      await _decisionMakingRepository.checkConsistencyRatio(
          matrix, priorityVector, source);
}
