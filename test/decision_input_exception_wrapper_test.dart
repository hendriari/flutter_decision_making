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
  });
}
