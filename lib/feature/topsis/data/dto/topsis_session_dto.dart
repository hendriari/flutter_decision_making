import 'package:flutter_decision_making/core/shared/dto/weighted_decision_criteria_dto.dart';
import 'package:flutter_decision_making/core/shared/dto/weighted_decision_matrix_dto.dart';

class TopsisSessionDto {
  final List<WeightedDecisionCriteriaDto> criterias;
  final List<WeightedDecisionMatrixDto> matrixs;

  TopsisSessionDto({
    required this.criterias,
    required this.matrixs,
  });

  factory TopsisSessionDto.fromJson(Map<String, dynamic> json) {
    return TopsisSessionDto(
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

  TopsisSessionDto copyWith({
    List<WeightedDecisionCriteriaDto>? criterias,
    List<WeightedDecisionMatrixDto>? matrixs,
  }) {
    return TopsisSessionDto(
        criterias: criterias ?? this.criterias,
        matrixs: matrixs ?? this.matrixs);
  }
}
