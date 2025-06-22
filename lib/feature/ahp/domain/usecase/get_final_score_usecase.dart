import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_item.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_result.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_consistency_ratio.dart';
import 'package:flutter_decision_making/feature/ahp/domain/repository/ahp_repository.dart';

class GetFinalScoreUsecase {
  final AhpRepository _decisionMakingRepository;

  GetFinalScoreUsecase(this._decisionMakingRepository);

  Future<AhpResult> execute(
    List<double> eigenVectorCriteria,
    List<List<double>> eigenVectorsAlternative,
    List<AhpItem> alternatives,
    AhpConsistencyRatio consistencyCriteria,
    List<AhpConsistencyRatio> consistencyAlternatives,
  ) async =>
      await _decisionMakingRepository.getFinalScore(
        eigenVectorCriteria,
        eigenVectorsAlternative,
        alternatives,
        consistencyCriteria,
        consistencyAlternatives,
      );
}
