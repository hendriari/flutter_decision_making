import 'package:flutter_decision_making/feature/saw/data/dto/saw_result_dto.dart';
import 'package:flutter_decision_making/feature/saw/data/mapper/saw_alternative_mapper.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_result.dart';

extension SawResultMapper on SawResultDto {
  SawResult toEntity() => SawResult(
    id: id,
    alternative: alternative.toEntity(),
    score: score,
    rank: rank,
  );
}

extension SawResultEntityMapper on SawResult {
  SawResultDto toDto() => SawResultDto(
    id: id,
    alternative: alternative.toDto(),
    score: score,
    rank: rank,
  );
}