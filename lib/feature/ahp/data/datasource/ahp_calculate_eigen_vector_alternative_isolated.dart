import 'package:flutter_decision_making/core/decision_making_performance_profiling.dart';

/// CALCULATE EIGEN VECTOR ALTERNATIVE
Future<List<double>> ahpCalculateEigenVectorAlternative(
    Map<String, dynamic> data) async {
  startPerformanceProfiling('calculate eigen vector alternative');
  try {
    final matrixRaw = data['matrix'] as List<List<dynamic>>;

    final matrix =
        matrixRaw.map((row) => (row).map((e) => e as double).toList()).toList();

    final int n = matrix.length;

    if (n == 0 || matrix.any((row) => row.length != n)) {
      throw ArgumentError('Matrix must be square and non-empty.');
    }

    List<double> colSums = List.filled(n, 0.0);
    for (int j = 0; j < n; j++) {
      for (int i = 0; i < n; i++) {
        colSums[j] += matrix[i][j];
      }
    }

    List<List<double>> normalizedMatrix =
        List.generate(n, (i) => List.filled(n, 0.0));
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        normalizedMatrix[i][j] = matrix[i][j] / colSums[j];
      }
    }

    List<double> priorities = List.filled(n, 0.0);
    for (int i = 0; i < n; i++) {
      double rowSum = 0.0;
      for (int j = 0; j < n; j++) {
        rowSum += normalizedMatrix[i][j];
      }
      priorities[i] = rowSum / n;
    }

    return priorities;
  } catch (e) {
    throw Exception('Failed to calculate eigen vector alternative: $e');
  } finally {
    endPerformanceProfiling('calculate eigen vector alternative');
  }
}
