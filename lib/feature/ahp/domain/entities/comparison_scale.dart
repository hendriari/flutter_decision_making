/// PAIRWISE COMPARISON SCALE
class ComparisonScale {
  final String? id;
  final String description;
  final int value;

  ComparisonScale({
    required this.id,
    required this.description,
    required this.value,
  });

  ComparisonScale copyWith({
    String? description,
  }) =>
      ComparisonScale(
        id: id,
        description: description ?? this.description,
        value: value,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComparisonScale &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
