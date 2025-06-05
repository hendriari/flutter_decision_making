import 'package:flutter_decision_making/ahp/domain/entities/criteria.dart';
import 'package:flutter_decision_making/ahp/domain/entities/pairwise_comparison_input.dart';
import 'package:flutter_decision_making/ahp/domain/repository/decision_making_repository.dart';

class GenerateResultPairwiseMatrixCriteriaUsecase {
  final DecisionMakingRepository _decisionMakingRepository;

  GenerateResultPairwiseMatrixCriteriaUsecase(this._decisionMakingRepository);

  Future<List<List<double>>> execute(List<Criteria> items,
          List<PairwiseComparisonInput<Criteria>> inputs) async =>
      await _decisionMakingRepository.generateResultPairwiseMatrixCriteria(
          items, inputs);
}
