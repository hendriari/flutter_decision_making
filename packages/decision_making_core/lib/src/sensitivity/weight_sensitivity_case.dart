import 'alternative_pair.dart';
import 'sensitivity_direction.dart';

/// Single test case in a weight sensitivity analysis representing a +/- delta perturbation on one criterion.
class WeightSensitivityCase {
  /// The ID of the perturbed criterion.
  final String criterionId;

  /// Perturbation direction (increase `+` or decrease `-`).
  final SensitivityDirection direction;

  /// Relative perturbation delta fraction (e.g. 0.1 for 10%).
  final double delta;

  /// New normalized weights of all criteria (summing to 1.0).
  final Map<String, double> weights;

  /// Recalculated scores of all alternatives.
  final Map<String, double> scores;

  /// Recalculated alternative IDs ordered descending by score.
  final List<String> ranking;

  /// Whether the relative ranking order of any alternative pair changed compared to base.
  final bool hasOrderChanged;

  /// List of alternative ID pairs whose relative ordering swapped.
  final List<AlternativePair> swappedPairs;

  /// Whether this perturbation case was skipped (e.g. w_k' >= 1.0, w_k' <= 0.0, or single criterion).
  final bool isSkipped;

  /// Reason why this case was skipped, if applicable.
  final String? skipReason;

  const WeightSensitivityCase({
    required this.criterionId,
    required this.direction,
    required this.delta,
    required this.weights,
    required this.scores,
    required this.ranking,
    required this.hasOrderChanged,
    required this.swappedPairs,
    this.isSkipped = false,
    this.skipReason,
  });

  /// Converts this sensitivity case to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'criterion_id': criterionId,
        'direction': direction.symbol,
        'delta': delta,
        'weights': Map<String, double>.from(weights),
        'scores': Map<String, double>.from(scores),
        'ranking': List<String>.from(ranking),
        'has_order_changed': hasOrderChanged,
        'swapped_pairs': swappedPairs.map((p) => p.toJson()).toList(),
        'is_skipped': isSkipped,
        'skip_reason': skipReason,
      };
}
