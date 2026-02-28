import 'package:flutter_decision_making/feature/topsis/data/dto/topsis_raw_matrix_dto.dart';
import 'package:flutter_decision_making/feature/topsis/domain/entities/topsis_raw_matrix.dart';

import '../../../../core/shared/mapper/weighted_decision_criteria_mapper.dart';
import '../../../../core/shared/mapper/weighted_decision_matrix_mapper.dart';

extension TopsisMatrixMapper on TopsisMatrixDto {
  TopsisRawMatrix toEntity() => TopsisRawMatrix(
        criterias: criterias.map((e) => e.toEntity()).toList(),
        matrixs: matrixs.map((e) => e.toEntity()).toList(),
      );
}

extension TopsisMatrixEntityMapper on TopsisRawMatrix {
  TopsisMatrixDto toDto() => TopsisMatrixDto(
        criterias: criterias.map((e) => e.toDto()).toList(),
        matrixs: matrixs.map((e) => e.toDto()).toList(),
      );
}
