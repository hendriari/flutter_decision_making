import 'package:flutter_decision_making/feature/saw/domain/entities/saw_alternative.dart';

class SawResult {
  final String? id;
  final SawAlternative alternative;
  final double score;
  final int rank;

  SawResult({
    this.id,
    required this.alternative,
    required this.score,
    required this.rank,
  });

  SawResult copyWith({
    String? id,
    SawAlternative? alternative,
    double? score,
    int? rank,
  }) =>
      SawResult(
        id: id ?? this.id,
        alternative: alternative ?? this.alternative,
        score: score ?? this.score,
        rank: rank ?? this.rank,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SawResult && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
