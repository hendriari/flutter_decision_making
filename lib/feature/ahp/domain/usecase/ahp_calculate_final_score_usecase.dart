import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_hierarchy.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_result.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_alternative_input.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_comparison_input.dart';
import 'package:flutter_decision_making/feature/ahp/domain/repository/ahp_repository.dart';

/// GET FINAL SCORE AHP
class AhpCalculateFinalScore {
  final AhpRepository _ahpRepository;

  AhpCalculateFinalScore(this._ahpRepository);

  Future<AhpResult> execute({
    required List<AhpHierarchy> hierarchy,
    required List<PairwiseComparisonInput> inputsCriteria,
    required List<PairwiseAlternativeInput> inputsAlternative,
  }) async {
    return await _ahpRepository.calculateFinalScore(
      hierarchy,
      inputsCriteria,
      inputsAlternative,
    );
  }
}
