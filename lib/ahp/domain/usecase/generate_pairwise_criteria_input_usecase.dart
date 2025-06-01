import 'package:flutter_decision_making/ahp/domain/entities/criteria.dart';
import 'package:flutter_decision_making/ahp/domain/entities/pairwise_comparison_input.dart';
import 'package:flutter_decision_making/ahp/domain/repository/decision_making_repository.dart';

class GeneratePairwiseCriteriaInputUsecase {
  final DecisionMakingRepository _decisionMakingRepository;

  GeneratePairwiseCriteriaInputUsecase(this._decisionMakingRepository);

  Future<List<PairwiseComparisonInput<Criteria>>> execute(
    List<Criteria> criteria,
  ) async => _decisionMakingRepository.generatePairwiseCriteria(criteria);
}
