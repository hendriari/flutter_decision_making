import 'package:flutter_decision_making/feature/saw/data/dto/saw_criteria_dto.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_criteria.dart';

extension SawCriteriaMapper on SawCriteriaDto {
  SawCriteria toEntity() => SawCriteria(
        id: id,
        name: name,
        isBenefit: isBenefit,
        weightPercent: weightPercent,
        description: description,
      );
}

extension SawCriteriaEntityMapper on SawCriteria {
  SawCriteriaDto toDto() => SawCriteriaDto(
        id: id,
        name: name,
        isBenefit: isBenefit,
        weightPercent: weightPercent,
        description: description,
      );
}
