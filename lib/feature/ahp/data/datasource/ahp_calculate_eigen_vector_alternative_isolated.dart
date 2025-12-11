import 'package:flutter_decision_making/core/decision_making_performance_profiling.dart';

/// Calculates the eigenvector (priority vector) for alternatives in AHP.
///
/// This function computes the principal eigenvector of a pairwise comparison matrix
/// using the **normalized column averaging method**. The eigenvector represents
/// the relative priorities or weights of alternatives being compared.
///
/// **Algorithm Steps:**
/// 1. Calculate column sums for the entire matrix
/// 2. Normalize each column by dividing each element by its column sum
/// 3. Calculate row averages of the normalized matrix
/// 4. The resulting row averages form the priority vector (eigenvector)
///
/// **Mathematical Formula:**
/// For a matrix M with elements m[i][j]:
/// - Column sum: colSum[j] = Σ(m[i][j]) for all i
/// - Normalized: normalized[i][j] = m[i][j] / colSum[j]
/// - Priority: priority[i] = (Σ(normalized[i][j]) for all j) / n
///
/// **Parameters:**
/// - [data]: Map containing:
///   - 'matrix': A square pairwise comparison matrix (`List<List<dynamic>>`)
///               where matrix[i][j] represents how much alternative i is
///               preferred over alternative j
///
/// **Returns:**
/// A list of doubles representing the priority weights for each alternative.
/// The sum of all priorities equals 1.0.
///
/// **Throws:**
/// - [ArgumentError] if the matrix is not square or is empty
/// - [Exception] if calculation fails for any reason
///
/// **Example:**
/// ```dart
/// final matrix = [
///   [1.0, 3.0, 5.0],
///   [0.33, 1.0, 2.0],
///   [0.2, 0.5, 1.0]
/// ];
///
/// final priorities = await ahpCalculateEigenVectorAlternative({
///   'matrix': matrix
/// });
/// // Result might be: [0.633, 0.260, 0.107]
/// ```
///
/// **Performance:**
/// Complexity is O(n²) where n is the number of alternatives.
/// Performance profiling is automatically tracked.
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

    // Step 1: Calculate column sums
    List<double> colSums = List.filled(n, 0.0);
    for (int j = 0; j < n; j++) {
      for (int i = 0; i < n; i++) {
        colSums[j] += matrix[i][j];
      }
    }

    // Step 2: Normalize matrix by dividing each element by its column sum
    List<List<double>> normalizedMatrix =
        List.generate(n, (i) => List.filled(n, 0.0));
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        normalizedMatrix[i][j] = matrix[i][j] / colSums[j];
      }
    }

    // Step 3: Calculate row averages to get priority vector
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
