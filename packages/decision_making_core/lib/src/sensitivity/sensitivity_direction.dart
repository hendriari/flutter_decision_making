/// Direction of weight perturbation in sensitivity analysis.
enum SensitivityDirection {
  /// Perturb weight upward by +delta: w_k' = w_k * (1 + delta)
  increase('+'),

  /// Perturb weight downward by -delta: w_k' = w_k * (1 - delta)
  decrease('-');

  /// String symbol representation of the perturbation direction.
  final String symbol;

  const SensitivityDirection(this.symbol);

  @override
  String toString() => symbol;
}
