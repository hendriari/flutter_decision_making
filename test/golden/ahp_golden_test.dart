import 'package:decision_making_core/decision_making_core.dart';
import 'package:flutter_decision_making/flutter_decision_making.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AHP ahp;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    ahp = AHP();
  });

  group('AHP Golden Tests - Core Wrapper Parity', () {
    test('Case 1: Consistent 3x3 case', () async {
      // Ground truth verified against core (decision_making_core)

      final criteriaItems = [
        AhpItem(id: 'c1', name: 'Cost'),
        AhpItem(id: 'c2', name: 'Quality'),
        AhpItem(id: 'c3', name: 'Delivery'),
      ];

      final altItems = [
        AhpItem(id: 'a', name: 'Alternative A'),
        AhpItem(id: 'b', name: 'Alternative B'),
        AhpItem(id: 'c', name: 'Alternative C'),
      ];

      final hierarchy = [
        AhpHierarchy(criteria: criteriaItems[0], alternative: altItems),
        AhpHierarchy(criteria: criteriaItems[1], alternative: altItems),
        AhpHierarchy(criteria: criteriaItems[2], alternative: altItems),
      ];

      final inputsCriteria = [
        PairwiseComparisonInput(
          id: 'p_c1_c2',
          left: criteriaItems[0],
          right: criteriaItems[1],
          preferenceValue: 3,
          isLeftMoreImportant: true,
        ),
        PairwiseComparisonInput(
          id: 'p_c1_c3',
          left: criteriaItems[0],
          right: criteriaItems[2],
          preferenceValue: 5,
          isLeftMoreImportant: true,
        ),
        PairwiseComparisonInput(
          id: 'p_c2_c3',
          left: criteriaItems[1],
          right: criteriaItems[2],
          preferenceValue: 2,
          isLeftMoreImportant: true,
        ),
      ];

      final inputsAlternative = [
        // Under C1 (Cost): A > B (2), A > C (5), B > C (3)
        PairwiseAlternativeInput(
          criteria: criteriaItems[0],
          alternative: [
            PairwiseComparisonInput(
              id: 'p1_a_b',
              left: altItems[0],
              right: altItems[1],
              preferenceValue: 2,
              isLeftMoreImportant: true,
            ),
            PairwiseComparisonInput(
              id: 'p1_a_c',
              left: altItems[0],
              right: altItems[2],
              preferenceValue: 5,
              isLeftMoreImportant: true,
            ),
            PairwiseComparisonInput(
              id: 'p1_b_c',
              left: altItems[1],
              right: altItems[2],
              preferenceValue: 3,
              isLeftMoreImportant: true,
            ),
          ],
        ),
        // Under C2 (Quality): B > A (3), A > C (2), B > C (4)
        PairwiseAlternativeInput(
          criteria: criteriaItems[1],
          alternative: [
            PairwiseComparisonInput(
              id: 'p2_a_b',
              left: altItems[0],
              right: altItems[1],
              preferenceValue: 3,
              isLeftMoreImportant: false, // B is more important
            ),
            PairwiseComparisonInput(
              id: 'p2_a_c',
              left: altItems[0],
              right: altItems[2],
              preferenceValue: 2,
              isLeftMoreImportant: true,
            ),
            PairwiseComparisonInput(
              id: 'p2_b_c',
              left: altItems[1],
              right: altItems[2],
              preferenceValue: 4,
              isLeftMoreImportant: true,
            ),
          ],
        ),
        // Under C3 (Delivery): A > B (2), A > C (3), B > C (3)
        PairwiseAlternativeInput(
          criteria: criteriaItems[2],
          alternative: [
            PairwiseComparisonInput(
              id: 'p3_a_b',
              left: altItems[0],
              right: altItems[1],
              preferenceValue: 2,
              isLeftMoreImportant: true,
            ),
            PairwiseComparisonInput(
              id: 'p3_a_c',
              left: altItems[0],
              right: altItems[2],
              preferenceValue: 3,
              isLeftMoreImportant: true,
            ),
            PairwiseComparisonInput(
              id: 'p3_b_c',
              left: altItems[1],
              right: altItems[2],
              preferenceValue: 3,
              isLeftMoreImportant: true,
            ),
          ],
        ),
      ];

      final expected = AhpCalculator.calculate(
        hierarchy: hierarchy,
        inputsCriteria: inputsCriteria,
        inputsAlternative: inputsAlternative,
      );

      final result = await ahp.getAhpResult(
        hierarchy: hierarchy,
        inputsCriteria: inputsCriteria,
        inputsAlternative: inputsAlternative,
      );

      final isolateResult = await ahp.getAhpResult(
        hierarchy: hierarchy,
        inputsCriteria: inputsCriteria,
        inputsAlternative: inputsAlternative,
        useIsolate: true,
      );

      // Verify wrapper (main thread) produces identical output to core
      expect(result.isConsistentCriteria, expected.isConsistentCriteria);
      if (expected.consistencyCriteriaRatio != null) {
        expect(result.consistencyCriteriaRatio,
            closeTo(expected.consistencyCriteriaRatio!, 1e-6));
      }
      expect(result.isConsistentAlternative, expected.isConsistentAlternative);
      if (expected.consistencyAlternativeRatio != null) {
        expect(result.consistencyAlternativeRatio,
            closeTo(expected.consistencyAlternativeRatio!, 1e-6));
      }
      expect(result.note, expected.note);

      expect(result.results!.length, expected.results!.length);
      for (int i = 0; i < expected.results!.length; i++) {
        expect(result.results![i].id, expected.results![i].id);
        expect(result.results![i].name, expected.results![i].name);
        expect(result.results![i].value, closeTo(expected.results![i].value, 1e-6));
      }

      // Verify wrapper (isolate) produces identical output to core
      expect(isolateResult.isConsistentCriteria, expected.isConsistentCriteria);
      if (expected.consistencyCriteriaRatio != null) {
        expect(isolateResult.consistencyCriteriaRatio,
            closeTo(expected.consistencyCriteriaRatio!, 1e-6));
      }
      expect(isolateResult.isConsistentAlternative, expected.isConsistentAlternative);
      if (expected.consistencyAlternativeRatio != null) {
        expect(isolateResult.consistencyAlternativeRatio,
            closeTo(expected.consistencyAlternativeRatio!, 1e-6));
      }
      expect(isolateResult.note, expected.note);

      expect(isolateResult.results!.length, expected.results!.length);
      for (int i = 0; i < expected.results!.length; i++) {
        expect(isolateResult.results![i].id, expected.results![i].id);
        expect(isolateResult.results![i].name, expected.results![i].name);
        expect(isolateResult.results![i].value,
            closeTo(expected.results![i].value, 1e-6));
      }

      // Verify wrapper detailed result matches core calculateDetailed
      final expectedDetailed = AhpCalculator.calculateDetailed(
        hierarchy: hierarchy,
        inputsCriteria: inputsCriteria,
        inputsAlternative: inputsAlternative,
      );
      final detailedResult = await ahp.getAhpDetailedResult(
        hierarchy: hierarchy,
        inputsCriteria: inputsCriteria,
        inputsAlternative: inputsAlternative,
      );

      // Criteria evaluation parity
      expect(detailedResult.criteriaEvaluation.comparisonMatrix.length,
          expectedDetailed.criteriaEvaluation.comparisonMatrix.length);
      expect(detailedResult.criteriaEvaluation.normalizedMatrix.length,
          expectedDetailed.criteriaEvaluation.normalizedMatrix.length);
      for (final key in expectedDetailed.criteriaWeights.keys) {
        expect(detailedResult.criteriaWeights[key],
            closeTo(expectedDetailed.criteriaWeights[key]!, 1e-4));
      }
      expect(detailedResult.criteriaEvaluation.lambdaMax,
          closeTo(expectedDetailed.criteriaEvaluation.lambdaMax, 1e-4));
      expect(detailedResult.criteriaEvaluation.ci,
          closeTo(expectedDetailed.criteriaEvaluation.ci, 1e-4));
      expect(detailedResult.criteriaEvaluation.ri,
          closeTo(expectedDetailed.criteriaEvaluation.ri, 1e-4));
      expect(detailedResult.criteriaEvaluation.cr,
          closeTo(expectedDetailed.criteriaEvaluation.cr, 1e-4));

      // Alternative evaluations parity
      for (final critKey in expectedDetailed.alternativeEvaluations.keys) {
        final expectedAlt = expectedDetailed.alternativeEvaluations[critKey]!;
        final actualAlt = detailedResult.alternativeEvaluations[critKey]!;
        for (final altKey in expectedAlt.weights.keys) {
          expect(actualAlt.weights[altKey],
              closeTo(expectedAlt.weights[altKey]!, 1e-4));
        }
        expect(actualAlt.lambdaMax, closeTo(expectedAlt.lambdaMax, 1e-4));
        expect(actualAlt.cr, closeTo(expectedAlt.cr, 1e-4));
      }

      // Final scores parity
      expect(detailedResult.scores.length, expectedDetailed.scores.length);
      for (int i = 0; i < expectedDetailed.scores.length; i++) {
        expect(detailedResult.scores[i].id, expectedDetailed.scores[i].id);
        expect(detailedResult.scores[i].value,
            closeTo(expectedDetailed.scores[i].value, 1e-4));
      }
    });

    test('Case 2: Candidate Selection - Multiple Levels', () async {
      // Ground truth verified against core (decision_making_core)

      final criteriaItems = [
        AhpItem(id: 'c1', name: 'Experience'),
        AhpItem(id: 'c2', name: 'Technical'),
        AhpItem(id: 'c3', name: 'Interview'),
      ];

      final altItems = [
        AhpItem(id: 'john', name: 'John'),
        AhpItem(id: 'mary', name: 'Mary'),
        AhpItem(id: 'david', name: 'David'),
      ];

      final criteriaMatrix = [
        [1.0, 2.0, 4.0],
        [1.0 / 2.0, 1.0, 3.0],
        [1.0 / 4.0, 1.0 / 3.0, 1.0],
      ];

      // 1. Verify Criteria Weights match core
      final expectedCriteriaWeights =
          AhpCalculator.calculateEigenVector(criteriaMatrix);
      final criteriaWeights = await ahpCalculateEigenVectorCriteria({
        'matrix': criteriaMatrix,
      });

      expect(criteriaWeights.length, expectedCriteriaWeights.length);
      for (int i = 0; i < expectedCriteriaWeights.length; i++) {
        expect(criteriaWeights[i], closeTo(expectedCriteriaWeights[i], 1e-6));
      }

      // 2. Verify Criteria Consistency Metrics match core
      final expectedCriteriaCR = AhpCalculator.checkConsistencyRatio(
        criteriaMatrix,
        expectedCriteriaWeights,
        'criteria',
      );
      final criteriaCR = await ahpCheckConsistencyRatio({
        'matrix': criteriaMatrix,
        'priority_vector': criteriaWeights,
        'source': 'criteria',
      });

      expect(criteriaCR['lambda_max'], closeTo(expectedCriteriaCR.lambdaMax!, 1e-6));
      expect(criteriaCR['ci'], closeTo(expectedCriteriaCR.ci!, 1e-6));
      expect(criteriaCR['ratio'], closeTo(expectedCriteriaCR.ratio, 1e-6));
      expect(criteriaCR['is_consistent'], expectedCriteriaCR.isConsistent);

      // 3. Full Hierarchy
      final hierarchy = [
        AhpHierarchy(criteria: criteriaItems[0], alternative: altItems),
        AhpHierarchy(criteria: criteriaItems[1], alternative: altItems),
        AhpHierarchy(criteria: criteriaItems[2], alternative: altItems),
      ];

      final inputsCriteria = [
        PairwiseComparisonInput(
          id: 'p_c1_c2',
          left: criteriaItems[0],
          right: criteriaItems[1],
          preferenceValue: 2,
          isLeftMoreImportant: true,
        ),
        PairwiseComparisonInput(
          id: 'p_c1_c3',
          left: criteriaItems[0],
          right: criteriaItems[2],
          preferenceValue: 4,
          isLeftMoreImportant: true,
        ),
        PairwiseComparisonInput(
          id: 'p_c2_c3',
          left: criteriaItems[1],
          right: criteriaItems[2],
          preferenceValue: 3,
          isLeftMoreImportant: true,
        ),
      ];

      final inputsAlternative = [
        // Under Experience (C1): John > Mary (3), John > David (5), Mary > David (2)
        PairwiseAlternativeInput(
          criteria: criteriaItems[0],
          alternative: [
            PairwiseComparisonInput(
              id: 'p1_j_m',
              left: altItems[0],
              right: altItems[1],
              preferenceValue: 3,
              isLeftMoreImportant: true,
            ),
            PairwiseComparisonInput(
              id: 'p1_j_d',
              left: altItems[0],
              right: altItems[2],
              preferenceValue: 5,
              isLeftMoreImportant: true,
            ),
            PairwiseComparisonInput(
              id: 'p1_m_d',
              left: altItems[1],
              right: altItems[2],
              preferenceValue: 2,
              isLeftMoreImportant: true,
            ),
          ],
        ),
        // Under Technical (C2): Mary > John (2), John > David (2), Mary > David (3)
        PairwiseAlternativeInput(
          criteria: criteriaItems[1],
          alternative: [
            PairwiseComparisonInput(
              id: 'p2_j_m',
              left: altItems[0],
              right: altItems[1],
              preferenceValue: 2,
              isLeftMoreImportant: false, // Mary > John
            ),
            PairwiseComparisonInput(
              id: 'p2_j_d',
              left: altItems[0],
              right: altItems[2],
              preferenceValue: 2,
              isLeftMoreImportant: true,
            ),
            PairwiseComparisonInput(
              id: 'p2_m_d',
              left: altItems[1],
              right: altItems[2],
              preferenceValue: 3,
              isLeftMoreImportant: true,
            ),
          ],
        ),
        // Under Interview (C3): John > Mary (2), David > John (2), David > Mary (3)
        PairwiseAlternativeInput(
          criteria: criteriaItems[2],
          alternative: [
            PairwiseComparisonInput(
              id: 'p3_j_m',
              left: altItems[0],
              right: altItems[1],
              preferenceValue: 2,
              isLeftMoreImportant: true,
            ),
            PairwiseComparisonInput(
              id: 'p3_j_d',
              left: altItems[0],
              right: altItems[2],
              preferenceValue: 2,
              isLeftMoreImportant: false, // David > John
            ),
            PairwiseComparisonInput(
              id: 'p3_m_d',
              left: altItems[1],
              right: altItems[2],
              preferenceValue: 3,
              isLeftMoreImportant: false, // David > Mary
            ),
          ],
        ),
      ];

      final expected = AhpCalculator.calculate(
        hierarchy: hierarchy,
        inputsCriteria: inputsCriteria,
        inputsAlternative: inputsAlternative,
      );

      final result = await ahp.getAhpResult(
        hierarchy: hierarchy,
        inputsCriteria: inputsCriteria,
        inputsAlternative: inputsAlternative,
      );

      final isolateResult = await ahp.getAhpResult(
        hierarchy: hierarchy,
        inputsCriteria: inputsCriteria,
        inputsAlternative: inputsAlternative,
        useIsolate: true,
      );

      // Verify wrapper (main thread) produces identical output to core
      expect(result.isConsistentCriteria, expected.isConsistentCriteria);
      if (expected.consistencyCriteriaRatio != null) {
        expect(result.consistencyCriteriaRatio,
            closeTo(expected.consistencyCriteriaRatio!, 1e-6));
      }
      expect(result.isConsistentAlternative, expected.isConsistentAlternative);
      if (expected.consistencyAlternativeRatio != null) {
        expect(result.consistencyAlternativeRatio,
            closeTo(expected.consistencyAlternativeRatio!, 1e-6));
      }
      expect(result.note, expected.note);

      expect(result.results!.length, expected.results!.length);
      for (int i = 0; i < expected.results!.length; i++) {
        expect(result.results![i].id, expected.results![i].id);
        expect(result.results![i].name, expected.results![i].name);
        expect(result.results![i].value, closeTo(expected.results![i].value, 1e-6));
      }

      // Verify wrapper (isolate) produces identical output to core
      expect(isolateResult.isConsistentCriteria, expected.isConsistentCriteria);
      if (expected.consistencyCriteriaRatio != null) {
        expect(isolateResult.consistencyCriteriaRatio,
            closeTo(expected.consistencyCriteriaRatio!, 1e-6));
      }
      expect(isolateResult.isConsistentAlternative, expected.isConsistentAlternative);
      if (expected.consistencyAlternativeRatio != null) {
        expect(isolateResult.consistencyAlternativeRatio,
            closeTo(expected.consistencyAlternativeRatio!, 1e-6));
      }
      expect(isolateResult.note, expected.note);

      expect(isolateResult.results!.length, expected.results!.length);
      for (int i = 0; i < expected.results!.length; i++) {
        expect(isolateResult.results![i].id, expected.results![i].id);
        expect(isolateResult.results![i].name, expected.results![i].name);
        expect(isolateResult.results![i].value,
            closeTo(expected.results![i].value, 1e-6));
      }

      // Verify wrapper detailed result matches core calculateDetailed
      final expectedDetailed = AhpCalculator.calculateDetailed(
        hierarchy: hierarchy,
        inputsCriteria: inputsCriteria,
        inputsAlternative: inputsAlternative,
      );
      final detailedResult = await ahp.getAhpDetailedResult(
        hierarchy: hierarchy,
        inputsCriteria: inputsCriteria,
        inputsAlternative: inputsAlternative,
      );

      // Criteria evaluation parity
      expect(detailedResult.criteriaEvaluation.comparisonMatrix.length,
          expectedDetailed.criteriaEvaluation.comparisonMatrix.length);
      expect(detailedResult.criteriaEvaluation.normalizedMatrix.length,
          expectedDetailed.criteriaEvaluation.normalizedMatrix.length);
      for (final key in expectedDetailed.criteriaWeights.keys) {
        expect(detailedResult.criteriaWeights[key],
            closeTo(expectedDetailed.criteriaWeights[key]!, 1e-4));
      }
      expect(detailedResult.criteriaEvaluation.lambdaMax,
          closeTo(expectedDetailed.criteriaEvaluation.lambdaMax, 1e-4));
      expect(detailedResult.criteriaEvaluation.ci,
          closeTo(expectedDetailed.criteriaEvaluation.ci, 1e-4));
      expect(detailedResult.criteriaEvaluation.ri,
          closeTo(expectedDetailed.criteriaEvaluation.ri, 1e-4));
      expect(detailedResult.criteriaEvaluation.cr,
          closeTo(expectedDetailed.criteriaEvaluation.cr, 1e-4));

      // Alternative evaluations parity
      for (final critKey in expectedDetailed.alternativeEvaluations.keys) {
        final expectedAlt = expectedDetailed.alternativeEvaluations[critKey]!;
        final actualAlt = detailedResult.alternativeEvaluations[critKey]!;
        for (final altKey in expectedAlt.weights.keys) {
          expect(actualAlt.weights[altKey],
              closeTo(expectedAlt.weights[altKey]!, 1e-4));
        }
        expect(actualAlt.lambdaMax, closeTo(expectedAlt.lambdaMax, 1e-4));
        expect(actualAlt.cr, closeTo(expectedAlt.cr, 1e-4));
      }

      // Final scores parity
      expect(detailedResult.scores.length, expectedDetailed.scores.length);
      for (int i = 0; i < expectedDetailed.scores.length; i++) {
        expect(detailedResult.scores[i].id, expectedDetailed.scores[i].id);
        expect(detailedResult.scores[i].value,
            closeTo(expectedDetailed.scores[i].value, 1e-4));
      }
    });

    test('Case 3 (Edge Case): Inconsistent Comparison Matrix with CR > 0.1', () async {
      // Ground truth verified against core (decision_making_core)

      final criteriaItems = [
        AhpItem(id: 'c1', name: 'Criteria 1'),
        AhpItem(id: 'c2', name: 'Criteria 2'),
        AhpItem(id: 'c3', name: 'Criteria 3'),
      ];

      final altItems = [
        AhpItem(id: 'a1', name: 'Alternative 1'),
        AhpItem(id: 'a2', name: 'Alternative 2'),
        AhpItem(id: 'a3', name: 'Alternative 3'),
      ];

      final inconsistentMatrix = [
        [1.0, 9.0, 1.0 / 9.0],
        [1.0 / 9.0, 1.0, 9.0],
        [9.0, 1.0 / 9.0, 1.0],
      ];

      // 1. Verify Weights under extreme circular inconsistency match core
      final expectedCriteriaWeights =
          AhpCalculator.calculateEigenVector(inconsistentMatrix);
      final criteriaWeights = await ahpCalculateEigenVectorCriteria({
        'matrix': inconsistentMatrix,
      });

      expect(criteriaWeights.length, expectedCriteriaWeights.length);
      for (int i = 0; i < expectedCriteriaWeights.length; i++) {
        expect(criteriaWeights[i], closeTo(expectedCriteriaWeights[i], 1e-6));
      }

      // 2. Verify lambda_max, CI, and severe CR violation match core
      final expectedCR = AhpCalculator.checkConsistencyRatio(
        inconsistentMatrix,
        expectedCriteriaWeights,
        'criteria',
      );
      final consistencyResult = await ahpCheckConsistencyRatio({
        'matrix': inconsistentMatrix,
        'priority_vector': criteriaWeights,
        'source': 'criteria',
      });

      expect(consistencyResult['lambda_max'], closeTo(expectedCR.lambdaMax!, 1e-6));
      expect(consistencyResult['ci'], closeTo(expectedCR.ci!, 1e-6));
      expect(consistencyResult['ratio'], closeTo(expectedCR.ratio, 1e-6));
      expect(consistencyResult['is_consistent'], expectedCR.isConsistent);

      // 3. Verify End-to-End detection and warning generation match core
      final hierarchy = [
        AhpHierarchy(criteria: criteriaItems[0], alternative: altItems),
        AhpHierarchy(criteria: criteriaItems[1], alternative: altItems),
        AhpHierarchy(criteria: criteriaItems[2], alternative: altItems),
      ];

      final inputsCriteria = [
        PairwiseComparisonInput(
          id: 'p_c1_c2',
          left: criteriaItems[0],
          right: criteriaItems[1],
          preferenceValue: 9,
          isLeftMoreImportant: true,
        ),
        PairwiseComparisonInput(
          id: 'p_c1_c3',
          left: criteriaItems[0],
          right: criteriaItems[2],
          preferenceValue: 9,
          isLeftMoreImportant: false, // Inconsistent: C3 >> C1
        ),
        PairwiseComparisonInput(
          id: 'p_c2_c3',
          left: criteriaItems[1],
          right: criteriaItems[2],
          preferenceValue: 9,
          isLeftMoreImportant: true,
        ),
      ];

      // Neutral equal comparisons for alternatives
      final neutralAltInputs = [
        PairwiseComparisonInput(
          id: 'alt_1_2',
          left: altItems[0],
          right: altItems[1],
          preferenceValue: 1,
          isLeftMoreImportant: true,
        ),
        PairwiseComparisonInput(
          id: 'alt_1_3',
          left: altItems[0],
          right: altItems[2],
          preferenceValue: 1,
          isLeftMoreImportant: true,
        ),
        PairwiseComparisonInput(
          id: 'alt_2_3',
          left: altItems[1],
          right: altItems[2],
          preferenceValue: 1,
          isLeftMoreImportant: true,
        ),
      ];

      final inputsAlternative = [
        PairwiseAlternativeInput(
          criteria: criteriaItems[0],
          alternative: neutralAltInputs,
        ),
        PairwiseAlternativeInput(
          criteria: criteriaItems[1],
          alternative: neutralAltInputs,
        ),
        PairwiseAlternativeInput(
          criteria: criteriaItems[2],
          alternative: neutralAltInputs,
        ),
      ];

      final expected = AhpCalculator.calculate(
        hierarchy: hierarchy,
        inputsCriteria: inputsCriteria,
        inputsAlternative: inputsAlternative,
      );

      final result = await ahp.getAhpResult(
        hierarchy: hierarchy,
        inputsCriteria: inputsCriteria,
        inputsAlternative: inputsAlternative,
      );

      final isolateResult = await ahp.getAhpResult(
        hierarchy: hierarchy,
        inputsCriteria: inputsCriteria,
        inputsAlternative: inputsAlternative,
        useIsolate: true,
      );

      // Verify wrapper (main thread) produces identical output to core
      expect(result.isConsistentCriteria, expected.isConsistentCriteria);
      if (expected.consistencyCriteriaRatio != null) {
        expect(result.consistencyCriteriaRatio,
            closeTo(expected.consistencyCriteriaRatio!, 1e-6));
      }
      expect(result.isConsistentAlternative, expected.isConsistentAlternative);
      if (expected.consistencyAlternativeRatio != null) {
        expect(result.consistencyAlternativeRatio,
            closeTo(expected.consistencyAlternativeRatio!, 1e-6));
      }
      expect(result.note, expected.note);

      expect(result.results!.length, expected.results!.length);
      for (int i = 0; i < expected.results!.length; i++) {
        expect(result.results![i].id, expected.results![i].id);
        expect(result.results![i].name, expected.results![i].name);
        expect(result.results![i].value, closeTo(expected.results![i].value, 1e-6));
      }

      // Verify wrapper (isolate) produces identical output to core
      expect(isolateResult.isConsistentCriteria, expected.isConsistentCriteria);
      if (expected.consistencyCriteriaRatio != null) {
        expect(isolateResult.consistencyCriteriaRatio,
            closeTo(expected.consistencyCriteriaRatio!, 1e-6));
      }
      expect(isolateResult.isConsistentAlternative, expected.isConsistentAlternative);
      if (expected.consistencyAlternativeRatio != null) {
        expect(isolateResult.consistencyAlternativeRatio,
            closeTo(expected.consistencyAlternativeRatio!, 1e-6));
      }
      expect(isolateResult.note, expected.note);

      expect(isolateResult.results!.length, expected.results!.length);
      for (int i = 0; i < expected.results!.length; i++) {
        expect(isolateResult.results![i].id, expected.results![i].id);
        expect(isolateResult.results![i].name, expected.results![i].name);
        expect(isolateResult.results![i].value,
            closeTo(expected.results![i].value, 1e-6));
      }

      // Verify wrapper detailed result matches core calculateDetailed
      final expectedDetailed = AhpCalculator.calculateDetailed(
        hierarchy: hierarchy,
        inputsCriteria: inputsCriteria,
        inputsAlternative: inputsAlternative,
      );
      final detailedResult = await ahp.getAhpDetailedResult(
        hierarchy: hierarchy,
        inputsCriteria: inputsCriteria,
        inputsAlternative: inputsAlternative,
      );

      // Criteria evaluation parity
      expect(detailedResult.criteriaEvaluation.comparisonMatrix.length,
          expectedDetailed.criteriaEvaluation.comparisonMatrix.length);
      expect(detailedResult.criteriaEvaluation.normalizedMatrix.length,
          expectedDetailed.criteriaEvaluation.normalizedMatrix.length);
      for (final key in expectedDetailed.criteriaWeights.keys) {
        expect(detailedResult.criteriaWeights[key],
            closeTo(expectedDetailed.criteriaWeights[key]!, 1e-4));
      }
      expect(detailedResult.criteriaEvaluation.lambdaMax,
          closeTo(expectedDetailed.criteriaEvaluation.lambdaMax, 1e-4));
      expect(detailedResult.criteriaEvaluation.ci,
          closeTo(expectedDetailed.criteriaEvaluation.ci, 1e-4));
      expect(detailedResult.criteriaEvaluation.ri,
          closeTo(expectedDetailed.criteriaEvaluation.ri, 1e-4));
      expect(detailedResult.criteriaEvaluation.cr,
          closeTo(expectedDetailed.criteriaEvaluation.cr, 1e-4));

      // Alternative evaluations parity
      for (final critKey in expectedDetailed.alternativeEvaluations.keys) {
        final expectedAlt = expectedDetailed.alternativeEvaluations[critKey]!;
        final actualAlt = detailedResult.alternativeEvaluations[critKey]!;
        for (final altKey in expectedAlt.weights.keys) {
          expect(actualAlt.weights[altKey],
              closeTo(expectedAlt.weights[altKey]!, 1e-4));
        }
        expect(actualAlt.lambdaMax, closeTo(expectedAlt.lambdaMax, 1e-4));
        expect(actualAlt.cr, closeTo(expectedAlt.cr, 1e-4));
      }

      // Final scores parity
      expect(detailedResult.scores.length, expectedDetailed.scores.length);
      for (int i = 0; i < expectedDetailed.scores.length; i++) {
        expect(detailedResult.scores[i].id, expectedDetailed.scores[i].id);
        expect(detailedResult.scores[i].value,
            closeTo(expectedDetailed.scores[i].value, 1e-4));
      }
    });
  });
}
