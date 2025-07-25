import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_hierarchy.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_identification.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_item.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_result.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_alternative_input.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_comparison_input.dart';

abstract class AhpRepository {
  /// TO IDENTIFICATION CRITERIA AND ALTERNATIVE
  Future<AhpIdentification> identification(
    List<AhpItem> criteria,
    List<AhpItem> alternative,
  );

  /// TO GENERATE HIERARCHY STRUCTURE
  Future<List<AhpHierarchy>> generateHierarchy(
    List<AhpItem> criteria,
    List<AhpItem> alternative,
  );

  /// TO GENERATE PAIRWISE CRITERIA INPUTS
  Future<List<PairwiseComparisonInput>> generatePairwiseCriteria(
      List<AhpItem> criteria);

  /// TO GENERATE PAIRWISE ALTERNATIVE INPUTS
  Future<List<PairwiseAlternativeInput>> generatePairwiseAlternative(
      List<AhpHierarchy> nodes);

  /// GET RESULT AHP
  Future<AhpResult> calculateFinalScore(
    List<AhpHierarchy> hierarchy,
    List<PairwiseComparisonInput> inputsCriteria,
    List<PairwiseAlternativeInput> inputsAlternative,
  );
}
