/// PAIRWISE COMPARISON INPUT [GENERIC]
class PairwiseComparisonInput<T> {
  final String? id;
  final T left;
  final T right;
  final int? preferenceValue;
  final bool? isLeftMoreImportant;

  const PairwiseComparisonInput({
    required this.id,
    required this.left,
    required this.right,
    this.preferenceValue,
    required this.isLeftMoreImportant,
  });

  PairwiseComparisonInput<T> copyWith({
    int? preferenceValue,
    bool? isLeftMoreImportant,
  }) =>
      PairwiseComparisonInput(
        id: this.id,
        left: this.left,
        right: this.right,
        preferenceValue: preferenceValue ?? this.preferenceValue,
        isLeftMoreImportant: isLeftMoreImportant ?? this.isLeftMoreImportant,
      );
}
