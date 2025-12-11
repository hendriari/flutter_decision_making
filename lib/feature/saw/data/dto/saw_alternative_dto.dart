class SawAlternativeDto {
  final String? id;
  final String name;
  final String? note;

  SawAlternativeDto({
    this.id,
    required this.name,
    this.note,
  });

  factory SawAlternativeDto.fromJson(Map<String, dynamic> json) {
    return SawAlternativeDto(
      id: json['id'] as String?,
      name: json['name'] as String,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'note': note,
  };
}


