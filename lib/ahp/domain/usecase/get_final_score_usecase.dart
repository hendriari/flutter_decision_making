import 'package:flutter_decision_making/ahp/domain/repository/decision_making_repository.dart';

class GetFinalScoreUsecase {
  final DecisionMakingRepository _decisionMakingRepository;

  GetFinalScoreUsecase(this._decisionMakingRepository);

  Future<List<double>> execute(
      List<double> eigenVectorCriteria,
      List<List<List<double>>> listMatrixAlternativePerCriteria,
      List<List<double>> listEigenVectorAlternativePerCriteria,
  ) async =>
      await _decisionMakingRepository.getFinalScore(
        eigenVectorCriteria,
        listMatrixAlternativePerCriteria,
        listEigenVectorAlternativePerCriteria,
      );
}
