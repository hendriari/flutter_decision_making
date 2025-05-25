import 'package:flutter_decision_making/ahp/domain/entities/alternative.dart';
import 'package:flutter_decision_making/ahp/domain/entities/criteria.dart';

class Hierarchy {
  final Criteria criteria;
  final List<Alternative> alternative;

  const Hierarchy({
    required this.criteria,
    required this.alternative,
  });
}
