import 'package:flutter_decision_making/core/shared/entity/weighted_decision_alternative.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_rating.dart';

/// MATRIX
class WeightedDecisionMatrix {
  final String? id;
  final WeightedDecisionAlternative alternative;
  final List<WeightedDecisionRating> ratings;

  WeightedDecisionMatrix({
    this.id,
    required this.alternative,
    required this.ratings,
  });

  WeightedDecisionMatrix copyWith({
    String? id,
    WeightedDecisionAlternative? alternative,
    List<WeightedDecisionRating>? ratings,
  }) {
    return WeightedDecisionMatrix(
      id: id ?? this.id,
      alternative: alternative ?? this.alternative,
      ratings: ratings ?? this.ratings,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightedDecisionMatrix && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
