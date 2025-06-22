import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_item_dto.dart';

class PairwiseComparisonInputDto {
  final String? id;
  final AhpItemDto left;
  final AhpItemDto right;
  final int? preferenceValue;
  final bool? isLeftMoreImportant;

  const PairwiseComparisonInputDto({
    required this.id,
    required this.left,
    required this.right,
    this.preferenceValue,
    required this.isLeftMoreImportant,
  });

  factory PairwiseComparisonInputDto.fromMap(Map<String, dynamic> map) {
    return PairwiseComparisonInputDto(
      id: map['id'],
      left: AhpItemDto.fromMap(map['left']),
      right: AhpItemDto.fromMap(map['right']),
      preferenceValue: map['preference_value'],
      isLeftMoreImportant: map['is_left_more_important'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'left': left.toMap(),
      'right': right.toMap(),
      'preference_value': preferenceValue,
      'is_left_more_important': isLeftMoreImportant,
    };
  }
}
