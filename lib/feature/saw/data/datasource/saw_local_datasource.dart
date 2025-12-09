import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter_decision_making/core/decision_making_enums.dart';
import 'package:flutter_decision_making/core/decision_making_helper.dart';
import 'package:flutter_decision_making/core/decision_making_performance_profiling.dart';
import 'package:flutter_decision_making/core/isolate/decision_isolate_main.dart';
import 'package:flutter_decision_making/feature/saw/data/dto/saw_matrix_dto.dart';
import 'package:flutter_decision_making/feature/saw/data/mapper/saw_alternative_mapper.dart';
import 'package:flutter_decision_making/feature/saw/data/mapper/saw_criteria_mapper.dart';
import 'package:flutter_decision_making/feature/saw/data/mapper/saw_matrix_mapper.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_alternative.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_criteria.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_matrix.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_rating.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_result.dart';

abstract class SawLocalDatasource {
  Future<List<SawMatrix>> generateSawMatrix({
    required List<SawAlternative> listAlternative,
    required List<SawCriteria> listCriteria,
  });

  Future<List<SawResult>> calculateSawResult({
    required List<SawMatrix> matrix,
  });

  Future<List<SawResult>> calculateResultWithExistingMatrix({
    required List<SawMatrix> matrix,
  });
}

class SawLocalDatasourceImpl extends SawLocalDatasource {
  final DecisionMakingHelper _helper;
  final DecisionIsolateMain _isolate;

  SawLocalDatasourceImpl({
    DecisionMakingHelper? helper,
    Stopwatch? stopwatch,
    DecisionIsolateMain? isolate,
  })  : _helper = helper ?? DecisionMakingHelper(),
        _isolate = isolate ?? DecisionIsolateMain();

  /// [MATRIX]
  /// GENERATE SAW MATRIX
  @override
  Future<List<SawMatrix>> generateSawMatrix({
    required List<SawAlternative> listAlternative,
    required List<SawCriteria> listCriteria,
  }) async {
    startPerformanceProfiling('Generate SAW pairwise matrix');
    try {
      _validateInputs(listAlternative, listCriteria);

      final normalizedCriteria = _normalizeCriteriaWeights(listCriteria);
      final updateAlternative = _ensureIdsForAlternatives(listAlternative);
      final updateCriteria = _ensureIdsForCriteria(normalizedCriteria);

      List<SawMatrix> result = [];
      final canUseIsolate = !kIsWeb &&
          (updateAlternative.length > 80 || updateCriteria.length > 25);

      if (canUseIsolate) {
        result = await _generateMatrixWithIsolate(
          updateAlternative,
          updateCriteria,
        );
      } else {
        result = _generateMatrixDirectly(updateAlternative, updateCriteria);
      }

      return result;
    } catch (e, s) {
      debugPrint('SAW Matrix Error: $e\n$s');
      throw Exception('Failed to generate SAW matrix: $e');
    } finally {
      endPerformanceProfiling('Generate SAW pairwise matrix');
    }
  }

  /// Validate inputs for matrix generation
  void _validateInputs(
    List<SawAlternative> alternatives,
    List<SawCriteria> criteria,
  ) {
    if (alternatives.isEmpty) {
      throw Exception("Alternatives list cannot be empty!");
    }

    if (criteria.isEmpty) {
      throw Exception("Criteria list cannot be empty!");
    }

    for (var c in criteria) {
      if (c.weightPercent < 0) {
        throw Exception("Criteria weight cannot be negative: ${c.name}");
      }
    }

    final totalWeight = criteria.fold<num>(0, (a, b) => a + b.weightPercent);
    if (totalWeight == 0) {
      throw Exception("Total criteria weight cannot be zero.");
    }
  }

