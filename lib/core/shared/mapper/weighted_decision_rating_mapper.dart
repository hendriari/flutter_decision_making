import 'package:flutter_decision_making/core/shared/dto/weighted_decision_rating_dto.dart';
import 'package:flutter_decision_making/core/shared/mapper/weighted_decision_criteria_mapper.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_rating.dart';

extension WeightedDecisionRatingMapper on WeightedDecisionRatingDto {
  WeightedDecisionRating toEntity() => WeightedDecisionRating(
        id: id,
        criteria: criteria?.toEntity(),
        value: value,
      );
}

extension WeightedDecisionRatingEntityMapper on WeightedDecisionRating {
  WeightedDecisionRatingDto toDto() => WeightedDecisionRatingDto(
        id: id,
        criteria: criteria?.toDto(),
        value: value,
      );
}
