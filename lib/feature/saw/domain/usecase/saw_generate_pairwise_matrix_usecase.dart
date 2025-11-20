import 'package:flutter_decision_making/feature/saw/domain/entities/saw_alternative.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_criteria.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_matrix.dart';
import 'package:flutter_decision_making/feature/saw/domain/repository/saw_repository.dart';

class SawGenerateMatrixUsecase {
  final SawRepository _sawRepository;

  SawGenerateMatrixUsecase(this._sawRepository);

  Future<List<SawMatrix>> execute({
    required List<SawAlternative> listAlternative,
    required List<SawCriteria> listCriteria,
  }) async =>
      await _sawRepository.generateSawMatrix(
        listAlternative: listAlternative,
        listCriteria: listCriteria,
      );
}
