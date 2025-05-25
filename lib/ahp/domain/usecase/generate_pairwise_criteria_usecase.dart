import 'package:flutter_decision_making/ahp/domain/entities/criteria.dart';
import 'package:flutter_decision_making/ahp/domain/entities/pairwise_comparison_matrix.dart';
import 'package:flutter_decision_making/ahp/domain/repository/decision_making_repository.dart';

class GeneratePairwiseCriteriaUsecase {
  final DecisionMakingRepository _decisionMakingRepository;

  GeneratePairwiseCriteriaUsecase(this._decisionMakingRepository);

  Future<List<PairwiseComparisonInput<Criteria>>> execute(
    List<Criteria> criteria,
  ) async => _decisionMakingRepository.generatePairwiseCriteria(criteria);
}
