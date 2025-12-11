import 'dart:math' as math;

import 'package:flutter_decision_making/feature/saw/data/dto/saw_matrix_dto.dart';
import 'package:flutter_decision_making/feature/saw/data/dto/saw_rating_dto.dart';

/// Normalizes SAW (Simple Additive Weighting) matrix in an isolate.
///
/// This function runs in a separate isolate to avoid blocking the UI thread
/// when performing calculations on large datasets.
///
/// The normalization process uses the following formulas:
/// - For benefit criteria: R = X / X_max
/// - For cost criteria: R = X_min / X
///
/// Where:
/// - R is the normalized rating value
/// - X is the original rating value
/// - X_max is the maximum value for that criteria
/// - X_min is the minimum value for that criteria
///
/// [data] Map containing key 'matrix' with value `List<Map<String, dynamic>>`
///        which is the JSON representation of list of SawMatrixDto
///
/// Returns `List<Map<String, dynamic>>` normalized result in JSON format
///
/// Throws [Exception] if:
/// - Matrix is empty
/// - An error occurs during normalization
Future<List<Map<String, dynamic>>> normalizeSawMatrixIsolate({
  required Map<String, dynamic> data,
}) async {
  try {
    // Extract and validate matrix data from parameter
    final rawListMatrix = List<Map<String, dynamic>>.from(
      data['matrix'] ?? const [],
    );

    if (rawListMatrix.isEmpty) {
      throw Exception('Matrix cannot be empty!');
    }

    // Parse JSON into DTO objects
    final listMatrix =
        rawListMatrix.map((e) => SawMatrixDto.fromJson(e)).toList();

    // Calculate statistics (min/max) for each criteria
    final criteriaStats = _calculateCriteriaStatsIsolate(listMatrix);

    // Normalize each rating in the matrix
    final normalized = listMatrix.map((matrix) {
      final newRatings = matrix.ratings.map((rating) {
        return _normalizeRatingIsolate(rating, criteriaStats);
      }).toList();

      return matrix.copyWith(ratings: newRatings);
    }).toList();

    // Convert back to JSON format to send back to main isolate
    return normalized.map((e) => e.toJson()).toList();
  } catch (e) {
    throw Exception('Failed to normalize matrix in isolate: $e');
  }
}

/// Calculates statistics (minimum and maximum values) for each criteria.
///
/// This function iterates through all matrices to identify the minimum
/// and maximum values for each criteria. These statistics are required
/// for the rating normalization process.
///
/// [listMatrix] List of SawMatrixDto to calculate statistics from
///
/// Returns Map with key as criteria ID and value as _CriteriaStats object
///         containing min and max values
///
/// Throws [Exception] if a rating without criteria ID is found
Map<String, _CriteriaStats> _calculateCriteriaStatsIsolate(
  List<SawMatrixDto> listMatrix,
) {
  final stats = <String, _CriteriaStats>{};

  // Iterate through all matrices and their ratings
  for (var matrix in listMatrix) {
    for (var rating in matrix.ratings) {
      final cid = rating.criteria?.id;
      final val = rating.value ?? 0;

      // Validate criteria ID exists
      if (cid == null) {
        throw Exception('Found rating without criteria ID! Data invalid.');
      }

      // Initialize or update statistics for this criteria
      if (!stats.containsKey(cid)) {
        stats[cid] = _CriteriaStats(max: val, min: val);
      } else {
        stats[cid] = _CriteriaStats(
          max: math.max(stats[cid]!.max, val),
          min: math.min(stats[cid]!.min, val),
        );
      }
    }
  }

  return stats;
}

/// Normalizes a single rating based on criteria statistics.
///
/// The normalization method depends on the criteria type:
/// - Benefit criteria (higher is better): normalized = value / max_value
/// - Cost criteria (lower is better): normalized = min_value / value
///
/// Special cases:
/// - If max equals min: normalized value is set to 1.0
/// - If max is 0 for benefit criteria: normalized value is 0
///
/// [rating] The SawRatingDto to be normalized
/// [stats] Map containing min/max statistics for each criteria
///
/// Returns A new SawRatingDto with the normalized value
///
/// Throws [Exception] if:
/// - Rating or criteria ID is null
/// - No statistics found for the criteria
/// - Zero value found in cost criteria (invalid for cost normalization)
/// - Minimum value is zero in cost criteria (makes normalization impossible)
SawRatingDto _normalizeRatingIsolate(
  SawRatingDto rating,
  Map<String, _CriteriaStats> stats,
) {
  final cid = rating.criteria?.id;
  final val = rating.value ?? 0;

  // Validate required data
  if (cid == null || rating.criteria == null) {
    throw Exception(
        'Rating or criteria ID cannot be null during normalization!');
  }

  if (!stats.containsKey(cid)) {
    throw Exception('No statistics found for criteria ID: $cid');
  }

  final maxV = stats[cid]!.max;
  final minV = stats[cid]!.min;

  num newValue;

  // Handle edge case: all values are the same
  if (maxV == minV) {
    newValue = 1.0;
  }
  // Benefit criteria: higher values are better
  else if (rating.criteria!.isBenefit == true) {
    newValue = maxV == 0 ? 0 : val / maxV;
  }
  // Cost criteria: lower values are better
  else {
    // Validate cost criteria values
    if (val == 0) {
      throw Exception(
        'Zero value found in cost criteria: ${rating.criteria!.name}. '
        'Cost criteria must have positive values.',
      );
    }

    if (minV == 0) {
      throw Exception(
        'Minimum value is zero in cost criteria: ${rating.criteria!.name}. '
        'Cost criteria cannot have zero values as it makes normalization impossible.',
      );
    }

    newValue = minV / val;
  }

  return rating.copyWith(value: newValue);
}

/// Helper class to store criteria statistics.
///
/// Contains the minimum and maximum values found for a specific criteria
/// across all alternatives in the decision matrix.
///
/// [max] The maximum value found for this criteria
/// [min] The minimum value found for this criteria
class _CriteriaStats {
  final num max;
  final num min;

  _CriteriaStats({required this.max, required this.min});
}
