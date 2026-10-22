/// CONSISTENCY RATIO ENTITIES
class AhpConsistencyRatio {
  final String source;
  final double ratio;
  final bool isConsistent;
  final double? lambdaMax;
  final double? ci;
  final double? ri;

  AhpConsistencyRatio({
    required this.source,
    required this.ratio,
    required this.isConsistent,
    this.lambdaMax,
    this.ci,
    this.ri,
  });
}
