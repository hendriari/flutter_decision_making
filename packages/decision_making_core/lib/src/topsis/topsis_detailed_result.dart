import '../common/weighted_decision_matrix.dart';
import '../common/weighted_decision_result.dart';
import 'topsis_ideal_value.dart';

/// Detailed result of a TOPSIS calculation.
///
/// Contains all intermediate computation steps:
/// - [initialMatrix]: The original decision matrix passed as input.
/// - [normalizedMatrix]: Decision matrix normalized per cell using Euclidean vector normalization (r_ij).
/// - [normalizedWeights]: Map of criteria IDs to their normalized weight fractions (w_j between 0.0 and 1.0, summing to 1.0).
/// - [weightedMatrix]: Matrix where each cell is weighted (v_ij = r_ij * w_j).
/// - [positiveIdeal]: Positive Ideal Solution (A_j^+) per criteria ID.
/// - [negativeIdeal]: Negative Ideal Solution (A_j^-) per criteria ID.
/// - [separationPlus]: Separation distance from Positive Ideal Solution (D_i^+) per alternative ID.
/// - [separationMinus]: Separation distance from Negative Ideal Solution (D_i^-) per alternative ID.
/// - [scores]: Final ranked alternatives with relative closeness scores (C_i = D_i^- / (D_i^+ + D_i^-)) and 1-based ranks.
class TopsisDetailedResult {
  /// The original decision matrix passed as input.
  final List<WeightedDecisionMatrix> initialMatrix;

  /// Decision matrix after Euclidean vector normalization (r_ij).
  final List<WeightedDecisionMatrix> normalizedMatrix;

  /// Normalized criteria weights as fractions summing to 1.0 (w_j).
  ///
  /// Key: Criteria ID.
  /// Value: Weight fraction (w_j = weightPercent / sum weightPercent).
  final Map<String, double> normalizedWeights;

  /// Weighted normalized decision matrix where each cell is v_ij = r_ij * w_j.
  final List<WeightedDecisionMatrix> weightedMatrix;

  /// Positive Ideal Solution (A_j^+) per criteria ID.
  final Map<String, double> positiveIdeal;

  /// Negative Ideal Solution (A_j^-) per criteria ID.
  final Map<String, double> negativeIdeal;

  /// Separation distance from Positive Ideal Solution (D_i^+) per alternative ID.
  final Map<String, double> separationPlus;

  /// Separation distance from Negative Ideal Solution (D_i^-) per alternative ID.
  final Map<String, double> separationMinus;

  /// Final scores and sequential rankings for each alternative.
  final List<WeightedDecisionResult> scores;

  const TopsisDetailedResult({
    required this.initialMatrix,
    required this.normalizedMatrix,
    required this.normalizedWeights,
    required this.weightedMatrix,
    required this.positiveIdeal,
    required this.negativeIdeal,
    required this.separationPlus,
    required this.separationMinus,
    required this.scores,
  });

  /// Convenience getter returning the final ranked results (identical to [TopsisCalculator.calculate]).
  List<WeightedDecisionResult> get results => scores;

  /// Convenience getter returning ideal solutions bundled as [TopsisIdealValue].
  TopsisIdealValue get idealValue => TopsisIdealValue(
        positiveIdeal: Map<String, dynamic>.from(positiveIdeal),
        negativeIdeal: Map<String, dynamic>.from(negativeIdeal),
      );

  /// Converts the detailed result and all intermediate calculation steps into a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'initial_matrix': initialMatrix
            .map((m) => {
                  'alternative': {
                    'id': m.alternative.id,
                    'name': m.alternative.name,
                  },
                  'ratings': m.ratings
                      .map((r) => {
                            'id': r.id,
                            'criteria_id': r.criteria?.id,
                            'criteria_name': r.criteria?.name,
                            'value': r.value,
                          })
                      .toList(),
                })
            .toList(),
        'normalized_matrix': normalizedMatrix
            .map((m) => {
                  'alternative': {
                    'id': m.alternative.id,
                    'name': m.alternative.name,
                  },
                  'ratings': m.ratings
                      .map((r) => {
                            'id': r.id,
                            'criteria_id': r.criteria?.id,
                            'criteria_name': r.criteria?.name,
                            'value': r.value,
                          })
                      .toList(),
                })
            .toList(),
        'normalized_weights': Map<String, double>.from(normalizedWeights),
        'weighted_matrix': weightedMatrix
            .map((m) => {
                  'alternative': {
                    'id': m.alternative.id,
                    'name': m.alternative.name,
                  },
                  'ratings': m.ratings
                      .map((r) => {
                            'id': r.id,
                            'criteria_id': r.criteria?.id,
                            'criteria_name': r.criteria?.name,
                            'value': r.value,
                          })
                      .toList(),
                })
            .toList(),
        'positive_ideal': Map<String, double>.from(positiveIdeal),
        'negative_ideal': Map<String, double>.from(negativeIdeal),
        'separation_plus': Map<String, double>.from(separationPlus),
        'separation_minus': Map<String, double>.from(separationMinus),
        'scores': scores
            .map((s) => {
                  'id': s.id,
                  'alternative': {
                    'id': s.alternative.id,
                    'name': s.alternative.name,
                  },
                  'score': s.score,
                  'rank': s.rank,
                })
            .toList(),
      };
}
