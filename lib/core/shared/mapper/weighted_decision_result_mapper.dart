import 'package:flutter_decision_making/core/shared/dto/weighted_decision_result_dto.dart';
import 'package:flutter_decision_making/core/shared/mapper/weighted_decision_alternative_mapper.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_result.dart';

extension WeightedDecisionResultMapper on WeightedDecisionResultDto {
  WeightedDecisionResult toEntity() => WeightedDecisionResult(
        id: id,
        alternative: alternative.toEntity(),
        score: score,
        rank: rank,
      );
}

extension WeightedDecisionResultEntityMapper on WeightedDecisionResult {
  WeightedDecisionResultDto toDto() => WeightedDecisionResultDto(
        id: id,
        alternative: alternative.toDto(),
        score: score,
        rank: rank,
      );
}
