import 'package:flutter_decision_making/ahp/domain/entities/alternative.dart';
import 'package:flutter_decision_making/ahp/domain/entities/criteria.dart';
import 'package:flutter_decision_making/ahp/domain/entities/hierarchy.dart';
import 'package:flutter_decision_making/ahp/domain/repository/decision_making_repository.dart';

class GenerateHierarchyUsecase {
  final DecisionMakingRepository _decisionMakingRepository;

  GenerateHierarchyUsecase(this._decisionMakingRepository);

  Future<List<Hierarchy>> execute({
    required List<Criteria> criteria,
    required List<Alternative> alternative,
  }) async =>
      await _decisionMakingRepository.generateHierarchy(criteria, alternative);
}
