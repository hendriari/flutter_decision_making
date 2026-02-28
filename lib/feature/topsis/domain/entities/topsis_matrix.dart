import 'package:flutter_decision_making/core/shared/entity/weighted_decision_matrix.dart';

class TopsisMatrix extends WeightedDecisionMatrix {
  TopsisMatrix({
    required super.alternative,
    required super.ratings,
    required this.distanceMinus,
    required this.distancePlus,
  });

  final double distancePlus, distanceMinus;
}
