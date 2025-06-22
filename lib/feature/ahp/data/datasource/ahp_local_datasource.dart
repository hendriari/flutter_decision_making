import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter_decision_making/core/decision_making_helper.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_consistency_ratio_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_hierarchy_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_item_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_result_detail_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_result_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/pairwise_comparison_alternative_input_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/pairwise_comparison_input_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/mapper/ahp_consistency_ratio_mapper.dart';
import 'package:flutter_decision_making/feature/ahp/data/mapper/ahp_hierarchy_mapper.dart';
import 'package:flutter_decision_making/feature/ahp/data/mapper/ahp_item_mapper.dart';
import 'package:flutter_decision_making/feature/ahp/data/mapper/ahp_result_mapper.dart';
import 'package:flutter_decision_making/feature/ahp/data/mapper/pairwise_comparison_alternative_input_mapper.dart';
import 'package:flutter_decision_making/feature/ahp/data/mapper/pairwise_comparison_input_mapper.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_consistency_ratio.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_hierarchy.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_identification.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_item.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_result.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_alternative_input.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_comparison_input.dart';

abstract class AhpLocalDatasource {
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

  /// TO GENERATE PAIRWISE INPUTS
  Future<List<PairwiseComparisonInput>> generatePairwiseCriteria(
    List<AhpItem> criteria,
  );

  Future<List<PairwiseAlternativeInput>> generatePairwiseAlternative(
    List<AhpHierarchy> nodes,
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
  Future<AhpConsistencyRatio> checkConsistencyRatio(
    List<List<double>> matrix,
    List<double> priorityVector,
    String source,
  );

  /// GET RESULT AHP
  Future<AhpResult> getFinalScore(
    List<double> eigenVectorCriteria,
    List<List<double>> eigenVectorsAlternative,
    List<AhpItem> alternatives,
    AhpConsistencyRatio consistencyCriteria,
    List<AhpConsistencyRatio> consistencyAlternatives,
  );
}

class AhpLocalDatasourceImpl extends AhpLocalDatasource {
  final DecisionMakingHelper _helper;
  final Stopwatch _stopwatch;

  AhpLocalDatasourceImpl({
    DecisionMakingHelper? helper,
    Stopwatch? stopwatch,
  })  : _helper = helper ?? DecisionMakingHelper(),
        _stopwatch = stopwatch ?? Stopwatch();

  /// VALIDATE UNIQUE ID
  static void _validateUniqueId<T>(List<T> items, String Function(T) getId) {
    final seen = <String>{};
    for (var e in items) {
      final id = getId(e);
      if (seen.contains(id)) {
        throw Exception('Duplicate id found');
      }
      seen.add(id);
    }
  }

  /// START DEV PERFORMANCE PROFILING
  void _startPerformanceProfiling(String name) {
    dev.log("🔄 start $name..");
    dev.Timeline.startSync(name);
    _stopwatch.start();
  }

  /// END DEV PERFORMANCE PROFILING
  void _endPerformanceProfiling(String name) {
    dev.Timeline.finishSync();
    _stopwatch.stop();
    dev.log(
        "🏁 $name has been execute - duration : ${_stopwatch.elapsedMilliseconds} ms");
    _stopwatch.reset();
  }

  /// IDENTIFICATION DETAIL
  @override
  Future<AhpIdentification> identification(
      List<AhpItem> criteria, List<AhpItem> alternative) async {
    _startPerformanceProfiling('identification');

    try {
      if (criteria.isEmpty) {
        throw Exception("Criteria can't be empty!");
      }
      if (alternative.isEmpty) {
        throw Exception("Alternative can't be empty!");
      }

      if (criteria.length > 30 || alternative.length > 50) {
        throw Exception(
          "Too much data, please limit the number of criteria/alternatives.",
        );
      }

      final updatedCriteria = List<AhpItem>.generate(criteria.length, (i) {
        final e = criteria[i];
        return (e.id == null || e.id!.isEmpty)
            ? e.copyWith(id: _helper.getCustomUniqueId())
            : e;
      });

      final updateAlternative = List<AhpItem>.generate(alternative.length, (
        i,
      ) {
        final e = alternative[i];
        return (e.id == null || e.id!.isEmpty)
            ? e.copyWith(id: _helper.getCustomUniqueId())
            : e;
      });

      _validateUniqueId<AhpItem>(updatedCriteria, (e) => e.id!);
      _validateUniqueId<AhpItem>(updateAlternative, (e) => e.id!);

      return AhpIdentification(
        criteria: updatedCriteria,
        alternative: updateAlternative,
      );
    } finally {
      _endPerformanceProfiling('identification');
    }
  }

