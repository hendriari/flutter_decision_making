import 'package:flutter_decision_making/core/shared/interface/weighted_decision_matrix_mixin.dart';
import 'package:flutter_decision_making/feature/topsis/data/datasource/topsis_local_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_decision_making/core/decision_making_enums.dart';
import 'package:flutter_decision_making/core/decision_making_helper.dart';
import 'package:flutter_decision_making/core/decision_making_performance_profiling.dart';
import 'package:flutter_decision_making/feature/topsis/domain/entities/topsis_ideal_value.dart';
import 'package:flutter_decision_making/feature/topsis/domain/entities/topsis_matrix.dart';

import 'dart:math' as math;

import 'package:flutter_decision_making/feature/topsis/domain/entities/topsis_raw_matrix.dart';
import 'package:flutter_decision_making/flutter_decision_making.dart';

/// Implementation of [TopsisLocalDatasource] that handles TOPSIS algorithm operations.
///
/// This implementation supports:
/// - Euclidean normalization
/// - Identification of Positive (A+) and Negative (A-) Ideal Solutions
/// - Separation measure calculations using Euclidean distance
/// - Relative closeness coefficient calculation
/// - Isolate-based processing for large datasets
/// - Performance profiling
///
/// **Example usage:**
/// ```dart
/// final datasource = TopsisLocalDatasourceImpl();
///
/// // Generate matrix
/// final rawMatrix = await datasource.generateTopsisMatrix(
///   listAlternative: alternatives,
///   listCriteria: criteria,
/// );
///
/// // Calculate results
/// final results = await datasource.calculateResult(rawMatrix: rawMatrix);
/// ```
class TopsisLocalDatasourceImpl
    with WeightedDecisionMatrixMixin
    implements TopsisLocalDatasource {
  final DecisionMakingHelper _helper;
  final DecisionIsolateMain _isolate;

  @override
  DecisionMakingHelper get helper => _helper;

  @override
  DecisionIsolateMain get isolate => _isolate;

  /// Creates an instance of [TopsisLocalDatasourceImpl].
  ///
  /// **Parameters:**
  /// - [helper]: Helper for utility functions (defaults to new instance)
  /// - [isolate]: Isolate manager for heavy computations (defaults to new instance)
  TopsisLocalDatasourceImpl({
    DecisionMakingHelper? helper,
    DecisionIsolateMain? isolate,
    Stopwatch? stopwatch,
  })  : _helper = helper ?? DecisionMakingHelper(),
        _isolate = isolate ?? DecisionIsolateMain();

  @override
  Future<TopsisRawMatrix> generateTopsisMatrix({
    required List<WeightedDecisionAlternative> listAlternative,
    required List<WeightedDecisionCriteria> listCriteria,
  }) async {
    final name = "Generate TOPSIS pairwise matrix";
    startPerformanceProfiling(name);
    try {
      validateInputs(listAlternative, listCriteria);

      final normalizedCriteria = normalizeCriteriaWeights(listCriteria);
      final updateAlternative = ensureIdsForAlternatives(listAlternative);
      final updateCriteria = ensureIdsForCriteria(normalizedCriteria);

      List<WeightedDecisionMatrix> result = [];
      final canUseIsolate = !kIsWeb &&
          (updateAlternative.length > 80 || updateCriteria.length > 25);

      if (canUseIsolate) {
        result = await generateMatrixWithIsolate(
          DecisionAlgorithm.topsis,
          TopsisProcessingIsolateCommand.generateMatrix,
          updateAlternative,
          updateCriteria,
        );
      } else {
        result = generateMatrixDirectly(updateAlternative, updateCriteria);
      }

      return TopsisRawMatrix(
        criterias: updateCriteria,
        matrixs: result,
      );
    } catch (e, s) {
      debugPrint('$name Error: $e\n$s');
      rethrow;
    } finally {
      endPerformanceProfiling(name);
    }
  }

  /// Normalizes the decision matrix using Euclidean normalization.
  ///
  /// Formula: r_ij = x_ij / sqrt(sum(x_ij^2))
  ///
  /// **Parameters:**
  /// - [matrix]: The matrix to normalize
  /// - [listCriteria]: The criteria to use for normalization
  ///
  /// **Returns:** Euclidean normalized matrix
  Future<List<WeightedDecisionMatrix>> _normalizeEuclidean({
    required List<WeightedDecisionMatrix> matrix,
    required List<WeightedDecisionCriteria> listCriteria,
  }) async {
    final name = "Normalize euclidean";
    startPerformanceProfiling(name);
    try {
      if (!kIsWeb && (matrix.length > 80 || listCriteria.length > 25)) {
        final data = await isolate.runTask(
          DecisionAlgorithm.topsis,
          TopsisProcessingIsolateCommand.normalizeEuclidean,
          {
            "criteria": listCriteria.map((e) => e.toDto().toJson()).toList(),
            "matrix": matrix.map((e) => e.toDto().toJson()).toList(),
          },
        );

        var result = (data as List)
            .map((e) => WeightedDecisionMatrixDto.fromJson(e))
            .toList();

        return result.map((e) => e.toEntity()).toList();
      } else {
        Map<String, double> dividers = {};

        for (var crt in listCriteria) {
          double sumSquared = 0;
          for (var alt in matrix) {
            final rating = alt.ratings.firstWhere(
              (r) => r.criteria?.id == crt.id,
            );
            final ratingValue = (rating.value ?? 0).toDouble();
            sumSquared += math.pow(ratingValue, 2);
          }
          dividers[crt.id!] = math.sqrt(sumSquared);
        }

        return matrix.map((alt) {
          final normalizedRatings = alt.ratings.map((r) {
            double divider = dividers[r.criteria?.id] ?? 1.0;
            return r.copyWith(
              value: divider == 0 ? 0 : (r.value ?? 0) / divider,
            );
          }).toList();

          return alt.copyWith(ratings: normalizedRatings);
        }).toList();
      }
    } catch (e, s) {
      debugPrint("$name Error: $e\n$s");
      rethrow;
    } finally {
      endPerformanceProfiling(name);
    }
  }

  /// Calculates the weighted normalized decision matrix.
  ///
  /// Formula: v_ij = w_j * r_ij
  ///
  /// **Parameters:**
  /// - [normalizeEuclideanMatrix]: Euclidean normalized matrix
  ///
  /// **Returns:** Weighted normalized matrix
  Future<List<WeightedDecisionMatrix>> _normalizeWeightedMatrix({
    required List<WeightedDecisionMatrix> normalizeEuclideanMatrix,
  }) async {
    final name = "Normalize Weighting Matrix";
    startPerformanceProfiling(name);
    try {
      var matrix = List<WeightedDecisionMatrix>.from(normalizeEuclideanMatrix);

      matrix = matrix.map((e) {
        final updatedRatings = e.ratings.map((r) {
          final value = (r.value ?? 0) * (r.criteria?.weightPercent ?? 0) / 100;
          return r.copyWith(value: value);
        }).toList();

        return e.copyWith(ratings: updatedRatings);
      }).toList();

      return matrix;
    } catch (e, s) {
      debugPrint("$name Error: $e\n$s");
      rethrow;
    } finally {
      endPerformanceProfiling(name);
    }
  }

  /// Identifies the positive and negative ideal solutions.
  ///
  /// For Benefit Criteria: A+ is Max, A- is Min
  /// For Cost Criteria: A+ is Min, A- is Max
  ///
  /// **Parameters:**
  /// - [normalizeMatrix]: Weighted normalized matrix
  /// - [listCriteria]: Criteria list
  ///
  /// **Returns:** [TopsisIdealValue] containing A+ and A-
  Future<TopsisIdealValue> _getIdealValue({
    required List<WeightedDecisionMatrix> normalizeMatrix,
    required List<WeightedDecisionCriteria> listCriteria,
  }) async {
    final name = "Get Ideal Value";
    startPerformanceProfiling(name);
    try {
      Map<String, double> positiveIdeal = {}; // A+
      Map<String, double> negativeIdeal = {}; // A-

      for (var crt in listCriteria) {
        final crtId = crt.id!;

        final values = normalizeMatrix.map((m) {
          final rating = m.ratings.firstWhere(
            (r) => r.criteria?.id == crtId,
          );
          return (rating.value ?? 0).toDouble();
        }).toList();

        final maxVal = values.reduce(math.max);
        final minVal = values.reduce(math.min);

        if (crt.isBenefit) {
          positiveIdeal[crtId] = maxVal; // A+ = Max
          negativeIdeal[crtId] = minVal; // A- = Min
        } else {
          positiveIdeal[crtId] = minVal; // A+ = Min (because is cost)
          negativeIdeal[crtId] = maxVal; // A- = Max (because is cost)
        }
      }

      return TopsisIdealValue(
        positiveIdeal: positiveIdeal,
        negativeIdeal: negativeIdeal,
      );
    } catch (e, s) {
      debugPrint("$name Error: $e\n$s");
      rethrow;
    } finally {
      endPerformanceProfiling(name);
    }
  }

  /// Calculates the separation measures (Euclidean distance) from ideal solutions.
  ///
  /// Formula: D_i = sqrt(sum(v_ij - a_j)^2)
  ///
  /// **Parameters:**
  /// - [weightedMatrix]: Weighted normalized matrix
  /// - [idealValue]: Ideal solution values
  ///
  /// **Returns:** List of matrix objects with calculated distances
  Future<List<TopsisMatrix>> _calculateIdealDistance({
    required List<WeightedDecisionMatrix> weightedMatrix,
    required TopsisIdealValue idealValue,
  }) async {
    final name = "Calculate ideal distance";
    startPerformanceProfiling(name);
    try {
      var result = weightedMatrix.map((alt) {
        double dPlus = 0;
        double dMinus = 0;

        for (var r in alt.ratings) {
          final crtId = r.criteria!.id!;
          final value = r.value ?? 0;

          final aPlus = idealValue.positiveIdeal[crtId] ?? 0;
          final aMinus = idealValue.negativeIdeal[crtId] ?? 0;

          dPlus += math.pow(value - aPlus, 2);
          dMinus += math.pow(value - aMinus, 2);
        }

        return TopsisMatrix(
          alternative: alt.alternative,
          ratings: alt.ratings,
          distancePlus: math.sqrt(dPlus),
          distanceMinus: math.sqrt(dMinus),
        );
      }).toList();

      return result;
    } catch (e, s) {
      debugPrint("$name Error: $e\n$s");
      rethrow;
    } finally {
      endPerformanceProfiling(name);
    }
  }

  @override
  Future<List<WeightedDecisionResult>> calculateResult({
    required TopsisRawMatrix rawMatrix,
  }) async {
    final name = "Calculate result";
    startPerformanceProfiling(name);
    try {
      /// NORMALIZE EUCLIDEAN
      var normalizeEuclidean = await _normalizeEuclidean(
          matrix: rawMatrix.matrixs, listCriteria: rawMatrix.criterias);

      /// NORMALIZE WEIGHTED MATRIX
      var normalizeWeightedMatrix = await _normalizeWeightedMatrix(
          normalizeEuclideanMatrix: normalizeEuclidean);

      /// GET IDEAL VALUE
      var idealValue = await _getIdealValue(
          normalizeMatrix: normalizeWeightedMatrix,
          listCriteria: rawMatrix.criterias);

      /// CALCULATE IDEAL DISTANCE
      var distanceMatrix = await _calculateIdealDistance(
          weightedMatrix: normalizeWeightedMatrix, idealValue: idealValue);

      var result = distanceMatrix.map((alt) {
        final dPlus = alt.distancePlus;
        final dMinus = alt.distanceMinus;

        final denominator = dPlus + dMinus;

        final score = denominator == 0 ? 0.5 : dMinus / denominator;

        return WeightedDecisionResult(
          alternative: alt.alternative,
          score: score.toDouble(),
          rank: 0,
        );
      }).toList();

      result.sort((a, b) => b.score.compareTo(a.score));

      for (int i = 0; i < result.length; i++) {
        result[i] = result[i].copyWith(rank: i + 1);
      }

      return result;
    } catch (e, s) {
      debugPrint("$name Error: $e\n$s");
      rethrow;
    } finally {
      endPerformanceProfiling(name);
    }
  }

  @override
  Future<List<WeightedDecisionResult>> calculateResultWithExistingMatrix({
    required TopsisRawMatrix rawMatrix,
  }) async {
    final name = "Calculate result from existing matrix";
    startPerformanceProfiling(name);
    try {
      await validateMaxInputValue(rawMatrix.matrixs);

      final validatedMatrix = validateAndFixMatrix(rawMatrix.matrixs);

      // Update criterias from validated matrix to ensure ID consistency
      final updatedCriterias =
          validatedMatrix.first.ratings.map((r) => r.criteria!).toList();

      /// NORMALIZE EUCLIDEAN
      var normalizeEuclidean = await _normalizeEuclidean(
          matrix: validatedMatrix, listCriteria: updatedCriterias);

      /// NORMALIZE WEIGHTED MATRIX
      var normalizeWeightedMatrix = await _normalizeWeightedMatrix(
          normalizeEuclideanMatrix: normalizeEuclidean);

      /// GET IDEAL VALUE
      var idealValue = await _getIdealValue(
          normalizeMatrix: normalizeWeightedMatrix,
          listCriteria: updatedCriterias);

      /// CALCULATE IDEAL DISTANCE
      var distanceMatrix = await _calculateIdealDistance(
          weightedMatrix: normalizeWeightedMatrix, idealValue: idealValue);

      var result = distanceMatrix.map((alt) {
        final dPlus = alt.distancePlus;
        final dMinus = alt.distanceMinus;

        final denominator = dPlus + dMinus;

        final score = denominator == 0 ? 0.5 : dMinus / denominator;

        return WeightedDecisionResult(
          alternative: alt.alternative,
          score: score.toDouble(),
          rank: 0,
        );
      }).toList();

      result.sort((a, b) => b.score.compareTo(a.score));

      for (int i = 0; i < result.length; i++) {
        result[i] = result[i].copyWith(rank: i + 1);
      }

      return result;
    } catch (e, s) {
      debugPrint("$name Error: $e\n$s");
      rethrow;
    } finally {
      endPerformanceProfiling(name);
    }
  }
}
