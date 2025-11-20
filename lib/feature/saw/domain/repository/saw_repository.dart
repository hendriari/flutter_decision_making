import 'package:flutter_decision_making/feature/saw/domain/entities/saw_alternative.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_criteria.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_matrix.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_result.dart';

abstract class SawRepository {
  Future<List<SawMatrix>> generateSawMatrix({
    required List<SawAlternative> listAlternative,
    required List<SawCriteria> listCriteria,
  });

  Future<List<SawResult>> calculateSawResult({
    required List<SawMatrix> matrix,
  });

  Future<List<SawResult>> calculateResultWithExistingMatrix({
    required List<SawMatrix> sawMatrix,
  });
}
