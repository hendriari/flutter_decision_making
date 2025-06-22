class AhpConsistencyRatioDto {
  final String source;
  final double ratio;
  final bool isConsistent;

  AhpConsistencyRatioDto({
    required this.source,
    required this.ratio,
    required this.isConsistent,
  });

  factory AhpConsistencyRatioDto.fromMap(Map<String, dynamic> map) {
    return AhpConsistencyRatioDto(
      source: map['source'] as String,
      ratio: (map['ratio'] as num).toDouble(),
      isConsistent: map['is_consistent'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'source': source,
      'ratio': ratio,
      'is_consistent': isConsistent,
    };
  }
}
