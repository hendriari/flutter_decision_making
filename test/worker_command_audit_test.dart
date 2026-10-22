import 'package:flutter_decision_making/core/decision_making_enums.dart';
import 'package:flutter_decision_making/core/isolate/decision_isolate_main.dart';
import 'package:flutter_decision_making/core/shared/interface/generate_weighted_decision_matrix_isolate.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_calculate_eigen_vector_alternative_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_calculate_eigen_vector_criteria_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_check_consistency_ratio_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_final_score_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_input_pairwise_matrix_alternative_with_compute.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_result_pairwise_matrix_alternative_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_result_pairwise_matrix_criteria_isolated.dart';
import 'package:flutter_decision_making/feature/saw/data/datasource/normalize_saw_matrix_isolate.dart';
import 'package:flutter_decision_making/feature/topsis/data/datasource/normalize_euclidean_matrix_isolate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DecisionIsolateMain isolate;

  setUp(() {
    DecisionIsolateMain.resetInstance();
    isolate = DecisionIsolateMain();
  });

  tearDown(() {
    DecisionIsolateMain.resetInstance();
  });

  group('Worker Routing Audit Tests: AHP Commands', () {
    test(
        'AhpProcessingIsolateCommand.generateInputPairwiseAlternative matches direct function',
        () async {
      final payload = {
        'data': [
          {
            'criteria': {'id': 'c1', 'name': 'Crit 1'},
            'alternative': [
              {'id': 'a1', 'name': 'Alt 1'},
              {'id': 'a2', 'name': 'Alt 2'},
            ],
          }
        ]
      };

      final direct = await generateInputPairwiseAlternative(payload);
      final worker = await isolate.runTask(
        DecisionAlgorithm.ahp,
        AhpProcessingIsolateCommand.generateInputPairwiseAlternative,
        payload,
      );

      final directList = direct as List;
      final workerList = worker as List;
      expect(workerList.length, equals(directList.length));
      expect(workerList[0]['criteria'], equals(directList[0]['criteria']));
      final directAlts = directList[0]['alternative'] as List;
      final workerAlts = workerList[0]['alternative'] as List;
      expect(workerAlts.length, equals(directAlts.length));
      expect(workerAlts[0]['left'], equals(directAlts[0]['left']));
      expect(workerAlts[0]['right'], equals(directAlts[0]['right']));
      expect(workerAlts[0]['preference_value'],
          equals(directAlts[0]['preference_value']));
      expect(workerAlts[0]['is_left_more_important'],
          equals(directAlts[0]['is_left_more_important']));
    });

    test(
        'AhpProcessingIsolateCommand.generateResultPairwiseMatrixCriteria matches direct function',
        () async {
      final payload = {
        'items': [
          {'id': 'c1', 'name': 'Cost'},
          {'id': 'c2', 'name': 'Quality'},
        ],
        'inputs': [
          {
            'id': 'p1',
            'left': {'id': 'c1', 'name': 'Cost'},
            'right': {'id': 'c2', 'name': 'Quality'},
            'preferenceValue': 3,
            'isLeftMoreImportant': true,
          }
        ]
      };

      final direct = await ahpGenerateResultPairwiseMatrixCriteria(payload);
      final worker = await isolate.runTask(
        DecisionAlgorithm.ahp,
        AhpProcessingIsolateCommand.generateResultPairwiseMatrixCriteria,
        payload,
      );

      expect(worker, equals(direct));
    });

    test(
        'AhpProcessingIsolateCommand.generateResultPairwiseMatrixAlternative matches direct function',
        () async {
      final payload = {
        'items': [
          {'id': 'a1', 'name': 'Alt 1'},
          {'id': 'a2', 'name': 'Alt 2'},
        ],
        'inputs': [
          {
            'criteria': {'id': 'c1', 'name': 'Cost'},
            'alternative': [
              {
                'id': 'pa1',
                'left': {'id': 'a1', 'name': 'Alt 1'},
                'right': {'id': 'a2', 'name': 'Alt 2'},
                'preferenceValue': 2,
                'isLeftMoreImportant': true,
              }
            ]
          }
        ]
      };

      final direct = await ahpGenerateResultPairwiseMatrixAlternative(payload);
      final worker = await isolate.runTask(
        DecisionAlgorithm.ahp,
        AhpProcessingIsolateCommand.generateResultPairwiseMatrixAlternative,
        payload,
      );

      expect(worker, equals(direct));
    });

    test(
        'AhpProcessingIsolateCommand.calculateEigenVectorCriteria matches direct function',
        () async {
      final payload = {
        'matrix': [
          [1.0, 3.0],
          [1.0 / 3.0, 1.0],
        ]
      };

      final direct = await ahpCalculateEigenVectorCriteria(payload);
      final worker = await isolate.runTask(
        DecisionAlgorithm.ahp,
        AhpProcessingIsolateCommand.calculateEigenVectorCriteria,
        payload,
      );

      expect(worker.length, direct.length);
      for (int i = 0; i < direct.length; i++) {
        expect(worker[i], closeTo(direct[i], 1e-6));
      }
    });

    test(
        'AhpProcessingIsolateCommand.calculateEigenVectorAlternative matches direct function',
        () async {
      final payload = {
        'matrix': [
          [1.0, 2.0],
          [0.5, 1.0],
        ]
      };

      final direct = await ahpCalculateEigenVectorAlternative(payload);
      final worker = await isolate.runTask(
        DecisionAlgorithm.ahp,
        AhpProcessingIsolateCommand.calculateEigenVectorAlternative,
        payload,
      );

      expect(worker.length, direct.length);
      for (int i = 0; i < direct.length; i++) {
        expect(worker[i], closeTo(direct[i], 1e-6));
      }
    });

    test(
        'AhpProcessingIsolateCommand.checkConsistencyRatio matches direct function',
        () async {
      final payload = {
        'matrix': [
          [1.0, 3.0],
          [1.0 / 3.0, 1.0],
        ],
        'priority_vector': [0.75, 0.25],
        'source': 'criteria',
      };

      final direct = await ahpCheckConsistencyRatio(payload);
      final worker = await isolate.runTask(
        DecisionAlgorithm.ahp,
        AhpProcessingIsolateCommand.checkConsistencyRatio,
        payload,
      );

      expect(worker['ratio'], closeTo(direct['ratio'], 1e-6));
      expect(worker['is_consistent'], equals(direct['is_consistent']));
      expect(worker['lambda_max'], closeTo(direct['lambda_max'], 1e-6));
    });

    test(
        'AhpProcessingIsolateCommand.calculateFinalScore matches direct function',
        () async {
      final payload = {
        'eigen_vector_criteria': [0.6, 0.4],
        'eigen_vector_alternative': [
          [0.7, 0.3],
          [0.5, 0.5],
        ],
        'alternative_raw': [
          {'id': 'a1', 'name': 'Alt 1'},
          {'id': 'a2', 'name': 'Alt 2'},
        ],
        'consistency_criteria_raw': {
          'source': 'criteria',
          'ratio': 0.01,
          'is_consistent': true
        },
        'consistency_alternative_raw': [
          {'source': 'c1', 'ratio': 0.01, 'is_consistent': true},
          {'source': 'c2', 'ratio': 0.01, 'is_consistent': true},
        ],
      };

      final direct = await ahpFinalScore(payload);
      final worker = await isolate.runTask(
        DecisionAlgorithm.ahp,
        AhpProcessingIsolateCommand.calculateFinalScore,
        payload,
      );

      expect(worker['is_consistent_criteria'],
          equals(direct['is_consistent_criteria']));
      final directResults = direct['results'] as List;
      final workerResults = worker['results'] as List;
      expect(workerResults.length, directResults.length);
      for (int i = 0; i < directResults.length; i++) {
        expect(workerResults[i]['id'], equals(directResults[i]['id']));
        expect(workerResults[i]['value'],
            closeTo(directResults[i]['value'], 1e-6));
      }
    });
  });

  group('Worker Routing Audit Tests: SAW Commands', () {
    test('SawProcessingIsolateCommand.generateMatrix matches direct function',
        () async {
      final payload = {
        'list_criteria': [
          {
            'id': 'c1',
            'name': 'C1',
            'weight_percent': 50.0,
            'is_benefit': true,
            'max_value': 100.0
          },
          {
            'id': 'c2',
            'name': 'C2',
            'weight_percent': 50.0,
            'is_benefit': true,
            'max_value': 100.0
          },
        ],
        'list_alternative': [
          {'id': 'a1', 'name': 'A1'},
          {'id': 'a2', 'name': 'A2'},
        ],
      };

      final direct = await generateWeightedDecisionMatrixIsolate(data: payload);
      final worker = await isolate.runTask(
        DecisionAlgorithm.saw,
        SawProcessingIsolateCommand.generateMatrix,
        payload,
      );

      expect((worker as List).length, (direct as List).length);
      for (int i = 0; i < direct.length; i++) {
        expect(worker[i]['alternative']['id'],
            equals(direct[i]['alternative']['id']));
        final directRatings = direct[i]['ratings'] as List;
        final workerRatings = worker[i]['ratings'] as List;
        expect(workerRatings.length, directRatings.length);
        for (int j = 0; j < directRatings.length; j++) {
          expect(workerRatings[j]['criteria']['id'],
              equals(directRatings[j]['criteria']['id']));
          expect(workerRatings[j]['value'], equals(directRatings[j]['value']));
        }
      }
    });

    test('SawProcessingIsolateCommand.normalizeMatrix matches direct function',
        () async {
      final payload = {
        'matrix': [
          {
            'id': 'm1',
            'alternative': {'id': 'a1', 'name': 'A1'},
            'ratings': [
              {
                'id': 'r1',
                'criteria': {
                  'id': 'c1',
                  'name': 'C1',
                  'weight_percent': 50.0,
                  'is_benefit': true,
                  'max_value': 100.0
                },
                'value': 80.0,
              },
              {
                'id': 'r2',
                'criteria': {
                  'id': 'c2',
                  'name': 'C2',
                  'weight_percent': 50.0,
                  'is_benefit': false,
                  'max_value': 100.0
                },
                'value': 40.0,
              },
            ],
          },
          {
            'id': 'm2',
            'alternative': {'id': 'a2', 'name': 'A2'},
            'ratings': [
              {
                'id': 'r3',
                'criteria': {
                  'id': 'c1',
                  'name': 'C1',
                  'weight_percent': 50.0,
                  'is_benefit': true,
                  'max_value': 100.0
                },
                'value': 60.0,
              },
              {
                'id': 'r4',
                'criteria': {
                  'id': 'c2',
                  'name': 'C2',
                  'weight_percent': 50.0,
                  'is_benefit': false,
                  'max_value': 100.0
                },
                'value': 20.0,
              },
            ],
          },
        ]
      };

      final direct = await normalizeWeightedMatrixIsolate(data: payload);
      final worker = await isolate.runTask(
        DecisionAlgorithm.saw,
        SawProcessingIsolateCommand.normalizeMatrix,
        payload,
      );

      final directList = direct as List;
      final workerList = worker as List;
      expect(workerList.length, directList.length);
      for (int i = 0; i < directList.length; i++) {
        final dRatings = directList[i]['ratings'] as List;
        final wRatings = workerList[i]['ratings'] as List;
        for (int j = 0; j < dRatings.length; j++) {
          expect(wRatings[j]['value'], closeTo(dRatings[j]['value'], 1e-6));
        }
      }
    });
  });

  group('Worker Routing Audit Tests: TOPSIS Commands', () {
    test(
        'TopsisProcessingIsolateCommand.generateMatrix matches direct function',
        () async {
      final payload = {
        'list_criteria': [
          {
            'id': 'c1',
            'name': 'C1',
            'weight_percent': 50.0,
            'is_benefit': true,
            'max_value': 100.0
          },
        ],
        'list_alternative': [
          {'id': 'a1', 'name': 'A1'},
        ],
      };

      final direct = await generateWeightedDecisionMatrixIsolate(data: payload);
      final worker = await isolate.runTask(
        DecisionAlgorithm.topsis,
        TopsisProcessingIsolateCommand.generateMatrix,
        payload,
      );

      expect((worker as List).length, (direct as List).length);
    });

    test(
        'TopsisProcessingIsolateCommand.normalizeEuclidean matches normalizeEuclideanMatrixIsolate',
        () async {
      final payload = {
        'criteria': [
          {
            'id': 'c1',
            'name': 'C1',
            'weight_percent': 50.0,
            'is_benefit': true,
            'max_value': 10.0
          },
          {
            'id': 'c2',
            'name': 'C2',
            'weight_percent': 50.0,
            'is_benefit': false,
            'max_value': 10.0
          },
        ],
        'matrix': [
          {
            'id': 'm1',
            'alternative': {'id': 'a1', 'name': 'A1'},
            'ratings': [
              {
                'id': 'r1',
                'criteria': {
                  'id': 'c1',
                  'name': 'C1',
                  'weight_percent': 50.0,
                  'is_benefit': true,
                  'max_value': 10.0
                },
                'value': 4.0,
              },
              {
                'id': 'r2',
                'criteria': {
                  'id': 'c2',
                  'name': 'C2',
                  'weight_percent': 50.0,
                  'is_benefit': false,
                  'max_value': 10.0
                },
                'value': 3.0,
              },
            ],
          },
          {
            'id': 'm2',
            'alternative': {'id': 'a2', 'name': 'A2'},
            'ratings': [
              {
                'id': 'r3',
                'criteria': {
                  'id': 'c1',
                  'name': 'C1',
                  'weight_percent': 50.0,
                  'is_benefit': true,
                  'max_value': 10.0
                },
                'value': 3.0,
              },
              {
                'id': 'r4',
                'criteria': {
                  'id': 'c2',
                  'name': 'C2',
                  'weight_percent': 50.0,
                  'is_benefit': false,
                  'max_value': 10.0
                },
                'value': 4.0,
              },
            ],
          },
        ],
      };

      final direct = await normalizeEuclideanMatrixIsolate(data: payload);
      final worker = await isolate.runTask(
        DecisionAlgorithm.topsis,
        TopsisProcessingIsolateCommand.normalizeEuclidean,
        payload,
      );

      final directList = direct as List;
      final workerList = worker as List;
      expect(workerList.length, directList.length);
      for (int i = 0; i < directList.length; i++) {
        final dRatings = directList[i]['ratings'] as List;
        final wRatings = workerList[i]['ratings'] as List;
        for (int j = 0; j < dRatings.length; j++) {
          expect(wRatings[j]['value'], closeTo(dRatings[j]['value'], 1e-6));
        }
      }
    });
  });
}
