import '../common/matrix_validator.dart';
import '../common/weighted_decision_matrix.dart';
import '../common/weighted_decision_rating.dart';
import '../common/weighted_decision_result.dart';
import '../sensitivity/sensitivity_analysis_result.dart';
import '../sensitivity/sensitivity_calculator.dart';
import 'saw_detailed_result.dart';

class _CriteriaStats {
  final double max;
  final double min;

  _CriteriaStats({required this.max, required this.min});
}

/// Pure Dart, synchronous calculation engine for the Simple Additive Weighting (SAW) algorithm.
class SawCalculator {
  /// Normalizes a decision matrix according to SAW benefit/cost rules.
  ///
  /// - For benefit criteria: $r_{ij} = x_{ij} / \max_k(x_{kj})$
  /// - For cost criteria: $r_{ij} = \min_k(x_{kj}) / x_{ij}$
  /// - When $\max_k(x_{kj}) == \min_k(x_{kj})$, $r_{ij} = 1.0$.
  static List<WeightedDecisionMatrix> normalize(
      List<WeightedDecisionMatrix> matrix) {
    if (matrix.isEmpty) {
      throw Exception('Matrix cannot be empty!');
    }

    final stats = _calculateCriteriaStats(matrix);

    return matrix.map((row) {
      final newRatings = row.ratings.map((rating) {
        return _normalizeRating(rating, stats);
      }).toList();

      return row.copyWith(ratings: newRatings);
    }).toList();
  }

  /// Calculates final SAW scores and ranks alternatives from an already normalized matrix.
  static List<WeightedDecisionResult> calculateScores(
      List<WeightedDecisionMatrix> normalizedMatrix) {
    if (normalizedMatrix.isEmpty) {
      throw Exception('Normalized matrix cannot be empty!');
    }

    final results = <WeightedDecisionResult>[];

    for (final row in normalizedMatrix) {
      double totalScore = 0.0;

      for (final rating in row.ratings) {
        final criteria = rating.criteria;
        if (criteria == null) {
          throw Exception(
            'Rating without criteria found for alternative: ${row.alternative.name}',
          );
        }

        final weight = criteria.weightPercent / 100.0;
        final value = rating.value ?? 0.0;
        totalScore += value * weight;
      }

      results.add(
        WeightedDecisionResult(
          alternative: row.alternative,
          score: totalScore,
          rank: 0,
        ),
      );
    }

    results.sort((a, b) => b.score.compareTo(a.score));

    for (int i = 0; i < results.length; i++) {
      results[i] = results[i].copyWith(rank: i + 1);
    }

    return results;
  }

  /// Calculates final SAW scores and ranks alternatives.
  ///
  /// Steps:
  /// 1. Validates matrix ratings and criteria boundaries.
  /// 2. Normalizes criteria weights so they sum to 100%.
  /// 3. Normalizes rating values according to SAW formula.
  /// 4. Computes weighted sum: $S_i = \sum_j (r_{ij} \times w_j / 100.0)$.
  /// 5. Sorts descending by score and assigns sequential ranks (1..n).
  static List<WeightedDecisionResult> calculate(
      List<WeightedDecisionMatrix> rawMatrix) {
    MatrixValidator.validateMatrixValues(rawMatrix);

    final normalizedWeightMatrix =
        MatrixValidator.normalizeCriteriaWeights(rawMatrix);
    final normalizedMatrix = normalize(normalizedWeightMatrix);

    return calculateScores(normalizedMatrix);
  }

  /// Calculates detailed SAW results including all intermediate steps:
  /// normalized weights, normalized matrix, weighted matrix, and final ranked scores.
  static SawDetailedResult calculateDetailed(
      List<WeightedDecisionMatrix> rawMatrix) {
    MatrixValidator.validateMatrixValues(rawMatrix);

    final normalizedWeightMatrix =
        MatrixValidator.normalizeCriteriaWeights(rawMatrix);

    final normalizedWeights = <String, double>{};
    if (normalizedWeightMatrix.isNotEmpty) {
      for (final rating in normalizedWeightMatrix.first.ratings) {
        final c = rating.criteria;
        if (c != null) {
          final id = c.id;
          if (id == null) {
            throw Exception('Found rating without criteria ID! Data invalid.');
          }
          normalizedWeights[id] = c.weightPercent / 100.0;
        }
      }
    }

    final normalizedMatrix = normalize(normalizedWeightMatrix);

    final weightedMatrix = normalizedMatrix.map((row) {
      final weightedRatings = row.ratings.map((rating) {
        final c = rating.criteria;
        final w = (c?.weightPercent ?? 0.0) / 100.0;
        final r = rating.value ?? 0.0;
        return rating.copyWith(value: r * w);
      }).toList();
      return row.copyWith(ratings: weightedRatings);
    }).toList();

    final scores = calculateScores(normalizedMatrix);

    return SawDetailedResult(
      initialMatrix: rawMatrix,
      normalizedMatrix: normalizedMatrix,
      normalizedWeights: normalizedWeights,
      weightedMatrix: weightedMatrix,
      scores: scores,
    );
  }