  /// GENERATE STRUCTURE HIERARCHY
  @override
  Future<List<AhpHierarchy>> generateHierarchy(
      List<AhpItem> criteria, List<AhpItem> alternative) async {
    _startPerformanceProfiling('generate hierarchy');
    try {
      final resultHierarchy = criteria.map((c) {
        return AhpHierarchy(criteria: c, alternative: alternative);
      }).toList();

      return resultHierarchy;
    } catch (e) {
      throw Exception('Failed generate hierarchy $e');
    } finally {
      _endPerformanceProfiling('generate hierarchy');
    }
  }

  /// GENERATE PAIRWISE CRITERIA INPUTS
  @override
  Future<List<PairwiseComparisonInput>> generatePairwiseCriteria(
      List<AhpItem> criteria) async {
    _startPerformanceProfiling('generate pairwise criteria');
    try {
      final result = <PairwiseComparisonInput>[];

      for (int i = 0; i < criteria.length; i++) {
        for (int j = i + 1; j < criteria.length; j++) {
          result.add(
            PairwiseComparisonInput(
              left: criteria[i],
              right: criteria[j],
              preferenceValue: null,
              isLeftMoreImportant: null,
              id: _helper.getCustomUniqueId(),
            ),
          );
        }
      }

      return result;
    } catch (e) {
      throw Exception('Failed generate pairwise criteria template $e');
    } finally {
      _endPerformanceProfiling('generate pairwise criteria');
    }
  }

  /// **************************************************************************

  /// GENERATE PAIRWISE ALTERNATIVE
  @override
  Future<List<PairwiseAlternativeInput>> generatePairwiseAlternative(
    List<AhpHierarchy> nodes,
  ) async {
    const computeThreshold = 20;

    final hierarchyList =
        nodes.map((e) => AhpHierarchyMapper.fromEntity(e).toMap()).toList();

    final resultMap = nodes.length < computeThreshold
        ? await _generatePairwiseAlternativeInIsolateMap(hierarchyList)
        : await compute(
            _generatePairwiseAlternativeInIsolateMap, hierarchyList);

    return resultMap
        .map((e) => PairwiseAlternativeInputDto.fromMap(e).toEntity())
        .toList();
  }

  /// ISOLATED
  Future<List<Map<String, dynamic>>> _generatePairwiseAlternativeInIsolateMap(
    List<Map<String, dynamic>> rawDtoList,
  ) async {
    _startPerformanceProfiling('generate pairwise alternative');

    try {
      final dtoList =
          rawDtoList.map((e) => AhpHierarchyDto.fromMap(e)).toList();

      final result = <PairwiseAlternativeInputDto>[];

      for (var dto in dtoList) {
        final alternative = dto.alternative;
        final pairwise = <PairwiseComparisonInputDto>[];

        for (int i = 0; i < alternative.length; i++) {
          for (int j = i + 1; j < alternative.length; j++) {
            pairwise.add(
              PairwiseComparisonInputDto(
                id: _helper.getCustomUniqueId(),
                left: alternative[i],
                right: alternative[j],
                preferenceValue: null,
                isLeftMoreImportant: null,
              ),
            );
          }
        }

        result.add(
          PairwiseAlternativeInputDto(
            criteria: dto.criteria,
            alternative: pairwise,
          ),
        );
      }
      return result.map((e) => e.toMap()).toList();
    } catch (e) {
      throw Exception('Failed generate pairwise alternative: $e');
    } finally {
      _endPerformanceProfiling('generate pairwise alternative');
    }
  }

  /// *************************************************************************

