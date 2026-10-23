import '../common/weighted_decision_criteria.dart';
import '../common/weighted_decision_matrix.dart';
import '../topsis/topsis_raw_matrix.dart';
import 'objective_weight_calculator.dart';

/// Result of Shannon Entropy objective weighting calculation.
///
/// Contains both final normalized criteria weights (summing to 1.0) and all
/// intermediate calculation steps:
/// - [criteriaIds]: Ordered list of criteria IDs matching the input order.
/// - [proportionMatrix]: Proportion matrix (p_ij = x_ij / sum_i(x_ij)) keyed by alternative ID -> criteria ID.
/// - [entropy]: Entropy value (e_j) per criteria ID.
/// - [divergence]: Degree of divergence (d_j = 1 - e_j) per criteria ID.
/// - [weights]: Final objective weights (w_j = d_j / sum_j(d_j)) per criteria ID (summing to 1.0).
class EntropyWeightResult {
  /// Ordered list of criteria IDs matching the input order.
  final List<String> criteriaIds;

  /// Proportion matrix (p_ij = x_ij / sum_i(x_ij)).
  /// Key: Alternative ID -> Criteria ID -> proportion value.
  final Map<String, Map<String, double>> proportionMatrix;

  /// Entropy value (e_j = -k * sum_i(p_ij * ln(p_ij))) keyed by criteria ID.
  final Map<String, double> entropy;

  /// Degree of divergence / diversification (d_j = 1 - e_j) keyed by criteria ID.
  final Map<String, double> divergence;

  /// Final normalized weights (w_j = d_j / sum_j(d_j)) keyed by criteria ID, summing to 1.0.
  final Map<String, double> weights;

  const EntropyWeightResult({
    required this.criteriaIds,
    required this.proportionMatrix,
    required this.entropy,
    required this.divergence,
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
        'proportion_matrix': proportionMatrix.map(
          (altId, row) => MapEntry(altId, Map<String, double>.from(row)),
        ),
        'entropy': Map<String, double>.from(entropy),
        'divergence': Map<String, double>.from(divergence),
        'weights': Map<String, double>.from(weights),
      };
}
