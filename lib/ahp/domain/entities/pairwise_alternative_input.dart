import 'package:flutter_decision_making/ahp/domain/entities/alternative.dart';
import 'package:flutter_decision_making/ahp/domain/entities/criteria.dart';
import 'package:flutter_decision_making/ahp/domain/entities/pairwise_comparison_input.dart';

class PairwiseAlternativeInput {
  final Criteria criteria;
  final List<PairwiseComparisonInput<Alternative>> alternative;

  PairwiseAlternativeInput({
    required this.criteria,
    required this.alternative,
  });

  PairwiseAlternativeInput copyWith({
    List<PairwiseComparisonInput<Alternative>>? alternative,
  }) => PairwiseAlternativeInput(
    criteria: criteria,
    alternative: alternative ?? this.alternative,
  );
}
