import 'package:flutter_decision_making/ahp/domain/entities/alternative.dart';
import 'package:flutter_decision_making/ahp/domain/entities/pairwise_alternative_input.dart';
import 'package:flutter_decision_making/ahp/domain/repository/decision_making_repository.dart';

class GenerateResultPairwiseMatrixAlternativeUsecase {
  final DecisionMakingRepository _decisionMakingRepository;

  GenerateResultPairwiseMatrixAlternativeUsecase(
      this._decisionMakingRepository);

  Future<List<List<double>>> execute(List<Alternative> items,
          List<PairwiseAlternativeInput> inputs) async =>
      await _decisionMakingRepository.generateResultPairwiseMatrixAlternative(
          items, inputs);
}
