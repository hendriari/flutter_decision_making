import 'package:flutter_decision_making/core/shared/entity/weighted_decision_alternative.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_criteria.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_result.dart';
import 'package:flutter_decision_making/feature/topsis/domain/entities/topsis_raw_matrix.dart';

/// Abstract class defining the contract for TOPSIS (Technique for Order of Preference by Similarity to Ideal Solution) local data operations.
///
/// This datasource handles the core TOPSIS algorithm operations including:
/// - Matrix generation from alternatives and criteria
/// - Euclidean normalization
/// - Weighted matrix calculation
/// - Ideal solution identification (A+ and A-)
/// - Distance measurement and relative closeness calculation
abstract interface class TopsisLocalDatasource {
  /// Generates a TOPSIS raw decision matrix from the given alternatives and criteria.
  ///
  /// The matrix represents all alternatives evaluated against all criteria,
  /// initializing with default values and ensuring data integrity.
  ///
  /// **Parameters:**
  /// - [listAlternative]: List of alternatives to be evaluated
  /// - [listCriteria]: List of criteria for evaluation
  ///
  /// **Returns:** A [TopsisRawMatrix] object containing the matrix and criteria
  ///
  /// **Throws:**
  /// - Exception if alternatives or criteria lists are empty
  /// - Exception if criteria weights are invalid
  Future<TopsisRawMatrix> generateTopsisMatrix({
    required List<WeightedDecisionAlternative> listAlternative,
    required List<WeightedDecisionCriteria> listCriteria,
  });

  /// Calculates the final TOPSIS results from a decision matrix.
  ///
  /// This method performs the complete TOPSIS calculation:
  /// 1. Euclidean Normalization
  /// 2. Weighted Matrix Calculation
  /// 3. Identifying Positive and Negative Ideal Solutions
  /// 4. Calculating Separation Measures (Distances)
  /// 5. Calculating Relative Closeness to Ideal Solution
  /// 6. Ranking
  ///
  /// **Parameters:**
  /// - [rawMatrix]: The raw decision matrix containing ratings and criteria
  ///
  /// **Returns:** A ranked list of [WeightedDecisionResult] objects
  ///
  /// **Throws:**
  /// - Exception if matrix is empty or contains invalid values
  Future<List<WeightedDecisionResult>> calculateResult({
    required TopsisRawMatrix rawMatrix,
  });

  /// Calculates results using an existing matrix with validation and fixing.
  ///
  /// This method is useful when working with pre-existing matrices that may
  /// need validation, weight normalization, or ID assignment before calculation.
  ///
  /// **Parameters:**
  /// - [rawMatrix]: The existing decision matrix to calculate from
  ///
  /// **Returns:** A ranked list of [WeightedDecisionResult] objects
  ///
  /// **Throws:**
  /// - Exception if matrix is empty or contains invalid data
  /// - Exception if rating values exceed criteria max values
  Future<List<WeightedDecisionResult>> calculateResultWithExistingMatrix({
    required TopsisRawMatrix rawMatrix,
  });
}
