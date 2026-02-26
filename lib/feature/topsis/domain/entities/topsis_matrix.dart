import 'package:flutter_decision_making/feature/topsis/domain/entities/topsis_alternative.dart';
import 'package:flutter_decision_making/feature/topsis/domain/entities/topsis_rating.dart';

/// MATRIX
class TopsisMatrix {
  final String? id;
  final TopsisAlternative alternative;
  final List<TopsisRating> ratings;

  TopsisMatrix({
    this.id,
    required this.alternative,
    required this.ratings,
  });

  TopsisMatrix copyWith({
    String? id,
    TopsisAlternative? alternative,
    List<TopsisRating>? ratings,
  }) {
    return TopsisMatrix(
      id: id ?? this.id,
      alternative: alternative ?? this.alternative,
      ratings: ratings ?? this.ratings,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopsisMatrix &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
