import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_hierarchy_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/mapper/ahp_item_mapper.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_hierarchy.dart';

extension AhpHierarchyMapper on AhpHierarchyDto {
  AhpHierarchy toEntity() {
    return AhpHierarchy(
      criteria: criteria.toEntity(),
      alternative: alternative.map((e) => e.toEntity()).toList(),
    );
  }

  static AhpHierarchyDto fromEntity(AhpHierarchy entity) {
    return AhpHierarchyDto(
      criteria: AhpItemMapper.fromEntity(entity.criteria),
      alternative:
          entity.alternative.map((e) => AhpItemMapper.fromEntity(e)).toList(),
    );
  }
}
