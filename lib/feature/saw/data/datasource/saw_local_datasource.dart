import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter_decision_making/core/decision_making_enums.dart';
import 'package:flutter_decision_making/core/decision_making_helper.dart';
import 'package:flutter_decision_making/core/decision_making_performance_profiling.dart';
import 'package:flutter_decision_making/core/isolate/decision_isolate_main.dart';
import 'package:flutter_decision_making/core/shared/dto/weighted_decision_matrix_dto.dart';
import 'package:flutter_decision_making/core/shared/interface/weighted_decision_matrix_mixin.dart';
import 'package:flutter_decision_making/core/shared/mapper/weighted_decision_matrix_mapper.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_alternative.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_criteria.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_matrix.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_rating.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_result.dart';

/// Abstract class defining the contract for SAW (Simple Additive Weighting) local data operations.
///
/// This datasource handles the core SAW algorithm operations including:
/// - Matrix generation from alternatives and criteria
/// - Matrix normalization
/// - Result calculation with ranking
abstract interface class SawLocalDatasource {
  /// Generates a SAW decision matrix from the given alternatives and criteria.
  ///
  /// The matrix represents all alternatives evaluated against all criteria,
  /// with each cell containing a rating value.
  ///
  /// **Parameters:**
  /// - [listAlternative]: List of alternatives to be evaluated
  /// - [listCriteria]: List of criteria for evaluation
  ///
  /// **Returns:** A list of [WeightedDecisionMatrix] objects, one for each alternative
  ///
  /// **Throws:**
  /// - Exception if alternatives or criteria lists are empty
  /// - Exception if criteria weights are invalid
  Future<List<WeightedDecisionMatrix>> generateSawMatrix({
    required List<WeightedDecisionAlternative> listAlternative,
    required List<WeightedDecisionCriteria> listCriteria,
  });

  /// Calculates the final SAW results from a decision matrix.
  ///
  /// This method performs the complete SAW calculation:
  /// 1. Validates input values
  /// 2. Normalizes the matrix
  /// 3. Calculates weighted scores
  /// 4. Ranks alternatives
  ///
  /// **Parameters:**
  /// - [matrix]: The decision matrix containing ratings for all alternatives
  ///
  /// **Returns:** A ranked list of [WeightedDecisionResult] objects
  ///
  /// **Throws:**
  /// - Exception if matrix is empty or contains invalid values
  Future<List<WeightedDecisionResult>> calculateSawResult({
    required List<WeightedDecisionMatrix> matrix,
  });

  /// Calculates results using an existing matrix with validation and fixing.
  ///
  /// This method is useful when working with pre-existing matrices that may
  /// need validation or weight normalization before calculation.
  ///
  /// **Parameters:**
  /// - [matrix]: The existing decision matrix to calculate from
  ///
  /// **Returns:** A ranked list of [WeightedDecisionResult] objects
  ///
  /// **Throws:**
  /// - Exception if matrix is empty or contains invalid data
  Future<List<WeightedDecisionResult>> calculateResultWithExistingMatrix({
    required List<WeightedDecisionMatrix> matrix,
  });
}

/// Implementation of [SawLocalDatasource] that handles SAW algorithm operations.
///
/// This implementation supports:
/// - Automatic weight normalization
/// - Isolate-based processing for large datasets
/// - Performance profiling
/// - Comprehensive input validation
///
/// **Example usage:**
/// ```dart
/// final datasource = SawLocalDatasourceImpl();
///
/// // Generate matrix
/// final matrix = await datasource.generateSawMatrix(
///   listAlternative: alternatives,
///   listCriteria: criteria,
/// );
///
/// // Calculate results
/// final results = await datasource.calculateSawResult(matrix: matrix);
/// ```
class SawLocalDatasourceImpl with WeightedDecisionMatrixInterface implements SawLocalDatasource {
  final DecisionMakingHelper _helper;
  final DecisionIsolateMain _isolate;

  @override
  DecisionMakingHelper get helper => _helper;

  @override
  DecisionIsolateMain get isolate => _isolate;

