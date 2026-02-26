import 'package:flutter_decision_making/feature/topsis/data/dto/topsis_session_dto.dart';
import 'package:flutter_decision_making/feature/topsis/domain/entities/topsis_session.dart';

import '../../../../core/shared/mapper/weighted_decision_criteria_mapper.dart';
import '../../../../core/shared/mapper/weighted_decision_matrix_mapper.dart';

extension TopsisSessionMapper on TopsisSessionDto {
  TopsisSession toEntity() => TopsisSession(
        criterias: criterias.map((e) => e.toEntity()).toList(),
        matrixs: matrixs.map((e) => e.toEntity()).toList(),
      );
}

extension TopsisSessionEntityMapper on TopsisSession {
  TopsisSessionDto toDto() => TopsisSessionDto(
        criterias: criterias.map((e) => e.toDto()).toList(),
        matrixs: matrixs.map((e) => e.toDto()).toList(),
      );
}
