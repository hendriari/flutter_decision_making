import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_calculate_eigen_vector_alternative_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_calculate_eigen_vector_criteria_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_check_consistency_ratio_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_final_score_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_local_datasource.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_result_pairwise_matrix_alternative_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_result_pairwise_matrix_criteria_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/mapper/ahp_item_mapper.dart';
import 'package:flutter_decision_making/feature/ahp/data/mapper/pairwise_comparison_alternative_input_mapper.dart';
import 'package:flutter_decision_making/feature/ahp/data/repository_impl/ahp_repository_impl.dart';
import 'package:flutter_decision_making/flutter_decision_making.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AhpRepositoryImpl repo;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    repo = AhpRepositoryImpl(AhpLocalDatasourceImpl());
  });

  group('identification', () {
    test('assigns unique IDs if null or empty and validates uniqueness',
        () async {
      final criteria = <AhpItem>[
        AhpItem(id: null, name: 'C1'),
        AhpItem(id: '', name: 'C2'),
      ];
      final alternatives = <AhpItem>[
        AhpItem(id: null, name: 'A1'),
        AhpItem(id: '', name: 'A2'),
      ];

      final result = await repo.identification(criteria, alternatives);

      expect(result.criteria.every((c) => c.id != null && c.id!.isNotEmpty),
          isTrue);
      expect(result.alternative.every((a) => a.id != null && a.id!.isNotEmpty),
          isTrue);

      final criteriaIds = result.criteria.map((c) => c.id!).toSet();
      final alternativeIds = result.alternative.map((a) => a.id!).toSet();

      expect(criteriaIds.length, result.criteria.length);
      expect(alternativeIds.length, result.alternative.length);
    });

    test('throws if criteria empty', () async {
      await expectLater(
        repo.identification([], [AhpItem(id: 'a1', name: 'A1')]),
        throwsException,
      );
    });

    test('throws if alternative empty', () async {
      await expectLater(
        repo.identification([AhpItem(id: 'c1', name: 'C1')], []),
        throwsException,
      );
    });
  });

  group('generateHierarchy', () {
    test('generates hierarchy with correct mapping', () async {
      final criteria = [
        AhpItem(id: 'c1', name: 'C1'),
        AhpItem(id: 'c2', name: 'C2'),
      ];
      final alternatives = [
        AhpItem(id: 'a1', name: 'A1'),
        AhpItem(id: 'a2', name: 'A2'),
      ];

      final result = await repo.generateHierarchy(criteria, alternatives);
      expect(result.length, criteria.length);
      expect(result[0].criteria, criteria[0]);
      expect(result[0].alternative, alternatives);
    });
  });

  group('generatePairwiseCriteria', () {
    test('generates all pairwise comparisons', () async {
      final criteria = [
        AhpItem(id: 'c1', name: 'C1'),
        AhpItem(id: 'c2', name: 'C2'),
        AhpItem(id: 'c3', name: 'C3'),
      ];

      final result = await repo.generatePairwiseCriteria(criteria);
      final expectedCount = criteria.length * (criteria.length - 1) ~/ 2;
      expect(result.length, expectedCount);
      final ids = result.map((p) => p.id).toSet();
      expect(ids.length, result.length);
      expect(result.every((p) => p.id!.isNotEmpty), isTrue);
    });
  });

  group('generateResultPairwiseMatrixCriteria', () {
    test('creates proper pairwise matrix', () async {
      final criteria = [
        {'id': 'c1', 'name': 'C1'},
        {'id': 'c2', 'name': 'C2'},
      ];

      final inputs = [
        {
          'id': 'p1',
          'left': criteria[0],
          'right': criteria[1],
          'preference_value': 3,
          'is_left_more_important': true,
        },
      ];

      final matrix = await ahpGenerateResultPairwiseMatrixCriteria({
        'items': criteria,
        'inputs': inputs,
      });

      expect(matrix.length, criteria.length);
      expect(matrix[0][1], 3.0);
      expect(matrix[1][0], closeTo(1 / 3, 1e-6));
      expect(matrix[0][0], 1.0);
      expect(matrix[1][1], 1.0);
    });

    test('throws if items not found', () async {
      final criteria = [
        {'id': 'c1', 'name': 'C1'},
      ];

      final inputs = [
        {
          'id': 'p1',
          'left': {'id': 'c2', 'name': 'C2'},
          'right': {'id': 'c3', 'name': 'C3'},
          'preference_value': 2,
          'is_left_more_important': true,
        },
      ];

      expect(
          () => ahpGenerateResultPairwiseMatrixCriteria({
                'items': criteria,
                'inputs': inputs,
              }),
          throwsException);
    });

    test('throws if preference value <= 0', () async {
      final criteria = [
        {'id': 'c1', 'name': 'C1'},
        {'id': 'c2', 'name': 'C2'},
      ];

      final inputs = [
        {
          'id': 'p1',
          'left': criteria[0],
          'right': criteria[0],
          'preference_value': 0,
          'is_left_more_important': true,
        },
      ];

      expect(
          () => ahpGenerateResultPairwiseMatrixCriteria({
                'items': criteria,
                'inputs': inputs,
              }),
          throwsException);
    });
  });

  group('generateResultPairwiseMatrixAlternative', () {
    test('creates matrix for alternatives with inputs', () async {
      final alternatives = [
        AhpItem(id: 'a1', name: 'A1'),
        AhpItem(id: 'a2', name: 'A2'),
      ];

      final criteria = AhpItem(name: 'A');

      final pairwiseInputs = [
        PairwiseComparisonInput(
          left: alternatives[0],
          right: alternatives[1],
          preferenceValue: 4,
          isLeftMoreImportant: true,
          id: 'p1',
        )
      ];

      final inputs = [
        PairwiseAlternativeInput(
            alternative: pairwiseInputs, criteria: criteria)
      ];

      final itemAlternative = inputs[0]
          .alternative
          .expand((e) => [e.left, e.right])
          .toSet()
          .toList(growable: false);

      final altItemList = itemAlternative
          .map((e) => AhpItemMapper.fromEntity(e).toMap())
          .toList(growable: false);

      final altInputs =
          PairwiseAlternativeInputMapper.fromEntity(inputs[0]).toMap();

      final matrix = await ahpGenerateResultPairwiseMatrixAlternative({
        "items": altItemList,
        "inputs": [altInputs],
      });

      expect(matrix.length, alternatives.length);
      expect(matrix[0][1], 4.0);
      expect(matrix[1][0], closeTo(1 / 4, 1e-6));
    });

    test('returns identity matrix if inputs empty', () async {
      final alternatives = [
        AhpItem(id: 'a1', name: 'A1'),
        AhpItem(id: 'a2', name: 'A2'),
      ];

      final altItemList = alternatives
          .map((e) => AhpItemMapper.fromEntity(e).toMap())
          .toList(growable: false);

      final result = await ahpGenerateResultPairwiseMatrixAlternative({
        "items": altItemList,
        "inputs": [],
      });

      expect(result.length, alternatives.length);
      for (var row in result) {
        for (var val in row) {
          expect(val, 1.0);
        }
      }
    });

    test('throws if alternative not found', () async {
      final alternatives = [
        AhpItem(id: 'a1', name: 'A1'),
      ];

      final criteria = AhpItem(name: 'A');

      final pairwiseInputs = [
        PairwiseComparisonInput(
          left: AhpItem(id: 'a2', name: 'A2'),
          right: AhpItem(id: 'a3', name: 'A3'),
          preferenceValue: 2,
          isLeftMoreImportant: true,
          id: 'p1',
        )
      ];

      final inputs = [
        PairwiseAlternativeInput(
            alternative: pairwiseInputs, criteria: criteria)
      ];

      final altItemList = alternatives
          .map((e) => AhpItemMapper.fromEntity(e).toMap())
          .toList(growable: false);

      final altInputs =
          PairwiseAlternativeInputMapper.fromEntity(inputs[0]).toMap();

      expect(
          () => ahpGenerateResultPairwiseMatrixAlternative({
                "items": altItemList,
                "inputs": [altInputs],
              }),
          throwsException);
    });
  });

  group('calculateEigenVectorCriteria', () {
    test('calculates priority vector correctly', () async {
      final matrix = [
        [1.0, 2.0],
        [0.5, 1.0],
      ];

      final result = await ahpCalculateEigenVectorCriteria({
        'matrix': matrix,
      });

      expect(result.length, 2);
      expect(result[0] > 0 && result[1] > 0, isTrue);
      expect(
          (result[0] + result[1]) - 1.0 < 1e-5, isTrue); // priorities sum to ~1
    });

    test('throws on invalid input', () async {
      final matrix = [
        [1.0, 2.0],
        [0.5], // invalid row length
      ];

      expect(
          () => ahpCalculateEigenVectorCriteria({
                'matrix': matrix,
              }),
          throwsException);
    });
  });

  group('calculateEigenVectorAlternative', () {
    test('calculates priority vector alternative correctly', () async {
      final matrix = [
        [1.0, 3.0],
        [1 / 3, 1.0],
      ];

      final result = await ahpCalculateEigenVectorAlternative({
        'matrix': matrix,
      });

      expect(result.length, 2);
      expect(result[0] > 0 && result[1] > 0, isTrue);
      expect((result[0] + result[1]) - 1.0 < 1e-5, isTrue);
    });

    test('throws on non-square matrix', () async {
      final matrix = [
        [1.0, 2.0],
        [0.5],
      ];

      expect(
        () => ahpCalculateEigenVectorAlternative({
          'matrix': matrix,
        }),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Matrix must be square and non-empty'),
        )),
      );
    });
  });

  group('checkConsistencyRatio', () {
    test('calculates consistency ratio correctly', () async {
      final matrix = [
        [1.0, 2.0],
        [0.5, 1.0],
      ];

      final priorityVector = [0.6, 0.4];

      final cr = await ahpCheckConsistencyRatio({
        'matrix': matrix,
        'priority_vector': priorityVector,
        'source': 'criteria',
      });

      expect(cr['source'], 'criteria');
      expect(cr['ratio'] >= 0.0, isTrue);
      expect(cr['ratio'] <= 1.0, isTrue);
      expect(cr['is_consistent'], cr['ratio'] < 0.1);
    });
  });

  group('getFinalScore', () {
    test('calculates final score correctly and sets consistency flags and note',
        () async {
      final alternatives = [
        {'id': 'a1', 'name': 'Alternative 1'},
        {'id': 'a2', 'name': 'Alternative 2'},
      ];

      final eigenVectorCriteria = [0.6, 0.4];

      final eigenVectorsAlternative = [
        [0.7, 0.3],
        [0.4, 0.6],
      ];

      final consistencyCriteria = {
        'source': 'criteria',
        'ratio': 0.05,
        'is_consistent': true,
      };

      final consistencyAlternatives = [
        {
          'source': 'criteria1',
          'ratio': 0.05,
          'is_consistent': true,
        },
        {
          'source': 'criteria2',
          'ratio': 0.05,
          'is_consistent': true,
        },
      ];

      final result = await ahpFinalScore({
        "eigen_vector_criteria": eigenVectorCriteria,
        "eigen_vector_alternative": eigenVectorsAlternative,
        "alternative_raw": alternatives,
        "consistency_criteria_raw": consistencyCriteria,
        "consistency_alternative_raw": consistencyAlternatives,
      });

      // Result vector calculation:
      // alternative 1: 0.6*0.7 + 0.4*0.4 = 0.42 + 0.16 = 0.58
      // alternative 2: 0.6*0.3 + 0.4*0.6 = 0.18 + 0.24 = 0.42

      expect(result['results']?.length, 2);

      // Sorted descending by value, so first alternative should be a1 with 0.58
      expect(result['results']?[0]['id'], 'a1');
      expect(result['results']?[0]['value'], closeTo(0.58, 1e-6));

      expect(result['results']?[1]['id'], 'a2');
      expect(result['results']?[1]['value'], closeTo(0.42, 1e-6));

      expect(result['is_consistent_criteria'], true);
      expect(result['consistency_criteria_ratio'], 0.05);

      expect(result['is_consistent_alternative'], true);
      expect(result['consistency_alternative_ratio'], 0.05);

      expect(result['note'], isNull);
    });

    test('returns note if inconsistency detected', () async {
      final alternatives = [
        {'id': 'a1', 'name': 'Alternative 1'},
        {'id': 'a2', 'name': 'Alternative 2'},
      ];

      final eigenVectorCriteria = [0.5, 0.5];
      final eigenVectorsAlternative = [
        [0.5, 0.5],
        [0.5, 0.5],
      ];

      final consistencyCriteria = {
        'source': 'criteria',
        'ratio': 0.15,
        'is_consistent': false,
      };

      final consistencyAlternatives = [
        {
          'source': 'criteria1',
          'ratio': 0.05,
          'is_consistent': true,
        },
        {
          'source': 'criteria2',
          'ratio': 0.2,
          'is_consistent': false,
        },
      ];

      final result = await ahpFinalScore({
        "eigen_vector_criteria": eigenVectorCriteria,
        "eigen_vector_alternative": eigenVectorsAlternative,
        "alternative_raw": alternatives,
        "consistency_criteria_raw": consistencyCriteria,
        "consistency_alternative_raw": consistencyAlternatives,
      });

      expect(result['note'], isNotNull);
      expect(result['note'], contains('inconsistency on criteria'));
      expect(result['note'],
          contains('Inconsistency on alternatives per criteria'));
      expect(result['is_consistent_criteria'], false);

      expect(result['is_consistent_alternative'], false);
      expect(result['consistency_alternative_ratio'], 0.2);
    });

    test('throws exception on invalid input', () async {
      final alternatives = [
        {'id': 'a1', 'name': 'Alternative 1'},
      ];

      final eigenVectorCriteria = [1.0];
      final eigenVectorsAlternative = [
        <double>[],
      ];

      final consistencyCriteria = {
        'source': 'criteria',
        'ratio': 0.0,
        'is_consistent': true,
      };

      final consistencyAlternatives = [];

      expect(
        () => ahpFinalScore({
          "eigen_vector_criteria": eigenVectorCriteria,
          "eigen_vector_alternative": eigenVectorsAlternative,
          "alternative_raw": alternatives,
          "consistency_criteria_raw": consistencyCriteria,
          "consistency_alternative_raw": consistencyAlternatives,
        }),
        throwsException,
      );
    });
  });
}
