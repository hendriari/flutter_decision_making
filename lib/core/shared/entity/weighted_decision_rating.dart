import 'package:flutter_decision_making/core/shared/entity/weighted_decision_criteria.dart';

/// RATINGS
class WeightedDecisionRating {
  final String? id;
  final WeightedDecisionCriteria? criteria;
  final num? value;

  WeightedDecisionRating({
    this.id,
    required this.criteria,
    required this.value,
  });

  WeightedDecisionRating copyWith({
    String? id,
    WeightedDecisionCriteria? criteria,
    num? value,
  }) =>
      WeightedDecisionRating(
        id: id ?? this.id,
        criteria: criteria ?? this.criteria,
        value: value ?? this.value,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightedDecisionRating && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
