import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_item.dart';

/// HIERARCHY ENTITIES
class AhpHierarchy {
  final AhpItem criteria;
  final List<AhpItem> alternative;

  const AhpHierarchy({
    required this.criteria,
    required this.alternative,
  });
}