  /// Creates an instance of [SawLocalDatasourceImpl].
  ///
  /// **Parameters:**
  /// - [helper]: Helper for utility functions (defaults to new instance)
  /// - [stopwatch]: Stopwatch for performance measurement (currently unused)
  /// - [isolate]: Isolate manager for heavy computations (defaults to new instance)
  SawLocalDatasourceImpl({
    DecisionMakingHelper? helper,
    Stopwatch? stopwatch,
    DecisionIsolateMain? isolate,
  })  : _helper = helper ?? DecisionMakingHelper(),
        _isolate = isolate ?? DecisionIsolateMain();

  /// [MATRIX]
  /// GENERATE SAW MATRIX
  @override
  Future<List<WeightedDecisionMatrix>> generateSawMatrix({
    required List<WeightedDecisionAlternative> listAlternative,
    required List<WeightedDecisionCriteria> listCriteria,
  }) async {
    startPerformanceProfiling('Generate SAW pairwise matrix');
    try {
      validateInputs(listAlternative, listCriteria);

      final normalizedCriteria = normalizeCriteriaWeights(listCriteria);
      final updateAlternative = ensureIdsForAlternatives(listAlternative);
      final updateCriteria = ensureIdsForCriteria(normalizedCriteria);

      List<WeightedDecisionMatrix> result = [];
      final canUseIsolate = !kIsWeb &&
          (updateAlternative.length > 10 || updateCriteria.length > 25);
          // (updateAlternative.length > 80 || updateCriteria.length > 25);

      if (canUseIsolate) {
        result = await generateMatrixWithIsolate(
          DecisionAlgorithm.saw,
          SawProcessingIsolateCommand.generateMatrix,
          updateAlternative,
          updateCriteria,
        );
      } else {
        result = generateMatrixDirectly(updateAlternative, updateCriteria);
      }

      return result;
    } catch (e, s) {
      debugPrint('SAW Matrix Error: $e\n$s');
      rethrow;
    } finally {
      endPerformanceProfiling('Generate SAW pairwise matrix');
    }
  }

  /// ==========================================================================
  /// [NORMALIZE]

  /// Normalizes the decision matrix.
  ///
  /// Normalization converts all ratings to a comparable scale (0-1).
  /// For benefit criteria: normalized = value / max_value
  /// For cost criteria: normalized = min_value / value
  ///
  /// **Parameters:**
  /// - [listMatrix]: The matrix to normalize
  ///
  /// **Returns:** Normalized matrix
  ///
  /// **Throws:**
  /// - Exception if matrix is empty
  /// - Exception if cost criteria contain zero values
  Future<List<WeightedDecisionMatrix>> _normalizeMatrix(List<WeightedDecisionMatrix> listMatrix) async {
    startPerformanceProfiling('normalize matrix saw');
    try {
      if (listMatrix.isEmpty) {
        throw Exception('Matrix cannot be empty!');
      }

      var normalized = <WeightedDecisionMatrix>[];
      final canUseIsolate = !kIsWeb &&
          (listMatrix.length > 80 || listMatrix.first.ratings.length > 25);

      if (canUseIsolate) {
        normalized = await _normalizeMatrixWithIsolate(listMatrix);
      } else {
        normalized = _normalizeMatrixDirectly(listMatrix);
      }

      return normalized;
    } catch (e) {
      rethrow;
    } finally {
      endPerformanceProfiling('normalize matrix saw');
    }
  }

  /// Normalizes matrix using isolate for large datasets.
  ///
  /// **Parameters:**
  /// - [listMatrix]: Matrix to normalize
  ///
  /// **Returns:** Normalized matrix
  Future<List<WeightedDecisionMatrix>> _normalizeMatrixWithIsolate(
      List<WeightedDecisionMatrix> listMatrix) async {
    final rawData = await _isolate.runTask(
      DecisionAlgorithm.saw,
      SawProcessingIsolateCommand.normalizeMatrix,
      {
        "matrix": listMatrix.map((e) => e.toDto().toJson()).toList(),
      },
    );

    final parsed =
        (rawData as List).map((e) => WeightedDecisionMatrixDto.fromJson(e)).toList();

    return parsed.map((e) => e.toEntity()).toList();
  }

