import 'ahp_item.dart';
import 'pairwise_comparison_input.dart';

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
