import 'dart:math' as math;

import 'package:decision_making_core/decision_making_core.dart';
import 'package:test/test.dart';

List<WeightedDecisionMatrix> _buildMatrix({
  required List<String> altIds,
  required List<String> critIds,
  required List<bool> isBenefits,
  required List<List<double>> values,
}) {
  final criteria = <WeightedDecisionCriteria>[];
  for (var j = 0; j < critIds.length; j++) {
    criteria.add(
      WeightedDecisionCriteria(
        id: critIds[j],
        name: critIds[j].toUpperCase(),
        isBenefit: isBenefits[j],
        weightPercent: 100.0 / critIds.length,
        maxValue: 10000.0,
      ),
    );
  }

  final rows = <WeightedDecisionMatrix>[];
  for (var i = 0; i < altIds.length; i++) {
    final alt = WeightedDecisionAlternative(
      id: altIds[i],
      name: altIds[i].toUpperCase(),
    );
    final ratings = <WeightedDecisionRating>[];
    for (var j = 0; j < critIds.length; j++) {
      ratings.add(
        WeightedDecisionRating(
          id: 'r_${altIds[i]}_${critIds[j]}',
          criteria: criteria[j],
          value: values[i][j],
        ),
      );
    }
    rows.add(
      WeightedDecisionMatrix(
        id: 'm_${altIds[i]}',
        alternative: alt,
        ratings: ratings,
      ),
    );
  }

  return rows;
}

