/// AHP RESULT DETAIL ENTITIES
class AhpResultDetail {
  final String? id;
  final String name;
  final double value;

  AhpResultDetail({
    required this.id,
    required this.name,
    required this.value,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AhpResultDetail &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
