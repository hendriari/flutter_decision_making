import 'package:flutter_decision_making/core/shared/dto/weighted_decision_alternative_dto.dart';
import 'package:flutter_decision_making/core/shared/dto/weighted_decision_rating_dto.dart';

class WeightedDecisionMatrixDto {
  final String? id;
  final WeightedDecisionAlternativeDto alternative;
  final List<WeightedDecisionRatingDto> ratings;

  WeightedDecisionMatrixDto({
    this.id,
    required this.alternative,
    required this.ratings,
  });

  factory WeightedDecisionMatrixDto.fromJson(Map<String, dynamic> json) {
    return WeightedDecisionMatrixDto(
      id: json['id'] as String?,
      alternative: WeightedDecisionAlternativeDto.fromJson(json['alternative']),
      ratings: (json['ratings'] as List)
          .map((e) => WeightedDecisionRatingDto.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'alternative': alternative.toJson(),
        'ratings': ratings.map((e) => e.toJson()).toList(),
      };

  WeightedDecisionMatrixDto copyWith({
    String? id,
    WeightedDecisionAlternativeDto? alternative,
    List<WeightedDecisionRatingDto>? ratings,
  }) {
    return WeightedDecisionMatrixDto(
      id: id ?? this.id,
      alternative: alternative ?? this.alternative,
      ratings: ratings ?? this.ratings,
    );
  }
}
