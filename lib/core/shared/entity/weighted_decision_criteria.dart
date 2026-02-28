/// CRITERIA
class WeightedDecisionCriteria {
  final String? id;
  final String name;
  final bool isBenefit;
  final double weightPercent;
  final double maxValue;
  final String? description;

  WeightedDecisionCriteria({
    this.id,
    required this.name,
    required this.isBenefit,
    required this.weightPercent,
    required this.maxValue,
    this.description,
  });

  WeightedDecisionCriteria copyWith({
    String? id,
    String? name,
    bool? isBenefit,
    double? weightPercent,
    double? maxValue,
    String? description,
  }) =>
      WeightedDecisionCriteria(
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
      other is WeightedDecisionCriteria &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
