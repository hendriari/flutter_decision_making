import 'package:flutter_decision_making/core/shared/entity/weighted_decision_alternative.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_criteria.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_matrix.dart';
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
