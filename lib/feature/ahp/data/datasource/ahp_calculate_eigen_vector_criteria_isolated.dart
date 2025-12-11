import 'package:flutter_decision_making/core/decision_making_performance_profiling.dart';

/// Calculates the eigenvector (priority vector) for criteria in AHP.
///
/// This function computes the principal eigenvector of a pairwise comparison matrix
/// representing criteria comparisons. The eigenvector represents the relative weights
/// or importance of each criterion in the decision-making process.
///
/// **Algorithm: Normalized Column Averaging Method**
///
/// This is a simplified approximation method that works well for consistent
/// or nearly consistent matrices:
///
/// 1. **Calculate column sums**: Sum all values in each column
/// 2. **Normalize columns**: Divide each element by its column sum
/// 3. **Average rows**: Calculate the average of each row in the normalized matrix
/// 4. **Result**: The row averages form the priority vector
///
/// **Mathematical Representation:**
/// ```
/// Given matrix M[i][j] where i,j are criteria indices:
///
/// colSum[j] = Σ M[i][j] for all i
/// normalized[i][j] = M[i][j] / colSum[j]
/// priority[i] = (Σ normalized[i][j] for all j) / n
///
/// Where n is the number of criteria
/// ```
///
/// **Parameters:**
/// - [data]: Map containing:
///   - 'matrix': Square pairwise comparison matrix (`List<List<dynamic>>`)
///               where matrix[i][j] indicates how much criterion i is
///               preferred over criterion j using Saaty's 1-9 scale
///
/// **Returns:**
/// List of priority weights for each criterion. The weights sum to 1.0,
/// representing the relative importance of each criterion.
///
/// **Throws:**
/// - [Exception] if matrix processing fails
///
/// **Example:**
/// ```dart
/// // Comparing 3 criteria: Cost, Quality, Time
/// final matrix = [
///   [1.0, 0.5, 3.0],  // Cost vs others
///   [2.0, 1.0, 4.0],  // Quality vs others
///   [0.33, 0.25, 1.0] // Time vs others
/// ];
///
/// final weights = await ahpCalculateEigenVectorCriteria({
///   'matrix': matrix
/// });
/// // Result might be: [0.279, 0.595, 0.126]
/// // Quality has highest priority (59.5%)
/// ```
///
/// **Saaty's 1-9 Scale:**
/// - 1: Equal importance
/// - 3: Moderate importance
/// - 5: Strong importance
/// - 7: Very strong importance
/// - 9: Extreme importance
/// - 2,4,6,8: Intermediate values
///
/// **Performance:**
/// - Time complexity: O(n²) where n is the number of criteria
/// - Space complexity: O(n²) for storing normalized matrix
/// - Automatically tracked via performance profiling
Future<List<double>> ahpCalculateEigenVectorCriteria(
    Map<String, dynamic> data) async {
  startPerformanceProfiling('calculate eigen vector');
  try {
    final matrixRaw = data['matrix'] as List<List<dynamic>>;

    final matrix =
        matrixRaw.map((row) => (row).map((e) => e as double).toList()).toList();

    // Step 1: Calculate column sums
    List<double> colSums = List.filled(matrix.length, 0);

    for (int j = 0; j < matrix.length; j++) {
      for (int i = 0; i < matrix.length; i++) {
        colSums[j] += matrix[i][j];
      }
    }

    // Step 2 & 3: Normalize and calculate row averages (priorities)
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
