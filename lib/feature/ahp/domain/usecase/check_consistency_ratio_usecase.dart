import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_consistency_ratio.dart';
import 'package:flutter_decision_making/feature/ahp/domain/repository/ahp_repository.dart';

class CheckConsistencyRatioUsecase {
  final AhpRepository _decisionMakingRepository;

  CheckConsistencyRatioUsecase(this._decisionMakingRepository);

  Future<AhpConsistencyRatio> execute(List<List<double>> matrix,
          List<double> priorityVector, String source) async =>
      await _decisionMakingRepository.checkConsistencyRatio(
          matrix, priorityVector, source);
}
