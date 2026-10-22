import 'package:decision_making_core/decision_making_core.dart';
import 'package:test/test.dart';

void main() {
  group('AHP Golden Tests (Tolerance 1e-4)', () {
    test('Case 1: Consistent 3x3 case', () {
      // Label: cross-checked (Python 3.9 + numpy)

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

      // Criteria Pairwise Matrix:
      // c1 vs c2: scale 3 (c1 > c2)
      // c1 vs c3: scale 5 (c1 > c3)
      // c2 vs c3: scale 2 (c2 > c3)
      final criteriaMatrix = [
        [1.0, 3.0, 5.0],
        [1.0 / 3.0, 1.0, 2.0],
        [1.0 / 5.0, 1.0 / 2.0, 1.0],
      ];

      // 1. Verify Criteria Weights (Eigenvector)
      final criteriaWeights =
          AhpCalculator.calculateEigenVector(criteriaMatrix);

      expect(criteriaWeights.length, 3);
      expect(criteriaWeights[0], closeTo(0.647947, 1e-4));
      expect(criteriaWeights[1], closeTo(0.229871, 1e-4));
      expect(criteriaWeights[2], closeTo(0.122182, 1e-4));

      // 2. Verify lambda_max, CI, and CR for Criteria
      final criteriaCR = AhpCalculator.checkConsistencyRatio(
        criteriaMatrix,
        criteriaWeights,
        'criteria',
      );

      expect(criteriaCR.lambdaMax, closeTo(3.003697, 1e-4));
      expect(criteriaCR.ci, closeTo(0.001848, 1e-4));
      expect(criteriaCR.ratio, closeTo(0.003187, 1e-4));
      expect(criteriaCR.isConsistent, isTrue);

      // 3. Build Full Hierarchy and Pairwise Inputs for End-to-End calculation
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
        // Under C3 (Delivery): A = B (1), A > C (3), B > C (3)
        PairwiseAlternativeInput(
          criteria: criteriaItems[2],
          alternative: [
            PairwiseComparisonInput(
              id: 'p3_a_b',
              left: altItems[0],
              right: altItems[1],
              preferenceValue: 1,
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

      final result = AhpCalculator.calculate(
        hierarchy: hierarchy,
        inputsCriteria: inputsCriteria,
        inputsAlternative: inputsAlternative,
      );

      // Verify Consistency Flags
      expect(result.isConsistentCriteria, isTrue);
      expect(result.consistencyCriteriaRatio, closeTo(0.003187, 1e-4));
      expect(result.isConsistentAlternative, isTrue);
      expect(result.note, isNull);

      // Verify Final Scores and Rankings
      final details = result.results!;
      expect(details.length, 3);

      // Rank 1: Alternative A (0.484043)
      expect(details[0].id, 'a');
      expect(details[0].value, closeTo(0.484043, 1e-4));

      // Rank 2: Alternative B (0.395938)
      expect(details[1].id, 'b');
      expect(details[1].value, closeTo(0.395938, 1e-4));

      // Rank 3: Alternative C (0.120019)
      expect(details[2].id, 'c');
      expect(details[2].value, closeTo(0.120019, 1e-4));
    });

    test('Case 2: Candidate Selection - Multiple Levels', () {
      // Label: cross-checked (Python 3.9)
      // 3 Criteria (Experience, Technical, Interview), 3 Candidates (John, Mary, David)

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

      // 1. Verify Criteria Weights
      final criteriaWeights =
          AhpCalculator.calculateEigenVector(criteriaMatrix);

      expect(criteriaWeights[0], closeTo(0.557143, 1e-4));
      expect(criteriaWeights[1], closeTo(0.320238, 1e-4));
      expect(criteriaWeights[2], closeTo(0.122619, 1e-4));

      // 2. Verify Criteria Consistency Metrics
      final criteriaCR = AhpCalculator.checkConsistencyRatio(
        criteriaMatrix,
        criteriaWeights,
        'criteria',
      );

      expect(criteriaCR.lambdaMax, closeTo(3.018325, 1e-4));
      expect(criteriaCR.ci, closeTo(0.009162, 1e-4));
      expect(criteriaCR.ratio, closeTo(0.015797, 1e-4));
      expect(criteriaCR.isConsistent, isTrue);

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

      final result = AhpCalculator.calculate(
        hierarchy: hierarchy,
        inputsCriteria: inputsCriteria,
        inputsAlternative: inputsAlternative,
      );

      expect(result.isConsistentCriteria, isTrue);
      expect(result.consistencyCriteriaRatio, closeTo(0.015797, 1e-4));
      expect(result.isConsistentAlternative, isTrue);
      expect(result.note, isNull);

      final details = result.results!;
      expect(details.length, 3);

      // Rank 1: John (0.492642)
      expect(details[0].id, 'john');
      expect(details[0].value, closeTo(0.492642, 1e-4));

      // Rank 2: Mary (0.320750)
      expect(details[1].id, 'mary');
      expect(details[1].value, closeTo(0.320750, 1e-4));

      // Rank 3: David (0.186609)
      expect(details[2].id, 'david');
      expect(details[2].value, closeTo(0.186609, 1e-4));
    });

    test('Case 3 (Edge Case): Inconsistent Comparison Matrix with CR > 0.1',
        () {
      // Label: cross-checked (Python 3.9)
      // Severe circular inconsistency: C1 >> C2 (9), C2 >> C3 (9), but C3 >> C1 (9)

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

      // 1. Verify Weights under extreme circular inconsistency (symmetry forces equal weights)
      final criteriaWeights =
          AhpCalculator.calculateEigenVector(inconsistentMatrix);

      expect(criteriaWeights[0], closeTo(0.333333, 1e-4));
      expect(criteriaWeights[1], closeTo(0.333333, 1e-4));
      expect(criteriaWeights[2], closeTo(0.333333, 1e-4));

      // 2. Verify lambda_max, CI, and severe CR violation (CR >> 0.1)
      final consistencyResult = AhpCalculator.checkConsistencyRatio(
        inconsistentMatrix,
        criteriaWeights,
        'criteria',
      );

      expect(consistencyResult.lambdaMax, closeTo(10.111111, 1e-4));
      expect(consistencyResult.ci, closeTo(3.555556, 1e-4));
      expect(consistencyResult.ratio, closeTo(6.130268, 1e-4));
      expect(consistencyResult.isConsistent, isFalse);

      // 3. Verify End-to-End detection and warning generation
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

      final result = AhpCalculator.calculate(
        hierarchy: hierarchy,
        inputsCriteria: inputsCriteria,
        inputsAlternative: inputsAlternative,
      );

      // Must detect inconsistency
      expect(result.isConsistentCriteria, isFalse);
      expect(result.consistencyCriteriaRatio, closeTo(6.130268, 1e-4));
      expect(result.note, isNotNull);
      expect(result.note, contains('exceeds the acceptable threshold of 0.1'));
      expect(result.note, contains('inconsistency on criteria'));
    });
  });

  group('AHP Detailed Results Tests - Intermediate Values (Tolerance 1e-4)', () {
    test('Case 1: Intermediate values for consistent 3x3 case', () {
      // Label: cross-checked (Python 3.9)
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
        PairwiseAlternativeInput(
          criteria: criteriaItems[1],
          alternative: [
            PairwiseComparisonInput(
              id: 'p2_a_b',
              left: altItems[0],
              right: altItems[1],
              preferenceValue: 3,
              isLeftMoreImportant: false,
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
        PairwiseAlternativeInput(
          criteria: criteriaItems[2],
          alternative: [
            PairwiseComparisonInput(
              id: 'p3_a_b',
              left: altItems[0],
              right: altItems[1],
              preferenceValue: 1,
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

      final detailed = AhpCalculator.calculateDetailed(
        hierarchy: hierarchy,
        inputsCriteria: inputsCriteria,
        inputsAlternative: inputsAlternative,
      );

      // 1. Criteria Matrix and Normalization
      expect(detailed.criteriaEvaluation.comparisonMatrix[0][1], closeTo(3.0, 1e-4));
      expect(detailed.criteriaEvaluation.comparisonMatrix[1][0], closeTo(1.0 / 3.0, 1e-4));
      expect(detailed.criteriaEvaluation.normalizedMatrix[0][0], closeTo(0.652174, 1e-4));
      expect(detailed.criteriaEvaluation.normalizedMatrix[0][1], closeTo(0.666667, 1e-4));
      expect(detailed.criteriaEvaluation.normalizedMatrix[0][2], closeTo(0.625000, 1e-4));
      expect(detailed.criteriaWeights['c1'], closeTo(0.647947, 1e-4));
      expect(detailed.criteriaWeights['c2'], closeTo(0.229871, 1e-4));
      expect(detailed.criteriaWeights['c3'], closeTo(0.122182, 1e-4));
      expect(detailed.criteriaEvaluation.lambdaMax, closeTo(3.003697, 1e-4));
      expect(detailed.criteriaEvaluation.ci, closeTo(0.001848, 1e-4));
      expect(detailed.criteriaEvaluation.ri, closeTo(0.58, 1e-4));
      expect(detailed.criteriaEvaluation.cr, closeTo(0.003187, 1e-4));
      expect(detailed.criteriaEvaluation.isConsistent, isTrue);

      // 2. Alternative under C1 (Cost)
      final altEvalC1 = detailed.alternativeEvaluations['c1']!;
      expect(altEvalC1.normalizedMatrix[0][0], closeTo(0.588235, 1e-4));
      expect(altEvalC1.normalizedMatrix[1][1], closeTo(0.300000, 1e-4));
      expect(altEvalC1.weights['a'], closeTo(0.581264, 1e-4));
      expect(altEvalC1.weights['b'], closeTo(0.309150, 1e-4));
      expect(altEvalC1.weights['c'], closeTo(0.109586, 1e-4));
      expect(altEvalC1.lambdaMax, closeTo(3.003696, 1e-4));
      expect(altEvalC1.ci, closeTo(0.001848, 1e-4));
      expect(altEvalC1.ri, closeTo(0.58, 1e-4));
      expect(altEvalC1.cr, closeTo(0.003186, 1e-4));

      // 3. Alternative under C2 (Quality)
      final altEvalC2 = detailed.alternativeEvaluations['c2']!;
      expect(altEvalC2.weights['a'], closeTo(0.239488, 1e-4));
      expect(altEvalC2.weights['b'], closeTo(0.623225, 1e-4));
      expect(altEvalC2.weights['c'], closeTo(0.137288, 1e-4));
      expect(altEvalC2.cr, closeTo(0.015808, 1e-4));

      // 4. Alternative under C3 (Delivery)
      final altEvalC3 = detailed.alternativeEvaluations['c3']!;
      expect(altEvalC3.weights['a'], closeTo(0.428571, 1e-4));
      expect(altEvalC3.weights['b'], closeTo(0.428571, 1e-4));
      expect(altEvalC3.weights['c'], closeTo(0.142857, 1e-4));
      expect(altEvalC3.cr, closeTo(0.000000, 1e-4));

      // 5. Final Synthesized Scores
      expect(detailed.scores[0].id, 'a');
      expect(detailed.scores[0].value, closeTo(0.484043, 1e-4));
      expect(detailed.scores[1].id, 'b');
      expect(detailed.scores[1].value, closeTo(0.395938, 1e-4));
      expect(detailed.scores[2].id, 'c');
      expect(detailed.scores[2].value, closeTo(0.120019, 1e-4));
      expect(detailed.isConsistent, isTrue);

      // 6. JSON serialization check
      final json = detailed.toJson();
      expect(json['criteria_evaluation'], isA<Map>());
      expect(json['alternative_evaluations'], isA<Map>());
      expect(json['scores'], isA<List>());
      expect(json['is_consistent'], isTrue);
    });

    test('Case 2: Intermediate values for candidate selection', () {
      // Label: cross-checked (Python 3.9)
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
        PairwiseAlternativeInput(
          criteria: criteriaItems[1],
          alternative: [
            PairwiseComparisonInput(
              id: 'p2_j_m',
              left: altItems[0],
              right: altItems[1],
              preferenceValue: 2,
              isLeftMoreImportant: false,
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
              isLeftMoreImportant: false,
            ),
            PairwiseComparisonInput(
              id: 'p3_m_d',
              left: altItems[1],
              right: altItems[2],
              preferenceValue: 3,
              isLeftMoreImportant: false,
            ),
          ],
        ),
      ];

      final detailed = AhpCalculator.calculateDetailed(
        hierarchy: hierarchy,
        inputsCriteria: inputsCriteria,
        inputsAlternative: inputsAlternative,
      );

      // Criteria check
      expect(detailed.criteriaWeights['c1'], closeTo(0.557143, 1e-4));
      expect(detailed.criteriaWeights['c2'], closeTo(0.320238, 1e-4));
      expect(detailed.criteriaWeights['c3'], closeTo(0.122619, 1e-4));
      expect(detailed.criteriaEvaluation.cr, closeTo(0.015797, 1e-4));

      // Alternative checks
      expect(detailed.scoresPerCriteria['c1']!['john'], closeTo(0.647947, 1e-4));
      expect(detailed.scoresPerCriteria['c1']!['mary'], closeTo(0.229871, 1e-4));
      expect(detailed.scoresPerCriteria['c1']!['david'], closeTo(0.122182, 1e-4));

      expect(detailed.scoresPerCriteria['c2']!['john'], closeTo(0.297258, 1e-4));
      expect(detailed.scoresPerCriteria['c2']!['mary'], closeTo(0.538961, 1e-4));
      expect(detailed.scoresPerCriteria['c2']!['david'], closeTo(0.163781, 1e-4));

      expect(detailed.scoresPerCriteria['c3']!['john'], closeTo(0.297258, 1e-4));
      expect(detailed.scoresPerCriteria['c3']!['mary'], closeTo(0.163781, 1e-4));
      expect(detailed.scoresPerCriteria['c3']!['david'], closeTo(0.538961, 1e-4));

      // Final Scores check
      expect(detailed.scores[0].id, 'john');
      expect(detailed.scores[0].value, closeTo(0.492642, 1e-4));
      expect(detailed.scores[1].id, 'mary');
      expect(detailed.scores[1].value, closeTo(0.320750, 1e-4));
      expect(detailed.scores[2].id, 'david');
      expect(detailed.scores[2].value, closeTo(0.186609, 1e-4));
      expect(detailed.isConsistent, isTrue);
    });
  });
}
