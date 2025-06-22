import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_item.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_hierarchy.dart';
import 'package:flutter_decision_making/feature/ahp/domain/repository/ahp_repository.dart';

class GenerateHierarchyUsecase {
  final AhpRepository _decisionMakingRepository;

  GenerateHierarchyUsecase(this._decisionMakingRepository);

  Future<List<AhpHierarchy>> execute({
    required List<AhpItem> criteria,
    required List<AhpItem> alternative,
  }) async =>
      await _decisionMakingRepository.generateHierarchy(criteria, alternative);
}
