import 'package:flutter_decision_making/feature/saw/domain/entities/saw_criteria.dart';

class SawRating {
  final String? id;
  final SawCriteria? criteria;
  final num? value;

  SawRating({
    this.id,
    required this.criteria,
    required this.value,
  });

  SawRating copyWith({
    String? id,
    SawCriteria? criteria,
    num? value,
  }) =>
      SawRating(
        id: id ?? this.id,
        criteria: criteria ?? this.criteria,
        value: value ?? this.value,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SawRating && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
