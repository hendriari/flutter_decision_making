/// PAIRWISE COMPARISON SCALE
class AhpComparisonScale {
  final String? id;
  final String description;
  final int value;

  AhpComparisonScale({
    required this.id,
    required this.description,
    required this.value,
  });

  AhpComparisonScale copyWith({
    String? description,
  }) =>
      AhpComparisonScale(
        id: id,
        description: description ?? this.description,
        value: value,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AhpComparisonScale &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
