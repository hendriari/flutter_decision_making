import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_item.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/identification.dart';
import 'package:flutter_decision_making/feature/ahp/domain/repository/decision_making_repository.dart';

class IdentificationUsecase {
  final AhpRepository _decisionMakingRepository;

  IdentificationUsecase(this._decisionMakingRepository);

  Future<Identification> execute(
    List<AhpItem> criteria,
    List<AhpItem> alternative,
  ) async =>
      await _decisionMakingRepository.identification(criteria, alternative);
}
