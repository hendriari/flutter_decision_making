import 'dart:developer' as dev;

import 'package:flutter_decision_making/core/decision_making_performance_profiling.dart';

/// Checks the consistency ratio (CR) of an AHP pairwise comparison matrix.
///
/// The consistency ratio measures the reliability of the pairwise comparisons.
/// A lower CR indicates more consistent judgments. According to Saaty (the creator
/// of AHP), a CR of 0.1 or less is considered acceptable.
///
/// **Consistency Importance:**
/// When making pairwise comparisons, humans may introduce inconsistencies. For example:
/// - If A is 3x more important than B
/// - And B is 2x more important than C
/// - Then A should be 6x more important than C (not 4x or 8x)
///
/// The CR helps identify when these inconsistencies are too large to trust the results.
///
/// **Algorithm:**
///
/// 1. **Calculate weighted sums**: Multiply matrix by priority vector
///    `weightedSum[i] = Σ(matrix[i][j] × priorityVector[j])`
///
/// 2. **Calculate λmax** (maximum eigenvalue):
///    `λmax = (1/n) × Σ(weightedSum[i] / priorityVector[i])`
///
/// 3. **Calculate Consistency Index (CI)**:
///    `CI = (λmax - n) / (n - 1)`
///    where n is the matrix size
///
/// 4. **Calculate Consistency Ratio (CR)**:
///    `CR = CI / RI`
///    where RI is the Random Index from Saaty's table
///
/// **Random Index (RI):**
/// The RI represents the average CI of randomly generated matrices.
/// It varies based on matrix size (n):
/// - n=1,2: 0.0 (always consistent)
/// - n=3: 0.58
/// - n=4: 0.90
/// - n=5: 1.12
/// - ...up to n=15: 1.59
///
/// **Parameters:**
/// - [data]: Map containing:
///   - 'matrix': Pairwise comparison matrix (`List<dynamic>`)
///   - 'priority_vector': Eigenvector/priority weights (`List<dynamic>`)
///   - 'source': String identifying what's being checked ('criteria' or 'alternative')
///
/// **Returns:**
/// Map containing:
/// - 'source': The source identifier (criteria/alternative name)
/// - 'ratio': The consistency ratio (CR) value
/// - 'is_consistent': Boolean indicating if CR ≤ 0.1
///
/// **Throws:**
/// - [ArgumentError] if inputs are invalid (empty, mismatched sizes, zero values)
///
/// **Interpretation:**
/// - CR ≤ 0.1: Acceptable consistency, results are reliable
/// - 0.1 < CR ≤ 0.2: Marginal consistency, consider revising judgments
/// - CR > 0.2: Unacceptable inconsistency, must revise pairwise comparisons
///
/// **Example:**
/// ```dart
/// final matrix = [
///   [1.0, 3.0, 5.0],
///   [0.33, 1.0, 2.0],
///   [0.2, 0.5, 1.0]
/// ];
/// final priorities = [0.633, 0.260, 0.107];
///
/// final result = await ahpCheckConsistencyRatio({
///   'matrix': matrix,
///   'priority_vector': priorities,
///   'source': 'criteria'
/// });
///
/// // Result: {
/// //   'source': 'criteria',
/// //   'ratio': 0.05,
/// //   'is_consistent': true
/// // }
/// ```
///
/// **Performance:**
/// - Time complexity: O(n²) for matrix multiplication
/// - Space complexity: O(n) for storing weighted sums
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

    // Step 1: Calculate weighted sums (matrix × priority vector)
    List<double> weightedSums = List.filled(n, 0);
    for (int i = 0; i < n; i++) {
      double sum = 0;
      for (int j = 0; j < n; j++) {
        sum += matrix[i][j] * priorityVector[j];
      }
      weightedSums[i] = sum;
    }

    // Step 2: Calculate λmax (maximum eigenvalue)
    double lambdaMax = 0;
    for (int i = 0; i < n; i++) {
      lambdaMax += weightedSums[i] / priorityVector[i];
    }
    lambdaMax /= n;

    // Step 3: Calculate Consistency Index (CI)
    double ci = (lambdaMax - n) / (n - 1);

    // Step 4: Get Random Index (RI) and calculate CR
    final ri = _getRI(n);
    if (ri == 0) {
      // For n ≤ 2, always consistent
      return {
        "source": source,
        "ratio": 0,
        "is_consistent": true,
      };
    }

    final cr = ci / ri;

    dev.log('λmax: $lambdaMax, CI: $ci, CR: $cr', name: 'DECISION MAKING');

    // Check if CR exceeds acceptable threshold (0.1)
    // Using epsilon comparison to avoid floating point precision issues
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

/// Returns the Random Index (RI) for a given matrix size.
///
/// The RI is the average Consistency Index (CI) of randomly generated
/// reciprocal matrices. These values were empirically determined by Saaty
/// through extensive testing.
///
/// **Purpose:**
/// The RI provides a baseline for comparison. It represents the expected
/// inconsistency level in a random matrix of size n.
///
/// **Parameters:**
/// - [n]: Size of the pairwise comparison matrix (number of elements being compared)
///
/// **Returns:**
/// The Random Index value for the given matrix size.
/// For n > 15, returns 1.59 (the approximate limit value).
///
/// **RI Table (Saaty, 1980):**
/// | Matrix Size (n) | RI Value |
/// |----------------|----------|
/// | 1-2            | 0.00     |
/// | 3              | 0.58     |
/// | 4              | 0.90     |
/// | 5              | 1.12     |
/// | 6              | 1.24     |
/// | 7              | 1.32     |
/// | 8              | 1.41     |
/// | 9              | 1.45     |
/// | 10             | 1.49     |
/// | 11             | 1.51     |
/// | 12             | 1.48     |
/// | 13             | 1.56     |
/// | 14             | 1.57     |
/// | 15+            | 1.59     |
///
/// **Note:**
/// For matrices of size 1 or 2, RI is 0.0 because:
/// - Size 1: Only one element, no comparisons needed (always consistent)
/// - Size 2: Only one comparison (A vs B), no possibility of inconsistency
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
