import 'package:flutter_decision_making/core/shared/dto/weighted_decision_criteria_dto.dart';

class WeightedDecisionRatingDto {
  final String? id;
  final WeightedDecisionCriteriaDto? criteria;
  final num? value;

  WeightedDecisionRatingDto({
    this.id,
    required this.criteria,
    required this.value,
  });

  factory WeightedDecisionRatingDto.fromJson(Map<String, dynamic> json) {
    return WeightedDecisionRatingDto(
      id: json['id'] as String?,
      criteria: json['criteria'] != null
          ? WeightedDecisionCriteriaDto.fromJson(json['criteria'] as Map<String, dynamic>)
          : null,
      value: json['value'] as num,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'criteria': criteria?.toJson(),
        'value': value,
      };

  WeightedDecisionRatingDto copyWith({
    String? id,
    WeightedDecisionCriteriaDto? criteria,
    num? value,
  }) {
    return WeightedDecisionRatingDto(
      id: id ?? this.id,
      criteria: criteria ?? this.criteria,
      value: value ?? this.value,
    );
  }
}
