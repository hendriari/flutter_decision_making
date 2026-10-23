import 'decision_input_exception.dart';
import 'weighted_decision_alternative.dart';
import 'weighted_decision_criteria.dart';
import 'weighted_decision_matrix.dart';
import 'weighted_decision_rating.dart';

/// Helper and validation utilities for weighted decision matrices (SAW and TOPSIS).
class MatrixValidator {
  /// Validates basic criteria and alternatives input constraints.
  static void validateInputs({
    required List<WeightedDecisionAlternative> alternatives,
    required List<WeightedDecisionCriteria> criteria,
  }) {
    if (alternatives.isEmpty) {
      throw DecisionInputException('Alternatives list cannot be empty!');
    }
    if (criteria.isEmpty) {
      throw DecisionInputException('Criteria list cannot be empty!');
    }
    if (alternatives.length > 100 || criteria.length > 100) {
      throw DecisionInputException(
          'Maximum 100 alternatives or criteria allowed!');
    }

    final totalWeight = criteria.fold<double>(
      0.0,
      (sum, item) {
        if (item.weightPercent < 0) {
          throw DecisionInputException(
              'Criteria weight cannot be negative: ${item.name}');
        }
        return sum + item.weightPercent;
      },
    );

    if (totalWeight <= 0) {
      throw DecisionInputException(
          'Total criteria weight must be greater than zero!');
    }
  }

  /// Validates that all ratings have valid values within criteria boundaries.
  static void validateMatrixValues(List<WeightedDecisionMatrix> matrix) {
    if (matrix.isEmpty) {
      throw DecisionInputException('Matrix cannot be empty!');
    }

    for (final row in matrix) {
      for (final r in row.ratings) {
        final c = r.criteria;
        if (c == null) {
          throw DecisionInputException(
              'Rating on ${row.alternative.name} has no criteria.');
        }
        final val = r.value;
        if (val == null) {
          throw DecisionInputException(
              'Empty value in ${row.alternative.name} for criteria ${c.name}');
        }
        if (val > c.maxValue) {
          throw DecisionInputException(
              "The value '$val' for alternative '${row.alternative.name}' in criteria '${c.name}' is greater than the maximum (${c.maxValue}).");
        }
      }
    }
  }

  /// Normalizes criteria weights so that they sum to 100.0%.
  static List<WeightedDecisionMatrix> normalizeCriteriaWeights(
      List<WeightedDecisionMatrix> rawMatrix) {
    if (rawMatrix.isEmpty) return rawMatrix;

    final firstRow = rawMatrix.first;
    final totalWeight = firstRow.ratings.fold<double>(
      0.0,
      (sum, r) => sum + (r.criteria?.weightPercent ?? 0.0),
    );

    if (totalWeight == 100.0 || totalWeight <= 0.0) {
      return rawMatrix;
    }

    final weightRatio = 100.0 / totalWeight;

    return rawMatrix.map((matrix) {
      final updatedRatings = matrix.ratings.map((rating) {
        final criteria = rating.criteria;
        if (criteria == null) return rating;
        return rating.copyWith(
          criteria: criteria.copyWith(
            weightPercent: criteria.weightPercent * weightRatio,
          ),
        );
      }).toList();

      return matrix.copyWith(ratings: updatedRatings);
    }).toList();
  }

  /// Generates a complete decision matrix template for given alternatives and criteria.
  static List<WeightedDecisionMatrix> generateMatrix({
    required List<WeightedDecisionAlternative> alternatives,
    required List<WeightedDecisionCriteria> criteria,
  }) {
    validateInputs(alternatives: alternatives, criteria: criteria);

    final result = <WeightedDecisionMatrix>[];
    for (int i = 0; i < alternatives.length; i++) {
      final alt = alternatives[i];
      final altId = alt.id ?? 'alt_${i + 1}';
      final resolvedAlt = alt.copyWith(id: altId);

      final ratings = <WeightedDecisionRating>[];
      for (int j = 0; j < criteria.length; j++) {
        final crit = criteria[j];
        final critId = crit.id ?? 'crit_${j + 1}';
        final resolvedCrit = crit.copyWith(id: critId);

        ratings.add(
          WeightedDecisionRating(
            id: 'rating_${altId}_$critId',
            criteria: resolvedCrit,
            value: 0.0,
          ),
        );
      }

      result.add(
        WeightedDecisionMatrix(
          id: 'matrix_$altId',
          alternative: resolvedAlt,
          ratings: ratings,
        ),
      );
    }

    return result;
  }
}
