/// Represents an unordered pair of alternative IDs whose ranking order swapped or reversed.
class AlternativePair {
  /// First alternative ID.
  final String firstId;

  /// Second alternative ID.
  final String secondId;

  const AlternativePair(this.firstId, this.secondId);

  /// Checks if this pair contains the given alternative [id].
  bool contains(String id) => firstId == id || secondId == id;

  /// Checks whether this pair matches the two specified alternative IDs in any order.
  bool matches(String idA, String idB) =>
      (firstId == idA && secondId == idB) ||
      (firstId == idB && secondId == idA);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlternativePair &&
          ((firstId == other.firstId && secondId == other.secondId) ||
              (firstId == other.secondId && secondId == other.firstId));

  @override
  int get hashCode => firstId.hashCode ^ secondId.hashCode;

  /// Converts this pair to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'first_id': firstId,
        'second_id': secondId,
      };

  @override
  String toString() => 'AlternativePair($firstId, $secondId)';
}
