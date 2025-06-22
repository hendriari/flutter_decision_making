import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_result_dto.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_result.dart';

import 'ahp_result_detail_mapper.dart';

extension AhpResultMapper on AhpResultDto {
  AhpResult toEntity() {
    return AhpResult(
      results: results.map((e) => e.toEntity()).toList(),
      isConsistentCriteria: isConsistentCriteria,
      consistencyCriteriaRatio: consistencyCriteriaRatio,
      isConsistentAlternative: isConsistentAlternative,
      consistencyAlternativeRatio: consistencyAlternativeRatio,
      note: note,
    );
  }

  static AhpResultDto fromEntity(AhpResult entity) {
    return AhpResultDto(
      results: entity.results
          .map((e) => AhpResultDetailMapper.fromEntity(e))
          .toList(),
      isConsistentCriteria: entity.isConsistentCriteria,
      consistencyCriteriaRatio: entity.consistencyCriteriaRatio,
      isConsistentAlternative: entity.isConsistentAlternative,
      consistencyAlternativeRatio: entity.consistencyAlternativeRatio,
      note: entity.note,
    );
  }
}
