import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_calculate_eigen_vector_criteria_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_check_consistency_ratio_isolated.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AHP Random Index (RI) Behavior Tests', () {
    // Helper to generate an n x n reciprocal matrix with a known slight inconsistency
    // (A[0][1] = 2, A[1][0] = 1/2, while other off-diagonals = 1)
    List<List<double>> createPerturbedMatrix(int n) {
      final matrix = List.generate(n, (i) => List.filled(n, 1.0));
      matrix[0][1] = 2.0;
      matrix[1][0] = 0.5;
      return matrix;
    }

    test('n = 3: uses Saaty RI = 0.58', () async {
      const n = 3;
      final matrix = createPerturbedMatrix(n);
      final priority =
          await ahpCalculateEigenVectorCriteria({'matrix': matrix});

      final result = await ahpCheckConsistencyRatio({
        'matrix': matrix,
        'priority_vector': priority,
        'source': 'test_n3',
      });

      final ci = result['ci'] as double;
      final cr = result['ratio'] as double;
      expect(ci > 0, isTrue);
      final derivedRI = ci / cr;
      expect(derivedRI, closeTo(0.58, 1e-4));
    });

    test('n = 10: uses Saaty RI = 1.49', () async {
      const n = 10;
      final matrix = createPerturbedMatrix(n);
      final priority =
          await ahpCalculateEigenVectorCriteria({'matrix': matrix});

      final result = await ahpCheckConsistencyRatio({
        'matrix': matrix,
        'priority_vector': priority,
        'source': 'test_n10',
      });

      final ci = result['ci'] as double;
      final cr = result['ratio'] as double;
      expect(ci > 0, isTrue);
      final derivedRI = ci / cr;
      expect(derivedRI, closeTo(1.49, 1e-4));
    });

    test('n = 15: uses Saaty RI = 1.59 (maximum defined entry in table)',
        () async {
      const n = 15;
      final matrix = createPerturbedMatrix(n);
      final priority =
          await ahpCalculateEigenVectorCriteria({'matrix': matrix});

      final result = await ahpCheckConsistencyRatio({
        'matrix': matrix,
        'priority_vector': priority,
        'source': 'test_n15',
      });

      final ci = result['ci'] as double;
      final cr = result['ratio'] as double;
      expect(ci > 0, isTrue);
      final derivedRI = ci / cr;
      expect(derivedRI, closeTo(1.59, 1e-4));
    });

    test('n = 16 (out of table): falls back to 1.59 without throwing',
        () async {
      const n = 16;
      final matrix = createPerturbedMatrix(n);
      final priority =
          await ahpCalculateEigenVectorCriteria({'matrix': matrix});

      final result = await ahpCheckConsistencyRatio({
        'matrix': matrix,
        'priority_vector': priority,
        'source': 'test_n16',
      });

      final ci = result['ci'] as double;
      final cr = result['ratio'] as double;
      expect(ci > 0, isTrue);
      final derivedRI = ci / cr;
      // Demonstrates current fallback: riTable[n] ?? 1.59
      expect(derivedRI, closeTo(1.59, 1e-4));
    });

    test('n = 80 (large dataset): falls back to 1.59 without throwing',
        () async {
      const n = 80;
      final matrix = createPerturbedMatrix(n);
      final priority =
          await ahpCalculateEigenVectorCriteria({'matrix': matrix});

      final result = await ahpCheckConsistencyRatio({
        'matrix': matrix,
        'priority_vector': priority,
        'source': 'test_n80',
      });

      final ci = result['ci'] as double;
      final cr = result['ratio'] as double;
      expect(ci > 0, isTrue);
      final derivedRI = ci / cr;
      // Demonstrates current fallback: riTable[n] ?? 1.59
      expect(derivedRI, closeTo(1.59, 1e-4));
    });
  });
}