  /// Performs weight sensitivity analysis and rank reversal detection for SAW.
  ///
  /// - Tests +/- [delta] (default 10% relative, `0.10`) perturbation on each criterion.
  /// - Tests rank reversal by removing each alternative (for n >= 3).
  static SensitivityAnalysisResult analyzeSensitivity(
    List<WeightedDecisionMatrix> rawMatrix, {
    double delta = 0.1,
  }) {
    MatrixValidator.validateMatrixValues(rawMatrix);

    final normalizedWeightMatrix =
        MatrixValidator.normalizeCriteriaWeights(rawMatrix);

    final criteriaIds = <String>[];
    final normalizedWeights = <String, double>{};

    for (final rating in normalizedWeightMatrix.first.ratings) {
      final c = rating.criteria;
      if (c != null) {
        final id = c.id;
        if (id == null) {
          throw Exception('Found rating without criteria ID! Data invalid.');
        }
        criteriaIds.add(id);
        normalizedWeights[id] = c.weightPercent / 100.0;
      }
    }

    final alternativeIds = <String>[];
    for (final row in rawMatrix) {
      final id = row.alternative.id;
      if (id == null) {
        throw Exception('Found alternative without ID! Data invalid.');
      }
      alternativeIds.add(id);
    }

    return SensitivityCalculator.run(
      alternativeIds: alternativeIds,
      criteriaIds: criteriaIds,
      normalizedWeights: normalizedWeights,
      calculateWithWeights: (weights) {
        final perturbed = rawMatrix.map((row) {
          final newRatings = row.ratings.map((r) {
            final cid = r.criteria!.id!;
            final w = (weights[cid] ?? 0.0) * 100.0;
            return r.copyWith(
              criteria: r.criteria!.copyWith(weightPercent: w),
            );
          }).toList();
          return row.copyWith(ratings: newRatings);
        }).toList();

        final results = calculate(perturbed);
        return {for (final r in results) r.alternative.id!: r.score};
      },
      calculateWithoutAlternative: (removedId) {
        final subMatrix = rawMatrix
            .where((row) => row.alternative.id != removedId)
            .toList();
        final results = calculate(subMatrix);
        return {for (final r in results) r.alternative.id!: r.score};
      },
      delta: delta,
    );
  }

  static Map<String, _CriteriaStats> _calculateCriteriaStats(
      List<WeightedDecisionMatrix> matrix) {
    final stats = <String, _CriteriaStats>{};

    for (final row in matrix) {
      for (final rating in row.ratings) {
        final cid = rating.criteria?.id;
        final val = rating.value ?? 0.0;

        if (cid == null) {
          throw Exception('Found rating without criteria ID! Data invalid.');
        }

        final current = stats[cid];
        if (current == null) {
          stats[cid] = _CriteriaStats(max: val, min: val);
        } else {
          stats[cid] = _CriteriaStats(
            max: val > current.max ? val : current.max,
            min: val < current.min ? val : current.min,
          );
        }
      }
    }

    return stats;
  }

  static WeightedDecisionRating _normalizeRating(
    WeightedDecisionRating rating,
    Map<String, _CriteriaStats> stats,
  ) {
    final criteria = rating.criteria;
    final cid = criteria?.id;
    final val = rating.value ?? 0.0;

    if (cid == null || criteria == null) {
      return rating;
    }

    if (!criteria.isBenefit && val == 0.0) {
      throw Exception(
        'Zero value found in cost criteria: ${criteria.name}. '
        'Cost criteria must have positive values.',
      );
    }

    final stat = stats[cid]!;
    final maxV = stat.max;
    final minV = stat.min;

    double newValue;
    if (maxV == minV) {
      newValue = 1.0;
    } else if (criteria.isBenefit) {
      newValue = maxV == 0.0 ? 0.0 : val / maxV;
    } else {
      newValue = minV / val;
    }

    return rating.copyWith(value: newValue);
  }
}