  /// GENERATE RESULT PAIRWISE MATRIX CRITERIA
  @override
  Future<List<List<double>>> generateResultPairwiseMatrixCriteria(
      List<AhpItem> items, List<PairwiseComparisonInput> inputs) async {
    final computeThreshold = 20;

    final itemList =
        items.map((e) => AhpItemMapper.fromEntity(e).toMap()).toList();

    final comparisonInput = inputs
        .map((e) => PairwiseComparisonInputMapper.fromEntity(e).toMap())
        .toList();

    final result = inputs.length < computeThreshold
        ? await _generateResultPairwiseMatrixCriteriaInIsolateMap({
            'items': itemList,
            'inputs': comparisonInput,
          })
        : await compute(
            _generateResultPairwiseMatrixCriteriaInIsolateMap,
            {
              'items': itemList,
              'inputs': comparisonInput,
            },
          );

    return result;
  }

  /// ISOLATED
  Future<List<List<double>>> _generateResultPairwiseMatrixCriteriaInIsolateMap(
      Map<String, dynamic> data) async {
    _startPerformanceProfiling('generate result pairwise matrix criteria');

    try {
      final itemsRaw = List<Map<String, dynamic>>.from(data['items']);
      final inputsRaw = List<Map<String, dynamic>>.from(data['inputs']);

      final inputsDto =
          inputsRaw.map((e) => PairwiseComparisonInputDto.fromMap(e)).toList();
      final itemDto = itemsRaw.map((e) => AhpItemDto.fromMap(e)).toList();

      final matrix = List.generate(
        itemDto.length,
        (_) => List.filled(itemDto.length, 1.0),
      );

      final itemIndexMap = <String, int>{};
      for (int index = 0; index < itemDto.length; index++) {
        final id = itemDto[index].id;
        if (id == null || id.isEmpty) {
          throw Exception('Item with missing ID found');
        }
        itemIndexMap[id] = index;
      }

      for (final e in inputsDto) {
        final i = itemIndexMap[e.left.id];
        final j = itemIndexMap[e.right.id];
        final value = e.preferenceValue?.toDouble() ?? 1.0;

        if (i == null || j == null) {
          throw Exception('One or both items not found in the list');
        }

        if (value <= 0) {
          throw Exception('Comparison value must be greater than zero');
        }

        if (e.isLeftMoreImportant == true) {
          matrix[i][j] = value;
          matrix[j][i] = 1 / value;
        } else {
          matrix[i][j] = 1 / value;
          matrix[j][i] = value;
        }
      }

      return matrix;
    } finally {
      _endPerformanceProfiling('generate result pairwise matrix criteria');
    }
  }

  /// **************************************************************************

  /// GENERATE RESULT PAIRWISE MATRIX ALTERNATIVE
  @override
  Future<List<List<double>>> generateResultPairwiseMatrixAlternative(
      List<AhpItem> items, List<PairwiseAlternativeInput> inputs) async {
    final computeThreshold = 20;

    final itemList =
        items.map((e) => AhpItemMapper.fromEntity(e).toMap()).toList();

    final alternativeInputs = inputs
        .map((e) => PairwiseAlternativeInputMapper.fromEntity(e).toMap())
        .toList();

    final result = alternativeInputs.length < computeThreshold
        ? await _generateResultPairwiseMatrixAlternativeInIsolatedMap({
            'items': itemList,
            'inputs': alternativeInputs,
          })
        : await compute(_generateResultPairwiseMatrixAlternativeInIsolatedMap, {
            'items': itemList,
            'inputs': alternativeInputs,
          });

    return result;
  }