  /// Normalizes matrix directly without using isolate.
  ///
  /// Calculates min/max values for each criteria, then normalizes
  /// each rating based on whether the criteria is benefit or cost type.
  ///
  /// **Parameters:**
  /// - [listMatrix]: Matrix to normalize
  ///
  /// **Returns:** Normalized matrix
  List<WeightedDecisionMatrix> _normalizeMatrixDirectly(List<WeightedDecisionMatrix> listMatrix) {
    final criteriaStats = _calculateCriteriaStats(listMatrix);

    return listMatrix.map((matrix) {
      final newRatings = matrix.ratings.map((rating) {
        return _normalizeRating(rating, criteriaStats);
      }).toList();

      return matrix.copyWith(ratings: newRatings);
    }).toList();
  }

  /// Calculates minimum and maximum values for each criteria across all alternatives.
  ///
  /// These statistics are needed for normalization calculations.
  ///
  /// **Parameters:**
  /// - [listMatrix]: Matrix to analyze
  ///
  /// **Returns:** Map of criteria ID to their min/max statistics
  ///
  /// **Throws:**
  /// - Exception if a rating is found without criteria ID
  Map<String, _CriteriaStats> _calculateCriteriaStats(
      List<WeightedDecisionMatrix> listMatrix) {
    final stats = <String, _CriteriaStats>{};

    for (var matrix in listMatrix) {
      for (var rating in matrix.ratings) {
        final cid = rating.criteria?.id;
        final val = rating.value ?? 0;

        if (cid == null) {
          throw Exception('Found rating without criteria ID! Data invalid.');
        }

        if (!stats.containsKey(cid)) {
          stats[cid] = _CriteriaStats(max: val, min: val);
        } else {
          stats[cid] = _CriteriaStats(
            max: val > stats[cid]!.max ? val : stats[cid]!.max,
            min: val < stats[cid]!.min ? val : stats[cid]!.min,
          );
        }
      }
    }

    return stats;
  }

  /// Normalizes a single rating value based on its criteria type and statistics.
  ///
  /// **Normalization formulas:**
  /// - Benefit criteria: normalized = value / max_value
  /// - Cost criteria: normalized = min_value / value
  /// - If all values are equal: normalized = 1
  ///
  /// **Parameters:**
  /// - [rating]: The rating to normalize
  /// - [stats]: Statistics for all criteria
  ///
  /// **Returns:** Normalized rating
  ///
  /// **Throws:**
  /// - Exception if zero value found in cost criteria
  WeightedDecisionRating _normalizeRating(
    WeightedDecisionRating rating,
    Map<String, _CriteriaStats> stats,
  ) {
    final cid = rating.criteria?.id;
    final val = rating.value ?? 0;

    if (cid == null || rating.criteria == null) {
      return rating;
    }

    if (rating.criteria!.isBenefit == false && val == 0) {
      throw Exception(
        'Zero value found in cost criteria: ${rating.criteria!.name}. '
        'Cost criteria must have positive values.',
      );
    }

    final maxV = stats[cid]!.max;
    final minV = stats[cid]!.min;

    num newValue;

    if (maxV == minV) {
      newValue = 1;
    } else if (rating.criteria!.isBenefit == true) {
      newValue = maxV == 0 ? 0 : val / maxV;
    } else {
      newValue = minV / val;
    }

    return rating.copyWith(value: newValue);
  }

  /// ==========================================================================
  /// [RESULT]

