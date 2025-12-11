class SawAlternative {
  final String? id;
  final String name;
  final String? note;

  SawAlternative({
    this.id,
    required this.name,
    this.note,
  });

  SawAlternative copyWith({
    String? id,
    String? name,
    String? note,
  }) =>
      SawAlternative(
        id: id ?? this.id,
        name: name ?? this.name,
        note: note ?? this.note,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SawAlternative &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
