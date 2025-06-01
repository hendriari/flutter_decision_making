import 'package:flutter_decision_making/ahp/domain/entities/ahp_result.dart';
import 'package:flutter_decision_making/ahp/domain/entities/alternative.dart';
import 'package:flutter_decision_making/ahp/domain/repository/decision_making_repository.dart';

class GetFinalScoreUsecase {
  final DecisionMakingRepository _decisionMakingRepository;

  GetFinalScoreUsecase(this._decisionMakingRepository);

  Future<List<AhpResult>> execute(
    List<double> eigenVectorCriteria,
    List<List<double>> eigenVectorsAlternative,
    List<Alternative> alternatives,
  ) async =>
      await _decisionMakingRepository.getFinalScore(
        eigenVectorCriteria,
        eigenVectorsAlternative,
        alternatives,
      );
}