  /// Calculates final SAW scores and ranks alternatives.
  ///
  /// For each alternative, calculates:
  /// - Weighted sum: Σ(normalized_value × weight)
  /// - Rank based on scores (highest score = rank 1)
  ///
  /// **Parameters:**
  /// - [normalizedMatrix]: The normalized decision matrix
  ///
  /// **Returns:** Sorted list of results with scores and ranks
  ///
  /// **Throws:**
  /// - Exception if matrix is empty
  /// - Exception if rating without criteria is found
  Future<List<WeightedDecisionResult>> _calculateSawScore(
      List<WeightedDecisionMatrix> normalizedMatrix) async {
    startPerformanceProfiling('Calculate SAW result');
    try {
      if (normalizedMatrix.isEmpty) {
        throw Exception('Normalized matrix cannot be empty!');
      }

      var sawResult = <WeightedDecisionResult>[];

      for (var matrix in normalizedMatrix) {
        double totalScore = 0;

        for (var rating in matrix.ratings) {
          if (rating.criteria == null) {
            throw Exception(
              'Rating without criteria found for alternative: ${matrix.alternative.name}',
            );
          }

          final weight = rating.criteria!.weightPercent / 100;
          final value = rating.value ?? 0;

          totalScore += value * weight;
        }

        sawResult.add(WeightedDecisionResult(
          alternative: matrix.alternative,
          score: totalScore,
          rank: 0,
        ));
      }

      sawResult.sort((a, b) => b.score.compareTo(a.score));

      for (int i = 0; i < sawResult.length; i++) {
        sawResult[i] = sawResult[i].copyWith(rank: i + 1);
      }

      return sawResult;
    } catch (e) {
      rethrow;
    } finally {
      endPerformanceProfiling('Calculate SAW result');
    }
  }

  @override
  Future<List<WeightedDecisionResult>> calculateSawResult({
    required List<WeightedDecisionMatrix> matrix,
  }) async {
    startPerformanceProfiling('Combined all method SAW algorithm');
    try {
      await _validateMaxInputValue(matrix);

      final normalized = await _normalizeMatrix(matrix);
      final result = await _calculateSawScore(normalized);

      return result;
    } catch (e) {
      rethrow;
    } finally {
      endPerformanceProfiling('Combined all method SAW algorithm');
    }
  }

  /// ==========================================================================
  /// [RESULT WITH CRITERIA]

  @override
  Future<List<WeightedDecisionResult>> calculateResultWithExistingMatrix({
    required List<WeightedDecisionMatrix> matrix,
  }) async {
    startPerformanceProfiling('Calculate result with existing matrix');
    try {
      if (matrix.isEmpty) {
        throw Exception("Matrix cannot be empty!");
      }

      await _validateMaxInputValue(matrix);

      final validatedMatrix = _validateAndFixMatrix(matrix);

      final normalizedMatrix = await _normalizeMatrix(validatedMatrix);
      final sawResult = await _calculateSawScore(normalizedMatrix);

      return sawResult;
    } catch (e) {
      rethrow;
    } finally {
      endPerformanceProfiling('Calculate result with existing matrix');
    }
  }

  /// Validates that all rating values do not exceed their criteria's maximum value.
  ///
  /// **Parameters:**
  /// - [matrix]: Matrix to validate
  ///
  /// **Throws:**
  /// - Exception if any rating is missing criteria
  /// - Exception if any rating value is null
  /// - Exception if any value exceeds its criteria's maximum
  Future<void> _validateMaxInputValue(List<WeightedDecisionMatrix> matrix) async {
    for (var e in matrix) {
      for (var r in e.ratings) {
        final criteria = r.criteria;

        if (criteria == null) {
          throw Exception("Rating on ${e.alternative.name} has no criteria.");
        }

        final value = r.value;

        if (value == null) {
          throw Exception(
              "Empty value in ${e.alternative.name} for criteria ${criteria.name}");
        }

        if (value > criteria.maxValue) {
          throw Exception(
              "The value '$value' for alternative '${e.alternative.name}' in criteria '${criteria.name}' "
              "is greater than the maximum (${criteria.maxValue}).");
        }
      }
    }
  }

  /// Validates and repairs matrix data structure.
  ///
  /// This method ensures:
  /// - All entities have IDs
  /// - Criteria weights are normalized
  /// - Data structure is consistent
  ///
  /// **Parameters:**
  /// - [matrix]: Matrix to validate and fix
  ///
  /// **Returns:** Validated and fixed matrix
  List<WeightedDecisionMatrix> _validateAndFixMatrix(List<WeightedDecisionMatrix> matrix) {
    return matrix.map((m) {
      var updatedMatrix = _ensureMatrixId(m);

      updatedMatrix = _ensureAlternativeId(updatedMatrix);

      updatedMatrix = _ensureRatingIds(updatedMatrix);

      updatedMatrix = _normalizeMatrixWeights(updatedMatrix);

      return updatedMatrix;
    }).toList();
  }

