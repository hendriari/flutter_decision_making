import 'package:flutter_decision_making/core/decision_making_enums.dart';
import 'package:flutter_decision_making/core/isolate/decision_isolate_main.dart';
import 'package:flutter_decision_making/flutter_decision_making.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FlutterDecisionMaking fdm;

  setUp(() {
    fdm = FlutterDecisionMaking();
  });

  group('DecisionInputException - Root Barrel Export', () {
    test(
        'DecisionInputException is directly accessible from flutter_decision_making barrel',
        () {
      const e = DecisionInputException('test');
      expect(e, isA<Exception>());
      expect(e.toString(), equals('Exception: test'));
    });
  });

  group('DecisionInputException - Presentation Layer Direct', () {
    test(
        'SAW updateSawMatrix throws DecisionInputException when matrixId not found',
        () async {
      expect(
        () => fdm.saw.updateSawMatrix(
          currentMatrix: [],
          matrixId: 'non_existent',
          ratingsId: 'r1',
          value: 1.0,
        ),
        throwsA(
          allOf(
            isA<DecisionInputException>(),
            predicate<DecisionInputException>(
                (e) => e.message.contains('Matrix not found!')),
          ),
        ),
      );
    });

    test(
        'TOPSIS updateTopsisMatrix throws DecisionInputException when matrixId not found',
        () async {
      expect(
        () => fdm.topsis.updateTopsisMatrix(
          currentRawMatrix: TopsisRawMatrix(criterias: [], matrixs: []),
          matrixId: 'non_existent',
          ratingsId: 'r1',
          value: 1.0,
        ),
        throwsA(
          allOf(
            isA<DecisionInputException>(),
            predicate<DecisionInputException>(
                (e) => e.message.contains('Matrix not found!')),
          ),
        ),
      );
    });

    test(
        'AHP generateHierarchy throws DecisionInputException when criteria is empty',
        () async {
      expect(
        () => fdm.ahp.generateHierarchy(
          listCriteria: [],
          listAlternative: [AhpItem(id: 'a1', name: 'Alt 1')],
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
  });

  group('DecisionInputException - Wrapper & Isolate Propagation', () {
    final criteriaCost = WeightedDecisionCriteria(
      id: 'c1',
      name: 'Cost',
      weightPercent: 100.0,
      isBenefit: false,
      maxValue: 1000.0,
    );

    final invalidCostZeroMatrix = [
      WeightedDecisionMatrix(
        id: 'm1',
        alternative: WeightedDecisionAlternative(id: 'a1', name: 'A1'),
        ratings: [
          WeightedDecisionRating(
            id: 'r1',
            criteria: criteriaCost,
            value: 0.0,
          ),
        ],
      ),
    ];

    test(
        'SAW getSawResult with useIsolate: false throws DecisionInputException',
        () async {
      expect(
        () => fdm.saw.getSawResult(
          matrix: invalidCostZeroMatrix,
          useIsolate: false,
        ),
        throwsA(
          allOf(
            isA<DecisionInputException>(),
            predicate<DecisionInputException>((e) =>
                e.message.contains('Zero value found in cost criteria') &&
                e.message.contains('Cost criteria must have positive values.')),
          ),
        ),
      );
    });

    test(
        'SAW getSawResult with useIsolate: true throws reconstructed DecisionInputException',
        () async {
      expect(
        () => fdm.saw.getSawResult(
          matrix: invalidCostZeroMatrix,
          useIsolate: true,
        ),
        throwsA(
          allOf(
            isA<DecisionInputException>(),
            predicate<DecisionInputException>((e) =>
                e.message.contains('Zero value found in cost criteria') &&
                e.message.contains('Cost criteria must have positive values.')),
          ),
        ),
      );
    });

    test(
        'TOPSIS getTopsisResult with useIsolate: false throws DecisionInputException on empty matrix',
        () async {
      expect(
        () => fdm.topsis.getTopsisResult(
          matrix: TopsisRawMatrix(
            criterias: [criteriaCost],
            matrixs: [],
          ),
          useIsolate: false,
        ),
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
        'TOPSIS getTopsisResult with useIsolate: true throws DecisionInputException on empty matrix',
        () async {
      expect(
        () => fdm.topsis.getTopsisResult(
          matrix: TopsisRawMatrix(
            criterias: [criteriaCost],
            matrixs: [],
          ),
          useIsolate: true,
        ),
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
        'AHP getAhpResult with useIsolate: true throws DecisionInputException on uncompleted criteria inputs',
        () async {
      final hierarchy = await fdm.ahp.generateHierarchy(
        listCriteria: [
          AhpItem(id: 'c1', name: 'Crit 1'),
          AhpItem(id: 'c2', name: 'Crit 2'),
        ],
        listAlternative: [
          AhpItem(id: 'a1', name: 'Alt 1'),
          AhpItem(id: 'a2', name: 'Alt 2'),
        ],
      );
      final criteriaInputs = await fdm.ahp.generateCriteriaInputs();

      expect(
        () => fdm.ahp.getAhpResult(
          hierarchy: hierarchy,
          inputsCriteria: criteriaInputs,
          inputsAlternative: [],
          useIsolate: true,
        ),
        throwsA(
          allOf(
            isA<DecisionInputException>(),
            predicate<DecisionInputException>((e) => e.message.contains(
                'Please complete all values from the criteria scale')),
          ),
        ),
      );
    });

    test(
        'AHP calculateFinalScore in isolate worker throws reconstructed DecisionInputException when alternative matrix is empty',
        () async {
      final isolateMain = DecisionIsolateMain();
      expect(
        () => isolateMain.runTask(
          DecisionAlgorithm.ahp,
          AhpProcessingIsolateCommand.calculateFinalScore,
          {
            'eigen_vector_criteria': [1.0],
            'eigen_vector_alternative': <dynamic>[],
            'alternative_raw': [
              {'id': 'a1', 'name': 'Alt 1'}
            ],
            'consistency_criteria_raw': {
              'source': 'criteria',
              'ratio': 0.0,
              'is_consistent': true,
            },
            'consistency_alternative_raw': <dynamic>[],
          },
        ),
        throwsA(
          allOf(
            isA<DecisionInputException>(),
            predicate<DecisionInputException>(
                (e) => e.message.contains('Alternative matrix is empty.')),
          ),
        ),
      );
    });

    test(
        'WeightedDecisionMatrixMixin validateMaxInputValue throws DecisionInputException when rating has no criteria',
        () async {
      final matrixWithNullCriteria = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: WeightedDecisionAlternative(id: 'a1', name: 'Product A'),
          ratings: [
            WeightedDecisionRating(
              id: 'r1',
              criteria: null,
              value: 10.0,
            ),
          ],
        ),
      ];

      expect(
        () => fdm.saw.getSawResult(
          matrix: matrixWithNullCriteria,
          useIsolate: false,
        ),
        throwsA(
          allOf(
            isA<DecisionInputException>(),
            predicate<DecisionInputException>((e) =>
                e.message.contains('Rating on Product A has no criteria.')),
          ),
        ),
      );
    });
  });
}
