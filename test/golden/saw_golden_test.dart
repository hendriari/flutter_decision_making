import 'package:decision_making_core/decision_making_core.dart';
import 'package:flutter_decision_making/flutter_decision_making.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SAW saw;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    saw = SAW();
  });

  group('SAW Golden Tests - Core Wrapper Parity', () {
    test('Case 1: Mixed benefit and cost 3x4 case', () async {
      // Ground truth verified against core (decision_making_core)

      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'Alternative 1'),
        WeightedDecisionAlternative(id: 'a2', name: 'Alternative 2'),
        WeightedDecisionAlternative(id: 'a3', name: 'Alternative 3'),
      ];

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

      final rawMatrix = [
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

      final expected = SawCalculator.calculate(rawMatrix);
      final result = await saw.getSawResult(matrix: rawMatrix);
      final isolateResult =
          await saw.getSawResult(matrix: rawMatrix, useIsolate: true);

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

      // Verify wrapper detailed result matches core calculateDetailed
      final expectedDetailed = SawCalculator.calculateDetailed(rawMatrix);
      final detailedResult = await saw.getSawDetailedResult(matrix: rawMatrix);

      expect(detailedResult.initialMatrix.length,
          expectedDetailed.initialMatrix.length);
      expect(detailedResult.normalizedMatrix.length,
          expectedDetailed.normalizedMatrix.length);
      expect(detailedResult.weightedMatrix.length,
          expectedDetailed.weightedMatrix.length);
      expect(detailedResult.scores.length, expectedDetailed.scores.length);

      // Verify normalized weights per key with closeTo
      for (final key in expectedDetailed.normalizedWeights.keys) {
        expect(detailedResult.normalizedWeights[key],
            closeTo(expectedDetailed.normalizedWeights[key]!, 1e-4));
      }

      // Verify each cell in normalized matrix with closeTo
      for (int i = 0; i < expectedDetailed.normalizedMatrix.length; i++) {
        for (int j = 0;
            j < expectedDetailed.normalizedMatrix[i].ratings.length;
            j++) {
          expect(
            detailedResult.normalizedMatrix[i].ratings[j].value,
            closeTo(
                expectedDetailed.normalizedMatrix[i].ratings[j].value!, 1e-4),
          );
        }
      }

      // Verify each cell in weighted matrix with closeTo
      for (int i = 0; i < expectedDetailed.weightedMatrix.length; i++) {
        for (int j = 0;
            j < expectedDetailed.weightedMatrix[i].ratings.length;
            j++) {
          expect(
            detailedResult.weightedMatrix[i].ratings[j].value,
            closeTo(expectedDetailed.weightedMatrix[i].ratings[j].value!, 1e-4),
          );
        }
      }

      // Verify final scores and ranks
      for (int i = 0; i < expectedDetailed.scores.length; i++) {
        expect(detailedResult.scores[i].alternative.id,
            expectedDetailed.scores[i].alternative.id);
        expect(detailedResult.scores[i].rank, expectedDetailed.scores[i].rank);
        expect(detailedResult.scores[i].score,
            closeTo(expectedDetailed.scores[i].score, 1e-4));
      }
    });

    test('Case 2: Employee Performance Evaluation - All Benefit', () async {
      // Ground truth verified against core (decision_making_core)

      final alternatives = [
        WeightedDecisionAlternative(id: 'e1', name: 'Employee 1'),
        WeightedDecisionAlternative(id: 'e2', name: 'Employee 2'),
        WeightedDecisionAlternative(id: 'e3', name: 'Employee 3'),
        WeightedDecisionAlternative(id: 'e4', name: 'Employee 4'),
      ];

      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Technical Skill',
          weightPercent: 40,
          isBenefit: true,
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'Communication',
          weightPercent: 30,
          isBenefit: true,
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          id: 'c3',
          name: 'Problem Solving',
          weightPercent: 30,
          isBenefit: true,
          maxValue: 100,
        ),
      ];

      final rawMatrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(
                id: 'r1_1', criteria: criteria[0], value: 80),
            WeightedDecisionRating(
                id: 'r1_2', criteria: criteria[1], value: 90),
            WeightedDecisionRating(
                id: 'r1_3', criteria: criteria[2], value: 70),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(
                id: 'r2_1', criteria: criteria[0], value: 90),
            WeightedDecisionRating(
                id: 'r2_2', criteria: criteria[1], value: 80),
            WeightedDecisionRating(
                id: 'r2_3', criteria: criteria[2], value: 75),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(
                id: 'r3_1', criteria: criteria[0], value: 85),
            WeightedDecisionRating(
                id: 'r3_2', criteria: criteria[1], value: 85),
            WeightedDecisionRating(
                id: 'r3_3', criteria: criteria[2], value: 80),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm4',
          alternative: alternatives[3],
          ratings: [
            WeightedDecisionRating(
                id: 'r4_1', criteria: criteria[0], value: 75),
            WeightedDecisionRating(
                id: 'r4_2', criteria: criteria[1], value: 70),
            WeightedDecisionRating(
                id: 'r4_3', criteria: criteria[2], value: 85),
          ],
        ),
      ];

      final expected = SawCalculator.calculate(rawMatrix);
      final result = await saw.getSawResult(matrix: rawMatrix);
      final isolateResult =
          await saw.getSawResult(matrix: rawMatrix, useIsolate: true);

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

      // Verify wrapper detailed result matches core calculateDetailed
      final expectedDetailed = SawCalculator.calculateDetailed(rawMatrix);
      final detailedResult = await saw.getSawDetailedResult(matrix: rawMatrix);

      expect(detailedResult.initialMatrix.length,
          expectedDetailed.initialMatrix.length);
      expect(detailedResult.normalizedMatrix.length,
          expectedDetailed.normalizedMatrix.length);
      expect(detailedResult.weightedMatrix.length,
          expectedDetailed.weightedMatrix.length);
      expect(detailedResult.scores.length, expectedDetailed.scores.length);

      // Verify normalized weights per key with closeTo
      for (final key in expectedDetailed.normalizedWeights.keys) {
        expect(detailedResult.normalizedWeights[key],
            closeTo(expectedDetailed.normalizedWeights[key]!, 1e-4));
      }

      // Verify each cell in normalized matrix with closeTo
      for (int i = 0; i < expectedDetailed.normalizedMatrix.length; i++) {
        for (int j = 0;
            j < expectedDetailed.normalizedMatrix[i].ratings.length;
            j++) {
          expect(
            detailedResult.normalizedMatrix[i].ratings[j].value,
            closeTo(
                expectedDetailed.normalizedMatrix[i].ratings[j].value!, 1e-4),
          );
        }
      }

      // Verify each cell in weighted matrix with closeTo
      for (int i = 0; i < expectedDetailed.weightedMatrix.length; i++) {
        for (int j = 0;
            j < expectedDetailed.weightedMatrix[i].ratings.length;
            j++) {
          expect(
            detailedResult.weightedMatrix[i].ratings[j].value,
            closeTo(expectedDetailed.weightedMatrix[i].ratings[j].value!, 1e-4),
          );
        }
      }

      // Verify final scores and ranks
      for (int i = 0; i < expectedDetailed.scores.length; i++) {
        expect(detailedResult.scores[i].alternative.id,
            expectedDetailed.scores[i].alternative.id);
        expect(detailedResult.scores[i].rank, expectedDetailed.scores[i].rank);
        expect(detailedResult.scores[i].score,
            closeTo(expectedDetailed.scores[i].score, 1e-4));
      }
    });

    test('Case 3 (Edge Case): Cost Criteria and Identical Alternatives (Tie)',
        () async {
      // Ground truth verified against core (decision_making_core)

      final alternatives = [
        WeightedDecisionAlternative(id: 'altA', name: 'Alternative A'),
        WeightedDecisionAlternative(id: 'altB', name: 'Alternative B'),
        WeightedDecisionAlternative(id: 'altC', name: 'Alternative C'),
      ];

      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Price',
          weightPercent: 50,
          isBenefit: false, // Cost criteria
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'Quality',
          weightPercent: 50,
          isBenefit: true, // Benefit criteria
          maxValue: 100,
        ),
      ];

      // altA and altB have identical values
      final rawMatrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(
                id: 'r1_1', criteria: criteria[0], value: 40),
            WeightedDecisionRating(
                id: 'r1_2', criteria: criteria[1], value: 80),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(
                id: 'r2_1', criteria: criteria[0], value: 40),
            WeightedDecisionRating(
                id: 'r2_2', criteria: criteria[1], value: 80),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(
                id: 'r3_1', criteria: criteria[0], value: 60),
            WeightedDecisionRating(
                id: 'r3_2', criteria: criteria[1], value: 60),
          ],
        ),
      ];

      final expected = SawCalculator.calculate(rawMatrix);
      final result = await saw.getSawResult(matrix: rawMatrix);
      final isolateResult =
          await saw.getSawResult(matrix: rawMatrix, useIsolate: true);

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

      // Verify wrapper detailed result matches core calculateDetailed
      final expectedDetailed = SawCalculator.calculateDetailed(rawMatrix);
      final detailedResult = await saw.getSawDetailedResult(matrix: rawMatrix);

      expect(detailedResult.initialMatrix.length,
          expectedDetailed.initialMatrix.length);
      expect(detailedResult.normalizedMatrix.length,
          expectedDetailed.normalizedMatrix.length);
      expect(detailedResult.weightedMatrix.length,
          expectedDetailed.weightedMatrix.length);
      expect(detailedResult.scores.length, expectedDetailed.scores.length);

      // Verify normalized weights per key with closeTo
      for (final key in expectedDetailed.normalizedWeights.keys) {
        expect(detailedResult.normalizedWeights[key],
            closeTo(expectedDetailed.normalizedWeights[key]!, 1e-4));
      }

      // Verify each cell in normalized matrix with closeTo
      for (int i = 0; i < expectedDetailed.normalizedMatrix.length; i++) {
        for (int j = 0;
            j < expectedDetailed.normalizedMatrix[i].ratings.length;
            j++) {
          expect(
            detailedResult.normalizedMatrix[i].ratings[j].value,
            closeTo(
                expectedDetailed.normalizedMatrix[i].ratings[j].value!, 1e-4),
          );
        }
      }

      // Verify each cell in weighted matrix with closeTo
      for (int i = 0; i < expectedDetailed.weightedMatrix.length; i++) {
        for (int j = 0;
            j < expectedDetailed.weightedMatrix[i].ratings.length;
            j++) {
          expect(
            detailedResult.weightedMatrix[i].ratings[j].value,
            closeTo(expectedDetailed.weightedMatrix[i].ratings[j].value!, 1e-4),
          );
        }
      }

      // Verify final scores and ranks
      for (int i = 0; i < expectedDetailed.scores.length; i++) {
        expect(detailedResult.scores[i].alternative.id,
            expectedDetailed.scores[i].alternative.id);
        expect(detailedResult.scores[i].rank, expectedDetailed.scores[i].rank);
        expect(detailedResult.scores[i].score,
            closeTo(expectedDetailed.scores[i].score, 1e-4));
      }
    });
  });
}
