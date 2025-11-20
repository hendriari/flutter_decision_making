import 'package:flutter_decision_making/feature/saw/data/dto/saw_criteria_dto.dart';

class SawRatingDto {
  final String? id;
  final SawCriteriaDto? criteria;
  final num? value;

  SawRatingDto({
    this.id,
    required this.criteria,
    required this.value,
  });

  factory SawRatingDto.fromJson(Map<String, dynamic> json) {
    return SawRatingDto(
      id: json['id'] as String?,
      criteria: json['criteria'] != null
          ? SawCriteriaDto.fromJson(json['criteria'] as Map<String, dynamic>)
          : null,
      value: json['value'] as num,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'criteria': criteria?.toJson(),
        'value': value,
      };

  SawRatingDto copyWith({
    String? id,
    SawCriteriaDto? criteria,
    num? value,
  }) {
    return SawRatingDto(
      id: id ?? this.id,
      criteria: criteria ?? this.criteria,
      value: value ?? this.value,
    );
  }
}
