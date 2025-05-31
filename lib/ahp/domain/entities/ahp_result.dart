import 'package:flutter_decision_making/ahp/domain/entities/ahp_weigth.dart';

class AhpResult<T> {
  final List<AhpWeight<T>> weights;
  final double consistencyRatio;
  final bool isConsistent;

  AhpResult({
    required this.weights,
    required this.consistencyRatio,
    required this.isConsistent,
  });
}
