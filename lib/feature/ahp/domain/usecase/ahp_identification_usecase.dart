import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_item.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_identification.dart';
import 'package:flutter_decision_making/feature/ahp/domain/repository/ahp_repository.dart';

class AhpIdentificationUsecase {
  final AhpRepository _decisionMakingRepository;

  AhpIdentificationUsecase(this._decisionMakingRepository);

  Future<AhpIdentification> execute(
    List<AhpItem> criteria,
    List<AhpItem> alternative,
  ) async =>
      await _decisionMakingRepository.identification(criteria, alternative);
}
