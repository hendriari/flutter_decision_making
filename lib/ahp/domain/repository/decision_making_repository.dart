import 'package:flutter_decision_making/ahp/domain/entities/alternative.dart';
import 'package:flutter_decision_making/ahp/domain/entities/criteria.dart';
import 'package:flutter_decision_making/ahp/domain/entities/hierarchy.dart';
import 'package:flutter_decision_making/ahp/domain/entities/identification.dart';
import 'package:flutter_decision_making/ahp/domain/entities/pairwise_alternative_input.dart';
import 'package:flutter_decision_making/ahp/domain/entities/pairwise_comparison_input.dart';

abstract class DecisionMakingRepository {
  Future<Identification> identification(
    List<Criteria> criteria,
    List<Alternative> alternative,
  );

  Future<List<Hierarchy>> generateHierarchy(
    List<Criteria> criteria,
    List<Alternative> alternative,
  );

  Future<List<PairwiseComparisonInput<Criteria>>> generatePairwiseCriteria(
    List<Criteria> criteria,
  );

  Future<List<List<double>>> generateResultPairwiseMatrixCriteria<Criteria>(
      List<Criteria> items, List<PairwiseComparisonInput<Criteria>> inputs);

  Future<List<List<double>>> generateResultPairwiseMatrixAlternative(
      List<Alternative> items, List<PairwiseAlternativeInput> inputs);

  Future<List<double>> calculateEigenVector(List<List<double>> matrix);

  Future<double> calculateConsistencyRatio(
    List<List<double>> matrix,
    List<double> priorityVector,
    String source,
  );
}
