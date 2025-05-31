class Criteria {
  final String? id;
  final String name;

  const Criteria({this.id, required this.name});

  Criteria copyWith({String? id, String? name}) =>
      Criteria(id: id ?? this.id, name: name ?? this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Criteria &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}
