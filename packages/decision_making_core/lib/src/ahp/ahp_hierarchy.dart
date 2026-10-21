import 'ahp_item.dart';

/// HIERARCHY ENTITIES
class AhpHierarchy {
  final AhpItem criteria;
  final List<AhpItem> alternative;

  const AhpHierarchy({
    required this.criteria,
    required this.alternative,
  });
}
