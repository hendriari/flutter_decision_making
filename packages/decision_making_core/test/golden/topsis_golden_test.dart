import 'package:decision_making_core/decision_making_core.dart';
import 'package:test/test.dart';

void main() {
  group('TOPSIS Golden Tests (Tolerance 1e-4)', () {
    test('Case 1: Consistent 4x4 case', () {
      // Label: cross-checked (Python 3.9 + numpy)

      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'Alternative 1'),
        WeightedDecisionAlternative(id: 'a2', name: 'Alternative 2'),
        WeightedDecisionAlternative(id: 'a3', name: 'Alternative 3'),
        WeightedDecisionAlternative(id: 'a4', name: 'Alternative 4'),
      ];

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
          isBenefit: false, // Cost criteria
          maxValue: 10,
        ),
      ];

      final rawMatrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(id: 'r1_1', criteria: criteria[0], value: 5),
            WeightedDecisionRating(id: 'r1_2', criteria: criteria[1], value: 8),
            WeightedDecisionRating(id: 'r1_3', criteria: criteria[2], value: 4),
            WeightedDecisionRating(id: 'r1_4', criteria: criteria[3], value: 7),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(id: 'r2_1', criteria: criteria[0], value: 7),
            WeightedDecisionRating(id: 'r2_2', criteria: criteria[1], value: 6),
            WeightedDecisionRating(id: 'r2_3', criteria: criteria[2], value: 8),
            WeightedDecisionRating(id: 'r2_4', criteria: criteria[3], value: 9),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(id: 'r3_1', criteria: criteria[0], value: 8),
            WeightedDecisionRating(id: 'r3_2', criteria: criteria[1], value: 9),
            WeightedDecisionRating(id: 'r3_3', criteria: criteria[2], value: 6),
            WeightedDecisionRating(id: 'r3_4', criteria: criteria[3], value: 6),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm4',
          alternative: alternatives[3],
          ratings: [
            WeightedDecisionRating(id: 'r4_1', criteria: criteria[0], value: 7),
            WeightedDecisionRating(id: 'r4_2', criteria: criteria[1], value: 7),
            WeightedDecisionRating(id: 'r4_3', criteria: criteria[2], value: 7),
            WeightedDecisionRating(id: 'r4_4', criteria: criteria[3], value: 7),
          ],
        ),
      ];

      final topsisMatrix = TopsisRawMatrix(
        criterias: criteria,
        matrixs: rawMatrix,
      );

      final result = TopsisCalculator.calculate(topsisMatrix);

      expect(result.length, 4);

      // Rank 1: Alternative 3 (score: ~0.720097)
      expect(result[0].alternative.id, 'a3');
      expect(result[0].rank, 1);
      expect(result[0].score, closeTo(0.720097, 1e-4));

      // Rank 2: Alternative 4 (score: ~0.655263)
      expect(result[1].alternative.id, 'a4');
      expect(result[1].rank, 2);
      expect(result[1].score, closeTo(0.655263, 1e-4));

      // Rank 3: Alternative 2 (score: ~0.566853)
      expect(result[2].alternative.id, 'a2');
      expect(result[2].rank, 3);
      expect(result[2].score, closeTo(0.566853, 1e-4));

      // Rank 4: Alternative 1 (score: ~0.292655)
      expect(result[3].alternative.id, 'a1');
      expect(result[3].rank, 4);
      expect(result[3].score, closeTo(0.292655, 1e-4));
    });

    test('Case 2: Vendor / Supplier Selection - Multiple Cost Criteria', () {
      // Label: cross-checked (Python 3.9)
      // 3 alternatives, 3 criteria (Quality [Benefit], Price [Cost], Delivery Time [Cost])

      final alternatives = [
        WeightedDecisionAlternative(id: 's1', name: 'Supplier 1'),
        WeightedDecisionAlternative(id: 's2', name: 'Supplier 2'),
        WeightedDecisionAlternative(id: 's3', name: 'Supplier 3'),
      ];

      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Product Quality',
          weightPercent: 50,
          isBenefit: true,
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'Quoted Price',
          weightPercent: 30,
          isBenefit: false, // Cost criteria
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          id: 'c3',
          name: 'Delivery Time',
          weightPercent: 20,
          isBenefit: false, // Cost criteria
          maxValue: 100,
        ),
      ];

      final rawMatrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(id: 'r1_1', criteria: criteria[0], value: 80),
            WeightedDecisionRating(id: 'r1_2', criteria: criteria[1], value: 20),
            WeightedDecisionRating(id: 'r1_3', criteria: criteria[2], value: 10),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(id: 'r2_1', criteria: criteria[0], value: 90),
            WeightedDecisionRating(id: 'r2_2', criteria: criteria[1], value: 30),
            WeightedDecisionRating(id: 'r2_3', criteria: criteria[2], value: 15),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(id: 'r3_1', criteria: criteria[0], value: 70),
            WeightedDecisionRating(id: 'r3_2', criteria: criteria[1], value: 15),
            WeightedDecisionRating(id: 'r3_3', criteria: criteria[2], value: 8),
          ],
        ),
      ];

      final topsisMatrix = TopsisRawMatrix(
        criterias: criteria,
        matrixs: rawMatrix,
      );

      final result = TopsisCalculator.calculate(topsisMatrix);

      expect(result.length, 3);

      // Rank 1: Supplier 3 (score: ~0.653390)
      expect(result[0].alternative.id, 's3');
      expect(result[0].rank, 1);
      expect(result[0].score, closeTo(0.653390, 1e-4));

      // Rank 2: Supplier 1 (score: ~0.636796)
      expect(result[1].alternative.id, 's1');
      expect(result[1].rank, 2);
      expect(result[1].score, closeTo(0.636796, 1e-4));

      // Rank 3: Supplier 2 (score: ~0.346610)
      expect(result[2].alternative.id, 's2');
      expect(result[2].rank, 3);
      expect(result[2].score, closeTo(0.346610, 1e-4));
    });

    test('Case 3 (Edge Case): Cost Criteria and Identical Alternatives (Tie)', () {
      // Label: cross-checked (Python 3.9)
      // Tests Euclidean distance to ideal solution when two alternatives are identical

      final alternatives = [
        WeightedDecisionAlternative(id: 'altA', name: 'Alternative A'),
        WeightedDecisionAlternative(id: 'altB', name: 'Alternative B'),
        WeightedDecisionAlternative(id: 'altC', name: 'Alternative C'),
      ];

      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Cost',
          weightPercent: 50,
          isBenefit: false, // Cost
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'Quality',
          weightPercent: 50,
          isBenefit: true, // Benefit
          maxValue: 100,
        ),
      ];

      final rawMatrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(id: 'r1_1', criteria: criteria[0], value: 30),
            WeightedDecisionRating(id: 'r1_2', criteria: criteria[1], value: 80),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(id: 'r2_1', criteria: criteria[0], value: 30),
            WeightedDecisionRating(id: 'r2_2', criteria: criteria[1], value: 80),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(id: 'r3_1', criteria: criteria[0], value: 50),
            WeightedDecisionRating(id: 'r3_2', criteria: criteria[1], value: 60),
          ],
        ),
      ];

      final topsisMatrix = TopsisRawMatrix(
        criterias: criteria,
        matrixs: rawMatrix,
      );

      final result = TopsisCalculator.calculate(topsisMatrix);

      expect(result.length, 3);

      // Both Alt A and Alt B achieve the ideal solution with score 1.000000
      expect(result[0].score, closeTo(1.000000, 1e-4));
      expect(result[1].score, closeTo(1.000000, 1e-4));

      // Perilaku saat ini: rank unik sekuensial (1, 2, 3, ...), urutan alternatif seri mengikuti urutan input pada ukuran data kecil.
      // Catatan: List.sort Dart tidak dijamin stabil, sehingga urutan alternatif seri pada data besar tidak dijamin.
      // Item terbuka: putuskan semantik rank saat seri (rank sama vs rank unik) dan tiebreak eksplisit.
      expect(result[0].alternative.id, 'altA');
      expect(result[0].rank, 1);
      expect(result[1].alternative.id, 'altB');
      expect(result[1].rank, 2);

      // Alt C is closest to negative ideal solution with score 0.000000
      expect(result[2].alternative.id, 'altC');
      expect(result[2].rank, 3);
      expect(result[2].score, closeTo(0.000000, 1e-4));
    });
  });
}
