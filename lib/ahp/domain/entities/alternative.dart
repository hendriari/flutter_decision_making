class Alternative {
  final String? id;
  final String name;

  const Alternative({this.id, required this.name});

  Alternative copyWith({String? id, String? name}) =>
      Alternative(id: id ?? this.id, name: name ?? this.name);
}
