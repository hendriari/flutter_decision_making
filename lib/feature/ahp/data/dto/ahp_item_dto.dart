class AhpItemDto {
  final String? id;
  final String name;
  final String? shortName;

  AhpItemDto({
    this.id,
    required this.name,
    this.shortName,
  });

  factory AhpItemDto.fromMap(Map<String, dynamic> map) {
    return AhpItemDto(
      id: map['id'],
      name: map['name'],
      shortName: map['short_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'short_name': shortName,
    };
  }
}
