class WeightedDecisionAlternativeDto {
  final String? id;
  final String name;
  final String? note;

  WeightedDecisionAlternativeDto({
    this.id,
    required this.name,
    this.note,
  });

  factory WeightedDecisionAlternativeDto.fromJson(Map<String, dynamic> json) {
    return WeightedDecisionAlternativeDto(
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
