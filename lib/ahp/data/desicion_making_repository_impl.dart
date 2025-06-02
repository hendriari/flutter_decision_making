import 'dart:developer' as dev;

import 'package:flutter_decision_making/ahp/domain/entities/ahp_result.dart';
import 'package:flutter_decision_making/ahp/domain/entities/alternative.dart';
import 'package:flutter_decision_making/ahp/domain/entities/criteria.dart';
import 'package:flutter_decision_making/ahp/domain/entities/hierarchy.dart';
import 'package:flutter_decision_making/ahp/domain/entities/identification.dart';
import 'package:flutter_decision_making/ahp/domain/entities/pairwise_alternative_input.dart';
import 'package:flutter_decision_making/ahp/domain/entities/pairwise_comparison_input.dart';
import 'package:flutter_decision_making/ahp/domain/repository/decision_making_repository.dart';
import 'package:flutter_decision_making/ahp/exception/cosistency_ratio_exception.dart';
import 'package:flutter_decision_making/ahp/helper/ahp_helper.dart';

class DecisionMakingRepositoryImpl extends DecisionMakingRepository {
  final AhpHelper _helper;
  final Stopwatch _stopwatch;

  DecisionMakingRepositoryImpl({AhpHelper? helper, Stopwatch? stopwatch})
      : _helper = helper ?? AhpHelper(),
        _stopwatch = stopwatch ?? Stopwatch();

  static void _validateUniqueId<T>(List<T> items, String Function(T) getId) {
    final seen = <String>{};
    for (var e in items) {
      final id = getId(e);
      if (seen.contains(id)) {
        throw ArgumentError('Duplicate id found');
      }
      seen.add(id);
    }
  }

  void _startPerformanceProfiling(String name) {
    dev.log("🔄 start $name..");
    dev.Timeline.startSync(name);
    _stopwatch.start();
  }

  void _endPerformanceProfiling(String name) {
    dev.Timeline.finishSync();
    _stopwatch.stop();
    dev.log(
        "🏁 $name has been execute - duration : ${_stopwatch.elapsedMilliseconds} ms");
  }

  @override
  Future<Identification> identification(
    List<Criteria> criteria,
    List<Alternative> alternative,
  ) async {
    _startPerformanceProfiling('identification');

    try {
      if (criteria.isEmpty) {
        throw ArgumentError("Criteria can't be empty!");
      }
      if (alternative.isEmpty) {
        throw ArgumentError("Alternative can't be empty!");
      }

      if (criteria.length > 50 || alternative.length > 99) {
        throw ArgumentError(
          "Too much data, please limit the number of criteria/alternatives.",
        );
      }

      final updatedCriteria = List<Criteria>.generate(criteria.length, (i) {
        final e = criteria[i];
        return (e.id == null || e.id!.isEmpty)
            ? e.copyWith(id: _helper.getCustomUniqueId())
            : e;
      });

      final updateAlternative = List<Alternative>.generate(alternative.length, (
        i,
      ) {
        final e = alternative[i];
        return (e.id == null || e.id!.isEmpty)
            ? e.copyWith(id: _helper.getCustomUniqueId())
            : e;
      });

      _validateUniqueId<Criteria>(updatedCriteria, (e) => e.id!);
      _validateUniqueId<Alternative>(updateAlternative, (e) => e.id!);

      return Identification(
        criteria: updatedCriteria,
        alternative: updateAlternative,
      );
    } finally {
      _endPerformanceProfiling('identification');
    }
  }

  @override
  Future<List<Hierarchy>> generateHierarchy(
    List<Criteria> criteria,
    List<Alternative> alternative,
  ) async {
    _startPerformanceProfiling('generate hierarchy');
    try {
      final resultHierarchy = criteria.map((c) {
        return Hierarchy(criteria: c, alternative: alternative);
      }).toList();

      return resultHierarchy;
    } catch (e) {
      throw Exception('Failed generate hierarchy $e');
    } finally {
      _endPerformanceProfiling('generate hierarchy');
    }
  }

