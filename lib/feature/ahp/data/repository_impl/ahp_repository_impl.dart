import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_local_datasource.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_hierarchy.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_identification.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_item.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_result.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_alternative_input.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_comparison_input.dart';
import 'package:flutter_decision_making/feature/ahp/domain/repository/ahp_repository.dart';

class AhpRepositoryImpl extends AhpRepository {
  final AhpLocalDatasource _localDatasource;

  AhpRepositoryImpl(this._localDatasource);

  @override
  Future<AhpIdentification> identification(
      List<AhpItem> criteria, List<AhpItem> alternative) async {
    return await _localDatasource.identification(criteria, alternative);
  }

  @override
  Future<List<AhpHierarchy>> generateHierarchy(
      List<AhpItem> criteria, List<AhpItem> alternative) async {
    return await _localDatasource.generateHierarchy(criteria, alternative);
  }

  @override
  Future<List<PairwiseComparisonInput>> generatePairwiseCriteria(
      List<AhpItem> criteria) async {
    return await _localDatasource.generatePairwiseCriteria(criteria);
  }

  @override
  Future<List<PairwiseAlternativeInput>> generatePairwiseAlternative(
      List<AhpHierarchy> nodes) async {
    return await _localDatasource.generatePairwiseAlternative(nodes);
  }

  @override
  Future<AhpResult> calculateFinalScore(
    List<AhpHierarchy> hierarchy,
    List<PairwiseComparisonInput> inputsCriteria,
    List<PairwiseAlternativeInput> inputsAlternative,
  ) async {
    return await _localDatasource.calculateFinalScore(
      hierarchy,
      inputsCriteria,
      inputsAlternative,
    );
  }
}
