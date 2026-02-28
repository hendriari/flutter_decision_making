import 'package:flutter_decision_making/core/shared/entity/weighted_decision_alternative.dart';

/// SAW RESULT
class WeightedDecisionResult {
  final String? id;
  final WeightedDecisionAlternative alternative;
  final double score;
  final int rank;

  WeightedDecisionResult({
    this.id,
    required this.alternative,
    required this.score,
    required this.rank,
  });

  WeightedDecisionResult copyWith({
    String? id,
    WeightedDecisionAlternative? alternative,
    double? score,
    int? rank,
  }) =>
      WeightedDecisionResult(
        id: id ?? this.id,
        alternative: alternative ?? this.alternative,
        score: score ?? this.score,
        rank: rank ?? this.rank,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightedDecisionResult && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