  @override
  Future<List<PairwiseComparisonInput<Criteria>>> generatePairwiseCriteria(
    List<Criteria> criteria,
  ) async {
    _startPerformanceProfiling('generate pairwise criteria');
    try {
      final result = <PairwiseComparisonInput<Criteria>>[];

      for (int i = 0; i < criteria.length; i++) {
        for (int j = i + 1; j < criteria.length; j++) {
          result.add(
            PairwiseComparisonInput<Criteria>(
              left: criteria[i],
              right: criteria[j],
              preferenceValue: null,
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

  @override
  Future<List<List<double>>> generateResultPairwiseMatrixCriteria(
    List<Criteria> items,
    List<PairwiseComparisonInput<Criteria>> inputs,
  ) async {
    _startPerformanceProfiling('generate result pairwise matrix criteria');

    try {
      final matrix = List.generate(
        items.length,
        (_) => List.filled(items.length, 1.0),
      );

      for (final e in inputs) {
        final i = items.indexOf(e.left);
        final j = items.indexOf(e.right);
        final value = e.preferenceValue?.value.toDouble() ?? 1.0;

        if (i == -1 || j == -1) {
          throw Exception('One or both items not found in the list');
        }

        if (value <= 0) {
          throw Exception('Comparison value must be greater than zero');
        }

        matrix[i][j] = value;
        matrix[j][i] = 1 / value;
      }

      return matrix;
    } finally {
      _endPerformanceProfiling('generate result pairwise matrix criteria');
    }
  }

  @override
  Future<List<List<double>>> generateResultPairwiseMatrixAlternative(
    List<Alternative> items,
    List<PairwiseAlternativeInput> inputs,
  ) async {
    _startPerformanceProfiling('generate pairwise matrix alternative');
    try {
      if (items.isEmpty) {
        throw ArgumentError('Alternative list is empty');
      }

      if (inputs.isEmpty) {
        return List.generate(
          items.length,
          (_) => List.filled(items.length, 1.0),
        );
      }

      final pairwise = inputs.first.alternative;

      final matrix = List.generate(
        items.length,
        (_) => List.filled(items.length, 1.0),
      );

      for (final comparison in pairwise) {
        final i = items.indexWhere((e) => e.id == comparison.left.id);
        final j = items.indexWhere((e) => e.id == comparison.right.id);

        if (i == -1 || j == -1) {
          throw Exception('Alternative not found in list');
        }

        final value = comparison.preferenceValue?.value.toDouble() ?? 1.0;
        if (value <= 0) {
          throw Exception('Comparison value must be greater than zero');
        }

        matrix[i][j] = value;
        matrix[j][i] = 1 / value;
      }

      return matrix;
    } finally {
      _endPerformanceProfiling('generate pairwise matrix alternative');
    }
  }

  @override
  Future<List<double>> calculateEigenVectorCriteria(
      List<List<double>> matrix) async {
    _startPerformanceProfiling('calculate eigen vector');
    try {
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

  @override
  Future<List<double>> calculateEigenVectorAlternative(
      List<List<double>> matrix) async {
    _startPerformanceProfiling('calculate eigen vector alternative');
    try {
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

  @override
  Future<double> checkConsistencyRatio(
    List<List<double>> matrix,
    List<double> priorityVector,
    String source,
  ) async {
    _startPerformanceProfiling('check consistency ratio');
    try {
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
      if (ri == 0) return 0;

      final cr = ci / ri;

      dev.log('λmax: $lambdaMax, CI: $ci, CR: $cr');

      if ((cr - 0.1) > 1e-5) {
        throw ConsistencyRatioException(type: source, value: cr);
      }

      return cr;
    } finally {
      _endPerformanceProfiling('check consistency ratio');
    }
  }

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

  @override
  Future<List<AhpResult>> getFinalScore(
    List<double> eigenVectorCriteria,
    List<List<double>> eigenVectorsAlternative,
    List<Alternative> alternatives,
  ) async {
    _startPerformanceProfiling('calculate final score..');
    try {
      final int altCount = eigenVectorsAlternative.first.length;
      final int criteriaCount = eigenVectorCriteria.length;

      List<double> result = List.filled(altCount, 0.0);

      for (int i = 0; i < altCount; i++) {
        for (int j = 0; j < criteriaCount; j++) {
          result[i] += eigenVectorCriteria[j] * eigenVectorsAlternative[j][i];
        }
      }

      final ahpResult = <AhpResult>[];

      for (int i = 0; i < altCount; i++) {
        ahpResult.add(AhpResult(
            id: alternatives[i].id,
            name: alternatives[i].name,
            value: result[i]));
      }

      return ahpResult..sort((a, b) => b.value.compareTo(a.value));
    } catch (e) {
      throw Exception('Failed calculate final score: $e');
    } finally {
      _endPerformanceProfiling('calculate final score');
    }
  }
}
