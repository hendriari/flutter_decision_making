import '../common/weighted_decision_matrix.dart';

/// Extension of WeightedDecisionMatrix that holds TOPSIS separation distances (D+ and D-).
class TopsisMatrix extends WeightedDecisionMatrix {
  TopsisMatrix({
    required super.alternative,
    required super.ratings,
    required this.distanceMinus,
    required this.distancePlus,
  });

  final double distancePlus;
  final double distanceMinus;
}
