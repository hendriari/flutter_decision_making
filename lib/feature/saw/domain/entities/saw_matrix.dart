import 'package:flutter_decision_making/feature/saw/domain/entities/saw_alternative.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_rating.dart';

class SawMatrix {
  final String? id;
  final SawAlternative alternative;
  final List<SawRating> ratings;

  SawMatrix({
    this.id,
    required this.alternative,
    required this.ratings,
  });

  SawMatrix copyWith({
    String? id,
    SawAlternative? alternative,
    List<SawRating>? ratings,
  }) {
    return SawMatrix(
      id: id ?? this.id,
      alternative: alternative ?? this.alternative,
      ratings: ratings ?? this.ratings,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SawMatrix && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
