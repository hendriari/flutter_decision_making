import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_item.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/hierarchy.dart';
import 'package:flutter_decision_making/feature/ahp/domain/repository/decision_making_repository.dart';

class GenerateHierarchyUsecase {
  final AhpRepository _decisionMakingRepository;

  GenerateHierarchyUsecase(this._decisionMakingRepository);

  Future<List<Hierarchy>> execute({
    required List<AhpItem> criteria,
    required List<AhpItem> alternative,
  }) async =>
      await _decisionMakingRepository.generateHierarchy(criteria, alternative);
}
