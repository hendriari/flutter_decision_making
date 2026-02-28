class WeightedDecisionCriteriaDto {
  final String? id;
  final String name;
  final bool isBenefit;
  final double weightPercent;
  final double maxValue;
  final String? description;

  WeightedDecisionCriteriaDto({
    this.id,
    required this.name,
    required this.isBenefit,
    required this.weightPercent,
    required this.maxValue,
    this.description,
  });

  factory WeightedDecisionCriteriaDto.fromJson(Map<String, dynamic> json) {
    return WeightedDecisionCriteriaDto(
      id: json['id'] as String?,
      name: json['name'] as String,
      isBenefit: json['is_benefit'] as bool,
      weightPercent: (json['weight_percent'] as num).toDouble(),
      maxValue: json['max_value'] as double,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'is_benefit': isBenefit,
        'weight_percent': weightPercent,
        'max_value': maxValue,
        'description': description,
      };

  WeightedDecisionCriteriaDto copyWith({
    String? id,
    String? name,
    bool? isBenefit,
    double? weightPercent,
    double? maxValue,
    String? description,
  }) {
    return WeightedDecisionCriteriaDto(
      id: id ?? this.id,
      name: name ?? this.name,
      isBenefit: isBenefit ?? this.isBenefit,
      weightPercent: weightPercent ?? this.weightPercent,
      maxValue: maxValue ?? this.maxValue,
      description: description ?? this.description,
    );
  }
}
