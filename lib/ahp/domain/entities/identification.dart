import 'package:flutter_decision_making/ahp/domain/entities/alternative.dart';
import 'package:flutter_decision_making/ahp/domain/entities/criteria.dart';

/// IDENTIFICATION ENTITIES
class Identification {
  final List<Criteria> criteria;
  final List<Alternative> alternative;

  Identification({required this.criteria, required this.alternative});
}
