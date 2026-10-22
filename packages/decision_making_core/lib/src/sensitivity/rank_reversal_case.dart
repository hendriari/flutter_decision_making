import 'alternative_pair.dart';

/// Single test case in a rank reversal analysis representing the removal of one alternative.
class RankReversalCase {
  /// The ID of the removed alternative.
  final String removedAlternativeId;

  /// Recalculated scores of the remaining alternatives.
  final Map<String, double> scores;

  /// Recalculated ranking of the remaining alternative IDs (ordered descending by score).
  final List<String> ranking;

  /// Whether any pair of remaining alternatives reversed their relative order compared to base.
  final bool hasReversal;

  /// List of alternative ID pairs whose relative ordering inverted.
  final List<AlternativePair> reversedPairs;

  /// Whether this rank reversal test was skipped (e.g. n < 3 alternatives).
  final bool isSkipped;

  /// Reason why this test was skipped, if applicable.
  final String? skipReason;

  const RankReversalCase({
    required this.removedAlternativeId,
    required this.scores,
    required this.ranking,
    required this.hasReversal,
    required this.reversedPairs,
    this.isSkipped = false,
    this.skipReason,
  });

  /// Converts this rank reversal case to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'removed_alternative_id': removedAlternativeId,
        'scores': Map<String, double>.from(scores),
        'ranking': List<String>.from(ranking),
        'has_reversal': hasReversal,
        'reversed_pairs': reversedPairs.map((p) => p.toJson()).toList(),
        'is_skipped': isSkipped,
        'skip_reason': skipReason,
      };
}
