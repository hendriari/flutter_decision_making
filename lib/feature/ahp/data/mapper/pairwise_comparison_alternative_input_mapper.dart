import 'package:flutter_decision_making/feature/ahp/data/dto/pairwise_comparison_alternative_input_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/mapper/ahp_item_mapper.dart';
import 'package:flutter_decision_making/feature/ahp/data/mapper/pairwise_comparison_input_mapper.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_alternative_input.dart';

extension PairwiseAlternativeInputMapper on PairwiseAlternativeInputDto {
  PairwiseAlternativeInput toEntity() {
    return PairwiseAlternativeInput(
      criteria: criteria.toEntity(),
      alternative: alternative.map((e) => e.toEntity()).toList(),
    );
  }

  static PairwiseAlternativeInputDto fromEntity(
      PairwiseAlternativeInput entity) {
    return PairwiseAlternativeInputDto(
      criteria: AhpItemMapper.fromEntity(entity.criteria),
      alternative: entity.alternative
          .map((e) => PairwiseComparisonInputMapper.fromEntity(e))
          .toList(),
    );
  }
}
