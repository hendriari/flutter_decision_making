import 'ahp_item_dto.dart';

class AhpHierarchyDto {
  final AhpItemDto criteria;
  final List<AhpItemDto> alternative;

  const AhpHierarchyDto({
    required this.criteria,
    required this.alternative,
  });

  factory AhpHierarchyDto.fromMap(Map<String, dynamic> map) => AhpHierarchyDto(
        criteria: AhpItemDto.fromMap(map['criteria']),
        alternative: List<AhpItemDto>.from((map['alternative'] as List)
            .map((data) => AhpItemDto.fromMap(data))).toList(),
      );

  Map<String, dynamic> toMap() => {
        'criteria': criteria.toMap(),
        'alternative': alternative.map((e) => e.toMap()).toList(),
      };
}