void main() {
  group('Entropy Weighting - Edge Cases', () {
    test('m = 1 alternative throws Exception', () {
      final matrix = _buildMatrix(
        altIds: ['a1'],
        critIds: ['c1', 'c2'],
        isBenefits: [true, false],
        values: [
          [10.0, 20.0],
        ],
      );

      expect(
        () => ObjectiveWeightCalculator.calculateEntropy(matrix),
        throwsException,
      );
    });

    test('negative value throws Exception', () {
      final matrix = _buildMatrix(
        altIds: ['a1', 'a2', 'a3'],
        critIds: ['c1', 'c2'],
        isBenefits: [true, true],
        values: [
          [10.0, 5.0],
          [-2.0, 8.0],
          [15.0, 9.0],
        ],
      );

      expect(
        () => ObjectiveWeightCalculator.calculateEntropy(matrix),
        throwsException,
      );
    });

    test('column sum = 0 throws Exception', () {
      final matrix = _buildMatrix(
        altIds: ['a1', 'a2', 'a3'],
        critIds: ['c1', 'c2'],
        isBenefits: [true, true],
        values: [
          [0.0, 5.0],
          [0.0, 8.0],
          [0.0, 9.0],
        ],
      );

      expect(
        () => ObjectiveWeightCalculator.calculateEntropy(matrix),
        throwsException,
      );
    });

    test(
        'zero cell value is allowed (0 * ln(0) = 0) when column sum > 0 and produces no NaN',
        () {
      // Column c1 has [0, 10, 10] -> proportions [0, 0.5, 0.5]
      // e_1 = -(1 / ln(3)) * (0 + 0.5*ln(0.5) + 0.5*ln(0.5)) = ln(2) / ln(3)
      // Column c2 has [5, 5, 5] -> constant -> e_2 = 1.0, d_2 = 0.0
      final matrix = _buildMatrix(
        altIds: ['a1', 'a2', 'a3'],
        critIds: ['c1', 'c2'],
        isBenefits: [true, true],
        values: [
          [0.0, 5.0],
          [10.0, 5.0],
          [10.0, 5.0],
        ],
      );

      final result = ObjectiveWeightCalculator.calculateEntropy(matrix);

      final expectedE1 = math.log(2.0) / math.log(3.0);
      expect(result.entropy['c1']!.isNaN, isFalse);
      expect(result.entropy['c1'], closeTo(expectedE1, 1e-6));
      expect(result.divergence['c1'], closeTo(1.0 - expectedE1, 1e-6));
      expect(result.entropy['c2'], closeTo(1.0, 1e-6));
      expect(result.divergence['c2'], closeTo(0.0, 1e-6));
      expect(result.weights['c1'], closeTo(1.0, 1e-6));
      expect(result.weights['c2'], closeTo(0.0, 1e-6));
    });

    test(
        'all d_j = 0 (all columns constant) returns equal weights (1 / n) and no NaN',
        () {
      final matrix = _buildMatrix(
        altIds: ['a1', 'a2', 'a3'],
        critIds: ['c1', 'c2', 'c3'],
        isBenefits: [true, false, true],
        values: [
          [10.0, 50.0, 7.0],
          [10.0, 50.0, 7.0],
          [10.0, 50.0, 7.0],
        ],
      );

      final result = ObjectiveWeightCalculator.calculateEntropy(matrix);

      for (final cid in ['c1', 'c2', 'c3']) {
        expect(result.entropy[cid]!.isNaN, isFalse);
        expect(result.divergence[cid]!.isNaN, isFalse);
        expect(result.weights[cid]!.isNaN, isFalse);
        expect(result.entropy[cid], closeTo(1.0, 1e-9));
        expect(result.divergence[cid], closeTo(0.0, 1e-9));
        expect(result.weights[cid], closeTo(1.0 / 3.0, 1e-9));
      }
    });
  });

  group('CRITIC Weighting - Edge Cases', () {
    test('m < 2 alternatives throws Exception', () {
      final matrix = _buildMatrix(
        altIds: ['a1'],
        critIds: ['c1', 'c2'],
        isBenefits: [true, false],
        values: [
          [10.0, 20.0],
        ],
      );

      expect(
        () => ObjectiveWeightCalculator.calculateCritic(matrix),
        throwsException,
      );
    });

    test(
        'constant column (max = min) has normalized = 0, sigma = 0, correlation with other columns = 0, C_j = 0, and no NaN',
        () {
      // c1 is constant [5, 5, 5]
      // c2 is benefit [10, 20, 30] -> norm [0, 0.5, 1.0], sigma = 0.5
      // c3 is cost [10, 20, 30] -> norm [1.0, 0.5, 0.0], sigma = 0.5
      // r(c2, c3) = -1.0
      // Correlations with c1 are 0.0
      final matrix = _buildMatrix(
        altIds: ['a1', 'a2', 'a3'],
        critIds: ['c1', 'c2', 'c3'],
        isBenefits: [true, true, false],
        values: [
          [5.0, 10.0, 10.0],
          [5.0, 20.0, 20.0],
          [5.0, 30.0, 30.0],
        ],
      );

      final result = ObjectiveWeightCalculator.calculateCritic(matrix);

      // Constant column c1:
      for (final aid in ['a1', 'a2', 'a3']) {
        expect(result.normalizedMatrix[aid]!['c1'], closeTo(0.0, 1e-9));
      }
      expect(result.standardDeviations['c1'], closeTo(0.0, 1e-9));
      expect(result.correlationMatrix['c1']!['c2'], closeTo(0.0, 1e-9));
      expect(result.correlationMatrix['c1']!['c3'], closeTo(0.0, 1e-9));
      expect(result.correlationMatrix['c2']!['c1'], closeTo(0.0, 1e-9));
      expect(result.correlationMatrix['c3']!['c1'], closeTo(0.0, 1e-9));
      expect(result.informationContent['c1'], closeTo(0.0, 1e-9));
      expect(result.weights['c1'], closeTo(0.0, 1e-9));

      // Non-constant columns c2 and c3:
      expect(result.standardDeviations['c2'], closeTo(0.5, 1e-9));
      expect(result.standardDeviations['c3'], closeTo(0.5, 1e-9));
      expect(result.correlationMatrix['c2']!['c3'], closeTo(-1.0, 1e-9));
      // For c2: sum_k(1 - r_2k) = (1 - 0) + (1 - 1) + (1 - (-1)) = 1 + 0 + 2 = 3.0
      // C_2 = 0.5 * 3.0 = 1.5
      expect(result.informationContent['c2'], closeTo(1.5, 1e-9));
      expect(result.informationContent['c3'], closeTo(1.5, 1e-9));
      expect(result.weights['c2'], closeTo(0.5, 1e-9));
      expect(result.weights['c3'], closeTo(0.5, 1e-9));
    });

    test(
        'all columns constant (sum C_j = 0) returns equal weights (1 / n) and no NaN',
        () {
      final matrix = _buildMatrix(
        altIds: ['a1', 'a2', 'a3'],
        critIds: ['c1', 'c2', 'c3'],
        isBenefits: [true, false, true],
        values: [
          [4.0, 8.0, 12.0],
          [4.0, 8.0, 12.0],
          [4.0, 8.0, 12.0],
        ],
      );

      final result = ObjectiveWeightCalculator.calculateCritic(matrix);

      for (final cid in ['c1', 'c2', 'c3']) {
        expect(result.standardDeviations[cid]!.isNaN, isFalse);
        expect(result.informationContent[cid]!.isNaN, isFalse);
        expect(result.weights[cid]!.isNaN, isFalse);
        expect(result.standardDeviations[cid], closeTo(0.0, 1e-9));
        expect(result.informationContent[cid], closeTo(0.0, 1e-9));
        expect(result.weights[cid], closeTo(1.0 / 3.0, 1e-9));
      }
    });

    test(
        'perfectly positively correlated columns (r_jk = 1 for all j, k -> sum C_j = 0) returns equal weights (1 / n)',
        () {
      // Both c1 and c2 are benefit and strictly linear: r_12 = 1.0 -> 1 - r_jk = 0 -> C_j = 0
      final matrix = _buildMatrix(
        altIds: ['a1', 'a2', 'a3'],
        critIds: ['c1', 'c2'],
        isBenefits: [true, true],
        values: [
          [10.0, 100.0],
          [20.0, 200.0],
          [30.0, 300.0],
        ],
      );

      final result = ObjectiveWeightCalculator.calculateCritic(matrix);

      expect(result.correlationMatrix['c1']!['c2'], closeTo(1.0, 1e-9));
      expect(result.informationContent['c1'], closeTo(0.0, 1e-9));
      expect(result.informationContent['c2'], closeTo(0.0, 1e-9));
      expect(result.weights['c1'], closeTo(0.5, 1e-9));
      expect(result.weights['c2'], closeTo(0.5, 1e-9));
    });
  });

  group('Matrix Validation - Edge Cases (Entropy & CRITIC)', () {
    test('duplicate alternative ID throws Exception (Entropy and CRITIC)', () {
      final matrix = _buildMatrix(
        altIds: ['a1', 'a1', 'a3'],
        critIds: ['c1', 'c2'],
        isBenefits: [true, true],
        values: [
          [10.0, 20.0],
          [15.0, 25.0],
          [20.0, 30.0],
        ],
      );

      expect(
        () => ObjectiveWeightCalculator.calculateEntropy(matrix),
        throwsException,
      );
      expect(
        () => ObjectiveWeightCalculator.calculateCritic(matrix),
        throwsException,
      );
    });

    test(
        'duplicate criterion ID in a row throws Exception (Entropy and CRITIC)',
        () {
      final matrix = _buildMatrix(
        altIds: ['a1', 'a2', 'a3'],
        critIds: ['c1', 'c1'],
        isBenefits: [true, false],
        values: [
          [10.0, 20.0],
          [15.0, 25.0],
          [20.0, 30.0],
        ],
      );

      expect(
        () => ObjectiveWeightCalculator.calculateEntropy(matrix),
        throwsException,
      );
      expect(
        () => ObjectiveWeightCalculator.calculateCritic(matrix),
        throwsException,
      );
    });

    test('NaN value throws Exception (Entropy and CRITIC)', () {
      final matrix = _buildMatrix(
        altIds: ['a1', 'a2', 'a3'],
        critIds: ['c1', 'c2'],
        isBenefits: [true, true],
        values: [
          [10.0, 20.0],
          [double.nan, 25.0],
          [20.0, 30.0],
        ],
      );

      expect(
        () => ObjectiveWeightCalculator.calculateEntropy(matrix),
        throwsException,
      );
      expect(
        () => ObjectiveWeightCalculator.calculateCritic(matrix),
        throwsException,
      );
    });

    test('Infinity value throws Exception (Entropy and CRITIC)', () {
      final c1 = WeightedDecisionCriteria(
        id: 'c1',
        name: 'C1',
        isBenefit: true,
        weightPercent: 50.0,
        maxValue: double.infinity,
      );
      final c2 = WeightedDecisionCriteria(
        id: 'c2',
        name: 'C2',
        isBenefit: true,
        weightPercent: 50.0,
        maxValue: double.infinity,
      );
      final matrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: WeightedDecisionAlternative(id: 'a1', name: 'A1'),
          ratings: [
            WeightedDecisionRating(id: 'r1_1', criteria: c1, value: 10.0),
            WeightedDecisionRating(id: 'r1_2', criteria: c2, value: 20.0),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: WeightedDecisionAlternative(id: 'a2', name: 'A2'),
          ratings: [
            WeightedDecisionRating(
              id: 'r2_1',
              criteria: c1,
              value: double.infinity,
            ),
            WeightedDecisionRating(id: 'r2_2', criteria: c2, value: 25.0),
          ],
        ),
      ];

      expect(
        () => ObjectiveWeightCalculator.calculateEntropy(matrix),
        throwsException,
      );
      expect(
        () => ObjectiveWeightCalculator.calculateCritic(matrix),
        throwsException,
      );
    });

    test('missing rating in a row throws Exception (Entropy and CRITIC)', () {
      final base = _buildMatrix(
        altIds: ['a1', 'a2', 'a3'],
        critIds: ['c1', 'c2'],
        isBenefits: [true, true],
        values: [
          [10.0, 20.0],
          [15.0, 25.0],
          [20.0, 30.0],
        ],
      );

      // Remove second rating from second row
      final incompleteMatrix = [
        base[0],
        base[1].copyWith(ratings: [base[1].ratings.first]),
        base[2],
      ];

      expect(
        () => ObjectiveWeightCalculator.calculateEntropy(incompleteMatrix),
        throwsException,
      );
      expect(
        () => ObjectiveWeightCalculator.calculateCritic(incompleteMatrix),
        throwsException,
      );
    });
  });
}
