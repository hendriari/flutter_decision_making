import 'package:flutter_decision_making/feature/ahp/data/dto/pairwise_comparison_input_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/mapper/ahp_item_mapper.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_comparison_input.dart';

extension PairwiseComparisonInputMapper on PairwiseComparisonInputDto {
  PairwiseComparisonInput toEntity() {
    return PairwiseComparisonInput(
      id: id,
      left: left.toEntity(),
      right: right.toEntity(),
      preferenceValue: preferenceValue,
      isLeftMoreImportant: isLeftMoreImportant,
    );
  }

  static PairwiseComparisonInputDto fromEntity(PairwiseComparisonInput entity) {
    return PairwiseComparisonInputDto(
      id: entity.id,
      left: AhpItemMapper.fromEntity(entity.left),
      right: AhpItemMapper.fromEntity(entity.right),
      preferenceValue: entity.preferenceValue,
      isLeftMoreImportant: entity.isLeftMoreImportant,
    );
  }
}
