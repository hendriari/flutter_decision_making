import 'package:flutter_decision_making/feature/saw/data/dto/saw_rating_dto.dart';
import 'package:flutter_decision_making/feature/saw/data/mapper/saw_criteria_mapper.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_rating.dart';

extension SawRatingMapper on SawRatingDto {
  SawRating toEntity() => SawRating(
        id: id,
        criteria: criteria?.toEntity(),
        value: value,
      );
}

extension SawRatingEntityMapper on SawRating {
  SawRatingDto toDto() => SawRatingDto(
        id: id,
        criteria: criteria?.toDto(),
        value: value,
      );
}
