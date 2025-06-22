import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_item_dto.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_item.dart';

extension AhpItemMapper on AhpItemDto {
  AhpItem toEntity() {
    return AhpItem(
      id: id,
      name: name,
      shortName: shortName,
    );
  }

  static AhpItemDto fromEntity(AhpItem entity) {
    return AhpItemDto(
      id: entity.id,
      name: entity.name,
      shortName: entity.shortName,
    );
  }
}
