class SawCriteria {
  final String? id;
  final String name;
  final bool isBenefit;
  final double weightPercent;
  final num maxValue;
  final String? description;

  SawCriteria({
    this.id,
    required this.name,
    required this.isBenefit,
    required this.weightPercent,
    required this.maxValue,
    this.description,
  });

  SawCriteria copyWith({
    String? id,
    String? name,
    bool? isBenefit,
    double? weightPercent,
    num? maxValue,
    String? description,
  }) =>
      SawCriteria(
        id: id ?? this.id,
        name: name ?? this.name,
        isBenefit: isBenefit ?? this.isBenefit,
        weightPercent: weightPercent ?? this.weightPercent,
        maxValue: maxValue ?? this.maxValue,
        description: description ?? this.description,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SawCriteria &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
