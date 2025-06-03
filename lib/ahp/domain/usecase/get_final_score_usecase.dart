import 'package:flutter_decision_making/ahp/domain/entities/ahp_result.dart';
import 'package:flutter_decision_making/ahp/domain/entities/alternative.dart';
import 'package:flutter_decision_making/ahp/domain/entities/consistency_ratio.dart';
import 'package:flutter_decision_making/ahp/domain/repository/decision_making_repository.dart';

class GetFinalScoreUsecase {
  final DecisionMakingRepository _decisionMakingRepository;

  GetFinalScoreUsecase(this._decisionMakingRepository);

  Future<AhpResult> execute(
    List<double> eigenVectorCriteria,
    List<List<double>> eigenVectorsAlternative,
    List<Alternative> alternatives,
    ConsistencyRatio consistencyCriteria,
    List<ConsistencyRatio> consistencyAlternatives,
  ) async =>
      await _decisionMakingRepository.getFinalScore(
        eigenVectorCriteria,
        eigenVectorsAlternative,
        alternatives,
        consistencyCriteria,
        consistencyAlternatives,
      );
}
