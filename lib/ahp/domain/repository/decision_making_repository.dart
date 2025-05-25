import 'package:flutter_decision_making/ahp/domain/entities/alternative.dart';
import 'package:flutter_decision_making/ahp/domain/entities/criteria.dart';
import 'package:flutter_decision_making/ahp/domain/entities/hierarchy.dart';
import 'package:flutter_decision_making/ahp/domain/entities/identification.dart';
import 'package:flutter_decision_making/ahp/domain/entities/pairwise_comparison_matrix.dart';

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
}
