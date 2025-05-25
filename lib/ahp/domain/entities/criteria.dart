class Criteria {
  final String? id;
  final String name;

  const Criteria({this.id, required this.name});

  Criteria copyWith({String? id, String? name}) =>
      Criteria(id: id ?? this.id, name: name ?? this.name);
}
