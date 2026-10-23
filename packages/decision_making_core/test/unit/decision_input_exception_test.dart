import 'package:decision_making_core/decision_making_core.dart';
import 'package:decision_making_core/src/sensitivity/sensitivity_calculator.dart';
import 'package:test/test.dart';

void main() {
  group('DecisionInputException - Class Contract', () {
    test('implements Exception and isA<Exception>()', () {
      const exception = DecisionInputException('Test message');
      expect(exception, isA<Exception>());
      expect(exception.message, equals('Test message'));
    });

    test('toString() produces "Exception: <message>" for compatibility', () {
      const exception = DecisionInputException('Invalid input parameter');
      expect(
          exception.toString(), equals('Exception: Invalid input parameter'));
    });
  });

  group('DecisionInputException - SAW Category', () {
    test(
        'Zero value on cost criteria throws DecisionInputException with preserved message',
        () {
      final criteriaCost = WeightedDecisionCriteria(
        id: 'c1',
        name: 'Price',
        weightPercent: 100.0,
        isBenefit: false,
        maxValue: 1000.0,
      );

      final matrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: WeightedDecisionAlternative(id: 'a1', name: 'Vendor A'),
          ratings: [
            WeightedDecisionRating(
              id: 'r1',
              criteria: criteriaCost,
              value: 0.0,
            ),
          ],
        ),
      ];

      expect(
        () => SawCalculator.normalize(matrix),
        throwsA(
          allOf(
            isA<DecisionInputException>(),
            isA<Exception>(),
            predicate<DecisionInputException>((e) =>
                e.message.contains('Zero value found in cost criteria') &&
                e.message.contains('Cost criteria must have positive values.')),
          ),
        ),
      );
    });

    test('Empty matrix in SAW normalize throws DecisionInputException', () {
      expect(
        () => SawCalculator.normalize([]),
        throwsA(
          allOf(
            isA<DecisionInputException>(),
            predicate<DecisionInputException>(
                (e) => e.message.contains('Matrix cannot be empty!')),
          ),
        ),
      );
    });
  });

  group('DecisionInputException - TOPSIS Category', () {
    test(
        'Empty matrix in TOPSIS normalizeEuclidean throws DecisionInputException',
        () {
      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Speed',
          weightPercent: 100.0,
          isBenefit: true,
          maxValue: 10,
        ),
      ];

      expect(
        () =>
            TopsisCalculator.normalizeEuclidean(matrix: [], criteria: criteria),
        throwsA(
          allOf(
            isA<DecisionInputException>(),
            predicate<DecisionInputException>(
                (e) => e.message.contains('Matrix cannot be empty!')),
          ),
        ),
      );
    });

    test(
        'Empty criteria in TOPSIS normalizeEuclidean throws DecisionInputException',
        () {
      final matrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: WeightedDecisionAlternative(id: 'a1', name: 'Alt 1'),
          ratings: [],
        ),
      ];

      expect(
        () => TopsisCalculator.normalizeEuclidean(
          matrix: matrix,
          criteria: <WeightedDecisionCriteria>[],
        ),
        throwsA(
          allOf(
            isA<DecisionInputException>(),
            predicate<DecisionInputException>(
                (e) => e.message.contains('Criteria list cannot be empty!')),
          ),
        ),
      );
    });
  });

  group('DecisionInputException - AHP Category', () {
    test('Empty criteria in AHP identification throws DecisionInputException',
        () {
      expect(
        () => AhpCalculator.identification(
          [],
          [AhpItem(id: 'a1', name: 'Alt 1')],
        ),
        throwsA(
          allOf(
            isA<DecisionInputException>(),
            predicate<DecisionInputException>(
                (e) => e.message.contains("Criteria can't be empty!")),
          ),
        ),
      );
    });

    test(
        'Empty alternative in AHP identification throws DecisionInputException',
        () {
      expect(
        () => AhpCalculator.identification(
          [AhpItem(id: 'c1', name: 'Crit 1')],
          [],
        ),
        throwsA(
          allOf(
            isA<DecisionInputException>(),
            predicate<DecisionInputException>(
                (e) => e.message.contains("Alternative can't be empty!")),
          ),
        ),
      );
    });

    test(
        'AHP calculate() throws DecisionInputException when criteria ID is empty',
        () {
      final hierarchy = [
        AhpHierarchy(
          criteria: AhpItem(id: '', name: 'Empty Crit ID'),
          alternative: [AhpItem(id: 'a1', name: 'Alt 1')],
        ),
      ];
      final inputsCriteria = [
        PairwiseComparisonInput(
          id: 'p1',
          left: AhpItem(id: 'c1', name: 'Crit 1'),
          right: AhpItem(id: 'c2', name: 'Crit 2'),
          preferenceValue: 1,
          isLeftMoreImportant: true,
        ),
      ];
      final inputsAlternative = [
        PairwiseAlternativeInput(
          criteria: AhpItem(id: 'c1', name: 'Crit 1'),
          alternative: [
            PairwiseComparisonInput(
              id: 'pa1',
              left: AhpItem(id: 'a1', name: 'Alt 1'),
              right: AhpItem(id: 'a2', name: 'Alt 2'),
              preferenceValue: 1,
              isLeftMoreImportant: true,
            ),
          ],
        ),
      ];

      expect(
        () => AhpCalculator.calculate(
          hierarchy: hierarchy,
          inputsCriteria: inputsCriteria,
          inputsAlternative: inputsAlternative,
        ),
        throwsA(
          allOf(
            isA<DecisionInputException>(),
            predicate<DecisionInputException>((e) =>
                e.message.contains('Found criteria without ID! Data invalid.')),
          ),
        ),
      );
    });
  });

  group('DecisionInputException - Objective Weighting Category', () {
    test('Entropy negative value throws DecisionInputException', () {
      final c1 = WeightedDecisionCriteria(
        id: 'c1',
        name: 'Crit 1',
        weightPercent: 50,
        isBenefit: true,
        maxValue: 10,
      );
      final c2 = WeightedDecisionCriteria(
        id: 'c2',
        name: 'Crit 2',
        weightPercent: 50,
        isBenefit: true,
        maxValue: 10,
      );

      final matrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: WeightedDecisionAlternative(id: 'a1', name: 'Alt 1'),
          ratings: [
            WeightedDecisionRating(id: 'r1', criteria: c1, value: -1.0),
            WeightedDecisionRating(id: 'r2', criteria: c2, value: 5.0),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: WeightedDecisionAlternative(id: 'a2', name: 'Alt 2'),
          ratings: [
            WeightedDecisionRating(id: 'r3', criteria: c1, value: 2.0),
            WeightedDecisionRating(id: 'r4', criteria: c2, value: 5.0),
          ],
        ),
      ];

      expect(
        () => ObjectiveWeightCalculator.calculateEntropy(matrix),
        throwsA(
          allOf(
            isA<DecisionInputException>(),
            predicate<DecisionInputException>((e) => e.message
                .contains('Entropy weighting does not allow negative values')),
          ),
        ),
      );
    });

    test(
        'Duplicate alternative ID throws DecisionInputException (Entropy and CRITIC)',
        () {
      final c1 = WeightedDecisionCriteria(
        id: 'c1',
        name: 'Crit 1',
        weightPercent: 100,
        isBenefit: true,
        maxValue: 10,
      );

      final matrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative:
              WeightedDecisionAlternative(id: 'dup_alt', name: 'Alt A'),
          ratings: [WeightedDecisionRating(id: 'r1', criteria: c1, value: 3.0)],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative:
              WeightedDecisionAlternative(id: 'dup_alt', name: 'Alt B'),
          ratings: [WeightedDecisionRating(id: 'r2', criteria: c1, value: 4.0)],
        ),
      ];

      expect(
        () => ObjectiveWeightCalculator.calculateEntropy(matrix),
        throwsA(
          allOf(
            isA<DecisionInputException>(),
            predicate<DecisionInputException>((e) => e.message.contains(
                'Duplicate alternative ID "dup_alt" found in matrix.')),
          ),
        ),
      );

      expect(
        () => ObjectiveWeightCalculator.calculateCritic(matrix),
        throwsA(
          allOf(
            isA<DecisionInputException>(),
            predicate<DecisionInputException>((e) => e.message.contains(
                'Duplicate alternative ID "dup_alt" found in matrix.')),
          ),
        ),
      );
    });

    test('Duplicate criterion ID throws DecisionInputException', () {
      final c1 = WeightedDecisionCriteria(
        id: 'c_dup',
        name: 'Crit 1',
        weightPercent: 50,
        isBenefit: true,
        maxValue: 10,
      );
      final c2 = WeightedDecisionCriteria(
        id: 'c_dup',
        name: 'Crit 1 Duplicate',
        weightPercent: 50,
        isBenefit: true,
        maxValue: 10,
      );

      final matrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: WeightedDecisionAlternative(id: 'a1', name: 'Alt 1'),
          ratings: [
            WeightedDecisionRating(id: 'r1', criteria: c1, value: 1.0),
            WeightedDecisionRating(id: 'r2', criteria: c2, value: 2.0),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: WeightedDecisionAlternative(id: 'a2', name: 'Alt 2'),
          ratings: [
            WeightedDecisionRating(id: 'r3', criteria: c1, value: 3.0),
            WeightedDecisionRating(id: 'r4', criteria: c2, value: 4.0),
          ],
        ),
      ];

      expect(
        () => ObjectiveWeightCalculator.calculateEntropy(matrix),
        throwsA(
          allOf(
            isA<DecisionInputException>(),
            predicate<DecisionInputException>((e) => e.message
                .contains('Duplicate criterion ID "c_dup" found in row')),
          ),
        ),
      );
    });

    test('NaN rating value throws DecisionInputException', () {
      final c1 = WeightedDecisionCriteria(
        id: 'c1',
        name: 'Crit 1',
        weightPercent: 100,
        isBenefit: true,
        maxValue: 10,
      );

      final matrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: WeightedDecisionAlternative(id: 'a1', name: 'Alt 1'),
          ratings: [
            WeightedDecisionRating(id: 'r1', criteria: c1, value: double.nan)
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: WeightedDecisionAlternative(id: 'a2', name: 'Alt 2'),
          ratings: [WeightedDecisionRating(id: 'r2', criteria: c1, value: 4.0)],
        ),
      ];

      expect(
        () => ObjectiveWeightCalculator.calculateEntropy(matrix),
        throwsA(
          allOf(
            isA<DecisionInputException>(),
            predicate<DecisionInputException>((e) => e.message.contains(
                'Invalid value for alternative "a1", criterion "c1".')),
          ),
        ),
      );
    });
  });

  group('DecisionInputException - Sensitivity Category', () {
    test('Non-positive delta throws DecisionInputException', () {
      expect(
        () => SensitivityCalculator.run(
          alternativeIds: ['a1', 'a2'],
          criteriaIds: ['c1'],
          normalizedWeights: {'c1': 1.0},
          calculateWithWeights: (w) => {'a1': 1.0, 'a2': 0.5},
          calculateWithoutAlternative: (id) => {'a1': 1.0},
          delta: 0.0,
        ),
        throwsA(
          allOf(
            isA<DecisionInputException>(),
            predicate<DecisionInputException>((e) => e.message
                .contains('Sensitivity delta must be greater than zero.')),
          ),
        ),
      );
    });

    test(
        'SawCalculator.analyzeSensitivity throws DecisionInputException for delta <= 0',
        () {
      final criteria = WeightedDecisionCriteria(
        id: 'c1',
        name: 'Speed',
        weightPercent: 100.0,
        isBenefit: true,
        maxValue: 10,
      );
      final matrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: WeightedDecisionAlternative(id: 'a1', name: 'Alt 1'),
          ratings: [
            WeightedDecisionRating(id: 'r1', criteria: criteria, value: 5.0)
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: WeightedDecisionAlternative(id: 'a2', name: 'Alt 2'),
          ratings: [
            WeightedDecisionRating(id: 'r2', criteria: criteria, value: 8.0)
          ],
        ),
      ];

      expect(
        () => SawCalculator.analyzeSensitivity(matrix, delta: 0.0),
        throwsA(
          allOf(
            isA<DecisionInputException>(),
            predicate<DecisionInputException>((e) => e.message
                .contains('Sensitivity delta must be greater than zero.')),
          ),
        ),
      );
    });
  });

  group('DecisionInputException - MatrixValidator Category', () {
    test('Empty alternatives throws DecisionInputException', () {
      expect(
        () => MatrixValidator.validateInputs(
          alternatives: [],
          criteria: [
            WeightedDecisionCriteria(
              id: 'c1',
              name: 'C1',
              weightPercent: 100,
              isBenefit: true,
              maxValue: 10,
            ),
          ],
        ),
        throwsA(
          allOf(
            isA<DecisionInputException>(),
            predicate<DecisionInputException>((e) =>
                e.message.contains('Alternatives list cannot be empty!')),
          ),
        ),
      );
    });

    test('Negative criterion weight throws DecisionInputException', () {
      expect(
        () => MatrixValidator.validateInputs(
          alternatives: [
            WeightedDecisionAlternative(id: 'a1', name: 'A1'),
          ],
          criteria: [
            WeightedDecisionCriteria(
              id: 'c1',
              name: 'Quality',
              weightPercent: -10,
              isBenefit: true,
              maxValue: 10,
            ),
          ],
        ),
        throwsA(
          allOf(
            isA<DecisionInputException>(),
            predicate<DecisionInputException>((e) => e.message
                .contains('Criteria weight cannot be negative: Quality')),
          ),
        ),
      );
    });

    test('Total criteria weight <= 0 throws DecisionInputException', () {
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
              maxValue: 10,
            ),
          ],
        ),
        throwsA(
          allOf(
            isA<DecisionInputException>(),
            predicate<DecisionInputException>((e) => e.message
                .contains('Total criteria weight must be greater than zero!')),
          ),
        ),
      );
    });
  });
}
