import 'package:flutter_decision_making/core/decision_making_performance_profiling.dart';

/// CALCULATE EIGEN VECTOR CRITERIA
Future<List<double>> ahpCalculateEigenVectorCriteria(
    Map<String, dynamic> data) async {
  startPerformanceProfiling('calculate eigen vector');
  try {
    final matrixRaw = data['matrix'] as List<List<dynamic>>;

    final matrix =
        matrixRaw.map((row) => (row).map((e) => e as double).toList()).toList();

    List<double> colSums = List.filled(matrix.length, 0);

    for (int j = 0; j < matrix.length; j++) {
      for (int i = 0; i < matrix.length; i++) {
        colSums[j] += matrix[i][j];
      }
    }

    List<double> priorities = List.filled(matrix.length, 0);

    for (int i = 0; i < matrix.length; i++) {
      double sum = 0;
      for (int j = 0; j < matrix.length; j++) {
        sum += matrix[i][j] / colSums[j];
      }
      priorities[i] = sum / matrix.length;
    }

    return priorities;
  } catch (e) {
    throw Exception('Failed calculate eigen vector $e');
  } finally {
    endPerformanceProfiling('calculate eigen vector');
  }
}
