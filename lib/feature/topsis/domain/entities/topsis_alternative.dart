/// ALTERNATIVE
class TopsisAlternative {
  final String? id;
  final String name;
  final String? note;

  TopsisAlternative({
    this.id,
    required this.name,
    this.note,
  });

  TopsisAlternative copyWith({
    String? id,
    String? name,
    String? note,
  }) =>
      TopsisAlternative(
        id: id ?? this.id,
        name: name ?? this.name,
        note: note ?? this.note,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TopsisAlternative &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}
