import 'package:flutter_decision_making/feature/topsis/domain/entities/topsis_alternative.dart';

/// RESULT
class TopsisResult {
  final String? id;
  final TopsisAlternative alternative;
  final double score;
  final int rank;

  TopsisResult({
    this.id,
    required this.alternative,
    required this.score,
    required this.rank,
  });

  TopsisResult copyWith({
    String? id,
    TopsisAlternative? alternative,
    double? score,
    int? rank,
  }) =>
      TopsisResult(
        id: id ?? this.id,
        alternative: alternative ?? this.alternative,
        score: score ?? this.score,
        rank: rank ?? this.rank,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopsisResult &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
