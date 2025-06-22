import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_item.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_comparison_input.dart';

/// PAIRWISE ALTERNATIVE INPUT ENTITIES
class PairwiseAlternativeInput {
  final AhpItem criteria;
  final List<PairwiseComparisonInput> alternative;

  PairwiseAlternativeInput({
    required this.criteria,
    required this.alternative,
  });

  PairwiseAlternativeInput copyWith({
    List<PairwiseComparisonInput>? alternative,
  }) =>
      PairwiseAlternativeInput(
        criteria: criteria,
        alternative: alternative ?? this.alternative,
      );
}
