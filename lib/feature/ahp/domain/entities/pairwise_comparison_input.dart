import 'ahp_item.dart';

/// PAIRWISE COMPARISON INPUT
class PairwiseComparisonInput {
  final String? id;
  final AhpItem left;
  final AhpItem right;
  final int? preferenceValue;
  final bool? isLeftMoreImportant;

  const PairwiseComparisonInput({
    required this.id,
    required this.left,
    required this.right,
    this.preferenceValue,
    required this.isLeftMoreImportant,
  });

  PairwiseComparisonInput copyWith({
    int? preferenceValue,
    bool? isLeftMoreImportant,
  }) =>
      PairwiseComparisonInput(
        id: id,
        left: left,
        right: right,
        preferenceValue: preferenceValue ?? this.preferenceValue,
        isLeftMoreImportant: isLeftMoreImportant ?? this.isLeftMoreImportant,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PairwiseComparisonInput &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
