import 'package:flutter_decision_making/feature/topsis/domain/entities/topsis_criteria.dart';

/// RATINGS
class TopsisRating {
  final String? id;
  final TopsisCriteria criteria;
  final double value;

  TopsisRating({
    this.id,
    required this.criteria,
    required this.value,
  });

  TopsisRating copyWith({
    String? id,
    TopsisCriteria? criteria,
    double? value,
  }) =>
      TopsisRating(
        id: id ?? this.id,
        criteria: criteria ?? this.criteria,
        value: value ?? this.value,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopsisRating && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
