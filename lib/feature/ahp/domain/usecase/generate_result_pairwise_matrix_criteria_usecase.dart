import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_item.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_comparison_input.dart';
import 'package:flutter_decision_making/feature/ahp/domain/repository/ahp_repository.dart';

class GenerateResultPairwiseMatrixCriteriaUsecase {
  final AhpRepository _decisionMakingRepository;

  GenerateResultPairwiseMatrixCriteriaUsecase(this._decisionMakingRepository);

  Future<List<List<double>>> execute(
          List<AhpItem> items, List<PairwiseComparisonInput> inputs) async =>
      await _decisionMakingRepository.generateResultPairwiseMatrixCriteria(
          items, inputs);
}
