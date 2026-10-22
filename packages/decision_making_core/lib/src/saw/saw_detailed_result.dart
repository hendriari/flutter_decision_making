import '../common/weighted_decision_matrix.dart';
import '../common/weighted_decision_result.dart';

/// Detailed result of a Simple Additive Weighting (SAW) calculation.
///
/// Contains all intermediate computation steps:
/// - [initialMatrix]: The original decision matrix passed as input.
/// - [normalizedMatrix]: Decision matrix normalized per cell according to SAW benefit/cost rules ($r_{ij}$).
/// - [normalizedWeights]: Map of criteria IDs to their normalized weight fractions ($w_j \in [0, 1]$, summing to 1.0).
/// - [weightedMatrix]: Matrix where each cell is weighted ($v_{ij} = r_{ij} \times w_j$).
/// - [scores]: Final ranked alternatives with total scores and 1-based ranks ($S_i = \sum_j v_{ij}$).
class SawDetailedResult {
  /// The original decision matrix passed as input.
  final List<WeightedDecisionMatrix> initialMatrix;

  /// Decision matrix after SAW benefit/cost normalization ($r_{ij}$).
  final List<WeightedDecisionMatrix> normalizedMatrix;

  /// Normalized criteria weights as fractions summing to 1.0 ($w_j$).
  ///
  /// Key: Criteria ID (or Criteria name if ID is null).
  /// Value: Weight fraction ($w_j = \text{weightPercent} / 100.0$).
  final Map<String, double> normalizedWeights;

  /// Weighted decision matrix where each cell is $v_{ij} = r_{ij} \times w_j$.
  final List<WeightedDecisionMatrix> weightedMatrix;

  /// Final scores and sequential rankings for each alternative.
  final List<WeightedDecisionResult> scores;

  const SawDetailedResult({
    required this.initialMatrix,
    required this.normalizedMatrix,
    required this.normalizedWeights,
    required this.weightedMatrix,
    required this.scores,
  });

  /// Convenience getter returning the final ranked results (identical to [SawCalculator.calculate]).
  List<WeightedDecisionResult> get results => scores;

  /// Converts the detailed result and all intermediate calculation steps into a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'initial_matrix': initialMatrix.map((m) => {
              'alternative': {
                'id': m.alternative.id,
                'name': m.alternative.name,
              },
              'ratings': m.ratings.map((r) => {
                    'id': r.id,
                    'criteria_id': r.criteria?.id,
                    'criteria_name': r.criteria?.name,
                    'value': r.value,
                  }).toList(),
            }).toList(),
        'normalized_matrix': normalizedMatrix.map((m) => {
              'alternative': {
                'id': m.alternative.id,
                'name': m.alternative.name,
              },
              'ratings': m.ratings.map((r) => {
                    'id': r.id,
                    'criteria_id': r.criteria?.id,
                    'criteria_name': r.criteria?.name,
                    'value': r.value,
                  }).toList(),
            }).toList(),
        'normalized_weights': Map<String, double>.from(normalizedWeights),
        'weighted_matrix': weightedMatrix.map((m) => {
              'alternative': {
                'id': m.alternative.id,
                'name': m.alternative.name,
              },
              'ratings': m.ratings.map((r) => {
                    'id': r.id,
                    'criteria_id': r.criteria?.id,
                    'criteria_name': r.criteria?.name,
                    'value': r.value,
                  }).toList(),
            }).toList(),
        'scores': scores.map((s) => {
              'id': s.id,
              'alternative': {
                'id': s.alternative.id,
                'name': s.alternative.name,
              },
              'score': s.score,
              'rank': s.rank,
            }).toList(),
      };
}
