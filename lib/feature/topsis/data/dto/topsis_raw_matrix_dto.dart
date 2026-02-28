import 'package:flutter_decision_making/core/shared/dto/weighted_decision_criteria_dto.dart';
import 'package:flutter_decision_making/core/shared/dto/weighted_decision_matrix_dto.dart';

class TopsisMatrixDto {
  final List<WeightedDecisionCriteriaDto> criterias;
  final List<WeightedDecisionMatrixDto> matrixs;

  TopsisMatrixDto({
    required this.criterias,
    required this.matrixs,
  });

  factory TopsisMatrixDto.fromJson(Map<String, dynamic> json) {
    return TopsisMatrixDto(
      criterias: (json["criterias"] as List)
          .map((e) => WeightedDecisionCriteriaDto.fromJson(e))
          .toList(),
      matrixs: (json["matrixs"] as List)
          .map((e) => WeightedDecisionMatrixDto.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        "criterias": criterias.map((e) => e.toJson()).toList(),
        "matrixs": matrixs.map((e) => e.toJson()).toList(),
      };

  TopsisMatrixDto copyWith({
    List<WeightedDecisionCriteriaDto>? criterias,
    List<WeightedDecisionMatrixDto>? matrixs,
  }) {
    return TopsisMatrixDto(
        criterias: criterias ?? this.criterias,
        matrixs: matrixs ?? this.matrixs);
  }
}
