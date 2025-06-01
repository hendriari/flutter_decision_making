class ConsistencyRatioException implements Exception {
  final String type;
  final double value;

  ConsistencyRatioException({
    required this.type,
    required this.value,
  });

  @override
  String toString() {
    final readableType = type == 'criteria' ? 'Criteria' : 'Alternative';
    return '$readableType consistency ratio exceeds limit (CR = ${value.toStringAsFixed(3)}).\nPlease double check the comparison weights for accurate results.';
  }
}
