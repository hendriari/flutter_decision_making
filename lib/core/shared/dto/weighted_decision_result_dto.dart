import 'package:flutter_decision_making/core/shared/dto/weighted_decision_alternative_dto.dart';

class WeightedDecisionResultDto {
  final String? id;
  final WeightedDecisionAlternativeDto alternative;
  final double score;
  final int rank;

  WeightedDecisionResultDto({
    this.id,
    required this.alternative,
    required this.score,
    required this.rank,
  });

  factory WeightedDecisionResultDto.fromJson(Map<String, dynamic> json) {
    return WeightedDecisionResultDto(
      id: json['id'] as String?,
      alternative: WeightedDecisionAlternativeDto.fromJson(json['alternative']),
      score: (json['score'] as num).toDouble(),
      rank: json['rank'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'alternative': alternative.toJson(),
        'score': score,
        'rank': rank,
      };
}
