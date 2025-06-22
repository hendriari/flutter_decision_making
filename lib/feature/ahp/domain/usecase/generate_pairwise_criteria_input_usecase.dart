import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_item.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_comparison_input.dart';
import 'package:flutter_decision_making/feature/ahp/domain/repository/ahp_repository.dart';

class GeneratePairwiseCriteriaInputUsecase {
  final AhpRepository _decisionMakingRepository;

  GeneratePairwiseCriteriaInputUsecase(this._decisionMakingRepository);

  Future<List<PairwiseComparisonInput>> execute(
    List<AhpItem> criteria,
  ) async =>
      _decisionMakingRepository.generatePairwiseCriteria(criteria);
}
