import 'dart:math' as math;

import 'package:flutter_decision_making/feature/saw/data/dto/saw_matrix_dto.dart';
import 'package:flutter_decision_making/feature/saw/data/dto/saw_rating_dto.dart';

Future<List<Map<String, dynamic>>> normalizeSawMatrixIsolate({
  required Map<String, dynamic> data,
}) async {
  try {
    final rawListMatrix = List<Map<String, dynamic>>.from(
      data['matrix'] ?? const [],
    );

    if (rawListMatrix.isEmpty) {
      throw Exception('Matrix cannot be empty!');
    }

    final listMatrix =
        rawListMatrix.map((e) => SawMatrixDto.fromJson(e)).toList();

    // Calculate min/max for each criteria
    final criteriaStats = _calculateCriteriaStatsIsolate(listMatrix);

    // Normalize each matrix
    final normalized = listMatrix.map((matrix) {
      final newRatings = matrix.ratings.map((rating) {
        return _normalizeRatingIsolate(rating, criteriaStats);
      }).toList();

      return matrix.copyWith(ratings: newRatings);
    }).toList();

    return normalized.map((e) => e.toJson()).toList();
  } catch (e) {
    throw Exception('Failed to normalize matrix in isolate: $e');
  }
}

/// Calculate min/max statistics for each criteria
Map<String, _CriteriaStats> _calculateCriteriaStatsIsolate(
  List<SawMatrixDto> listMatrix,
) {
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
          max: math.max(stats[cid]!.max, val),
          min: math.min(stats[cid]!.min, val),
        );
      }
    }
  }

  return stats;
}

/// Normalize a single rating based on criteria statistics
SawRatingDto _normalizeRatingIsolate(
  SawRatingDto rating,
  Map<String, _CriteriaStats> stats,
) {
  final cid = rating.criteria?.id;
  final val = rating.value ?? 0;

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

  // Case 1: All values are the same (no variance)
  if (maxV == minV) {
    newValue = 1.0;
  }
  // Case 2: Benefit criteria (higher is better)
  else if (rating.criteria!.isBenefit == true) {
    // Formula: value / max
    newValue = maxV == 0 ? 0 : val / maxV;
  }
  // Case 3: Cost criteria (lower is better)
  else {
    // Validate: cost criteria cannot have zero values
    if (val == 0) {
      throw Exception(
        'Zero value found in cost criteria: ${rating.criteria!.name}. '
        'Cost criteria must have positive values.',
      );
    }

    // Additional validation: if min is 0, data is invalid
    if (minV == 0) {
      throw Exception(
        'Minimum value is zero in cost criteria: ${rating.criteria!.name}. '
        'Cost criteria cannot have zero values as it makes normalization impossible.',
      );
    }

    // Standard SAW formula for cost criteria: min / value
    newValue = minV / val;
  }

  return rating.copyWith(value: newValue);
}

/// Helper class to store criteria statistics
class _CriteriaStats {
  final num max;
  final num min;

  _CriteriaStats({required this.max, required this.min});
}
