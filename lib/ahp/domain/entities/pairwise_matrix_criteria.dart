import 'package:flutter_decision_making/ahp/domain/entities/criteria.dart';

class PairwiseMatrixCriteria {
  final String id;
  final Criteria criteria;
  final List<List<double>> matrix;

  PairwiseMatrixCriteria({
    required this.id,
    required this.criteria,
    required this.matrix,
  });
}
