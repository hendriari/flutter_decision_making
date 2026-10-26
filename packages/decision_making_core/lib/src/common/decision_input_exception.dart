/// Exception thrown when decision-making input or validation is invalid.
///
/// Implements [Exception] and produces an identical [toString] representation
/// (`Exception: <message>`) to preserve backwards compatibility for code parsing
/// exception messages.
class DecisionInputException implements Exception {
  /// Detailed description of the input validation failure.
  final String message;

  /// Creates a new [DecisionInputException] with the given [message].
  const DecisionInputException(this.message);

  @override
  String toString() => 'Exception: $message';
}
