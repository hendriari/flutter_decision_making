import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_consistency_ratio_dto.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_consistency_ratio.dart';

extension AhpConsistencyRatioMapper on AhpConsistencyRatioDto {
  AhpConsistencyRatio toEntity() {
    return AhpConsistencyRatio(
      source: source,
      ratio: ratio,
      isConsistent: isConsistent,
    );
  }

  static AhpConsistencyRatioDto fromEntity(AhpConsistencyRatio entity) {
    return AhpConsistencyRatioDto(
      source: entity.source,
      ratio: entity.ratio,
      isConsistent: entity.isConsistent,
    );
  }
}
