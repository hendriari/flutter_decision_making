import 'package:flutter_decision_making/flutter_decision_making.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FlutterDecisionMaking fdm;

  setUp(() {
    fdm = FlutterDecisionMaking();
  });

  group('Sensitivity & Rank Reversal - Wrapper Parity Golden Tests', () {
    // -------------------------------------------------------------------------
    // SAW S2 Parity Test
    // -------------------------------------------------------------------------
    test('SAW Dataset S2 via fdm.saw.analyzeSensitivity matches reference values', () async {
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

      final result = await fdm.saw.analyzeSensitivity(matrix: matrix, delta: 0.1);

      expect(result.isStable, isFalse);
      expect(result.baseRanking, ['a3', 'a2', 'a4', 'a1']);

      // C1 +10%
      final c1Plus = result.sensitivityCases.firstWhere(
        (c) => c.criterionId == 'c1' && c.direction == SensitivityDirection.increase,
      );
      expect(c1Plus.ranking, ['a3', 'a2', 'a1', 'a4']);
      expect(c1Plus.hasOrderChanged, isTrue);
      expect(c1Plus.swappedPairs.any((p) => p.matches('a1', 'a4')), isTrue);

      // Rank reversal on A3 removal
      final remA3 = result.rankReversalCases.firstWhere(
        (c) => c.removedAlternativeId == 'a3',
      );
      expect(remA3.ranking, ['a1', 'a4', 'a2']);
      expect(remA3.hasReversal, isTrue);
      expect(remA3.reversedPairs.any((p) => p.matches('a1', 'a2')), isTrue);
    });

    // -------------------------------------------------------------------------
    // TOPSIS T1 Parity Test
    // -------------------------------------------------------------------------
    test('TOPSIS Dataset T1 via fdm.topsis.analyzeSensitivity matches reference values', () async {
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
          isBenefit: false,
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
              WeightedDecisionRating(id: 'r1_1', criteria: criteria[0], value: 8),
              WeightedDecisionRating(id: 'r1_2', criteria: criteria[1], value: 7),
              WeightedDecisionRating(id: 'r1_3', criteria: criteria[2], value: 1),
            ],
          ),
          WeightedDecisionMatrix(
            id: 'm2',
            alternative: alternatives[1],
            ratings: [
              WeightedDecisionRating(id: 'r2_1', criteria: criteria[0], value: 2),
              WeightedDecisionRating(id: 'r2_2', criteria: criteria[1], value: 6),
              WeightedDecisionRating(id: 'r2_3', criteria: criteria[2], value: 9),
            ],
          ),
          WeightedDecisionMatrix(
            id: 'm3',
            alternative: alternatives[2],
            ratings: [
              WeightedDecisionRating(id: 'r3_1', criteria: criteria[0], value: 9),
              WeightedDecisionRating(id: 'r3_2', criteria: criteria[1], value: 2),
              WeightedDecisionRating(id: 'r3_3', criteria: criteria[2], value: 6),
            ],
          ),
          WeightedDecisionMatrix(
            id: 'm4',
            alternative: alternatives[3],
            ratings: [
              WeightedDecisionRating(id: 'r4_1', criteria: criteria[0], value: 1),
              WeightedDecisionRating(id: 'r4_2', criteria: criteria[1], value: 2),
              WeightedDecisionRating(id: 'r4_3', criteria: criteria[2], value: 2),
            ],
          ),
        ],
      );

      final result = await fdm.topsis.analyzeSensitivity(matrix: rawMatrix, delta: 0.1);

      expect(result.baseRanking, ['a1', 'a3', 'a2', 'a4']);

      // C2 -10%
      final c2Minus = result.sensitivityCases.firstWhere(
        (c) => c.criterionId == 'c2' && c.direction == SensitivityDirection.decrease,
      );
      expect(c2Minus.ranking, ['a1', 'a3', 'a4', 'a2']);
      expect(c2Minus.hasOrderChanged, isTrue);

      // C3 +10%
      final c3Plus = result.sensitivityCases.firstWhere(
        (c) => c.criterionId == 'c3' && c.direction == SensitivityDirection.increase,
      );
      expect(c3Plus.ranking, ['a1', 'a3', 'a4', 'a2']);
      expect(c3Plus.hasOrderChanged, isTrue);

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
    });

    // -------------------------------------------------------------------------
    // TOPSIS T2 Parity Test
    // -------------------------------------------------------------------------
    test('TOPSIS Dataset T2 via fdm.topsis.analyzeSensitivity matches reference values', () async {
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
          isBenefit: false,
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
              WeightedDecisionRating(id: 'r1_1', criteria: criteria[0], value: 8),
              WeightedDecisionRating(id: 'r1_2', criteria: criteria[1], value: 5),
              WeightedDecisionRating(id: 'r1_3', criteria: criteria[2], value: 7),
            ],
          ),
          WeightedDecisionMatrix(
            id: 'm2',
            alternative: alternatives[1],
            ratings: [
              WeightedDecisionRating(id: 'r2_1', criteria: criteria[0], value: 3),
              WeightedDecisionRating(id: 'r2_2', criteria: criteria[1], value: 1),
              WeightedDecisionRating(id: 'r2_3', criteria: criteria[2], value: 1),
            ],
          ),
          WeightedDecisionMatrix(
            id: 'm3',
            alternative: alternatives[2],
            ratings: [
              WeightedDecisionRating(id: 'r3_1', criteria: criteria[0], value: 9),
              WeightedDecisionRating(id: 'r3_2', criteria: criteria[1], value: 9),
              WeightedDecisionRating(id: 'r3_3', criteria: criteria[2], value: 3),
            ],
          ),
          WeightedDecisionMatrix(
            id: 'm4',
            alternative: alternatives[3],
            ratings: [
              WeightedDecisionRating(id: 'r4_1', criteria: criteria[0], value: 4),
              WeightedDecisionRating(id: 'r4_2', criteria: criteria[1], value: 3),
              WeightedDecisionRating(id: 'r4_3', criteria: criteria[2], value: 2),
            ],
          ),
        ],
      );

      final result = await fdm.topsis.analyzeSensitivity(matrix: rawMatrix, delta: 0.1);

      expect(result.baseRanking, ['a3', 'a1', 'a4', 'a2']);

      final remA1 = result.rankReversalCases.firstWhere(
        (c) => c.removedAlternativeId == 'a1',
      );
      expect(remA1.ranking, ['a3', 'a2', 'a4']);
      expect(remA1.hasReversal, isTrue);
      expect(remA1.reversedPairs.any((p) => p.matches('a2', 'a4')), isTrue);
    });
  });
}