  /// ISOLATED
  Future<List<List<double>>>
      _generateResultPairwiseMatrixAlternativeInIsolatedMap(
          Map<String, dynamic> data) async {
    _startPerformanceProfiling('generate pairwise matrix alternative');
    try {
      final itemsRaw = List<Map<String, dynamic>>.from(data['items']);
      final inputsRaw = List<Map<String, dynamic>>.from(data['inputs']);

      final itemDto = itemsRaw.map((e) => AhpItemDto.fromMap(e)).toList();
      final inputsDto =
          inputsRaw.map((e) => PairwiseAlternativeInputDto.fromMap(e)).toList();

      if (itemDto.isEmpty) {
        throw ArgumentError('Alternative list is empty');
      }

      if (inputsDto.isEmpty) {
        return List.generate(
          itemDto.length,
          (_) => List.filled(itemDto.length, 1.0),
        );
      }

      final pairwise = inputsDto.first.alternative;

      final matrix = List.generate(
        itemDto.length,
        (_) => List.filled(itemDto.length, 1.0),
      );

      final itemIndexMap = <String, int>{};
      for (int index = 0; index < itemDto.length; index++) {
        final id = itemDto[index].id;
        if (id == null || id.isEmpty) {
          throw Exception('Alternative item has missing ID');
        }
        itemIndexMap[id] = index;
      }

      for (final comparison in pairwise) {
        final i = itemIndexMap[comparison.left.id];
        final j = itemIndexMap[comparison.right.id];

        if (i == null || j == null) {
          throw Exception('Alternative not found in list');
        }

        final value = comparison.preferenceValue?.toDouble() ?? 1.0;
        if (value <= 0) {
          throw Exception('Comparison value must be greater than zero');
        }

        if (comparison.isLeftMoreImportant == true) {
          matrix[i][j] = value;
          matrix[j][i] = 1 / value;
        } else {
          matrix[i][j] = 1 / value;
          matrix[j][i] = value;
        }
      }

      return matrix;
    } finally {
      _endPerformanceProfiling('generate pairwise matrix alternative');
    }
  }

  /// **************************************************************************

  /// CALCULATE EIGEN VECTOR CRITERIA
  @override
  Future<List<double>> calculateEigenVectorCriteria(
      List<List<double>> matrix) async {
    final matrixRaw = matrix.map((e) => e.cast<dynamic>()).toList();

    final result =
        await compute(_calculateEigenVectorCriteriaInIsolated, matrixRaw);

    return result;
  }

  /// ISOLATED
  Future<List<double>> _calculateEigenVectorCriteriaInIsolated(
      List<dynamic> matrixRaw) async {
    _startPerformanceProfiling('calculate eigen vector');
    try {
      final matrix = matrixRaw
          .map((row) => (row as List<dynamic>).map((e) => e as double).toList())
          .toList();

      List<double> colSums = List.filled(matrix.length, 0);

      for (int j = 0; j < matrix.length; j++) {
        for (int i = 0; i < matrix.length; i++) {
          colSums[j] += matrix[i][j];
        }
      }

      List<double> priorities = List.filled(matrix.length, 0);

      for (int i = 0; i < matrix.length; i++) {
        double sum = 0;
        for (int j = 0; j < matrix.length; j++) {
          sum += matrix[i][j] / colSums[j];
        }
        priorities[i] = sum / matrix.length;
      }

      return priorities;
    } catch (e) {
      throw Exception('Failed calculate eigen vector $e');
    } finally {
      _endPerformanceProfiling('calculate eigen vector');
    }
  }

  /// **************************************************************************

  /// CALCULATE EIGEN VECTOR ALTERNATIVE
  @override
  Future<List<double>> calculateEigenVectorAlternative(
      List<List<double>> matrix) async {
    final rawMatrix = matrix.map((e) => e.cast<dynamic>()).toList();

    final result =
        await compute(_calculateEigenVectorAlternativeInIsolated, rawMatrix);

    return result;
  }

  /// ISOLATED
  Future<List<double>> _calculateEigenVectorAlternativeInIsolated(
      List<dynamic> matrixRaw) async {
    _startPerformanceProfiling('calculate eigen vector alternative');
    try {
      final matrix = matrixRaw
          .map((row) => (row as List<dynamic>).map((e) => e as double).toList())
          .toList();

      final int n = matrix.length;

      if (n == 0 || matrix.any((row) => row.length != n)) {
        throw ArgumentError('Matrix must be square and non-empty.');
      }

      List<double> colSums = List.filled(n, 0.0);
      for (int j = 0; j < n; j++) {
        for (int i = 0; i < n; i++) {
          colSums[j] += matrix[i][j];
        }
      }

      List<List<double>> normalizedMatrix =
          List.generate(n, (i) => List.filled(n, 0.0));
      for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
          normalizedMatrix[i][j] = matrix[i][j] / colSums[j];
        }
      }

      List<double> priorities = List.filled(n, 0.0);
      for (int i = 0; i < n; i++) {
        double rowSum = 0.0;
        for (int j = 0; j < n; j++) {
          rowSum += normalizedMatrix[i][j];
        }
        priorities[i] = rowSum / n;
      }

