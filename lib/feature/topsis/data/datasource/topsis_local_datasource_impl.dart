import 'package:flutter_decision_making/core/shared/entity/weighted_decision_alternative.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_criteria.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_matrix.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_result.dart';
import 'package:flutter_decision_making/core/shared/interface/weighted_decision_matrix_mixin.dart';
import 'package:flutter_decision_making/feature/topsis/data/datasource/topsis_local_datasource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_decision_making/core/decision_making_enums.dart';
import 'package:flutter_decision_making/core/decision_making_helper.dart';
import 'package:flutter_decision_making/core/decision_making_performance_profiling.dart';
import 'package:flutter_decision_making/core/isolate/decision_isolate_main.dart';
import 'package:flutter_decision_making/feature/topsis/domain/entities/topsis_ideal_value.dart';
import 'package:flutter_decision_making/feature/topsis/domain/entities/topsis_matrix.dart';

import 'dart:math' as math;

import 'package:flutter_decision_making/feature/topsis/domain/entities/topsis_raw_matrix.dart';

class TopsisLocalDatasourceImpl
    with WeightedDecisionMatrixInterface
    implements TopsisLocalDatasource {
  final DecisionMakingHelper _helper;
  final DecisionIsolateMain _isolate;

  @override
  DecisionMakingHelper get helper => _helper;

  @override
  DecisionIsolateMain get isolate => _isolate;

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
        criterias: listCriteria,
        matrixs: result,
      );
    } catch (e, s) {
      debugPrint('$name Error: $e\n$s');
      rethrow;
    } finally {
      endPerformanceProfiling(name);
    }
  }

  /// NORMALIZE DECISION MATRIX
  Future<List<WeightedDecisionMatrix>> _normalizeEuclidean({
    required List<WeightedDecisionMatrix> matrix,
    required List<WeightedDecisionCriteria> listCriteria,
  }) async {
    final name = "Normalize euclidean";
    startPerformanceProfiling(name);
    try {
      Map<String, double> dividers = {};

      for (var crt in listCriteria) {
        double sumSquared = 0;
        for (var alt in matrix) {
          var rating = alt.ratings.firstWhere((r) => r.criteria?.id == crt.id);
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
    } catch (e, s) {
      debugPrint("$name Error: $e\n$s");
      rethrow;
    } finally {
      endPerformanceProfiling(name);
    }
  }

  /// NORMALIZE WEIGHTING MATRIX
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

  /// IDEAL VALUE MIN & MAX
  Future<TopsisIdealValue> _getIdealValue({
    required List<WeightedDecisionMatrix> normalizeMatrix,
    required List<WeightedDecisionCriteria> listCriteria,
  }) async {
    final name = "Get Ideal Value";
    startPerformanceProfiling(name);
    try {
      // Map untuk menampung nilai ideal per criteria ID
      Map<String, double> positiveIdeal = {}; // A+
      Map<String, double> negativeIdeal = {}; // A-

      for (var crt in listCriteria) {
        final crtId = crt.id!;

        // Ambil semua nilai dari semua alternatif untuk kriteria ini
        final values = normalizeMatrix.map((m) {
          return (m.ratings.firstWhere((r) => r.criteria?.id == crtId).value ??
                  0)
              .toDouble();
        }).toList();

        final maxVal = values.reduce(math.max);
        final minVal = values.reduce(math.min);

        if (crt.isBenefit) {
          positiveIdeal[crtId] = maxVal; // A+ = Max
          negativeIdeal[crtId] = minVal; // A- = Min
        } else {
          positiveIdeal[crtId] = minVal; // A+ = Min (karena cost)
          negativeIdeal[crtId] = maxVal; // A- = Max (karena cost)
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

  /// CALCULATE DISTANCE
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

  /// RESULT TOPSIS
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
}
