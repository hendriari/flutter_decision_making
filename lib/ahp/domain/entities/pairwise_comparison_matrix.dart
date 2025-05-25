import 'package:flutter_decision_making/ahp/domain/entities/pairwise_comparison_scale.dart';

class PairwiseComparisonInput<T> {
  final String? id;
  final T left;
  final T right;
  final PairwiseComparisonScale? preferenceValue;

  const PairwiseComparisonInput({
    required this.id,
    required this.left,
    required this.right,
    this.preferenceValue,
  });

  PairwiseComparisonInput<T> copyWith({
    PairwiseComparisonScale? preferenceValue,
  }) => PairwiseComparisonInput(
    id: this.id,
    left: this.left,
    right: this.right,
    preferenceValue: preferenceValue ?? this.preferenceValue,
  );
}
