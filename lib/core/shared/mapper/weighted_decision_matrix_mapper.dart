import 'package:flutter_decision_making/core/shared/dto/weighted_decision_matrix_dto.dart';
import 'package:flutter_decision_making/core/shared/mapper/weighted_decision_alternative_mapper.dart';
import 'package:flutter_decision_making/core/shared/mapper/weighted_decision_rating_mapper.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_matrix.dart';

extension WeightedDecisionMatrixMapper on WeightedDecisionMatrixDto {
  WeightedDecisionMatrix toEntity() => WeightedDecisionMatrix(
        id: id,
        alternative: alternative.toEntity(),
        ratings: ratings.map((e) => e.toEntity()).toList(),
      );
}

extension WeightedDecisionMatrixEntityMapper on WeightedDecisionMatrix {
  WeightedDecisionMatrixDto toDto() => WeightedDecisionMatrixDto(
        id: id,
        alternative: alternative.toDto(),
        ratings: ratings.map((e) => e.toDto()).toList(),
      );
}
