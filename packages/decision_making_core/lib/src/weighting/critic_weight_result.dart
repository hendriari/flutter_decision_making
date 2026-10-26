import '../common/weighted_decision_criteria.dart';
import '../common/weighted_decision_matrix.dart';
import '../topsis/topsis_raw_matrix.dart';
import 'objective_weight_calculator.dart';

/// Result of CRITIC (Criteria Importance Through Intercriteria Correlation)
/// objective weighting calculation.
///
/// Contains both final normalized criteria weights (summing to 1.0) and all
/// intermediate calculation steps:
/// - [criteriaIds]: Ordered list of criteria IDs matching the input order.
/// - [normalizedMatrix]: Min-max normalized matrix (r_ij) keyed by alternative ID -> criteria ID.
/// - [standardDeviations]: Sample standard deviation (sigma_j, divisor m - 1) per criteria ID.
/// - [correlationMatrix]: Pearson correlation matrix (`R = r_jk`) keyed by criteria ID -> criteria ID.
/// - [informationContent]: Amount of information (`C_j = sigma_j * sum_k(1 - r_jk)`) per criteria ID.
/// - [weights]: Final objective weights (w_j = C_j / sum_j(C_j)) per criteria ID (summing to 1.0).
class CriticWeightResult {
  /// Ordered list of criteria IDs matching the input order.
  final List<String> criteriaIds;

  /// Min-max normalized matrix (r_ij).
  /// Benefit: (x - min) / (max - min); Cost: (max - x) / (max - min).
  /// Key: Alternative ID -> Criteria ID -> normalized value.
  final Map<String, Map<String, double>> normalizedMatrix;

  /// Sample standard deviation (sigma_j, divisor m - 1) of each normalized column, keyed by criteria ID.
  final Map<String, double> standardDeviations;

  /// Pearson correlation matrix (R) between normalized criteria columns.
  /// Key: Criteria ID (j) -> Criteria ID (k) -> correlation coefficient r_jk.
  final Map<String, Map<String, double>> correlationMatrix;

  /// Information content / contrast intensity and conflict measure (C_j = sigma_j * sum_k(1 - r_jk)) keyed by criteria ID.
  final Map<String, double> informationContent;

  /// Final normalized weights (w_j = C_j / sum_j(C_j)) keyed by criteria ID, summing to 1.0.
  final Map<String, double> weights;

  const CriticWeightResult({
    required this.criteriaIds,
    required this.normalizedMatrix,
    required this.standardDeviations,
    required this.correlationMatrix,
    required this.informationContent,
    required this.weights,
  });

  /// Applies the calculated weights (`weightPercent = w_j * 100`) to [criteria],
  /// preserving each criterion's benefit/cost type and other attributes.
  List<WeightedDecisionCriteria> applyToCriteria(
    List<WeightedDecisionCriteria> criteria,
  ) {
    return ObjectiveWeightCalculator.applyWeightsToCriteria(criteria, weights);
  }

  /// Applies the calculated weights (`weightPercent = w_j * 100`) to all criteria
  /// inside [rawMatrix], returning a new matrix ready for [SawCalculator].
  List<WeightedDecisionMatrix> applyToMatrix(
    List<WeightedDecisionMatrix> rawMatrix,
  ) {
    return ObjectiveWeightCalculator.applyWeightsToMatrix(rawMatrix, weights);
  }

  /// Applies the calculated weights (`weightPercent = w_j * 100`) to [rawMatrix],
  /// returning a new [TopsisRawMatrix] ready for [TopsisCalculator].
  TopsisRawMatrix applyToTopsisRawMatrix(TopsisRawMatrix rawMatrix) {
    return ObjectiveWeightCalculator.applyWeightsToTopsisMatrix(
      rawMatrix,
      weights,
    );
  }

  /// Converts this result and all intermediate values into a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'criteria_ids': List<String>.from(criteriaIds),
        'normalized_matrix': normalizedMatrix.map(
          (altId, row) => MapEntry(altId, Map<String, double>.from(row)),
        ),
        'standard_deviations': Map<String, double>.from(standardDeviations),
        'correlation_matrix': correlationMatrix.map(
          (cIdJ, row) => MapEntry(cIdJ, Map<String, double>.from(row)),
        ),
        'information_content': Map<String, double>.from(informationContent),
        'weights': Map<String, double>.from(weights),
      };
}
