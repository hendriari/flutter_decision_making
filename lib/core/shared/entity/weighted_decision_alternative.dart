/// ALTERNATIVE
class WeightedDecisionAlternative {
  final String? id;
  final String name;
  final String? note;

  WeightedDecisionAlternative({
    this.id,
    required this.name,
    this.note,
  });

  WeightedDecisionAlternative copyWith({
    String? id,
    String? name,
    String? note,
  }) =>
      WeightedDecisionAlternative(
        id: id ?? this.id,
        name: name ?? this.name,
        note: note ?? this.note,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightedDecisionAlternative &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
