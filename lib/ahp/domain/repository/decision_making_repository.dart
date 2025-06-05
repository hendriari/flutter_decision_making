import 'package:flutter_decision_making/ahp/domain/entities/ahp_result.dart';
import 'package:flutter_decision_making/ahp/domain/entities/alternative.dart';
import 'package:flutter_decision_making/ahp/domain/entities/consistency_ratio.dart';
import 'package:flutter_decision_making/ahp/domain/entities/criteria.dart';
import 'package:flutter_decision_making/ahp/domain/entities/hierarchy.dart';
import 'package:flutter_decision_making/ahp/domain/entities/identification.dart';
import 'package:flutter_decision_making/ahp/domain/entities/pairwise_alternative_input.dart';
import 'package:flutter_decision_making/ahp/domain/entities/pairwise_comparison_input.dart';

abstract class DecisionMakingRepository {
  /// TO IDENTIFICATION CRITERIA AND ALTERNATIVE
  Future<Identification> identification(
    List<Criteria> criteria,
    List<Alternative> alternative,
  );

  /// TO GENERATE HIERARCHY STRUCTURE
  Future<List<Hierarchy>> generateHierarchy(
    List<Criteria> criteria,
    List<Alternative> alternative,
  );

  /// TO GENERATE PAIRWISE INPUTS
  Future<List<PairwiseComparisonInput<Criteria>>> generatePairwiseCriteria(
    List<Criteria> criteria,
  );

  /// TO GENERATE RESULT PAIRWISE MATRIX CRITERIA
  Future<List<List<double>>> generateResultPairwiseMatrixCriteria(
      List<Criteria> items, List<PairwiseComparisonInput<Criteria>> inputs);

  /// TO GENERATE RESULT PAIRWISE MATRIX ALTERNATIVE
  Future<List<List<double>>> generateResultPairwiseMatrixAlternative(
      List<Alternative> items, List<PairwiseAlternativeInput> inputs);

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

  Future<AhpResult> getFinalScore(
    List<double> eigenVectorCriteria,
    List<List<double>> eigenVectorsAlternative,
    List<Alternative> alternatives,
    ConsistencyRatio consistencyCriteria,
    List<ConsistencyRatio> consistencyAlternatives,
  );
}
