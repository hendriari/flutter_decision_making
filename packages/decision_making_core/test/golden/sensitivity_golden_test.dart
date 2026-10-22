import 'package:decision_making_core/decision_making_core.dart';
import 'package:test/test.dart';

void main() {
  group('Sensitivity Analysis & Rank Reversal - Golden Tests', () {
    // -------------------------------------------------------------------------
    // Negative Control 1: Golden SAW Case 1 (3x4)
    // -------------------------------------------------------------------------
    test('Negative Control: Golden SAW Case 1 isStable = true, no reversal',
        () {
      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Investment Cost',
          weightPercent: 25,
          isBenefit: false,
          maxValue: 250,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'Market Share',
          weightPercent: 25,
          isBenefit: true,
          maxValue: 5,
        ),
        WeightedDecisionCriteria(
          id: 'c3',
          name: 'Capacity',
          weightPercent: 25,
          isBenefit: true,
          maxValue: 5000,
        ),
        WeightedDecisionCriteria(
          id: 'c4',
          name: 'Risk Level',
          weightPercent: 25,
          isBenefit: false,
          maxValue: 5,
        ),
      ];

      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'Alternative 1'),
        WeightedDecisionAlternative(id: 'a2', name: 'Alternative 2'),
        WeightedDecisionAlternative(id: 'a3', name: 'Alternative 3'),
      ];

      final matrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(
                id: 'r1_1', criteria: criteria[0], value: 100),
            WeightedDecisionRating(id: 'r1_2', criteria: criteria[1], value: 3),
            WeightedDecisionRating(
                id: 'r1_3', criteria: criteria[2], value: 3500),
            WeightedDecisionRating(
                id: 'r1_4', criteria: criteria[3], value: 1.5),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(
                id: 'r2_1', criteria: criteria[0], value: 150),
            WeightedDecisionRating(id: 'r2_2', criteria: criteria[1], value: 2),
            WeightedDecisionRating(
                id: 'r2_3', criteria: criteria[2], value: 4500),
            WeightedDecisionRating(
                id: 'r2_4', criteria: criteria[3], value: 2.0),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(
                id: 'r3_1', criteria: criteria[0], value: 200),
            WeightedDecisionRating(id: 'r3_2', criteria: criteria[1], value: 3),
            WeightedDecisionRating(
                id: 'r3_3', criteria: criteria[2], value: 3000),
            WeightedDecisionRating(
                id: 'r3_4', criteria: criteria[3], value: 3.5),
          ],
        ),
      ];

      final result = SawCalculator.analyzeSensitivity(matrix, delta: 0.1);

      expect(result.isStable, isTrue);
      expect(result.baseRanking, ['a1', 'a2', 'a3']);
      expect(result.rankReversalCases.every((c) => !c.hasReversal), isTrue);
      expect(result.sensitivityCases.every((c) => !c.hasOrderChanged), isTrue);

      // Verify C1 +10% specific reference values
      final c1Plus = result.sensitivityCases.firstWhere(
        (c) =>
            c.criterionId == 'c1' &&
            c.direction == SensitivityDirection.increase,
      );
      expect(c1Plus.weights['c1'], closeTo(0.275000, 1e-4));
      expect(c1Plus.weights['c2'], closeTo(0.241667, 1e-4));
      expect(c1Plus.weights['c3'], closeTo(0.241667, 1e-4));
      expect(c1Plus.weights['c4'], closeTo(0.241667, 1e-4));
      expect(c1Plus.scores['a1'], closeTo(0.946296, 1e-4));
      expect(c1Plus.scores['a2'], closeTo(0.767361, 1e-4));
      expect(c1Plus.scores['a3'], closeTo(0.643849, 1e-4));
      expect(c1Plus.ranking, ['a1', 'a2', 'a3']);
      expect(c1Plus.hasOrderChanged, isFalse);
    });

    // -------------------------------------------------------------------------
    // Negative Control 2: Golden TOPSIS Case 1 (4x4)
    // -------------------------------------------------------------------------
    test('Negative Control: Golden TOPSIS Case 1 isStable = true, no reversal',
        () {
      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Criteria 1',
          weightPercent: 30,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'Criteria 2',
          weightPercent: 20,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c3',
          name: 'Criteria 3',
          weightPercent: 25,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c4',
          name: 'Criteria 4',
          weightPercent: 25,
          isBenefit: false,
          maxValue: 10,
        ),
      ];

      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'Alternative 1'),
        WeightedDecisionAlternative(id: 'a2', name: 'Alternative 2'),
        WeightedDecisionAlternative(id: 'a3', name: 'Alternative 3'),
        WeightedDecisionAlternative(id: 'a4', name: 'Alternative 4'),
      ];

      final rawMatrix = TopsisRawMatrix(
        criterias: criteria,
        matrixs: [
          WeightedDecisionMatrix(
            id: 'm1',
            alternative: alternatives[0],
            ratings: [
              WeightedDecisionRating(
                  id: 'r1_1', criteria: criteria[0], value: 5),
              WeightedDecisionRating(
                  id: 'r1_2', criteria: criteria[1], value: 8),
              WeightedDecisionRating(
                  id: 'r1_3', criteria: criteria[2], value: 4),
              WeightedDecisionRating(
                  id: 'r1_4', criteria: criteria[3], value: 7),
            ],
          ),
          WeightedDecisionMatrix(
            id: 'm2',
            alternative: alternatives[1],
            ratings: [
              WeightedDecisionRating(
                  id: 'r2_1', criteria: criteria[0], value: 7),
              WeightedDecisionRating(
                  id: 'r2_2', criteria: criteria[1], value: 6),
              WeightedDecisionRating(
                  id: 'r2_3', criteria: criteria[2], value: 8),
              WeightedDecisionRating(
                  id: 'r2_4', criteria: criteria[3], value: 9),
            ],
          ),
          WeightedDecisionMatrix(
            id: 'm3',
            alternative: alternatives[2],
            ratings: [
              WeightedDecisionRating(
                  id: 'r3_1', criteria: criteria[0], value: 8),
              WeightedDecisionRating(
                  id: 'r3_2', criteria: criteria[1], value: 9),
              WeightedDecisionRating(
                  id: 'r3_3', criteria: criteria[2], value: 6),
              WeightedDecisionRating(
                  id: 'r3_4', criteria: criteria[3], value: 6),
            ],
          ),
          WeightedDecisionMatrix(
            id: 'm4',
            alternative: alternatives[3],
            ratings: [
              WeightedDecisionRating(
                  id: 'r4_1', criteria: criteria[0], value: 7),
              WeightedDecisionRating(
                  id: 'r4_2', criteria: criteria[1], value: 7),
              WeightedDecisionRating(
                  id: 'r4_3', criteria: criteria[2], value: 7),
              WeightedDecisionRating(
                  id: 'r4_4', criteria: criteria[3], value: 7),
            ],
          ),
        ],
      );

      final result = TopsisCalculator.analyzeSensitivity(rawMatrix, delta: 0.1);

      expect(result.isStable, isTrue);
      expect(result.baseRanking, ['a3', 'a4', 'a2', 'a1']);
      expect(result.rankReversalCases.every((c) => !c.hasReversal), isTrue);
      expect(result.sensitivityCases.every((c) => !c.hasOrderChanged), isTrue);

      // Verify C3 +10% specific reference values
      final c3Plus = result.sensitivityCases.firstWhere(
        (c) =>
            c.criterionId == 'c3' &&
            c.direction == SensitivityDirection.increase,
      );
      expect(c3Plus.weights['c1'], closeTo(0.290000, 1e-4));
      expect(c3Plus.weights['c2'], closeTo(0.193333, 1e-4));
      expect(c3Plus.weights['c3'], closeTo(0.275000, 1e-4));
      expect(c3Plus.weights['c4'], closeTo(0.241667, 1e-4));
      expect(c3Plus.scores['a1'], closeTo(0.277134, 1e-4));
      expect(c3Plus.scores['a2'], closeTo(0.591460, 1e-4));
      expect(c3Plus.scores['a3'], closeTo(0.697944, 1e-4));
      expect(c3Plus.scores['a4'], closeTo(0.664424, 1e-4));
      expect(c3Plus.ranking, ['a3', 'a4', 'a2', 'a1']);
      expect(c3Plus.hasOrderChanged, isFalse);
    });

    // -------------------------------------------------------------------------
    // SAW Dataset S2: X = [[5,1,5],[2,7,9],[9,6,8],[4,2,5]]
    // -------------------------------------------------------------------------
    test('SAW Dataset S2: sensitivity shifts and rank reversal', () {
      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'C1',
          weightPercent: 40,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'C2',
          weightPercent: 35,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c3',
          name: 'C3',
          weightPercent: 25,
          isBenefit: false, // Cost criteria
          maxValue: 10,
        ),
      ];

      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'A1'),
        WeightedDecisionAlternative(id: 'a2', name: 'A2'),
        WeightedDecisionAlternative(id: 'a3', name: 'A3'),
        WeightedDecisionAlternative(id: 'a4', name: 'A4'),
      ];

      final matrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(id: 'r1_1', criteria: criteria[0], value: 5),
            WeightedDecisionRating(id: 'r1_2', criteria: criteria[1], value: 1),
            WeightedDecisionRating(id: 'r1_3', criteria: criteria[2], value: 5),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(id: 'r2_1', criteria: criteria[0], value: 2),
            WeightedDecisionRating(id: 'r2_2', criteria: criteria[1], value: 7),
            WeightedDecisionRating(id: 'r2_3', criteria: criteria[2], value: 9),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(id: 'r3_1', criteria: criteria[0], value: 9),
            WeightedDecisionRating(id: 'r3_2', criteria: criteria[1], value: 6),
            WeightedDecisionRating(id: 'r3_3', criteria: criteria[2], value: 8),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm4',
          alternative: alternatives[3],
          ratings: [
            WeightedDecisionRating(id: 'r4_1', criteria: criteria[0], value: 4),
            WeightedDecisionRating(id: 'r4_2', criteria: criteria[1], value: 2),
            WeightedDecisionRating(id: 'r4_3', criteria: criteria[2], value: 5),
          ],
        ),
      ];

      final result = SawCalculator.analyzeSensitivity(matrix, delta: 0.1);

      expect(result.isStable, isFalse);

      // Base scores & order
      expect(result.baseScores['a1'], closeTo(0.522222, 1e-4));
      expect(result.baseScores['a2'], closeTo(0.577778, 1e-4));
      expect(result.baseScores['a3'], closeTo(0.856250, 1e-4));
      expect(result.baseScores['a4'], closeTo(0.527778, 1e-4));
      expect(result.baseRanking, ['a3', 'a2', 'a4', 'a1']);

      // C1 +10%
      final c1Plus = result.sensitivityCases.firstWhere(
        (c) =>
            c.criterionId == 'c1' &&
            c.direction == SensitivityDirection.increase,
      );
      expect(c1Plus.weights['c1'], closeTo(0.440000, 1e-4));
      expect(c1Plus.weights['c2'], closeTo(0.326667, 1e-4));
      expect(c1Plus.weights['c3'], closeTo(0.233333, 1e-4));
      expect(c1Plus.scores['a1'], closeTo(0.524444, 1e-4));
      expect(c1Plus.scores['a2'], closeTo(0.554074, 1e-4));
      expect(c1Plus.scores['a3'], closeTo(0.865833, 1e-4));
      expect(c1Plus.scores['a4'], closeTo(0.522222, 1e-4));
      expect(c1Plus.ranking, ['a3', 'a2', 'a1', 'a4']);
      expect(c1Plus.hasOrderChanged, isTrue);
      expect(c1Plus.swappedPairs.any((p) => p.matches('a1', 'a4')), isTrue);

      // C2 -10%
      final c2Minus = result.sensitivityCases.firstWhere(
        (c) =>
            c.criterionId == 'c2' &&
            c.direction == SensitivityDirection.decrease,
      );
      expect(c2Minus.weights['c1'], closeTo(0.421538, 1e-4));
      expect(c2Minus.weights['c2'], closeTo(0.315000, 1e-4));
      expect(c2Minus.weights['c3'], closeTo(0.263462, 1e-4));
      expect(c2Minus.scores['a1'], closeTo(0.542650, 1e-4));
      expect(c2Minus.scores['a2'], closeTo(0.555043, 1e-4));
      expect(c2Minus.scores['a3'], closeTo(0.856202, 1e-4));
      expect(c2Minus.scores['a4'], closeTo(0.540812, 1e-4));
      expect(c2Minus.ranking, ['a3', 'a2', 'a1', 'a4']);
      expect(c2Minus.hasOrderChanged, isTrue);
      expect(c2Minus.swappedPairs.any((p) => p.matches('a1', 'a4')), isTrue);

      // Rank reversal: remove A3
      final remA3 = result.rankReversalCases.firstWhere(
        (c) => c.removedAlternativeId == 'a3',
      );
      expect(remA3.scores['a1'], closeTo(0.700000, 1e-4));
      expect(remA3.scores['a2'], closeTo(0.648889, 1e-4));
      expect(remA3.scores['a4'], closeTo(0.670000, 1e-4));
      expect(remA3.ranking, ['a1', 'a4', 'a2']);
      expect(remA3.hasReversal, isTrue);
      expect(remA3.reversedPairs.any((p) => p.matches('a1', 'a2')), isTrue);

      // Other removals (A1, A2, A4) should NOT have reversal
      final others = result.rankReversalCases
          .where((c) => c.removedAlternativeId != 'a3')
          .toList();
      for (final c in others) {
        expect(c.hasReversal, isFalse);
      }
    });

    // -------------------------------------------------------------------------
    // TOPSIS Dataset T1: X = [[8,7,1],[2,6,9],[9,2,6],[1,2,2]]
    // -------------------------------------------------------------------------
    test('TOPSIS Dataset T1: sensitivity shifts', () {
      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'C1',
          weightPercent: 40,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'C2',
          weightPercent: 35,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c3',
          name: 'C3',
          weightPercent: 25,
          isBenefit: false, // Cost criteria
          maxValue: 10,
        ),
      ];

      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'A1'),
        WeightedDecisionAlternative(id: 'a2', name: 'A2'),
        WeightedDecisionAlternative(id: 'a3', name: 'A3'),
        WeightedDecisionAlternative(id: 'a4', name: 'A4'),
      ];

      final rawMatrix = TopsisRawMatrix(
        criterias: criteria,
        matrixs: [
          WeightedDecisionMatrix(
            id: 'm1',
            alternative: alternatives[0],
            ratings: [
              WeightedDecisionRating(
                  id: 'r1_1', criteria: criteria[0], value: 8),
              WeightedDecisionRating(
                  id: 'r1_2', criteria: criteria[1], value: 7),
              WeightedDecisionRating(
                  id: 'r1_3', criteria: criteria[2], value: 1),
            ],
          ),
          WeightedDecisionMatrix(
            id: 'm2',
            alternative: alternatives[1],
            ratings: [
              WeightedDecisionRating(
                  id: 'r2_1', criteria: criteria[0], value: 2),
              WeightedDecisionRating(
                  id: 'r2_2', criteria: criteria[1], value: 6),
              WeightedDecisionRating(
                  id: 'r2_3', criteria: criteria[2], value: 9),
            ],
          ),
          WeightedDecisionMatrix(
            id: 'm3',
            alternative: alternatives[2],
            ratings: [
              WeightedDecisionRating(
                  id: 'r3_1', criteria: criteria[0], value: 9),
              WeightedDecisionRating(
                  id: 'r3_2', criteria: criteria[1], value: 2),
              WeightedDecisionRating(
                  id: 'r3_3', criteria: criteria[2], value: 6),
            ],
          ),
          WeightedDecisionMatrix(
            id: 'm4',
            alternative: alternatives[3],
            ratings: [
              WeightedDecisionRating(
                  id: 'r4_1', criteria: criteria[0], value: 1),
              WeightedDecisionRating(
                  id: 'r4_2', criteria: criteria[1], value: 2),
              WeightedDecisionRating(
                  id: 'r4_3', criteria: criteria[2], value: 2),
            ],
          ),
        ],
      );

      final result = TopsisCalculator.analyzeSensitivity(rawMatrix, delta: 0.1);

      // Base scores & order
      expect(result.baseScores['a1'], closeTo(0.913173, 1e-4));
      expect(result.baseScores['a2'], closeTo(0.336130, 1e-4));
      expect(result.baseScores['a3'], closeTo(0.557971, 1e-4));
      expect(result.baseScores['a4'], closeTo(0.331906, 1e-4));
      expect(result.baseRanking, ['a1', 'a3', 'a2', 'a4']);

      // C2 -10%
      final c2Minus = result.sensitivityCases.firstWhere(
        (c) =>
            c.criterionId == 'c2' &&
            c.direction == SensitivityDirection.decrease,
      );
      expect(c2Minus.weights['c1'], closeTo(0.421538, 1e-4));
      expect(c2Minus.weights['c2'], closeTo(0.315000, 1e-4));
      expect(c2Minus.weights['c3'], closeTo(0.263462, 1e-4));
      expect(c2Minus.scores['a1'], closeTo(0.910008, 1e-4));
      expect(c2Minus.scores['a2'], closeTo(0.304181, 1e-4));
      expect(c2Minus.scores['a3'], closeTo(0.584507, 1e-4));
      expect(c2Minus.scores['a4'], closeTo(0.342152, 1e-4));
      expect(c2Minus.ranking, ['a1', 'a3', 'a4', 'a2']);
      expect(c2Minus.hasOrderChanged, isTrue);
      expect(c2Minus.swappedPairs.any((p) => p.matches('a2', 'a4')), isTrue);

      // C3 +10%
      final c3Plus = result.sensitivityCases.firstWhere(
        (c) =>
            c.criterionId == 'c3' &&
            c.direction == SensitivityDirection.increase,
      );
      expect(c3Plus.weights['c1'], closeTo(0.386667, 1e-4));
      expect(c3Plus.weights['c2'], closeTo(0.338333, 1e-4));
      expect(c3Plus.weights['c3'], closeTo(0.275000, 1e-4));
      expect(c3Plus.scores['a1'], closeTo(0.916245, 1e-4));
      expect(c3Plus.scores['a2'], closeTo(0.324396, 1e-4));
      expect(c3Plus.scores['a3'], closeTo(0.550453, 1e-4));
      expect(c3Plus.scores['a4'], closeTo(0.360982, 1e-4));
      expect(c3Plus.ranking, ['a1', 'a3', 'a4', 'a2']);
      expect(c3Plus.hasOrderChanged, isTrue);
      expect(c3Plus.swappedPairs.any((p) => p.matches('a2', 'a4')), isTrue);

      // Rank reversal on A3 removal: produces reversal on (A2, A4)
      final remA3 = result.rankReversalCases.firstWhere(
        (c) => c.removedAlternativeId == 'a3',
      );
      expect(remA3.scores['a1'], closeTo(1.000000, 1e-4));
      expect(remA3.scores['a2'], closeTo(0.300923, 1e-4));
      expect(remA3.scores['a4'], closeTo(0.328529, 1e-4));
      expect(remA3.ranking, ['a1', 'a4', 'a2']);
      expect(remA3.hasReversal, isTrue);
      expect(remA3.reversedPairs.length, 1);
      expect(remA3.reversedPairs.first.matches('a2', 'a4'), isTrue);

      // Other removals (A1, A2, A4) should NOT have reversal
      final remA1 = result.rankReversalCases.firstWhere(
        (c) => c.removedAlternativeId == 'a1',
      );
      expect(remA1.scores['a2'], closeTo(0.386959, 1e-4));
      expect(remA1.scores['a3'], closeTo(0.604836, 1e-4));
      expect(remA1.scores['a4'], closeTo(0.282284, 1e-4));
      expect(remA1.ranking, ['a3', 'a2', 'a4']);
      expect(remA1.hasReversal, isFalse);
      expect(remA1.reversedPairs, isEmpty);

      final remA2 = result.rankReversalCases.firstWhere(
        (c) => c.removedAlternativeId == 'a2',
      );
      expect(remA2.scores['a1'], closeTo(0.920153, 1e-4));
      expect(remA2.scores['a3'], closeTo(0.466354, 1e-4));
      expect(remA2.scores['a4'], closeTo(0.306057, 1e-4));
      expect(remA2.ranking, ['a1', 'a3', 'a4']);
      expect(remA2.hasReversal, isFalse);
      expect(remA2.reversedPairs, isEmpty);

      final remA4 = result.rankReversalCases.firstWhere(
        (c) => c.removedAlternativeId == 'a4',
      );
      expect(remA4.scores['a1'], closeTo(0.908930, 1e-4));
      expect(remA4.scores['a2'], closeTo(0.333583, 1e-4));
      expect(remA4.scores['a3'], closeTo(0.523215, 1e-4));
      expect(remA4.ranking, ['a1', 'a3', 'a2']);
      expect(remA4.hasReversal, isFalse);
      expect(remA4.reversedPairs, isEmpty);
    });

    // -------------------------------------------------------------------------
    // TOPSIS Dataset T2: X = [[8,5,7],[3,1,1],[9,9,3],[4,3,2]]
    // -------------------------------------------------------------------------
    test('TOPSIS Dataset T2: rank reversal upon alternative removal', () {
      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'C1',
          weightPercent: 40,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'C2',
          weightPercent: 35,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c3',
          name: 'C3',
          weightPercent: 25,
          isBenefit: false, // Cost criteria
          maxValue: 10,
        ),
      ];

      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'A1'),
        WeightedDecisionAlternative(id: 'a2', name: 'A2'),
        WeightedDecisionAlternative(id: 'a3', name: 'A3'),
        WeightedDecisionAlternative(id: 'a4', name: 'A4'),
      ];

      final rawMatrix = TopsisRawMatrix(
        criterias: criteria,
        matrixs: [
          WeightedDecisionMatrix(
            id: 'm1',
            alternative: alternatives[0],
            ratings: [
              WeightedDecisionRating(
                  id: 'r1_1', criteria: criteria[0], value: 8),
              WeightedDecisionRating(
                  id: 'r1_2', criteria: criteria[1], value: 5),
              WeightedDecisionRating(
                  id: 'r1_3', criteria: criteria[2], value: 7),
            ],
          ),
          WeightedDecisionMatrix(
            id: 'm2',
            alternative: alternatives[1],
            ratings: [
              WeightedDecisionRating(
                  id: 'r2_1', criteria: criteria[0], value: 3),
              WeightedDecisionRating(
                  id: 'r2_2', criteria: criteria[1], value: 1),
              WeightedDecisionRating(
                  id: 'r2_3', criteria: criteria[2], value: 1),
            ],
          ),
          WeightedDecisionMatrix(
            id: 'm3',
            alternative: alternatives[2],
            ratings: [
              WeightedDecisionRating(
                  id: 'r3_1', criteria: criteria[0], value: 9),
              WeightedDecisionRating(
                  id: 'r3_2', criteria: criteria[1], value: 9),
              WeightedDecisionRating(
                  id: 'r3_3', criteria: criteria[2], value: 3),
            ],
          ),
          WeightedDecisionMatrix(
            id: 'm4',
            alternative: alternatives[3],
            ratings: [
              WeightedDecisionRating(
                  id: 'r4_1', criteria: criteria[0], value: 4),
              WeightedDecisionRating(
                  id: 'r4_2', criteria: criteria[1], value: 3),
              WeightedDecisionRating(
                  id: 'r4_3', criteria: criteria[2], value: 2),
            ],
          ),
        ],
      );

      final result = TopsisCalculator.analyzeSensitivity(rawMatrix, delta: 0.1);

      // Base scores & order
      expect(result.baseScores['a1'], closeTo(0.464910, 1e-4));
      expect(result.baseScores['a2'], closeTo(0.372362, 1e-4));
      expect(result.baseScores['a3'], closeTo(0.844668, 1e-4));
      expect(result.baseScores['a4'], closeTo(0.409062, 1e-4));
      expect(result.baseRanking, ['a3', 'a1', 'a4', 'a2']);

      // Rank reversal: remove A1
      final remA1 = result.rankReversalCases.firstWhere(
        (c) => c.removedAlternativeId == 'a1',
      );
      expect(remA1.scores['a2'], closeTo(0.262817, 1e-4));
      expect(remA1.scores['a3'], closeTo(0.737183, 1e-4));
      expect(remA1.scores['a4'], closeTo(0.261422, 1e-4));
      expect(remA1.ranking, ['a3', 'a2', 'a4']);
      expect(remA1.hasReversal, isTrue);
      expect(remA1.reversedPairs.any((p) => p.matches('a2', 'a4')), isTrue);

      // Remove A2, A3, A4 should NOT have reversal
      final remA2 = result.rankReversalCases.firstWhere(
        (c) => c.removedAlternativeId == 'a2',
      );
      expect(remA2.scores['a1'], closeTo(0.405769, 1e-4));
      expect(remA2.scores['a3'], closeTo(0.898689, 1e-4));
      expect(remA2.scores['a4'], closeTo(0.387071, 1e-4));
      expect(remA2.ranking, ['a3', 'a1', 'a4']);
      expect(remA2.hasReversal, isFalse);
      expect(remA2.reversedPairs, isEmpty);

      final remA3 = result.rankReversalCases.firstWhere(
        (c) => c.removedAlternativeId == 'a3',
      );
      expect(remA3.scores['a1'], closeTo(0.608838, 1e-4));
      expect(remA3.scores['a2'], closeTo(0.391162, 1e-4));
      expect(remA3.scores['a4'], closeTo(0.502288, 1e-4));
      expect(remA3.ranking, ['a1', 'a4', 'a2']);
      expect(remA3.hasReversal, isFalse);
      expect(remA3.reversedPairs, isEmpty);

      final remA4 = result.rankReversalCases.firstWhere(
        (c) => c.removedAlternativeId == 'a4',
      );
      expect(remA4.scores['a1'], closeTo(0.467440, 1e-4));
      expect(remA4.scores['a2'], closeTo(0.369883, 1e-4));
      expect(remA4.scores['a3'], closeTo(0.845871, 1e-4));
      expect(remA4.ranking, ['a3', 'a1', 'a2']);
      expect(remA4.hasReversal, isFalse);
      expect(remA4.reversedPairs, isEmpty);
    });

    // -------------------------------------------------------------------------
    // Invariant Test: 80/70/50 weights produce identical results to 40/35/25
    // -------------------------------------------------------------------------
    test(
        'Invariant test: scaled criteria weights 80/70/50 yield identical results to 40/35/25 (SAW and TOPSIS)',
        () {
      // 1. SAW S2 with 40/35/25 vs 80/70/50
      final criteria40Saw = [
        WeightedDecisionCriteria(
            id: 'c1',
            name: 'C1',
            weightPercent: 40,
            isBenefit: true,
            maxValue: 10),
        WeightedDecisionCriteria(
            id: 'c2',
            name: 'C2',
            weightPercent: 35,
            isBenefit: true,
            maxValue: 10),
        WeightedDecisionCriteria(
            id: 'c3',
            name: 'C3',
            weightPercent: 25,
            isBenefit: false,
            maxValue: 10),
      ];
      final criteria80Saw = [
        WeightedDecisionCriteria(
            id: 'c1',
            name: 'C1',
            weightPercent: 80,
            isBenefit: true,
            maxValue: 10),
        WeightedDecisionCriteria(
            id: 'c2',
            name: 'C2',
            weightPercent: 70,
            isBenefit: true,
            maxValue: 10),
        WeightedDecisionCriteria(
            id: 'c3',
            name: 'C3',
            weightPercent: 50,
            isBenefit: false,
            maxValue: 10),
      ];
      final alts = [
        WeightedDecisionAlternative(id: 'a1', name: 'A1'),
        WeightedDecisionAlternative(id: 'a2', name: 'A2'),
        WeightedDecisionAlternative(id: 'a3', name: 'A3'),
        WeightedDecisionAlternative(id: 'a4', name: 'A4'),
      ];
      final matrix40Saw = [
        WeightedDecisionMatrix(id: 'm1', alternative: alts[0], ratings: [
          WeightedDecisionRating(
              id: 'r1_1', criteria: criteria40Saw[0], value: 5),
          WeightedDecisionRating(
              id: 'r1_2', criteria: criteria40Saw[1], value: 1),
          WeightedDecisionRating(
              id: 'r1_3', criteria: criteria40Saw[2], value: 5),
        ]),
        WeightedDecisionMatrix(id: 'm2', alternative: alts[1], ratings: [
          WeightedDecisionRating(
              id: 'r2_1', criteria: criteria40Saw[0], value: 2),
          WeightedDecisionRating(
              id: 'r2_2', criteria: criteria40Saw[1], value: 7),
          WeightedDecisionRating(
              id: 'r2_3', criteria: criteria40Saw[2], value: 9),
        ]),
        WeightedDecisionMatrix(id: 'm3', alternative: alts[2], ratings: [
          WeightedDecisionRating(
              id: 'r3_1', criteria: criteria40Saw[0], value: 9),
          WeightedDecisionRating(
              id: 'r3_2', criteria: criteria40Saw[1], value: 6),
          WeightedDecisionRating(
              id: 'r3_3', criteria: criteria40Saw[2], value: 8),
        ]),
        WeightedDecisionMatrix(id: 'm4', alternative: alts[3], ratings: [
          WeightedDecisionRating(
              id: 'r4_1', criteria: criteria40Saw[0], value: 4),
          WeightedDecisionRating(
              id: 'r4_2', criteria: criteria40Saw[1], value: 2),
          WeightedDecisionRating(
              id: 'r4_3', criteria: criteria40Saw[2], value: 5),
        ]),
      ];
      final matrix80Saw = [
        WeightedDecisionMatrix(id: 'm1', alternative: alts[0], ratings: [
          WeightedDecisionRating(
              id: 'r1_1', criteria: criteria80Saw[0], value: 5),
          WeightedDecisionRating(
              id: 'r1_2', criteria: criteria80Saw[1], value: 1),
          WeightedDecisionRating(
              id: 'r1_3', criteria: criteria80Saw[2], value: 5),
        ]),
        WeightedDecisionMatrix(id: 'm2', alternative: alts[1], ratings: [
          WeightedDecisionRating(
              id: 'r2_1', criteria: criteria80Saw[0], value: 2),
          WeightedDecisionRating(
              id: 'r2_2', criteria: criteria80Saw[1], value: 7),
          WeightedDecisionRating(
              id: 'r2_3', criteria: criteria80Saw[2], value: 9),
        ]),
        WeightedDecisionMatrix(id: 'm3', alternative: alts[2], ratings: [
          WeightedDecisionRating(
              id: 'r3_1', criteria: criteria80Saw[0], value: 9),
          WeightedDecisionRating(
              id: 'r3_2', criteria: criteria80Saw[1], value: 6),
          WeightedDecisionRating(
              id: 'r3_3', criteria: criteria80Saw[2], value: 8),
        ]),
        WeightedDecisionMatrix(id: 'm4', alternative: alts[3], ratings: [
          WeightedDecisionRating(
              id: 'r4_1', criteria: criteria80Saw[0], value: 4),
          WeightedDecisionRating(
              id: 'r4_2', criteria: criteria80Saw[1], value: 2),
          WeightedDecisionRating(
              id: 'r4_3', criteria: criteria80Saw[2], value: 5),
        ]),
      ];

      final sawRes40 =
          SawCalculator.analyzeSensitivity(matrix40Saw, delta: 0.1);
      final sawRes80 =
          SawCalculator.analyzeSensitivity(matrix80Saw, delta: 0.1);

      expect(sawRes80.isStable, sawRes40.isStable);
      expect(sawRes80.baseRanking, sawRes40.baseRanking);
      for (final altId in sawRes40.baseScores.keys) {
        expect(sawRes80.baseScores[altId],
            closeTo(sawRes40.baseScores[altId]!, 1e-9));
      }
      expect(
          sawRes80.sensitivityCases.length, sawRes40.sensitivityCases.length);
      for (var i = 0; i < sawRes40.sensitivityCases.length; i++) {
        final c40 = sawRes40.sensitivityCases[i];
        final c80 = sawRes80.sensitivityCases[i];
        expect(c80.ranking, c40.ranking);
        expect(c80.hasOrderChanged, c40.hasOrderChanged);
        for (final k in c40.scores.keys) {
          expect(c80.scores[k], closeTo(c40.scores[k]!, 1e-9));
        }
      }
      expect(
          sawRes80.rankReversalCases.length, sawRes40.rankReversalCases.length);
      for (var i = 0; i < sawRes40.rankReversalCases.length; i++) {
        final r40 = sawRes40.rankReversalCases[i];
        final r80 = sawRes80.rankReversalCases[i];
        expect(r80.ranking, r40.ranking);
        expect(r80.hasReversal, r40.hasReversal);
        for (final k in r40.scores.keys) {
          expect(r80.scores[k], closeTo(r40.scores[k]!, 1e-9));
        }
      }

      // 2. TOPSIS T1 with 40/35/25 vs 80/70/50
      final topsisRaw40 = TopsisRawMatrix(
        criterias: criteria40Saw,
        matrixs: [
          WeightedDecisionMatrix(id: 'm1', alternative: alts[0], ratings: [
            WeightedDecisionRating(
                id: 'r1_1', criteria: criteria40Saw[0], value: 8),
            WeightedDecisionRating(
                id: 'r1_2', criteria: criteria40Saw[1], value: 7),
            WeightedDecisionRating(
                id: 'r1_3', criteria: criteria40Saw[2], value: 1),
          ]),
          WeightedDecisionMatrix(id: 'm2', alternative: alts[1], ratings: [
            WeightedDecisionRating(
                id: 'r2_1', criteria: criteria40Saw[0], value: 2),
            WeightedDecisionRating(
                id: 'r2_2', criteria: criteria40Saw[1], value: 6),
            WeightedDecisionRating(
                id: 'r2_3', criteria: criteria40Saw[2], value: 9),
          ]),
          WeightedDecisionMatrix(id: 'm3', alternative: alts[2], ratings: [
            WeightedDecisionRating(
                id: 'r3_1', criteria: criteria40Saw[0], value: 9),
            WeightedDecisionRating(
                id: 'r3_2', criteria: criteria40Saw[1], value: 2),
            WeightedDecisionRating(
                id: 'r3_3', criteria: criteria40Saw[2], value: 6),
          ]),
          WeightedDecisionMatrix(id: 'm4', alternative: alts[3], ratings: [
            WeightedDecisionRating(
                id: 'r4_1', criteria: criteria40Saw[0], value: 1),
            WeightedDecisionRating(
                id: 'r4_2', criteria: criteria40Saw[1], value: 2),
            WeightedDecisionRating(
                id: 'r4_3', criteria: criteria40Saw[2], value: 2),
          ]),
        ],
      );
      final topsisRaw80 = TopsisRawMatrix(
        criterias: criteria80Saw,
        matrixs: [
          WeightedDecisionMatrix(id: 'm1', alternative: alts[0], ratings: [
            WeightedDecisionRating(
                id: 'r1_1', criteria: criteria80Saw[0], value: 8),
            WeightedDecisionRating(
                id: 'r1_2', criteria: criteria80Saw[1], value: 7),
            WeightedDecisionRating(
                id: 'r1_3', criteria: criteria80Saw[2], value: 1),
          ]),
          WeightedDecisionMatrix(id: 'm2', alternative: alts[1], ratings: [
            WeightedDecisionRating(
                id: 'r2_1', criteria: criteria80Saw[0], value: 2),
            WeightedDecisionRating(
                id: 'r2_2', criteria: criteria80Saw[1], value: 6),
            WeightedDecisionRating(
                id: 'r2_3', criteria: criteria80Saw[2], value: 9),
          ]),
          WeightedDecisionMatrix(id: 'm3', alternative: alts[2], ratings: [
            WeightedDecisionRating(
                id: 'r3_1', criteria: criteria80Saw[0], value: 9),
            WeightedDecisionRating(
                id: 'r3_2', criteria: criteria80Saw[1], value: 2),
            WeightedDecisionRating(
                id: 'r3_3', criteria: criteria80Saw[2], value: 6),
          ]),
          WeightedDecisionMatrix(id: 'm4', alternative: alts[3], ratings: [
            WeightedDecisionRating(
                id: 'r4_1', criteria: criteria80Saw[0], value: 1),
            WeightedDecisionRating(
                id: 'r4_2', criteria: criteria80Saw[1], value: 2),
            WeightedDecisionRating(
                id: 'r4_3', criteria: criteria80Saw[2], value: 2),
          ]),
        ],
      );

      final topsisRes40 =
          TopsisCalculator.analyzeSensitivity(topsisRaw40, delta: 0.1);
      final topsisRes80 =
          TopsisCalculator.analyzeSensitivity(topsisRaw80, delta: 0.1);

      expect(topsisRes80.isStable, topsisRes40.isStable);
      expect(topsisRes80.baseRanking, topsisRes40.baseRanking);
      for (final altId in topsisRes40.baseScores.keys) {
        expect(topsisRes80.baseScores[altId],
            closeTo(topsisRes40.baseScores[altId]!, 1e-9));
      }
      expect(topsisRes80.sensitivityCases.length,
          topsisRes40.sensitivityCases.length);
      for (var i = 0; i < topsisRes40.sensitivityCases.length; i++) {
        final c40 = topsisRes40.sensitivityCases[i];
        final c80 = topsisRes80.sensitivityCases[i];
        expect(c80.ranking, c40.ranking);
        expect(c80.hasOrderChanged, c40.hasOrderChanged);
        for (final k in c40.scores.keys) {
          expect(c80.scores[k], closeTo(c40.scores[k]!, 1e-9));
        }
      }
      expect(topsisRes80.rankReversalCases.length,
          topsisRes40.rankReversalCases.length);
      for (var i = 0; i < topsisRes40.rankReversalCases.length; i++) {
        final r40 = topsisRes40.rankReversalCases[i];
        final r80 = topsisRes80.rankReversalCases[i];
        expect(r80.ranking, r40.ranking);
        expect(r80.hasReversal, r40.hasReversal);
        for (final k in r40.scores.keys) {
          expect(r80.scores[k], closeTo(r40.scores[k]!, 1e-9));
        }
      }
    });

    // -------------------------------------------------------------------------
    // JSON Serialization Check
    // -------------------------------------------------------------------------
    test('SensitivityAnalysisResult and components serialize to JSON correctly',
        () {
      final pair = AlternativePair('a1', 'a2');
      final pairJson = pair.toJson();
      expect(pairJson['first_id'], 'a1');
      expect(pairJson['second_id'], 'a2');

      final sCase = WeightSensitivityCase(
        criterionId: 'c1',
        direction: SensitivityDirection.increase,
        delta: 0.1,
        weights: {'c1': 0.5, 'c2': 0.5},
        scores: {'a1': 0.8, 'a2': 0.6},
        ranking: ['a1', 'a2'],
        hasOrderChanged: false,
        swappedPairs: const [],
      );
      final sCaseJson = sCase.toJson();
      expect(sCaseJson['criterion_id'], 'c1');
      expect(sCaseJson['direction'], '+');
      expect(sCaseJson['delta'], 0.1);
      expect(sCaseJson['is_skipped'], isFalse);

      final rCase = RankReversalCase(
        removedAlternativeId: 'a3',
        scores: {'a1': 0.7, 'a2': 0.6},
        ranking: ['a1', 'a2'],
        hasReversal: true,
        reversedPairs: [pair],
      );
      final rCaseJson = rCase.toJson();
      expect(rCaseJson['removed_alternative_id'], 'a3');
      expect(rCaseJson['has_reversal'], isTrue);
      expect(rCaseJson['reversed_pairs'], isNotEmpty);

      final result = SensitivityAnalysisResult(
        delta: 0.1,
        baseRanking: ['a1', 'a2'],
        baseScores: {'a1': 0.8, 'a2': 0.6},
        sensitivityCases: [sCase],
        rankReversalCases: [rCase],
        isStable: false,
      );
      final resultJson = result.toJson();
      expect(resultJson['delta'], 0.1);
      expect(resultJson['is_stable'], isFalse);
      expect(resultJson['sensitivity_cases'], isA<List>());
      expect(resultJson['rank_reversal_cases'], isA<List>());
    });
  });
}
