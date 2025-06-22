import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_result_detail_dto.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_result_detail.dart';

extension AhpResultDetailMapper on AhpResultDetailDto {
  AhpResultDetail toEntity() {
    return AhpResultDetail(
      id: id,
      name: name,
      value: value,
    );
  }

  static AhpResultDetailDto fromEntity(AhpResultDetail entity) {
    return AhpResultDetailDto(
      id: entity.id,
      name: entity.name,
      value: entity.value,
    );
  }
}
