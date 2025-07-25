import 'dart:developer' as dev;

import 'package:flutter_decision_making/core/decision_making_performance_profiling.dart';

/// CHECK CONSISTENCY RATIO
Future<Map<String, dynamic>> ahpCheckConsistencyRatio(
  Map<String, dynamic> data,
) async {
  startPerformanceProfiling('check consistency ratio');
  try {
    final matrixRaw = data['matrix'] as List<dynamic>;
    final priorityRaw = data['priority_vector'] as List<dynamic>;
    final source = data['source'] as String;

    final matrix = matrixRaw
        .map((row) => (row as List<dynamic>).map((e) => e as double).toList())
        .toList();

    final priorityVector = priorityRaw.map((e) => e as double).toList();

    final int n = matrix.length;

    if (n == 0 || priorityVector.isEmpty || priorityVector.length != n) {
      throw ArgumentError(
        'Matrix and priority vector must be non-empty and of the same size.',
      );
    }

    if (priorityVector.any((e) => e == 0)) {
      throw ArgumentError(
          'Priority vector contains zero, cannot divide by zero.');
    }

    List<double> weightedSums = List.filled(n, 0);
    for (int i = 0; i < n; i++) {
      double sum = 0;
      for (int j = 0; j < n; j++) {
        sum += matrix[i][j] * priorityVector[j];
      }
      weightedSums[i] = sum;
    }

    double lambdaMax = 0;
    for (int i = 0; i < n; i++) {
      lambdaMax += weightedSums[i] / priorityVector[i];
    }
    lambdaMax /= n;

    double ci = (lambdaMax - n) / (n - 1);

    final ri = _getRI(n);
    if (ri == 0) {
      return {
        "source": source,
        "ratio": 0,
        "is_consistent": true,
      };
    }

    final cr = ci / ri;

    dev.log('λmax: $lambdaMax, CI: $ci, CR: $cr', name: 'DECISION MAKING');

    if ((cr - 0.1) > 1e-5) {
      return {
        "source": source,
        "ratio": cr,
        "is_consistent": false,
      };
    }

    return {
      "source": source,
      "ratio": cr,
      "is_consistent": true,
    };
  } finally {
    endPerformanceProfiling('check consistency ratio');
  }
}

/// RANDOM INDEX
double _getRI(int n) {
  const Map<int, double> riTable = {
    1: 0.0,
    2: 0.0,
    3: 0.58,
    4: 0.90,
    5: 1.12,
    6: 1.24,
    7: 1.32,
    8: 1.41,
    9: 1.45,
    10: 1.49,
    11: 1.51,
    12: 1.48,
    13: 1.56,
    14: 1.57,
    15: 1.59,
  };
  return riTable[n] ?? 1.59;
}
