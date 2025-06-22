import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_item.dart';

/// IDENTIFICATION ENTITIES
class Identification {
  final List<AhpItem> criteria;
  final List<AhpItem> alternative;

  Identification({required this.criteria, required this.alternative});
}
