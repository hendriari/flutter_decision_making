import 'package:decision_making_core/decision_making_core.dart';
import 'package:test/test.dart';

void main() {
  group('MatrixValidator Tests', () {
    test('Empty alternatives or criteria throws exception', () {
      expect(
        () => MatrixValidator.validateInputs(
          alternatives: [],
          criteria: [
            WeightedDecisionCriteria(
              id: 'c1',
              name: 'C1',
              weightPercent: 50,
              isBenefit: true,
              maxValue: 100,
            ),
          ],
        ),
        throwsA(isA<Exception>()),
      );

      expect(
        () => MatrixValidator.validateInputs(
          alternatives: [
            WeightedDecisionAlternative(id: 'a1', name: 'A1'),
          ],
          criteria: [],
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Total weight <= 0 throws exception', () {
      expect(
        () => MatrixValidator.validateInputs(
          alternatives: [
            WeightedDecisionAlternative(id: 'a1', name: 'A1'),
          ],
          criteria: [
            WeightedDecisionCriteria(
              id: 'c1',
              name: 'C1',
              weightPercent: 0,
              isBenefit: true,
              maxValue: 100,
            ),
          ],
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Empty matrix values throws exception', () {
      expect(
        () => MatrixValidator.validateMatrixValues([]),
        throwsA(isA<Exception>()),
      );
    });

    test('Valid matrix values pass validation', () {
      final c1 = WeightedDecisionCriteria(
        id: 'c1',
        name: 'C1',
        weightPercent: 50,
        isBenefit: true,
        maxValue: 100,
      );
      final c2 = WeightedDecisionCriteria(
        id: 'c2',
        name: 'C2',
        weightPercent: 50,
        isBenefit: false,
        maxValue: 100,
      );

      final matrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: WeightedDecisionAlternative(id: 'a1', name: 'A1'),
          ratings: [
            WeightedDecisionRating(id: 'r1', criteria: c1, value: 10),
            WeightedDecisionRating(id: 'r2', criteria: c2, value: 20),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: WeightedDecisionAlternative(id: 'a2', name: 'A2'),
          ratings: [
            WeightedDecisionRating(id: 'r3', criteria: c1, value: 15),
            WeightedDecisionRating(id: 'r4', criteria: c2, value: 25),
          ],
        ),
      ];

      expect(() => MatrixValidator.validateMatrixValues(matrix), returnsNormally);
    });
  });
}
