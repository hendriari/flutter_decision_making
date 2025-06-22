import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_item.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_alternative_input.dart';
import 'package:flutter_decision_making/feature/ahp/domain/repository/ahp_repository.dart';

class GenerateResultPairwiseMatrixAlternativeUsecase {
  final AhpRepository _decisionMakingRepository;

  GenerateResultPairwiseMatrixAlternativeUsecase(
      this._decisionMakingRepository);

  Future<List<List<double>>> execute(
          List<AhpItem> items, List<PairwiseAlternativeInput> inputs) async =>
      await _decisionMakingRepository.generateResultPairwiseMatrixAlternative(
          items, inputs);
}
