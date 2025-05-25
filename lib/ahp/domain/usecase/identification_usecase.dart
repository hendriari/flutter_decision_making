import 'package:flutter_decision_making/ahp/domain/entities/alternative.dart';
import 'package:flutter_decision_making/ahp/domain/entities/criteria.dart';
import 'package:flutter_decision_making/ahp/domain/entities/identification.dart';
import 'package:flutter_decision_making/ahp/domain/repository/decision_making_repository.dart';

class IdentificationUsecase {
  final DecisionMakingRepository _decisionMakingRepository;

  IdentificationUsecase(this._decisionMakingRepository);

  Future<Identification> execute(
    List<Criteria> criteria,
    List<Alternative> alternative,
  ) async =>
      await _decisionMakingRepository.identification(criteria, alternative);
}
