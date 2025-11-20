import 'package:flutter_decision_making/feature/saw/data/dto/saw_matrix_dto.dart';
import 'package:flutter_decision_making/feature/saw/data/mapper/saw_alternative_mapper.dart';
import 'package:flutter_decision_making/feature/saw/data/mapper/saw_rating_mapper.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_matrix.dart';

extension SawMatrixMapper on SawMatrixDto {
  SawMatrix toEntity() => SawMatrix(
        id: id,
        alternative: alternative.toEntity(),
        ratings: ratings.map((e) => e.toEntity()).toList(),
      );
}

extension SawMatrixEntityMapper on SawMatrix {
  SawMatrixDto toDto() => SawMatrixDto(
        id: id,
        alternative: alternative.toDto(),
        ratings: ratings.map((e) => e.toDto()).toList(),
      );
}
