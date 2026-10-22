import 'package:decision_making_core/decision_making_core.dart';
import 'package:test/test.dart';

void main() {
  group('Sensitivity & Rank Reversal - Edge Cases', () {
    // -------------------------------------------------------------------------
    // Edge Case 1: n = 2 alternatives (rank reversal skipped)
    // -------------------------------------------------------------------------
    test('Edge Case 1: n = 2 alternatives skips rank reversal and records reason', () {
      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'C1',
          weightPercent: 50,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'C2',
          weightPercent: 50,
          isBenefit: true,
          maxValue: 10,
        ),
      ];

      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'A1'),
        WeightedDecisionAlternative(id: 'a2', name: 'A2'),
      ];

      final matrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(id: 'r1_1', criteria: criteria[0], value: 8),
            WeightedDecisionRating(id: 'r1_2', criteria: criteria[1], value: 6),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(id: 'r2_1', criteria: criteria[0], value: 5),
            WeightedDecisionRating(id: 'r2_2', criteria: criteria[1], value: 9),
          ],
        ),
      ];

      final result = SawCalculator.analyzeSensitivity(matrix, delta: 0.1);

      expect(result.rankReversalCases.length, 1);
      final rCase = result.rankReversalCases.first;
      expect(rCase.isSkipped, isTrue);
      expect(rCase.skipReason, contains('requires at least 3 alternatives'));
      expect(rCase.hasReversal, isFalse);
    });

    // -------------------------------------------------------------------------
    // Edge Case 2: 1 criterion (sensitivity skipped)
    // -------------------------------------------------------------------------
    test('Edge Case 2: Single criterion skips sensitivity perturbation and records reason', () {
      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Solo Criterion',
          weightPercent: 100,
          isBenefit: true,
          maxValue: 10,
        ),
      ];

      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'A1'),
        WeightedDecisionAlternative(id: 'a2', name: 'A2'),
        WeightedDecisionAlternative(id: 'a3', name: 'A3'),
      ];

      final matrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(id: 'r1_1', criteria: criteria[0], value: 8),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(id: 'r2_1', criteria: criteria[0], value: 6),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(id: 'r3_1', criteria: criteria[0], value: 4),
          ],
        ),
      ];

      final result = SawCalculator.analyzeSensitivity(matrix, delta: 0.1);

      expect(result.sensitivityCases.isNotEmpty, isTrue);
      for (final sCase in result.sensitivityCases) {
        expect(sCase.isSkipped, isTrue);
        expect(sCase.skipReason, contains('requires at least 2 criteria'));
      }
    });

    // -------------------------------------------------------------------------
    // Edge Case 3: Weight very close to 1 / Perturbed weight >= 1.0 (skipped)
    // -------------------------------------------------------------------------
    test("Edge Case 3: Perturbed weight w_k' >= 1.0 is skipped and records reason", () {
      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Dominant Criterion',
          weightPercent: 95,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'Minor Criterion',
          weightPercent: 5,
          isBenefit: true,
          maxValue: 10,
        ),
      ];

      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'A1'),
        WeightedDecisionAlternative(id: 'a2', name: 'A2'),
        WeightedDecisionAlternative(id: 'a3', name: 'A3'),
      ];

      final matrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(id: 'r1_1', criteria: criteria[0], value: 8),
            WeightedDecisionRating(id: 'r1_2', criteria: criteria[1], value: 7),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(id: 'r2_1', criteria: criteria[0], value: 6),
            WeightedDecisionRating(id: 'r2_2', criteria: criteria[1], value: 9),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(id: 'r3_1', criteria: criteria[0], value: 5),
            WeightedDecisionRating(id: 'r3_2', criteria: criteria[1], value: 8),
          ],
        ),
      ];

      // With delta = 0.10, c1 perturbed = 0.95 * 1.1 = 1.045 >= 1.0
      final result = SawCalculator.analyzeSensitivity(matrix, delta: 0.1);

      final c1Increase = result.sensitivityCases.firstWhere(
        (c) => c.criterionId == 'c1' && c.direction == SensitivityDirection.increase,
      );

      expect(c1Increase.isSkipped, isTrue);
      expect(c1Increase.skipReason, contains('greater than or equal to 1.0'));
    });

    // -------------------------------------------------------------------------
    // Edge Case 4: Tied scores (|score_i - score_j| <= 1e-9) are not counted as changed
    // -------------------------------------------------------------------------
    test('Edge Case 4: Identical/tied alternatives do not count as order change or rank reversal', () {
      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'C1',
          weightPercent: 50,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'C2',
          weightPercent: 50,
          isBenefit: true,
          maxValue: 10,
        ),
      ];

      // Alternatives with exact same ratings (tied scores)
      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'A1'),
        WeightedDecisionAlternative(id: 'a2', name: 'A2'),
        WeightedDecisionAlternative(id: 'a3', name: 'A3'),
      ];

      final matrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(id: 'r1_1', criteria: criteria[0], value: 7),
            WeightedDecisionRating(id: 'r1_2', criteria: criteria[1], value: 7),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(id: 'r2_1', criteria: criteria[0], value: 7),
            WeightedDecisionRating(id: 'r2_2', criteria: criteria[1], value: 7),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(id: 'r3_1', criteria: criteria[0], value: 7),
            WeightedDecisionRating(id: 'r3_2', criteria: criteria[1], value: 7),
          ],
        ),
      ];

      final result = SawCalculator.analyzeSensitivity(matrix, delta: 0.1);

      expect(result.isStable, isTrue);
      for (final sCase in result.sensitivityCases) {
        expect(sCase.hasOrderChanged, isFalse);
        expect(sCase.swappedPairs, isEmpty);
      }
      for (final rCase in result.rankReversalCases) {
        expect(rCase.hasReversal, isFalse);
        expect(rCase.reversedPairs, isEmpty);
      }
    });

    // -------------------------------------------------------------------------
    // Edge Case 5: Delta <= 0 throws Exception
    // -------------------------------------------------------------------------
    test('Edge Case 5: Delta <= 0 throws Exception', () {
      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'C1',
          weightPercent: 50,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'C2',
          weightPercent: 50,
          isBenefit: true,
          maxValue: 10,
        ),
      ];

      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'A1'),
        WeightedDecisionAlternative(id: 'a2', name: 'A2'),
      ];

      final matrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(id: 'r1_1', criteria: criteria[0], value: 8),
            WeightedDecisionRating(id: 'r1_2', criteria: criteria[1], value: 6),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(id: 'r2_1', criteria: criteria[0], value: 5),
            WeightedDecisionRating(id: 'r2_2', criteria: criteria[1], value: 9),
          ],
        ),
      ];

      expect(
        () => SawCalculator.analyzeSensitivity(matrix, delta: 0.0),
        throwsA(isA<Exception>()),
      );
      expect(
        () => SawCalculator.analyzeSensitivity(matrix, delta: -0.1),
        throwsA(isA<Exception>()),
      );
    });
  });
}