  /// Normalize criteria weights to sum to 100%
  List<SawCriteria> _normalizeCriteriaWeights(List<SawCriteria> criteria) {
    final totalWeight = criteria.fold<num>(0, (a, b) => a + b.weightPercent);

    if (totalWeight == 100) {
      return List<SawCriteria>.from(criteria);
    }

    dev.log(
      "[SAW] Total weight = $totalWeight, auto-normalizing to 100%.",
      name: "DECISION MAKING",
    );

    return criteria.map((c) {
      final normalized = (c.weightPercent / totalWeight) * 100;
      return c.copyWith(weightPercent: normalized);
    }).toList();
  }

  /// Ensure all alternatives have IDs
  List<SawAlternative> _ensureIdsForAlternatives(
      List<SawAlternative> alternatives) {
    return alternatives.map((e) {
      return (e.id == null || e.id!.isEmpty)
          ? e.copyWith(id: _helper.getCustomUniqueId())
          : e;
    }).toList();
  }

  /// Ensure all criteria have IDs
  List<SawCriteria> _ensureIdsForCriteria(List<SawCriteria> criteria) {
    return criteria.map((e) {
      return (e.id == null || e.id!.isEmpty)
          ? e.copyWith(id: _helper.getCustomUniqueId())
          : e;
    }).toList();
  }

  /// Generate matrix using isolate for large datasets
  Future<List<SawMatrix>> _generateMatrixWithIsolate(
    List<SawAlternative> alternatives,
    List<SawCriteria> criteria,
  ) async {
    final rawResult = await _isolate.runTask(
      DecisionAlgorithm.saw,
      SawProcessingCommand.generateSawMatrix,
      {
        "list_criteria": criteria.map((e) => e.toDto().toJson()).toList(),
        "list_alternative":
            alternatives.map((e) => e.toDto().toJson()).toList(),
      },
    );

    return (rawResult as List)
        .map((e) =>
            SawMatrixDto.fromJson(Map<String, dynamic>.from(e)).toEntity())
        .toList();
  }

  /// Generate matrix directly without isolate
  List<SawMatrix> _generateMatrixDirectly(
    List<SawAlternative> alternatives,
    List<SawCriteria> criteria,
  ) {
    return alternatives.map((alt) {
      final ratings = criteria.map((crt) {
        return SawRating(
          id: _helper.getCustomUniqueId(),
          criteria: crt,
          value: 0,
        );
      }).toList();

      return SawMatrix(
        id: _helper.getCustomUniqueId(),
        alternative: alt,
        ratings: ratings,
      );
    }).toList();
  }

  /// ==========================================================================
  /// [NORMALIZE]

  /// NORMALIZE MATRIX
  Future<List<SawMatrix>> _normalizeMatrix(List<SawMatrix> listMatrix) async {
    startPerformanceProfiling('normalize matrix saw');
    try {
      if (listMatrix.isEmpty) {
        throw Exception('Matrix cannot be empty!');
      }

      var normalized = <SawMatrix>[];
      final canUseIsolate = !kIsWeb &&
          (listMatrix.length > 80 || listMatrix.first.ratings.length > 25);

      if (canUseIsolate) {
        normalized = await _normalizeMatrixWithIsolate(listMatrix);
      } else {
        normalized = _normalizeMatrixDirectly(listMatrix);
      }

      return normalized;
    } catch (e) {
      throw Exception('Failed to normalize matrix: $e');
    } finally {
      endPerformanceProfiling('normalize matrix saw');
    }
  }

  /// Normalize matrix using isolate
  Future<List<SawMatrix>> _normalizeMatrixWithIsolate(
      List<SawMatrix> listMatrix) async {
    final rawData = await _isolate.runTask(
      DecisionAlgorithm.saw,
      SawProcessingCommand.normalizeMatrix,
      {
        "matrix": listMatrix.map((e) => e.toDto().toJson()).toList(),
      },
    );

    final parsed =
        (rawData as List).map((e) => SawMatrixDto.fromJson(e)).toList();

    return parsed.map((e) => e.toEntity()).toList();
  }

