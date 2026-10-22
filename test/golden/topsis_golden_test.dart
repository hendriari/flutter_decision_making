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

      // Verify wrapper detailed result matches core calculateDetailed
      final expectedDetailed = TopsisCalculator.calculateDetailed(topsisMatrix);
      final detailedResult =
          await topsis.getTopsisDetailedResult(matrix: topsisMatrix);

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

      // Verify ideal solutions
      for (final key in expectedDetailed.positiveIdeal.keys) {
        expect(detailedResult.positiveIdeal[key],
            closeTo(expectedDetailed.positiveIdeal[key]!, 1e-4));
      }
      for (final key in expectedDetailed.negativeIdeal.keys) {
        expect(detailedResult.negativeIdeal[key],
            closeTo(expectedDetailed.negativeIdeal[key]!, 1e-4));
      }

      // Verify separation distances
      for (final key in expectedDetailed.separationPlus.keys) {
        expect(detailedResult.separationPlus[key],
            closeTo(expectedDetailed.separationPlus[key]!, 1e-4));
      }
      for (final key in expectedDetailed.separationMinus.keys) {
        expect(detailedResult.separationMinus[key],
            closeTo(expectedDetailed.separationMinus[key]!, 1e-4));
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

    test(
        'Case 1: Halved criteria weights (15/10/12.5/12.5) produce normalizedWeights [0.3, 0.2, 0.25, 0.25] and identical intermediate values and calculate() scores',
        () async {
      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'Alternative 1'),
        WeightedDecisionAlternative(id: 'a2', name: 'Alternative 2'),
        WeightedDecisionAlternative(id: 'a3', name: 'Alternative 3'),
        WeightedDecisionAlternative(id: 'a4', name: 'Alternative 4'),
      ];

      final standardCriteria = [
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

      final halvedCriteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Criteria 1',
          weightPercent: 15,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'Criteria 2',
          weightPercent: 10,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c3',
          name: 'Criteria 3',
          weightPercent: 12.5,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c4',
          name: 'Criteria 4',
          weightPercent: 12.5,
          isBenefit: false,
          maxValue: 10,
        ),
      ];

      final rawMatrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(
                id: 'r1_1', criteria: standardCriteria[0], value: 5),
            WeightedDecisionRating(
                id: 'r1_2', criteria: standardCriteria[1], value: 8),
            WeightedDecisionRating(
                id: 'r1_3', criteria: standardCriteria[2], value: 4),
            WeightedDecisionRating(
                id: 'r1_4', criteria: standardCriteria[3], value: 7),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(
                id: 'r2_1', criteria: standardCriteria[0], value: 7),
            WeightedDecisionRating(
                id: 'r2_2', criteria: standardCriteria[1], value: 6),
            WeightedDecisionRating(
                id: 'r2_3', criteria: standardCriteria[2], value: 8),
            WeightedDecisionRating(
                id: 'r2_4', criteria: standardCriteria[3], value: 9),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(
                id: 'r3_1', criteria: standardCriteria[0], value: 8),
            WeightedDecisionRating(
                id: 'r3_2', criteria: standardCriteria[1], value: 9),
            WeightedDecisionRating(
                id: 'r3_3', criteria: standardCriteria[2], value: 6),
            WeightedDecisionRating(
                id: 'r3_4', criteria: standardCriteria[3], value: 6),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm4',
          alternative: alternatives[3],
          ratings: [
            WeightedDecisionRating(
                id: 'r4_1', criteria: standardCriteria[0], value: 7),
            WeightedDecisionRating(
                id: 'r4_2', criteria: standardCriteria[1], value: 7),
            WeightedDecisionRating(
                id: 'r4_3', criteria: standardCriteria[2], value: 7),
            WeightedDecisionRating(
                id: 'r4_4', criteria: standardCriteria[3], value: 7),
          ],
        ),
      ];

      final halvedRawMatrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(
                id: 'r1_1', criteria: halvedCriteria[0], value: 5),
            WeightedDecisionRating(
                id: 'r1_2', criteria: halvedCriteria[1], value: 8),
            WeightedDecisionRating(
                id: 'r1_3', criteria: halvedCriteria[2], value: 4),
            WeightedDecisionRating(
                id: 'r1_4', criteria: halvedCriteria[3], value: 7),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(
                id: 'r2_1', criteria: halvedCriteria[0], value: 7),
            WeightedDecisionRating(
                id: 'r2_2', criteria: halvedCriteria[1], value: 6),
            WeightedDecisionRating(
                id: 'r2_3', criteria: halvedCriteria[2], value: 8),
            WeightedDecisionRating(
                id: 'r2_4', criteria: halvedCriteria[3], value: 9),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(
                id: 'r3_1', criteria: halvedCriteria[0], value: 8),
            WeightedDecisionRating(
                id: 'r3_2', criteria: halvedCriteria[1], value: 9),
            WeightedDecisionRating(
                id: 'r3_3', criteria: halvedCriteria[2], value: 6),
            WeightedDecisionRating(
                id: 'r3_4', criteria: halvedCriteria[3], value: 6),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm4',
          alternative: alternatives[3],
          ratings: [
            WeightedDecisionRating(
                id: 'r4_1', criteria: halvedCriteria[0], value: 7),
            WeightedDecisionRating(
                id: 'r4_2', criteria: halvedCriteria[1], value: 7),
            WeightedDecisionRating(
                id: 'r4_3', criteria: halvedCriteria[2], value: 7),
            WeightedDecisionRating(
                id: 'r4_4', criteria: halvedCriteria[3], value: 7),
          ],
        ),
      ];

      final standardDetailed = await topsis.getTopsisDetailedResult(
        matrix:
            TopsisRawMatrix(criterias: standardCriteria, matrixs: rawMatrix),
      );
      final halvedDetailed = await topsis.getTopsisDetailedResult(
        matrix: TopsisRawMatrix(
            criterias: halvedCriteria, matrixs: halvedRawMatrix),
      );
      final calculatedScores = await topsis.getTopsisResult(
        matrix: TopsisRawMatrix(
            criterias: halvedCriteria, matrixs: halvedRawMatrix),
      );

      // Verify normalizedWeights are [0.3, 0.2, 0.25, 0.25]
      expect(halvedDetailed.normalizedWeights['c1'], closeTo(0.3, 1e-4));
      expect(halvedDetailed.normalizedWeights['c2'], closeTo(0.2, 1e-4));
      expect(halvedDetailed.normalizedWeights['c3'], closeTo(0.25, 1e-4));
      expect(halvedDetailed.normalizedWeights['c4'], closeTo(0.25, 1e-4));

      // Verify intermediate values match standard 30/20/25/25
      // 1. weightedMatrix
      for (int i = 0; i < standardDetailed.weightedMatrix.length; i++) {
        for (int j = 0;
            j < standardDetailed.weightedMatrix[i].ratings.length;
            j++) {
          expect(
            halvedDetailed.weightedMatrix[i].ratings[j].value,
            closeTo(standardDetailed.weightedMatrix[i].ratings[j].value!, 1e-4),
          );
        }
      }

      // 2. ideal values
      for (final key in standardDetailed.positiveIdeal.keys) {
        expect(halvedDetailed.positiveIdeal[key],
            closeTo(standardDetailed.positiveIdeal[key]!, 1e-4));
        expect(halvedDetailed.negativeIdeal[key],
            closeTo(standardDetailed.negativeIdeal[key]!, 1e-4));
      }

      // 3. separationPlus and separationMinus
      for (final key in standardDetailed.separationPlus.keys) {
        expect(halvedDetailed.separationPlus[key],
            closeTo(standardDetailed.separationPlus[key]!, 1e-4));
        expect(halvedDetailed.separationMinus[key],
            closeTo(standardDetailed.separationMinus[key]!, 1e-4));
      }

      // 4. scores identical to calculate()
      expect(halvedDetailed.scores.length, calculatedScores.length);
      for (int i = 0; i < calculatedScores.length; i++) {
        expect(halvedDetailed.scores[i].alternative.id,
            calculatedScores[i].alternative.id);
        expect(halvedDetailed.scores[i].rank, calculatedScores[i].rank);
        expect(halvedDetailed.scores[i].score,
            closeTo(calculatedScores[i].score, 1e-4));
      }
    });

    test('Case 2: Vendor / Supplier Selection - Multiple Cost Criteria',
        () async {
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
            WeightedDecisionRating(
                id: 'r1_1', criteria: criteria[0], value: 80),
            WeightedDecisionRating(
                id: 'r1_2', criteria: criteria[1], value: 20),
            WeightedDecisionRating(
                id: 'r1_3', criteria: criteria[2], value: 10),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(
                id: 'r2_1', criteria: criteria[0], value: 90),
            WeightedDecisionRating(
                id: 'r2_2', criteria: criteria[1], value: 30),
            WeightedDecisionRating(
                id: 'r2_3', criteria: criteria[2], value: 15),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(
                id: 'r3_1', criteria: criteria[0], value: 70),
            WeightedDecisionRating(
                id: 'r3_2', criteria: criteria[1], value: 15),
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

      // Verify wrapper detailed result matches core calculateDetailed
      final expectedDetailed = TopsisCalculator.calculateDetailed(topsisMatrix);
      final detailedResult =
          await topsis.getTopsisDetailedResult(matrix: topsisMatrix);

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

      // Verify ideal solutions
      for (final key in expectedDetailed.positiveIdeal.keys) {
        expect(detailedResult.positiveIdeal[key],
            closeTo(expectedDetailed.positiveIdeal[key]!, 1e-4));
      }
      for (final key in expectedDetailed.negativeIdeal.keys) {
        expect(detailedResult.negativeIdeal[key],
            closeTo(expectedDetailed.negativeIdeal[key]!, 1e-4));
      }

      // Verify separation distances
      for (final key in expectedDetailed.separationPlus.keys) {
        expect(detailedResult.separationPlus[key],
            closeTo(expectedDetailed.separationPlus[key]!, 1e-4));
      }
      for (final key in expectedDetailed.separationMinus.keys) {
        expect(detailedResult.separationMinus[key],
            closeTo(expectedDetailed.separationMinus[key]!, 1e-4));
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
            WeightedDecisionRating(
                id: 'r1_1', criteria: criteria[0], value: 30),
            WeightedDecisionRating(
                id: 'r1_2', criteria: criteria[1], value: 80),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(
                id: 'r2_1', criteria: criteria[0], value: 30),
            WeightedDecisionRating(
                id: 'r2_2', criteria: criteria[1], value: 80),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(
                id: 'r3_1', criteria: criteria[0], value: 50),
            WeightedDecisionRating(
                id: 'r3_2', criteria: criteria[1], value: 60),
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

      // Verify wrapper detailed result matches core calculateDetailed
      final expectedDetailed = TopsisCalculator.calculateDetailed(topsisMatrix);
      final detailedResult =
          await topsis.getTopsisDetailedResult(matrix: topsisMatrix);

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

      // Verify ideal solutions
      for (final key in expectedDetailed.positiveIdeal.keys) {
        expect(detailedResult.positiveIdeal[key],
            closeTo(expectedDetailed.positiveIdeal[key]!, 1e-4));
      }
      for (final key in expectedDetailed.negativeIdeal.keys) {
        expect(detailedResult.negativeIdeal[key],
            closeTo(expectedDetailed.negativeIdeal[key]!, 1e-4));
      }

      // Verify separation distances
      for (final key in expectedDetailed.separationPlus.keys) {
        expect(detailedResult.separationPlus[key],
            closeTo(expectedDetailed.separationPlus[key]!, 1e-4));
      }
      for (final key in expectedDetailed.separationMinus.keys) {
        expect(detailedResult.separationMinus[key],
            closeTo(expectedDetailed.separationMinus[key]!, 1e-4));
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