      return priorities;
    } catch (e) {
      throw Exception('Failed to calculate eigen vector alternative: $e');
    } finally {
      _endPerformanceProfiling('calculate eigen vector alternative');
    }
  }

  /// **************************************************************************

  /// CHECK CONSISTENCY RATIO
  @override
  Future<AhpConsistencyRatio> checkConsistencyRatio(List<List<double>> matrix,
      List<double> priorityVector, String source) async {
    final result = await compute(
      _checkConsistencyRatioInIsolatedMap,
      {
        "matrix": matrix,
        "priority_vector": priorityVector,
        "source": source,
      },
    );

    final data = AhpConsistencyRatioDto.fromMap(result);

    return data.toEntity();
  }

  /// ISOLATED
  Future<Map<String, dynamic>> _checkConsistencyRatioInIsolatedMap(
    Map<String, dynamic> data,
  ) async {
    _startPerformanceProfiling('check consistency ratio');
    try {
      final matrixRaw = data['matrix'] as List<dynamic>;
      final priorityRaw = data['priority_vector'] as List<dynamic>;
      final source = data['source'] as String;

      final matrix = matrixRaw
          .map((row) => (row as List<dynamic>).map((e) => e as double).toList())
          .toList();

      final priorityVector = priorityRaw.map((e) => e as double).toList();

      final int n = matrix.length;

      if (n == 0 || priorityVector.isEmpty || priorityVector.length != n) {
        throw ArgumentError(
          'Matrix and priority vector must be non-empty and of the same size.',
        );
      }

      if (priorityVector.any((e) => e == 0)) {
        throw ArgumentError(
            'Priority vector contains zero, cannot divide by zero.');
      }

      List<double> weightedSums = List.filled(n, 0);
      for (int i = 0; i < n; i++) {
        double sum = 0;
        for (int j = 0; j < n; j++) {
          sum += matrix[i][j] * priorityVector[j];
        }
        weightedSums[i] = sum;
      }

      double lambdaMax = 0;
      for (int i = 0; i < n; i++) {
        lambdaMax += weightedSums[i] / priorityVector[i];
      }
      lambdaMax /= n;

      double ci = (lambdaMax - n) / (n - 1);

      final ri = _getRI(n);
      if (ri == 0) {
        return {
          "source": source,
          "ratio": 0,
          "is_consistent": true,
        };
      }

      final cr = ci / ri;

      dev.log('λmax: $lambdaMax, CI: $ci, CR: $cr');

      if ((cr - 0.1) > 1e-5) {
        return {
          "source": source,
          "ratio": cr,
          "is_consistent": false,
        };
      }

      return {
        "source": source,
        "ratio": cr,
        "is_consistent": true,
      };
    } finally {
      _endPerformanceProfiling('check consistency ratio');
    }
  }

  /// RANDOM INDEX
  static double _getRI(int n) {
    const Map<int, double> riTable = {
      1: 0.0,
      2: 0.0,
      3: 0.58,
      4: 0.90,
      5: 1.12,
      6: 1.24,
      7: 1.32,
      8: 1.41,
      9: 1.45,
      10: 1.49,
      11: 1.51,
      12: 1.48,
      13: 1.56,
      14: 1.57,
      15: 1.59,
    };
    return riTable[n] ?? 1.59;
  }

  /// **************************************************************************

  /// GET FINAL SCORE
  @override
  Future<AhpResult> getFinalScore(
    List<double> eigenVectorCriteria,
    List<List<double>> eigenVectorsAlternative,
    List<AhpItem> alternatives,
    AhpConsistencyRatio consistencyCriteria,
    List<AhpConsistencyRatio> consistencyAlternatives,
  ) async {
    final eigenVectorAltRaw =
        eigenVectorsAlternative.map((e) => e.cast<dynamic>()).toList();
    final alternativeRaw =
        alternatives.map((e) => AhpItemMapper.fromEntity(e).toMap()).toList();
    final consistencyCriteriaRaw =
        AhpConsistencyRatioMapper.fromEntity(consistencyCriteria).toMap();
    final consistencyAltRaw = consistencyAlternatives
        .map((e) => AhpConsistencyRatioMapper.fromEntity(e).toMap())
        .toList();

    final result = await compute(_getFinalScoreInIsolatedMap, {
      "eigen_vector_criteria": eigenVectorCriteria,
      "eigen_vector_alternative": eigenVectorAltRaw,
      "alternative_raw": alternativeRaw,
      "consistency_criteria_raw": consistencyCriteriaRaw,
      "consistency_alternative_raw": consistencyAltRaw,
    });

    final data = AhpResultDto.fromMap(result);

    return data.toEntity();
  }

  /// ISOLATED
  Future<Map<String, dynamic>> _getFinalScoreInIsolatedMap(
      Map<String, dynamic> data) async {
    _startPerformanceProfiling('calculate final score..');
    try {
      final eigenVectorsAlternativeRaw =
          data['eigen_vector_alternative'] as List<dynamic>;
      final alternativesRaw = data['alternative_raw'] as List<dynamic>;
      final consistencyCriteriaRaw = data['consistency_criteria_raw'];
      final consistencyAlternativesRaw =
          data['consistency_alternative_raw'] as List<dynamic>;

      List<double> eigenVectorCriteria = data['eigen_vector_criteria'];
      List<List<double>> eigenVectorsAlternative = eigenVectorsAlternativeRaw
          .map((row) => (row as List<dynamic>).map((e) => e as double).toList())
          .toList();
      List<AhpItemDto> alternatives =
          alternativesRaw.map((e) => AhpItemDto.fromMap(e)).toList();
      final consistencyCriteria =
          AhpConsistencyRatioDto.fromMap(consistencyCriteriaRaw);
      List<AhpConsistencyRatioDto> consistencyAlternatives =
          consistencyAlternativesRaw
              .map((e) => AhpConsistencyRatioDto.fromMap(e))
              .toList();

      if (eigenVectorsAlternative.isEmpty ||
          eigenVectorsAlternative.first.isEmpty) {
        throw Exception('Alternative matrix is empty.');
      }

      final int altCount = eigenVectorsAlternative.first.length;
      final int criteriaCount = eigenVectorCriteria.length;

      List<double> result = List.filled(altCount, 0.0);

      for (int i = 0; i < altCount; i++) {
        for (int j = 0; j < criteriaCount; j++) {
          result[i] += eigenVectorCriteria[j] * eigenVectorsAlternative[j][i];
        }
      }

      final ahpResultDetail = <AhpResultDetailDto>[];

      for (int i = 0; i < altCount; i++) {
        ahpResultDetail.add(
          AhpResultDetailDto(
            id: alternatives[i].id,
            name: alternatives[i].name,
            value: result[i],
          ),
        );
      }

      final alternativesConsistency = consistencyAlternatives
        ..sort((a, b) => b.ratio.compareTo(a.ratio));

      String? note = !consistencyCriteria.isConsistent ||
              consistencyAlternatives.any((e) => e.isConsistent == false)
          ? '''
Thank you for completing the assessment process. Based on the consistency check, the resulting Consistency Ratio (CR) exceeds the acceptable threshold of 0.1.
As a result, the current assessment does not meet the expected level of consistency and therefore cannot yet be considered valid.
We recommend reviewing and revising the assessment to ensure that the resulting analysis is more accurate and reliable for decision-making.
Detail:
${!consistencyCriteria.isConsistent ? '* inconsistency on criteria' : ''}
${consistencyAlternatives.any((e) => e.isConsistent == false) ? '* Inconsistency on alternatives per criteria:\n${consistencyAlternatives.where((e) => !e.isConsistent).map((e) => '- ${e.source}: ${e.ratio}').join('\n')}' : ''}
'''
          : null;

      final ahpResult = AhpResultDto(
        results: ahpResultDetail..sort((a, b) => b.value.compareTo(a.value)),
        isConsistentCriteria: consistencyCriteria.isConsistent,
        consistencyCriteriaRatio: consistencyCriteria.ratio,
        isConsistentAlternative: alternativesConsistency[0].isConsistent,
        consistencyAlternativeRatio: alternativesConsistency[0].ratio,
        note: note,
      );

      return ahpResult.toMap();
    } catch (e) {
      throw Exception('Failed calculate final score: $e');
    } finally {
      _endPerformanceProfiling('calculate final score');
    }
  }
}
