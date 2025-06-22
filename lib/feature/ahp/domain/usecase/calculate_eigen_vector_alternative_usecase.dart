import 'package:flutter_decision_making/feature/ahp/domain/repository/ahp_repository.dart';

class CalculateEigenVectorAlternativeUsecase {
  final AhpRepository _decisionMakingRepository;

  CalculateEigenVectorAlternativeUsecase(this._decisionMakingRepository);

  Future<List<double>> execute(List<List<double>> matrix) async =>
      await _decisionMakingRepository.calculateEigenVectorAlternative(matrix);
}
