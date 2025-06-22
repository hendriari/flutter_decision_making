import 'dart:core';

import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_hierarchy.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_alternative_input.dart';
import 'package:flutter_decision_making/feature/ahp/domain/repository/ahp_repository.dart';

class GeneratePairwiseAlternativeInputUsecase {
  final AhpRepository _ahpRepository;

  GeneratePairwiseAlternativeInputUsecase(this._ahpRepository);

  Future<List<PairwiseAlternativeInput>> execute(
    List<AhpHierarchy> nodes,
  ) async =>
      await _ahpRepository.generatePairwiseAlternative(nodes);
}
