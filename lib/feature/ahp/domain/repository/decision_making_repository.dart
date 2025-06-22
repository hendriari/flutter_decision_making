import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_item.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_result.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/consistency_ratio.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/hierarchy.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/identification.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_alternative_input.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_comparison_input.dart';

abstract class AhpRepository {
  /// TO IDENTIFICATION CRITERIA AND ALTERNATIVE
  Future<Identification> identification(
    List<AhpItem> criteria,
    List<AhpItem> alternative,
  );

  /// TO GENERATE HIERARCHY STRUCTURE
  Future<List<Hierarchy>> generateHierarchy(
    List<AhpItem> criteria,
    List<AhpItem> alternative,
  );

  /// TO GENERATE PAIRWISE INPUTS
  Future<List<PairwiseComparisonInput>> generatePairwiseCriteria(
    List<AhpItem> criteria,
  );

  /// TO GENERATE RESULT PAIRWISE MATRIX CRITERIA
  Future<List<List<double>>> generateResultPairwiseMatrixCriteria(
      List<AhpItem> items, List<PairwiseComparisonInput> inputs);

  /// TO GENERATE RESULT PAIRWISE MATRIX ALTERNATIVE
  Future<List<List<double>>> generateResultPairwiseMatrixAlternative(
      List<AhpItem> items, List<PairwiseAlternativeInput> inputs);

  /// TO CALCULATE EIGEN VECTOR CRITERIA
  Future<List<double>> calculateEigenVectorCriteria(List<List<double>> matrix);

  /// TO CALCULATE EIGEN VECTOR ALTERNATIVE
  Future<List<double>> calculateEigenVectorAlternative(
      List<List<double>> matrix);

  /// TO CALCULATE AHP RESULT
  Future<ConsistencyRatio> checkConsistencyRatio(
    List<List<double>> matrix,
    List<double> priorityVector,
    String source,
  );

  /// GET RESULT AHP
  Future<AhpResult> getFinalScore(
    List<double> eigenVectorCriteria,
    List<List<double>> eigenVectorsAlternative,
    List<AhpItem> alternatives,
    ConsistencyRatio consistencyCriteria,
    List<ConsistencyRatio> consistencyAlternatives,
  );
}
