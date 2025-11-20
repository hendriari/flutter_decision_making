class SawCriteriaDto {
  final String? id;
  final String name;
  final bool isBenefit;
  final double weightPercent;
  final String? description;

  SawCriteriaDto({
    this.id,
    required this.name,
    required this.isBenefit,
    required this.weightPercent,
    this.description,
  });

  factory SawCriteriaDto.fromJson(Map<String, dynamic> json) {
    return SawCriteriaDto(
      id: json['id'] as String?,
      name: json['name'] as String,
      isBenefit: json['is_benefit'] as bool,
      weightPercent: (json['weight_percent'] as num).toDouble(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'is_benefit': isBenefit,
        'weight_percent': weightPercent,
        'description': description,
      };

  SawCriteriaDto copyWith({
    String? id,
    String? name,
    bool? isBenefit,
    double? weightPercent,
    String? description,
  }) {
    return SawCriteriaDto(
      id: id ?? this.id,
      name: name ?? this.name,
      isBenefit: isBenefit ?? this.isBenefit,
      weightPercent: weightPercent ?? this.weightPercent,
      description: description ?? this.description,
    );
  }
}
