import 'package:flutter_decision_making/core/shared/dto/weighted_decision_alternative_dto.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_alternative.dart';

extension WeightedDecisionAlternativeMapper on WeightedDecisionAlternativeDto {
  WeightedDecisionAlternative toEntity() => WeightedDecisionAlternative(
        id: id,
        name: name,
        note: note,
      );
}

extension SawAlternativeEntityMapper on WeightedDecisionAlternative {
  WeightedDecisionAlternativeDto toDto() => WeightedDecisionAlternativeDto(
        id: id,
        name: name,
        note: note,
      );
}
