import 'package:flutter_decision_making/core/shared/dto/weighted_decision_criteria_dto.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_criteria.dart';

extension WeightedDecisionCriteriaMapper on WeightedDecisionCriteriaDto {
  WeightedDecisionCriteria toEntity() => WeightedDecisionCriteria(
        id: id,
        name: name,
        isBenefit: isBenefit,
        weightPercent: weightPercent,
        maxValue: maxValue,
        description: description,
      );
}

extension WeightedDecisionCriteriaEntityMapper on WeightedDecisionCriteria {
  WeightedDecisionCriteriaDto toDto() => WeightedDecisionCriteriaDto(
        id: id,
        name: name,
        isBenefit: isBenefit,
        weightPercent: weightPercent,
        maxValue: maxValue,
        description: description,
      );
}
