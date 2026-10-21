import 'package:flutter_decision_making/core/isolate/decision_isolate_main.dart';
import 'package:flutter_decision_making/feature/topsis/presentation/topsis.dart';
import 'package:flutter_decision_making/flutter_decision_making.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    DecisionIsolateMain.resetInstance();
  });

  tearDown(() {
    DecisionIsolateMain.resetInstance();
  });

  group('Isolate Opt-In & Lazy Lifecycle Tests', () {
    test('Instantiating SAW, TOPSIS, and AHP does not initialize DecisionIsolateMain', () {
      expect(DecisionIsolateMain.hasInstance, isFalse);
      expect(DecisionIsolateMain.isWorkerRunning, isFalse);

      final saw = SAW();
      final topsis = TOPSIS();
      final ahp = AHP();

      expect(saw, isNotNull);
      expect(topsis, isNotNull);
      expect(ahp, isNotNull);

      expect(DecisionIsolateMain.hasInstance, isFalse);
      expect(DecisionIsolateMain.isWorkerRunning, isFalse);
    });

    test('getSawResult with useIsolate: false does not initialize DecisionIsolateMain even for >80 alternatives', () async {
      final saw = SAW();

      // Create 85 alternatives and 2 criteria (exceeding old threshold of 80)
      final alts = List.generate(
        85,
        (i) => WeightedDecisionAlternative(id: 'a$i', name: 'Alt $i'),
      );
      final crts = [
        WeightedDecisionCriteria(id: 'c1', name: 'C1', weightPercent: 50, isBenefit: true, maxValue: 100),
        WeightedDecisionCriteria(id: 'c2', name: 'C2', weightPercent: 50, isBenefit: true, maxValue: 100),
      ];

      final matrix = alts.map((a) {
        return WeightedDecisionMatrix(
          id: 'm_${a.id}',
          alternative: a,
          ratings: [
            WeightedDecisionRating(id: 'r_${a.id}_1', criteria: crts[0], value: 50),
            WeightedDecisionRating(id: 'r_${a.id}_2', criteria: crts[1], value: 60),
          ],
        );
      }).toList();

      expect(DecisionIsolateMain.hasInstance, isFalse);

      final result = await saw.getSawResult(matrix: matrix, useIsolate: false);

      expect(result.length, 85);
      expect(DecisionIsolateMain.hasInstance, isFalse,
          reason: 'DecisionIsolateMain should not be initialized when useIsolate: false');
      expect(DecisionIsolateMain.isWorkerRunning, isFalse);
    });

    test('getTopsisResult with useIsolate: false does not initialize DecisionIsolateMain even for >80 alternatives', () async {
      final topsis = TOPSIS();

      final alts = List.generate(
        85,
        (i) => WeightedDecisionAlternative(id: 'a$i', name: 'Alt $i'),
      );
      final crts = [
        WeightedDecisionCriteria(id: 'c1', name: 'C1', weightPercent: 50, isBenefit: true, maxValue: 100),
        WeightedDecisionCriteria(id: 'c2', name: 'C2', weightPercent: 50, isBenefit: true, maxValue: 100),
      ];

      final matrix = alts.map((a) {
        return WeightedDecisionMatrix(
          id: 'm_${a.id}',
          alternative: a,
          ratings: [
            WeightedDecisionRating(id: 'r_${a.id}_1', criteria: crts[0], value: 50),
            WeightedDecisionRating(id: 'r_${a.id}_2', criteria: crts[1], value: 60),
          ],
        );
      }).toList();

      final rawMatrix = TopsisRawMatrix(criterias: crts, matrixs: matrix);

      expect(DecisionIsolateMain.hasInstance, isFalse);

      final result = await topsis.getTopsisResult(matrix: rawMatrix, useIsolate: false);

      expect(result.length, 85);
      expect(DecisionIsolateMain.hasInstance, isFalse,
          reason: 'DecisionIsolateMain should not be initialized when useIsolate: false');
      expect(DecisionIsolateMain.isWorkerRunning, isFalse);
    });

    test('getAhpResult with useIsolate: false does not initialize DecisionIsolateMain', () async {
      final ahp = AHP();

      final c1 = AhpItem(id: 'c1', name: 'Criteria 1');
      final c2 = AhpItem(id: 'c2', name: 'Criteria 2');
      final a1 = AhpItem(id: 'a1', name: 'Alt 1');
      final a2 = AhpItem(id: 'a2', name: 'Alt 2');

      final hierarchy = [
        AhpHierarchy(criteria: c1, alternative: [a1, a2]),
        AhpHierarchy(criteria: c2, alternative: [a1, a2]),
      ];

      final inputsCriteria = [
        PairwiseComparisonInput(id: 'p_c', left: c1, right: c2, preferenceValue: 1, isLeftMoreImportant: true),
      ];

      final inputsAlternative = [
        PairwiseAlternativeInput(criteria: c1, alternative: [
          PairwiseComparisonInput(id: 'p_a_1', left: a1, right: a2, preferenceValue: 1, isLeftMoreImportant: true),
        ]),
        PairwiseAlternativeInput(criteria: c2, alternative: [
          PairwiseComparisonInput(id: 'p_a_2', left: a1, right: a2, preferenceValue: 1, isLeftMoreImportant: true),
        ]),
      ];

      expect(DecisionIsolateMain.hasInstance, isFalse);

      final result = await ahp.getAhpResult(
        hierarchy: hierarchy,
        inputsCriteria: inputsCriteria,
        inputsAlternative: inputsAlternative,
        useIsolate: false,
      );

      expect(result.results?.length, 2);
      expect(DecisionIsolateMain.hasInstance, isFalse,
          reason: 'DecisionIsolateMain should not be initialized when useIsolate: false');
      expect(DecisionIsolateMain.isWorkerRunning, isFalse);
    });

    test('useIsolate: true initializes DecisionIsolateMain and produces identical result to useIsolate: false', () async {
      final saw = SAW();

      final alts = [
        WeightedDecisionAlternative(id: 'a1', name: 'Alt 1'),
        WeightedDecisionAlternative(id: 'a2', name: 'Alt 2'),
      ];
      final crts = [
        WeightedDecisionCriteria(id: 'c1', name: 'C1', weightPercent: 60, isBenefit: true, maxValue: 100),
        WeightedDecisionCriteria(id: 'c2', name: 'C2', weightPercent: 40, isBenefit: false, maxValue: 100),
      ];
      final matrix = [
        WeightedDecisionMatrix(id: 'm1', alternative: alts[0], ratings: [
          WeightedDecisionRating(id: 'r1_1', criteria: crts[0], value: 80),
          WeightedDecisionRating(id: 'r1_2', criteria: crts[1], value: 40),
        ]),
        WeightedDecisionMatrix(id: 'm2', alternative: alts[1], ratings: [
          WeightedDecisionRating(id: 'r2_1', criteria: crts[0], value: 60),
          WeightedDecisionRating(id: 'r2_2', criteria: crts[1], value: 20),
        ]),
      ];

      final resDirect = await saw.getSawResult(matrix: matrix, useIsolate: false);
      expect(DecisionIsolateMain.hasInstance, isFalse);

      final resIsolate = await saw.getSawResult(matrix: matrix, useIsolate: true);
      expect(DecisionIsolateMain.hasInstance, isTrue);

      expect(resIsolate.length, resDirect.length);
      for (int i = 0; i < resDirect.length; i++) {
        expect(resIsolate[i].alternative.id, resDirect[i].alternative.id);
        expect(resIsolate[i].rank, resDirect[i].rank);
        expect(resIsolate[i].score, closeTo(resDirect[i].score, 1e-6));
      }
    });
  });
}