  /// Ensures the matrix has a unique ID.
  ///
  /// **Parameters:**
  /// - [matrix]: Matrix to check
  ///
  /// **Returns:** Matrix with guaranteed ID
  WeightedDecisionMatrix _ensureMatrixId(WeightedDecisionMatrix matrix) {
    if (matrix.id == null || matrix.id!.isEmpty) {
      return matrix.copyWith(id: _helper.getCustomUniqueId());
    }
    return matrix;
  }

  /// Ensures the alternative in the matrix has a unique ID.
  ///
  /// **Parameters:**
  /// - [matrix]: Matrix to check
  ///
  /// **Returns:** Matrix with alternative having guaranteed ID
  WeightedDecisionMatrix _ensureAlternativeId(WeightedDecisionMatrix matrix) {
    if (matrix.alternative.id == null || matrix.alternative.id!.isEmpty) {
      final updatedAlternative =
          matrix.alternative.copyWith(id: _helper.getCustomUniqueId());
      return matrix.copyWith(alternative: updatedAlternative);
    }
    return matrix;
  }

  /// Ensures all ratings and their criteria have unique IDs.
  ///
  /// **Parameters:**
  /// - [matrix]: Matrix to check
  ///
  /// **Returns:** Matrix with all ratings having guaranteed IDs
  WeightedDecisionMatrix _ensureRatingIds(WeightedDecisionMatrix matrix) {
    final needsUpdate = matrix.ratings.any((d) =>
        d.id == null ||
        d.id!.isEmpty ||
        d.criteria?.id == null ||
        d.criteria!.id!.isEmpty);

    if (!needsUpdate) {
      return matrix;
    }

    final updatedRatings = matrix.ratings.map((rating) {
      var updatedRating = rating;

      if (rating.id == null || rating.id!.isEmpty) {
        updatedRating = rating.copyWith(id: _helper.getCustomUniqueId());
      }

      if (rating.criteria?.id == null || rating.criteria!.id!.isEmpty) {
        final updatedCriteria =
            rating.criteria?.copyWith(id: _helper.getCustomUniqueId());
        updatedRating = updatedRating.copyWith(criteria: updatedCriteria);
      }

      return updatedRating;
    }).toList();

    return matrix.copyWith(ratings: updatedRatings);
  }

  /// Normalizes criteria weights within the matrix to sum to 100%.
  ///
  /// Ensures all criteria weights are consistent and properly normalized.
  ///
  /// **Parameters:**
  /// - [matrix]: Matrix to normalize
  ///
  /// **Returns:** Matrix with normalized criteria weights
  ///
  /// **Throws:**
  /// - Exception if total weight is zero
  /// - Exception if any weight is negative
  WeightedDecisionMatrix _normalizeMatrixWeights(WeightedDecisionMatrix matrix) {
    final totalWeight = matrix.ratings
        .fold<double>(0, (a, b) => a + (b.criteria?.weightPercent ?? 0));

    if (totalWeight == 0) {
      throw Exception("Total criteria weight cannot be zero.");
    }

    if (totalWeight == 100) {
      return matrix;
    }

    dev.log(
      "[SAW] Total weight = $totalWeight, auto-normalizing to 100%.",
      name: "DECISION MAKING",
    );

    final normalizedRatings = matrix.ratings.map((rating) {
      final currentWeight = rating.criteria?.weightPercent ?? 0;

      if (currentWeight < 0) {
        throw Exception(
          "Weight cannot be negative for criteria: ${rating.criteria?.name}",
        );
      }

      final normalized = (currentWeight / totalWeight) * 100;
      final updatedCriteria =
          rating.criteria?.copyWith(weightPercent: normalized);

      return rating.copyWith(criteria: updatedCriteria);
    }).toList();

    return matrix.copyWith(ratings: normalizedRatings);
  }
}

/// Helper class to store minimum and maximum statistics for a criteria.
///
/// Used during the normalization process to calculate normalized values
/// based on the range of values for each criteria.
class _CriteriaStats {
  /// Maximum value found for this criteria across all alternatives
  final num max;

  /// Minimum value found for this criteria across all alternatives
  final num min;

  _CriteriaStats({required this.max, required this.min});
}
