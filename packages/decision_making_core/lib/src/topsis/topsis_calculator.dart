import 'dart:math' as math;

import '../common/matrix_validator.dart';
import '../common/weighted_decision_criteria.dart';
import '../common/weighted_decision_matrix.dart';
import '../common/weighted_decision_result.dart';
import 'topsis_ideal_value.dart';
import 'topsis_matrix.dart';
import 'topsis_raw_matrix.dart';

/// Pure Dart, synchronous calculation engine for TOPSIS (Technique for Order Preference by Similarity to Ideal Solution).
class TopsisCalculator {
  /// Normalizes a decision matrix using Euclidean vector normalization.
  ///
  /// Formula: $r_{ij} = x_{ij} / \sqrt{\sum_{k=1}^m x_{kj}^2}$
  static List<WeightedDecisionMatrix> normalizeEuclidean({
    required List<WeightedDecisionMatrix> matrix,
    required List<WeightedDecisionCriteria> criteria,
  }) {
    if (matrix.isEmpty) {
      throw Exception('Matrix cannot be empty!');
    }
    if (criteria.isEmpty) {
      throw Exception('Criteria list cannot be empty!');
    }

    final dividers = <String, double>{};
    for (final crt in criteria) {
      final crtId = crt.id ?? '';
      double sumSquares = 0.0;
      for (final alt in matrix) {
        final rating = alt.ratings.firstWhere(
          (r) => r.criteria?.id == crtId,
        );
        final val = rating.value ?? 0.0;
        sumSquares += math.pow(val, 2);
      }
      dividers[crtId] = math.sqrt(sumSquares);
    }

    return matrix.map((alt) {
      final normalizedRatings = alt.ratings.map((r) {
        final divider = dividers[r.criteria?.id] ?? 1.0;
        return r.copyWith(
          value: divider == 0.0 ? 0.0 : (r.value ?? 0.0) / divider,
        );
      }).toList();

      return alt.copyWith(ratings: normalizedRatings);
    }).toList();
  }

  /// Calculates the weighted normalized decision matrix.
  ///
  /// Formula: $v_{ij} = r_{ij} \times (w_j / 100.0)$
  static List<WeightedDecisionMatrix> weightMatrix(
      List<WeightedDecisionMatrix> normalizedMatrix) {
    return normalizedMatrix.map((row) {
      final updatedRatings = row.ratings.map((r) {
        final weight = (r.criteria?.weightPercent ?? 0.0) / 100.0;
        final value = (r.value ?? 0.0) * weight;
        return r.copyWith(value: value);
      }).toList();

      return row.copyWith(ratings: updatedRatings);
    }).toList();
  }

  /// Identifies the Positive Ideal Solution (A+) and Negative Ideal Solution (A-).
  ///
  /// - For Benefit: $A^+ = \max(v_{ij})$, $A^- = \min(v_{ij})$
  /// - For Cost: $A^+ = \min(v_{ij})$, $A^- = \max(v_{ij})$
  static TopsisIdealValue calculateIdealSolutions({
    required List<WeightedDecisionMatrix> weightedMatrix,
    required List<WeightedDecisionCriteria> criteria,
  }) {
    final positiveIdeal = <String, double>{};
    final negativeIdeal = <String, double>{};

    for (final crt in criteria) {
      final crtId = crt.id!;
      final values = weightedMatrix.map((m) {
        final rating = m.ratings.firstWhere((r) => r.criteria?.id == crtId);
        return (rating.value ?? 0.0).toDouble();
      }).toList();

      final maxVal = values.reduce(math.max);
      final minVal = values.reduce(math.min);

      if (crt.isBenefit) {
        positiveIdeal[crtId] = maxVal;
        negativeIdeal[crtId] = minVal;
      } else {
        positiveIdeal[crtId] = minVal;
        negativeIdeal[crtId] = maxVal;
      }
    }

    return TopsisIdealValue(
      positiveIdeal: positiveIdeal,
      negativeIdeal: negativeIdeal,
    );
  }

  /// Calculates separation measures from ideal solutions using Euclidean distance.
  ///
  /// - $D_i^+ = \sqrt{\sum (v_{ij} - A_j^+)^2}$
  /// - $D_i^- = \sqrt{\sum (v_{ij} - A_j^-)^2}$
  static List<TopsisMatrix> calculateSeparationDistances({
    required List<WeightedDecisionMatrix> weightedMatrix,
    required TopsisIdealValue idealValue,
  }) {
    return weightedMatrix.map((alt) {
      double dPlus = 0.0;
      double dMinus = 0.0;

      for (final r in alt.ratings) {
        final crtId = r.criteria!.id!;
        final value = r.value ?? 0.0;

        final aPlus = idealValue.positiveIdeal[crtId] ?? 0.0;
        final aMinus = idealValue.negativeIdeal[crtId] ?? 0.0;

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
  }

  /// Calculates the relative closeness to the ideal solution and assigns ranks.
  static List<WeightedDecisionResult> calculateRelativeCloseness(
      List<TopsisMatrix> distanceMatrix) {
    final results = distanceMatrix.map((alt) {
      final dPlus = alt.distancePlus;
      final dMinus = alt.distanceMinus;
      final denominator = dPlus + dMinus;
      final score = denominator == 0.0 ? 0.5 : dMinus / denominator;

      return WeightedDecisionResult(
        alternative: alt.alternative,
        score: score,
        rank: 0,
      );
    }).toList();

    results.sort((a, b) => b.score.compareTo(a.score));

    for (int i = 0; i < results.length; i++) {
      results[i] = results[i].copyWith(rank: i + 1);
    }

    return results;
  }

  /// Executes full end-to-end TOPSIS calculation and returns ranked results.
  static List<WeightedDecisionResult> calculate(TopsisRawMatrix rawMatrix) {
    MatrixValidator.validateMatrixValues(rawMatrix.matrixs);

    final normalizedEuclidean = normalizeEuclidean(
      matrix: rawMatrix.matrixs,
      criteria: rawMatrix.criterias,
    );

    final weightedMatrix = weightMatrix(normalizedEuclidean);

    final idealSolutions = calculateIdealSolutions(
      weightedMatrix: weightedMatrix,
      criteria: rawMatrix.criterias,
    );

    final distanceMatrix = calculateSeparationDistances(
      weightedMatrix: weightedMatrix,
      idealValue: idealSolutions,
    );

    return calculateRelativeCloseness(distanceMatrix);
  }
}
