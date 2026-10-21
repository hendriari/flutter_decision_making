/// CONSISTENCY RATIO ENTITIES
class AhpConsistencyRatio {
  final String source;
  final double ratio;
  final bool isConsistent;
  final double? lambdaMax;
  final double? ci;

  AhpConsistencyRatio({
    required this.source,
    required this.ratio,
    required this.isConsistent,
    this.lambdaMax,
    this.ci,
  });
}
