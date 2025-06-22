import 'package:flutter_decision_making/feature/ahp/domain/entities/consistency_ratio.dart';
import 'package:flutter_decision_making/feature/ahp/domain/repository/decision_making_repository.dart';

class CheckConsistencyRatioUsecase {
  final AhpRepository _decisionMakingRepository;

  CheckConsistencyRatioUsecase(this._decisionMakingRepository);

  Future<ConsistencyRatio> execute(List<List<double>> matrix,
          List<double> priorityVector, String source) async =>
      await _decisionMakingRepository.checkConsistencyRatio(
          matrix, priorityVector, source);
}
