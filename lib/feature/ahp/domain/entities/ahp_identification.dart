import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_item.dart';

/// IDENTIFICATION ENTITIES
class AhpIdentification {
  final List<AhpItem> criteria;
  final List<AhpItem> alternative;

  AhpIdentification({required this.criteria, required this.alternative});
}
