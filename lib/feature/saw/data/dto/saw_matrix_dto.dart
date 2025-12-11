import 'package:flutter_decision_making/feature/saw/data/dto/saw_alternative_dto.dart';
import 'package:flutter_decision_making/feature/saw/data/dto/saw_rating_dto.dart';

class SawMatrixDto {
  final String? id;
  final SawAlternativeDto alternative;
  final List<SawRatingDto> ratings;

  SawMatrixDto({
    this.id,
    required this.alternative,
    required this.ratings,
  });

  factory SawMatrixDto.fromJson(Map<String, dynamic> json) {
    return SawMatrixDto(
      id: json['id'] as String?,
      alternative: SawAlternativeDto.fromJson(json['alternative']),
      ratings: (json['ratings'] as List)
          .map((e) => SawRatingDto.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'alternative': alternative.toJson(),
        'ratings': ratings.map((e) => e.toJson()).toList(),
      };

  SawMatrixDto copyWith({
    String? id,
    SawAlternativeDto? alternative,
    List<SawRatingDto>? ratings,
  }) {
    return SawMatrixDto(
      id: id ?? this.id,
      alternative: alternative ?? this.alternative,
      ratings: ratings ?? this.ratings,
    );
  }
}
