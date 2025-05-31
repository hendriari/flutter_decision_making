import 'package:flutter_decision_making/ahp/domain/repository/decision_making_repository.dart';

class CalculateEigenVectorUsecase {
  final DecisionMakingRepository _decisionMakingRepository;

  CalculateEigenVectorUsecase(this._decisionMakingRepository);

  Future<List<double>> execute(List<List<double>> matrix) async =>
      await _decisionMakingRepository.calculateEigenVector(matrix);
}
