import 'package:flutter_decision_making/flutter_decision_making.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Test data for SAW and TOPSIS
  final criteria = [
    WeightedDecisionCriteria(
      id: 'c1',
      name: 'Cost',
      weightPercent: 40.0,
      isBenefit: false,
      maxValue: 100.0,
    ),
    WeightedDecisionCriteria(
      id: 'c2',
      name: 'Quality',
      weightPercent: 60.0,
      isBenefit: true,
      maxValue: 100.0,
    ),
  ];

  final alternatives = [
    WeightedDecisionAlternative(id: 'a1', name: 'Vendor A'),
    WeightedDecisionAlternative(id: 'a2', name: 'Vendor B'),
  ];

  final matrix = [
    WeightedDecisionMatrix(
      id: 'm1',
      alternative: alternatives[0],
      ratings: [
        WeightedDecisionRating(id: 'r1_1', criteria: criteria[0], value: 40.0),
        WeightedDecisionRating(id: 'r1_2', criteria: criteria[1], value: 80.0),
      ],
    ),
    WeightedDecisionMatrix(
      id: 'm2',
      alternative: alternatives[1],
      ratings: [
        WeightedDecisionRating(id: 'r2_1', criteria: criteria[0], value: 60.0),
        WeightedDecisionRating(id: 'r2_2', criteria: criteria[1], value: 90.0),
      ],
    ),
  ];

  final topsisRawMatrix = TopsisRawMatrix(
    criterias: criteria,
    matrixs: matrix,
  );

  // Test data for AHP
  final ahpCriteria = [
    AhpItem(id: 'ac1', name: 'Price'),
    AhpItem(id: 'ac2', name: 'Quality'),
  ];

  final ahpAlternatives = [
    AhpItem(id: 'aa1', name: 'Option 1'),
    AhpItem(id: 'aa2', name: 'Option 2'),
  ];

  final ahpHierarchy = [
    AhpHierarchy(criteria: ahpCriteria[0], alternative: ahpAlternatives),
    AhpHierarchy(criteria: ahpCriteria[1], alternative: ahpAlternatives),
  ];

  final ahpInputsCriteria = [
    PairwiseComparisonInput(
      id: 'pc1_2',
      left: ahpCriteria[0],
      right: ahpCriteria[1],
      preferenceValue: 2,
      isLeftMoreImportant: true,
    ),
  ];

  final ahpInputsAlternative = [
    PairwiseAlternativeInput(
      criteria: ahpCriteria[0],
      alternative: [
        PairwiseComparisonInput(
          id: 'pa0_1_2',
          left: ahpAlternatives[0],
          right: ahpAlternatives[1],
          preferenceValue: 3,
          isLeftMoreImportant: true,
        ),
      ],
    ),
    PairwiseAlternativeInput(
      criteria: ahpCriteria[1],
      alternative: [
        PairwiseComparisonInput(
          id: 'pa1_1_2',
          left: ahpAlternatives[0],
          right: ahpAlternatives[1],
          preferenceValue: 2,
          isLeftMoreImportant: false,
        ),
      ],
    ),
  ];

  group('Public API Barrel Access via FlutterDecisionMaking()', () {
    final fdm = FlutterDecisionMaking();

    test('SAW calculation via fdm.saw', () async {
      final List<WeightedDecisionResult> results =
          await fdm.saw.getSawResult(matrix: matrix);

      expect(results.length, 2);
      expect(results[0].rank, 1);
      expect(results[1].rank, 2);
    });

    test('SAW detailed calculation via fdm.saw returning SawDetailedResult',
        () async {
      final SawDetailedResult detailed =
          await fdm.saw.getSawDetailedResult(matrix: matrix);

      expect(detailed.initialMatrix.length, 2);
      expect(detailed.normalizedMatrix.length, 2);
      expect(detailed.normalizedWeights.length, 2);
      expect(detailed.weightedMatrix.length, 2);
      expect(detailed.scores.length, 2);
      expect(detailed.results.length, 2);
      expect(detailed.toJson(), isA<Map<String, dynamic>>());
    });

    test('TOPSIS calculation via fdm.topsis with TopsisRawMatrix', () async {
      final List<WeightedDecisionResult> results =
          await fdm.topsis.getTopsisResult(matrix: topsisRawMatrix);

      expect(results.length, 2);
      expect(results[0].rank, 1);
      expect(results[1].rank, 2);
    });

    test(
        'TOPSIS detailed calculation via fdm.topsis returning TopsisDetailedResult',
        () async {
      final TopsisDetailedResult detailed =
          await fdm.topsis.getTopsisDetailedResult(matrix: topsisRawMatrix);

      expect(detailed.initialMatrix.length, 2);
      expect(detailed.normalizedMatrix.length, 2);
      expect(detailed.normalizedWeights.length, 2);
      expect(detailed.weightedMatrix.length, 2);
      expect(detailed.positiveIdeal.length, 2);
      expect(detailed.negativeIdeal.length, 2);
      expect(detailed.separationPlus.length, 2);
      expect(detailed.separationMinus.length, 2);
      expect(detailed.scores.length, 2);
      expect(detailed.results.length, 2);
      expect(detailed.toJson(), isA<Map<String, dynamic>>());
    });

    test('AHP calculation via fdm.ahp', () async {
      final AhpResult result = await fdm.ahp.getAhpResult(
        hierarchy: ahpHierarchy,
        inputsCriteria: ahpInputsCriteria,
        inputsAlternative: ahpInputsAlternative,
      );

      expect(result.results, isNotNull);
      expect(result.results!.length, 2);
      expect(result.isConsistentCriteria, isTrue);
    });

    test('AHP detailed calculation via fdm.ahp returning AhpDetailedResult',
        () async {
      final AhpDetailedResult detailed = await fdm.ahp.getAhpDetailedResult(
        hierarchy: ahpHierarchy,
        inputsCriteria: ahpInputsCriteria,
        inputsAlternative: ahpInputsAlternative,
      );

      expect(detailed.criteriaEvaluation, isA<AhpMatrixEvaluation>());
      expect(detailed.criteriaEvaluation.comparisonMatrix.length, 2);
      expect(detailed.criteriaEvaluation.normalizedMatrix.length, 2);
      expect(detailed.criteriaEvaluation.weights.length, 2);
      expect(detailed.alternativeEvaluations.length, 2);
      expect(detailed.scoresPerCriteria.length, 2);
      expect(detailed.weightedScoresPerCriteria.length, 2);
      expect(detailed.scores.length, 2);
      expect(detailed.results.length, 2);
      expect(detailed.isConsistent, isTrue);
      expect(detailed.toJson(), isA<Map<String, dynamic>>());
    });

    test(
        'SAW sensitivity analysis via fdm.saw returning SensitivityAnalysisResult',
        () async {
      final SensitivityAnalysisResult sensitivity =
          await fdm.saw.analyzeSensitivity(matrix: matrix, delta: 0.1);

      expect(sensitivity.delta, 0.1);
      expect(sensitivity.baseRanking.length, 2);
      expect(sensitivity.sensitivityCases.isNotEmpty, isTrue);
      expect(sensitivity.rankReversalCases.isNotEmpty, isTrue);
      expect(sensitivity.toJson(), isA<Map<String, dynamic>>());
    });

    test(
        'TOPSIS sensitivity analysis via fdm.topsis returning SensitivityAnalysisResult',
        () async {
      final SensitivityAnalysisResult sensitivity = await fdm.topsis
          .analyzeSensitivity(matrix: topsisRawMatrix, delta: 0.1);

      expect(sensitivity.delta, 0.1);
      expect(sensitivity.baseRanking.length, 2);
      expect(sensitivity.sensitivityCases.isNotEmpty, isTrue);
      expect(sensitivity.rankReversalCases.isNotEmpty, isTrue);
      expect(sensitivity.toJson(), isA<Map<String, dynamic>>());
    });
  });

  group('Public API Barrel Access via Direct Class Constructors', () {
    test('SAW constructor directly accessible from barrel', () async {
      final SAW saw = SAW();
      final List<WeightedDecisionResult> results =
          await saw.getSawResult(matrix: matrix);

      expect(results.length, 2);
      expect(results[0].score, isNonZero);

      final SawDetailedResult detailed =
          await saw.getSawDetailedResult(matrix: matrix);
      expect(detailed.scores.length, 2);

      final SensitivityAnalysisResult sensitivity =
          await saw.analyzeSensitivity(matrix: matrix);
      expect(sensitivity.baseRanking.length, 2);
    });

    test('TOPSIS constructor directly accessible from barrel', () async {
      final TOPSIS topsis = TOPSIS();
      final List<WeightedDecisionResult> results =
          await topsis.getTopsisResult(matrix: topsisRawMatrix);

      expect(results.length, 2);
      expect(results[0].score, isNonZero);

      final TopsisDetailedResult detailed =
          await topsis.getTopsisDetailedResult(matrix: topsisRawMatrix);
      expect(detailed.scores.length, 2);

      final SensitivityAnalysisResult sensitivity =
          await topsis.analyzeSensitivity(matrix: topsisRawMatrix);
      expect(sensitivity.baseRanking.length, 2);
    });

    test('AHP constructor directly accessible from barrel', () async {
      final AHP ahp = AHP();
      final AhpResult result = await ahp.getAhpResult(
        hierarchy: ahpHierarchy,
        inputsCriteria: ahpInputsCriteria,
        inputsAlternative: ahpInputsAlternative,
      );

      expect(result.results, isNotNull);
      expect(result.results!.length, 2);

      final AhpDetailedResult detailed = await ahp.getAhpDetailedResult(
        hierarchy: ahpHierarchy,
        inputsCriteria: ahpInputsCriteria,
        inputsAlternative: ahpInputsAlternative,
      );
      expect(detailed.scores.length, 2);
    });
  });
}
