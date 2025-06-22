import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_local_datasource.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_consistency_ratio.dart';
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
  Future<List<List<double>>> generateResultPairwiseMatrixCriteria(
      List<AhpItem> items, List<PairwiseComparisonInput> inputs) async {
    return await _localDatasource.generateResultPairwiseMatrixCriteria(
        items, inputs);
  }

  @override
  Future<List<List<double>>> generateResultPairwiseMatrixAlternative(
      List<AhpItem> items, List<PairwiseAlternativeInput> inputs) async {
    return await _localDatasource.generateResultPairwiseMatrixAlternative(
        items, inputs);
  }

  @override
  Future<List<double>> calculateEigenVectorCriteria(
      List<List<double>> matrix) async {
    return await _localDatasource.calculateEigenVectorCriteria(matrix);
  }

  @override
  Future<List<double>> calculateEigenVectorAlternative(
      List<List<double>> matrix) async {
    return await _localDatasource.calculateEigenVectorAlternative(matrix);
  }

  @override
  Future<AhpConsistencyRatio> checkConsistencyRatio(List<List<double>> matrix,
      List<double> priorityVector, String source) async {
    return await _localDatasource.checkConsistencyRatio(
        matrix, priorityVector, source);
  }

  @override
  Future<AhpResult> getFinalScore(
      List<double> eigenVectorCriteria,
      List<List<double>> eigenVectorsAlternative,
      List<AhpItem> alternatives,
      AhpConsistencyRatio consistencyCriteria,
      List<AhpConsistencyRatio> consistencyAlternatives) async {
    return await _localDatasource.getFinalScore(
        eigenVectorCriteria,
        eigenVectorsAlternative,
        alternatives,
        consistencyCriteria,
        consistencyAlternatives);
  }
}
