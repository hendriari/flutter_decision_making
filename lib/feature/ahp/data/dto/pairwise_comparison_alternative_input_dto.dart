import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_item_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/pairwise_comparison_input_dto.dart';

class PairwiseAlternativeInputDto {
  final AhpItemDto criteria;
  final List<PairwiseComparisonInputDto> alternative;

  const PairwiseAlternativeInputDto({
    required this.criteria,
    required this.alternative,
  });

  factory PairwiseAlternativeInputDto.fromMap(Map<String, dynamic> map) {
    return PairwiseAlternativeInputDto(
      criteria: AhpItemDto.fromMap(map['criteria']),
      alternative: List<PairwiseComparisonInputDto>.from(
        (map['alternative'] as List)
            .map((item) => PairwiseComparisonInputDto.fromMap(item)),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'criteria': criteria.toMap(),
      'alternative': alternative.map((e) => e.toMap()).toList(),
    };
  }
}
