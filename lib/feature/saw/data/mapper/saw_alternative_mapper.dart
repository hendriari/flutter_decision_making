import 'package:flutter_decision_making/feature/saw/data/dto/saw_alternative_dto.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_alternative.dart';

extension SawAlternativeMapper on SawAlternativeDto {
  SawAlternative toEntity() => SawAlternative(
        id: id,
        name: name,
        note: note,
      );
}

extension SawAlternativeEntityMapper on SawAlternative {
  SawAlternativeDto toDto() => SawAlternativeDto(
        id: id,
        name: name,
        note: note,
      );
}
