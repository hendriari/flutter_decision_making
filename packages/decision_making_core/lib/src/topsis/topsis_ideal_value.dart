/// Represents the Positive Ideal Solution (A+) and Negative Ideal Solution (A-).
class TopsisIdealValue {
  final Map<String, dynamic> positiveIdeal;
  final Map<String, dynamic> negativeIdeal;

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
