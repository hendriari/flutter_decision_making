import 'package:decision_making_core/decision_making_core.dart';
import 'package:test/test.dart';

void main() {
  group('AHP Edge Cases & ID Validation', () {
    final validCriteria = [
      AhpItem(id: 'c1', name: 'Cost'),
      AhpItem(id: 'c2', name: 'Quality'),
    ];

    final validAlternatives = [
      AhpItem(id: 'a1', name: 'Alt 1'),
      AhpItem(id: 'a2', name: 'Alt 2'),
    ];

    List<AhpHierarchy> makeHierarchy({
      List<AhpItem>? criteria,
      List<AhpItem>? alternatives,
    }) {
      final crits = criteria ?? validCriteria;
      final alts = alternatives ?? validAlternatives;
      return crits
          .map((c) => AhpHierarchy(criteria: c, alternative: alts))
          .toList();
    }

    List<PairwiseComparisonInput> makeInputsCriteria({
      List<AhpItem>? criteria,
    }) {
      final crits = criteria ?? validCriteria;
      return [
        PairwiseComparisonInput(
          id: 'p_crit_1_2',
          left: crits[0],
          right: crits[1],
          preferenceValue: 3,
          isLeftMoreImportant: true,
        ),
      ];
    }

    List<PairwiseAlternativeInput> makeInputsAlternative({
      List<AhpItem>? criteria,
      List<AhpItem>? alternatives,
    }) {
      final crits = criteria ?? validCriteria;
      final alts = alternatives ?? validAlternatives;
      return crits.map((c) {
        return PairwiseAlternativeInput(
          criteria: c,
          alternative: [
            PairwiseComparisonInput(
              id: 'p_alt_1_2_${c.id}',
              left: alts[0],
              right: alts[1],
              preferenceValue: 2,
              isLeftMoreImportant: true,
            ),
          ],
        );
      }).toList();
    }

    test('Throws Exception when criteria in hierarchy has null ID', () {
      final badCriteria = [
        AhpItem(id: null, name: 'Cost'),
        AhpItem(id: 'c2', name: 'Quality'),
      ];

      expect(
        () => AhpCalculator.calculateDetailed(
          hierarchy: makeHierarchy(criteria: badCriteria),
          inputsCriteria: makeInputsCriteria(),
          inputsAlternative: makeInputsAlternative(),
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Found criteria without ID! Data invalid.'),
          ),
        ),
      );
    });

    test('Throws Exception when criteria in hierarchy has empty ID', () {
      final badCriteria = [
        AhpItem(id: '', name: 'Cost'),
        AhpItem(id: 'c2', name: 'Quality'),
      ];

      expect(
        () => AhpCalculator.calculateDetailed(
          hierarchy: makeHierarchy(criteria: badCriteria),
          inputsCriteria: makeInputsCriteria(),
          inputsAlternative: makeInputsAlternative(),
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Found criteria without ID! Data invalid.'),
          ),
        ),
      );
    });

    test('Throws Exception when alternative in hierarchy has null ID', () {
      final badAlternatives = [
        AhpItem(id: null, name: 'Alt 1'),
        AhpItem(id: 'a2', name: 'Alt 2'),
      ];

      expect(
        () => AhpCalculator.calculateDetailed(
          hierarchy: makeHierarchy(alternatives: badAlternatives),
          inputsCriteria: makeInputsCriteria(),
          inputsAlternative: makeInputsAlternative(),
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Found alternative without ID! Data invalid.'),
          ),
        ),
      );
    });

    test('Throws Exception when alternative in hierarchy has empty ID', () {
      final badAlternatives = [
        AhpItem(id: '', name: 'Alt 1'),
        AhpItem(id: 'a2', name: 'Alt 2'),
      ];

      expect(
        () => AhpCalculator.calculateDetailed(
          hierarchy: makeHierarchy(alternatives: badAlternatives),
          inputsCriteria: makeInputsCriteria(),
          inputsAlternative: makeInputsAlternative(),
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Found alternative without ID! Data invalid.'),
          ),
        ),
      );
    });

    test('Throws Exception when criteria in inputsCriteria has null/empty ID',
        () {
      final badInputsCriteria = [
        PairwiseComparisonInput(
          id: 'p_crit_1_2',
          left: AhpItem(id: null, name: 'Cost'),
          right: validCriteria[1],
          preferenceValue: 3,
          isLeftMoreImportant: true,
        ),
      ];

      expect(
        () => AhpCalculator.calculateDetailed(
          hierarchy: makeHierarchy(),
          inputsCriteria: badInputsCriteria,
          inputsAlternative: makeInputsAlternative(),
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Found criteria without ID! Data invalid.'),
          ),
        ),
      );
    });

    test(
        'Throws Exception when alternative in inputsAlternative has null/empty ID',
        () {
      final badInputsAlternative = [
        PairwiseAlternativeInput(
          criteria: validCriteria[0],
          alternative: [
            PairwiseComparisonInput(
              id: 'p_alt_1_2',
              left: AhpItem(id: '', name: 'Alt 1'),
              right: validAlternatives[1],
              preferenceValue: 2,
              isLeftMoreImportant: true,
            ),
          ],
        ),
        PairwiseAlternativeInput(
          criteria: validCriteria[1],
          alternative: [
            PairwiseComparisonInput(
              id: 'p_alt_1_2_c2',
              left: validAlternatives[0],
              right: validAlternatives[1],
              preferenceValue: 2,
              isLeftMoreImportant: true,
            ),
          ],
        ),
      ];

      expect(
        () => AhpCalculator.calculateDetailed(
          hierarchy: makeHierarchy(),
          inputsCriteria: makeInputsCriteria(),
          inputsAlternative: badInputsAlternative,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Found alternative without ID! Data invalid.'),
          ),
        ),
      );
    });

    test('calculate() throws identical exception on invalid criteria ID', () {
      final badCriteria = [
        AhpItem(id: null, name: 'Cost'),
        AhpItem(id: 'c2', name: 'Quality'),
      ];

      expect(
        () => AhpCalculator.calculate(
          hierarchy: makeHierarchy(criteria: badCriteria),
          inputsCriteria: makeInputsCriteria(),
          inputsAlternative: makeInputsAlternative(),
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Found criteria without ID! Data invalid.'),
          ),
        ),
      );
    });

    test(
        'calculate() produces identical results to calculateDetailed().toAhpResult()',
        () {
      final detailed = AhpCalculator.calculateDetailed(
        hierarchy: makeHierarchy(),
        inputsCriteria: makeInputsCriteria(),
        inputsAlternative: makeInputsAlternative(),
      );
      final converted = detailed.toAhpResult();

      final direct = AhpCalculator.calculate(
        hierarchy: makeHierarchy(),
        inputsCriteria: makeInputsCriteria(),
        inputsAlternative: makeInputsAlternative(),
      );

      expect(
          direct.isConsistentCriteria, equals(converted.isConsistentCriteria));
      expect(direct.consistencyCriteriaRatio,
          equals(converted.consistencyCriteriaRatio));
      expect(direct.isConsistentAlternative,
          equals(converted.isConsistentAlternative));
      expect(direct.consistencyAlternativeRatio,
          equals(converted.consistencyAlternativeRatio));
      expect(direct.note, equals(converted.note));
      expect(direct.results?.length, equals(converted.results?.length));

      for (int i = 0; i < direct.results!.length; i++) {
        expect(direct.results![i].id, equals(converted.results![i].id));
        expect(direct.results![i].name, equals(converted.results![i].name));
        expect(direct.results![i].value, equals(converted.results![i].value));
      }
    });
  });
}
