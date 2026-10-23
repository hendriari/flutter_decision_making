import 'package:decision_making_core/decision_making_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_decision_making/core/decision_making_enums.dart';
import 'package:flutter_decision_making/core/decision_making_helper.dart';
import 'package:flutter_decision_making/core/decision_making_performance_profiling.dart';
import 'package:flutter_decision_making/core/isolate/decision_isolate_main.dart';
import 'package:flutter_decision_making/core/shared/dto/weighted_decision_matrix_dto.dart';
import 'package:flutter_decision_making/core/shared/interface/weighted_decision_matrix_mixin.dart';
import 'package:flutter_decision_making/core/shared/mapper/weighted_decision_matrix_mapper.dart';
import 'package:flutter_decision_making/feature/saw/data/datasource/saw_local_datasource.dart';

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
class SawLocalDatasourceImpl
    with WeightedDecisionMatrixMixin
    implements SawLocalDatasource {
  final DecisionMakingHelper _helper;
  DecisionIsolateMain? _isolate;

  @override
  DecisionMakingHelper get helper => _helper;

  @override
  DecisionIsolateMain get isolate => _isolate ??= DecisionIsolateMain();

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
        _isolate = isolate;

  /// ### Matrix Generation
  /// GENERATE SAW MATRIX
  @override
  Future<List<WeightedDecisionMatrix>> generateSawMatrix({
    required List<WeightedDecisionAlternative> listAlternative,
    required List<WeightedDecisionCriteria> listCriteria,
    bool useIsolate = false,
  }) async {
    startPerformanceProfiling('Generate SAW pairwise matrix');
    try {
      validateInputs(listAlternative, listCriteria);

      final normalizedCriteria = normalizeCriteriaWeights(listCriteria);
      final updateAlternative = ensureIdsForAlternatives(listAlternative);
      final updateCriteria = ensureIdsForCriteria(normalizedCriteria);

      List<WeightedDecisionMatrix> result = [];
      final canUseIsolate = useIsolate && !kIsWeb;

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
  /// - [useIsolate]: Whether to run normalization in an isolate worker (defaults to false)
  ///
  /// **Returns:** Normalized matrix
  ///
  /// **Throws:**
  /// - Exception if matrix is empty
  /// - Exception if cost criteria contain zero values
  Future<List<WeightedDecisionMatrix>> _normalizeMatrix(
    List<WeightedDecisionMatrix> listMatrix, {
    bool useIsolate = false,
  }) async {
    startPerformanceProfiling('normalize matrix saw');
    try {
      if (listMatrix.isEmpty) {
        throw DecisionInputException('Matrix cannot be empty!');
      }

      var normalized = <WeightedDecisionMatrix>[];
      final canUseIsolate = useIsolate && !kIsWeb;

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
    final rawData = await isolate.runTask(
      DecisionAlgorithm.saw,
      SawProcessingIsolateCommand.normalizeMatrix,
      {
        "matrix": listMatrix.map((e) => e.toDto().toJson()).toList(),
      },
    );

    final parsed = (rawData as List)
        .map((e) => WeightedDecisionMatrixDto.fromJson(e))
        .toList();

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
  List<WeightedDecisionMatrix> _normalizeMatrixDirectly(
      List<WeightedDecisionMatrix> listMatrix) {
    return SawCalculator.normalize(listMatrix);
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
      return SawCalculator.calculateScores(normalizedMatrix);
    } catch (e) {
      rethrow;
    } finally {
      endPerformanceProfiling('Calculate SAW result');
    }
  }

  @override
  Future<List<WeightedDecisionResult>> calculateSawResult({
    required List<WeightedDecisionMatrix> matrix,
    bool useIsolate = false,
  }) async {
    startPerformanceProfiling('Combined all method SAW algorithm');
    try {
      await validateMaxInputValue(matrix);

      final normalized = await _normalizeMatrix(matrix, useIsolate: useIsolate);
      final result = await _calculateSawScore(normalized);

      return result;
    } catch (e) {
      rethrow;
    } finally {
      endPerformanceProfiling('Combined all method SAW algorithm');
    }
  }

  /// ==========================================================================
  /// ### Result With Criteria

  @override
  Future<List<WeightedDecisionResult>> calculateResultWithExistingMatrix({
    required List<WeightedDecisionMatrix> matrix,
    bool useIsolate = false,
  }) async {
    startPerformanceProfiling('Calculate result with existing matrix');
    try {
      if (matrix.isEmpty) {
        throw DecisionInputException("Matrix cannot be empty!");
      }

      await validateMaxInputValue(matrix);

      final validatedMatrix = validateAndFixMatrix(matrix);

      final normalizedMatrix =
          await _normalizeMatrix(validatedMatrix, useIsolate: useIsolate);
      final sawResult = await _calculateSawScore(normalizedMatrix);

      return sawResult;
    } catch (e) {
      rethrow;
    } finally {
      endPerformanceProfiling('Calculate result with existing matrix');
    }
  }
}
