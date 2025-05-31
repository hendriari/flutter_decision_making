class Alternative {
  final String? id;
  final String name;

  const Alternative({this.id, required this.name});

  Alternative copyWith({String? id, String? name}) =>
      Alternative(id: id ?? this.id, name: name ?? this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Alternative &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