  /// Normalize matrix directly
  List<SawMatrix> _normalizeMatrixDirectly(List<SawMatrix> listMatrix) {
    final criteriaStats = _calculateCriteriaStats(listMatrix);

    return listMatrix.map((matrix) {
      final newRatings = matrix.ratings.map((rating) {
        return _normalizeRating(rating, criteriaStats);
      }).toList();

      return matrix.copyWith(ratings: newRatings);
    }).toList();
  }

  /// Calculate min/max statistics for each criteria
  Map<String, _CriteriaStats> _calculateCriteriaStats(
      List<SawMatrix> listMatrix) {
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

  /// Normalize a single rating based on criteria statistics
  /// Normalize a single rating based on criteria statistics
  SawRating _normalizeRating(
      SawRating rating,
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

  /// CALCULATE SAW RESULT
  Future<List<SawResult>> _calculateSawScore(
      List<SawMatrix> normalizedMatrix) async {
    startPerformanceProfiling('Calculate SAW result');
    try {
      if (normalizedMatrix.isEmpty) {
        throw Exception('Normalized matrix cannot be empty!');
      }

      var sawResult = <SawResult>[];

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

        sawResult.add(SawResult(
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
      throw Exception('Failed to calculate SAW scores: $e');
    } finally {
      endPerformanceProfiling('Calculate SAW result');
    }
  }

  @override
  Future<List<SawResult>> calculateSawResult({
    required List<SawMatrix> matrix,
  }) async {
    startPerformanceProfiling('Combined all method SAW algorithm');
    try {
      final normalized = await _normalizeMatrix(matrix);
      final result = await _calculateSawScore(normalized);

      return result;
    } catch (e) {
      throw Exception('Failed to calculate SAW algorithm: $e');
    } finally {
      endPerformanceProfiling('Combined all method SAW algorithm');
    }
  }

  /// ==========================================================================
  /// [RESULT WITH CRITERIA]

  @override
  Future<List<SawResult>> calculateResultWithExistingMatrix({
    required List<SawMatrix> matrix,
  }) async {
    startPerformanceProfiling('Calculate result with existing matrix');
    try {
      if (matrix.isEmpty) {
        throw Exception("Matrix cannot be empty!");
      }

      final validatedMatrix = _validateAndFixMatrix(matrix);

      final normalizedMatrix = await _normalizeMatrix(validatedMatrix);
      final sawResult = await _calculateSawScore(normalizedMatrix);

      return sawResult;
    } catch (e) {
      throw Exception('Failed to calculate result with existing matrix: $e');
    } finally {
      endPerformanceProfiling('Calculate result with existing matrix');
    }
  }

  /// Validate and fix matrix data structure
  List<SawMatrix> _validateAndFixMatrix(List<SawMatrix> matrix) {
    return matrix.map((m) {
      var updatedMatrix = _ensureMatrixId(m);

      updatedMatrix = _ensureAlternativeId(updatedMatrix);

      updatedMatrix = _ensureRatingIds(updatedMatrix);

      updatedMatrix = _normalizeMatrixWeights(updatedMatrix);

      return updatedMatrix;
    }).toList();
  }

  /// Ensure matrix has ID
  SawMatrix _ensureMatrixId(SawMatrix matrix) {
    if (matrix.id == null || matrix.id!.isEmpty) {
      return matrix.copyWith(id: _helper.getCustomUniqueId());
    }
    return matrix;
  }

  /// Ensure alternative has ID
  SawMatrix _ensureAlternativeId(SawMatrix matrix) {
    if (matrix.alternative.id == null || matrix.alternative.id!.isEmpty) {
      final updatedAlternative =
          matrix.alternative.copyWith(id: _helper.getCustomUniqueId());
      return matrix.copyWith(alternative: updatedAlternative);
    }
    return matrix;
  }

  /// Ensure all ratings have IDs
  SawMatrix _ensureRatingIds(SawMatrix matrix) {
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

  /// Normalize weights in matrix if necessary
  SawMatrix _normalizeMatrixWeights(SawMatrix matrix) {
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

/// Helper class to store criteria statistics
class _CriteriaStats {
  final num max;
  final num min;

  _CriteriaStats({required this.max, required this.min});
}
