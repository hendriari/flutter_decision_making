import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_item.dart';

/// HIERARCHY ENTITIES
class Hierarchy {
  final AhpItem criteria;
  final List<AhpItem> alternative;

  const Hierarchy({
    required this.criteria,
    required this.alternative,
  });
}
