import 'package:flutter_decision_making/feature/saw/data/dto/saw_alternative_dto.dart';

class SawResultDto {
  final String? id;
  final SawAlternativeDto alternative;
  final double score;
  final int rank;

  SawResultDto({
    this.id,
    required this.alternative,
    required this.score,
    required this.rank,
  });

  factory SawResultDto.fromJson(Map<String, dynamic> json) {
    return SawResultDto(
      id: json['id'] as String?,
      alternative: SawAlternativeDto.fromJson(json['alternative']),
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
