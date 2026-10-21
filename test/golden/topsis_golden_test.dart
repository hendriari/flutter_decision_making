import 'package:decision_making_core/decision_making_core.dart';
import 'package:flutter_decision_making/flutter_decision_making.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TOPSIS topsis;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    topsis = TOPSIS();
  });

  group('TOPSIS Golden Tests - Core Wrapper Parity', () {
    test('Case 1: Consistent 4x4 case', () async {
      // Ground truth verified against core (decision_making_core)

      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'Alternative 1'),
        WeightedDecisionAlternative(id: 'a2', name: 'Alternative 2'),
        WeightedDecisionAlternative(id: 'a3', name: 'Alternative 3'),
        WeightedDecisionAlternative(id: 'a4', name: 'Alternative 4'),
      ];

      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Style',
          weightPercent: 10,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'Reliability',
          weightPercent: 40,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c3',
          name: 'Economy',
          weightPercent: 40,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c4',
          name: 'Warranty',
          weightPercent: 10,
          isBenefit: true,
          maxValue: 10,
        ),
      ];

      final rawMatrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(id: 'r1_1', criteria: criteria[0], value: 7),
            WeightedDecisionRating(id: 'r1_2', criteria: criteria[1], value: 9),
            WeightedDecisionRating(id: 'r1_3', criteria: criteria[2], value: 9),
            WeightedDecisionRating(id: 'r1_4', criteria: criteria[3], value: 8),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(id: 'r2_1', criteria: criteria[0], value: 8),
            WeightedDecisionRating(id: 'r2_2', criteria: criteria[1], value: 7),
            WeightedDecisionRating(id: 'r2_3', criteria: criteria[2], value: 8),
            WeightedDecisionRating(id: 'r2_4', criteria: criteria[3], value: 7),
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

      final expected = TopsisCalculator.calculate(topsisMatrix);

      final result = await topsis.getTopsisResult(matrix: topsisMatrix);
      final isolateResult =
          await topsis.getTopsisResult(matrix: topsisMatrix, useIsolate: true);

      // Verify wrapper (main thread) produces identical output to core
      expect(result.length, expected.length);
      for (int i = 0; i < expected.length; i++) {
        expect(result[i].alternative.id, expected[i].alternative.id);
        expect(result[i].rank, expected[i].rank);
        expect(result[i].score, closeTo(expected[i].score, 1e-6));
      }

      // Verify wrapper (isolate) produces identical output to core
      expect(isolateResult.length, expected.length);
      for (int i = 0; i < expected.length; i++) {
        expect(isolateResult[i].alternative.id, expected[i].alternative.id);
        expect(isolateResult[i].rank, expected[i].rank);
        expect(isolateResult[i].score, closeTo(expected[i].score, 1e-6));
      }
    });

    test('Case 2: Vendor / Supplier Selection - Multiple Cost Criteria', () async {
      // Ground truth verified against core (decision_making_core)

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

      final expected = TopsisCalculator.calculate(topsisMatrix);

      final result = await topsis.getTopsisResult(matrix: topsisMatrix);
      final isolateResult =
          await topsis.getTopsisResult(matrix: topsisMatrix, useIsolate: true);

      // Verify wrapper (main thread) produces identical output to core
      expect(result.length, expected.length);
      for (int i = 0; i < expected.length; i++) {
        expect(result[i].alternative.id, expected[i].alternative.id);
        expect(result[i].rank, expected[i].rank);
        expect(result[i].score, closeTo(expected[i].score, 1e-6));
      }

      // Verify wrapper (isolate) produces identical output to core
      expect(isolateResult.length, expected.length);
      for (int i = 0; i < expected.length; i++) {
        expect(isolateResult[i].alternative.id, expected[i].alternative.id);
        expect(isolateResult[i].rank, expected[i].rank);
        expect(isolateResult[i].score, closeTo(expected[i].score, 1e-6));
      }
    });

    test('Case 3 (Edge Case): Cost Criteria and Identical Alternatives (Tie)', () async {
      // Ground truth verified against core (decision_making_core)

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

      final expected = TopsisCalculator.calculate(topsisMatrix);

      final result = await topsis.getTopsisResult(matrix: topsisMatrix);
      final isolateResult =
          await topsis.getTopsisResult(matrix: topsisMatrix, useIsolate: true);

      // Verify wrapper (main thread) produces identical output to core
      expect(result.length, expected.length);
      for (int i = 0; i < expected.length; i++) {
        expect(result[i].alternative.id, expected[i].alternative.id);
        expect(result[i].rank, expected[i].rank);
        expect(result[i].score, closeTo(expected[i].score, 1e-6));
      }

      // Verify wrapper (isolate) produces identical output to core
      expect(isolateResult.length, expected.length);
      for (int i = 0; i < expected.length; i++) {
        expect(isolateResult[i].alternative.id, expected[i].alternative.id);
        expect(isolateResult[i].rank, expected[i].rank);
        expect(isolateResult[i].score, closeTo(expected[i].score, 1e-6));
      }
    });
  });
}
