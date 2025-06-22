/// CRITERIA OR ALTERNATIVE ENTITIES
class AhpItem {
  final String? id;
  final String name;
  final String? shortName;

  const AhpItem({
    this.id,
    required this.name,
    this.shortName,
  });

  AhpItem copyWith({
    String? id,
    String? name,
    String? shortName,
  }) =>
      AhpItem(
        id: id ?? this.id,
        name: name ?? this.name,
        shortName: shortName ?? this.shortName,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AhpItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
