class TopsisIdealValue {
  final Map<String, dynamic> positiveIdeal, negativeIdeal;

  TopsisIdealValue({
    required this.positiveIdeal,
    required this.negativeIdeal,
  });

  TopsisIdealValue copyWith({
    Map<String, dynamic>? positiveIdeal,
    Map<String, dynamic>? negativeIdeal,
  }) =>
      TopsisIdealValue(
        positiveIdeal: positiveIdeal ?? this.positiveIdeal,
        negativeIdeal: negativeIdeal ?? this.negativeIdeal,
      );
}
