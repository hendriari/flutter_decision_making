import 'package:flutter_decision_making/ahp/domain/repository/decision_making_repository.dart';

class CalculateEigenVectorAlternativeUsecase {
  final DecisionMakingRepository _decisionMakingRepository;

  CalculateEigenVectorAlternativeUsecase(this._decisionMakingRepository);

  Future<List<double>> execute(List<List<double>> matrix) async =>
      await _decisionMakingRepository.calculateEigenVectorAlternative(matrix);
}
