import 'package:flutter_decision_making/core/shared/entity/weighted_decision_alternative.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_criteria.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_matrix.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_rating.dart';
import 'package:flutter_decision_making/feature/topsis/data/datasource/topsis_local_datasource_impl.dart';
import 'package:flutter_decision_making/feature/topsis/data/repository_impl/topsis_repository_impl.dart';
import 'package:flutter_decision_making/feature/topsis/domain/entities/topsis_raw_matrix.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TopsisRepositoryImpl repo;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    repo = TopsisRepositoryImpl(TopsisLocalDatasourceImpl());
  });

  group('generateTopsisMatrix', () {
    final testAlternatives = [
      WeightedDecisionAlternative(id: 'alt1', name: 'Alternative 1'),
      WeightedDecisionAlternative(id: 'alt2', name: 'Alternative 2'),
    ];

    final testCriteria = [
      WeightedDecisionCriteria(
        id: 'crt1',
        name: 'Criteria 1',
        weightPercent: 50,
        isBenefit: true,
        maxValue: 100,
      ),
      WeightedDecisionCriteria(
        id: 'crt2',
        name: 'Criteria 2',
        weightPercent: 50,
        isBenefit: false,
        maxValue: 100,
      ),
    ];

    test('should successfully generate matrix with valid inputs', () async {
      // Act
      final result = await repo.generateTopsisMatrix(
        listAlternative: testAlternatives,
        listCriteria: testCriteria,
      );

      // Assert
      expect(result.matrixs, isNotEmpty);
      expect(result.matrixs.length, equals(testAlternatives.length));
      expect(result.matrixs.first.ratings.length, equals(testCriteria.length));
      expect(result.criterias, equals(testCriteria));
    });

    test('should throw exception when alternatives list is empty', () async {
      // Act & Assert
      expect(
        () => repo.generateTopsisMatrix(
          listAlternative: [],
          listCriteria: testCriteria,
        ),
        throwsException,
      );
    });

    test('should throw exception when criteria list is empty', () async {
      // Act & Assert
      expect(
        () => repo.generateTopsisMatrix(
          listAlternative: testAlternatives,
          listCriteria: [],
        ),
        throwsException,
      );
    });

    test('should throw exception when criteria weight is negative', () async {
      final invalidCriteria = [
        WeightedDecisionCriteria(
          id: 'crt1',
          name: 'Criteria 1',
          weightPercent: -10,
          isBenefit: true,
          maxValue: 100,
        ),
      ];

      // Act & Assert
      expect(
        () => repo.generateTopsisMatrix(
          listAlternative: testAlternatives,
          listCriteria: invalidCriteria,
        ),
        throwsException,
      );
    });

    test('should throw exception when total weight is zero', () async {
      final zeroCriteria = [
        WeightedDecisionCriteria(
          id: 'crt1',
          name: 'Criteria 1',
          weightPercent: 0,
          isBenefit: true,
          maxValue: 100,
        ),
      ];

      // Act & Assert
      expect(
        () => repo.generateTopsisMatrix(
          listAlternative: testAlternatives,
          listCriteria: zeroCriteria,
        ),
        throwsException,
      );
    });

    test('should normalize criteria weights when total is not 100', () async {
      final unnormalizedCriteria = [
        WeightedDecisionCriteria(
          id: 'crt1',
          name: 'Criteria 1',
          weightPercent: 30,
          isBenefit: true,
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          id: 'crt2',
          name: 'Criteria 2',
          weightPercent: 20,
          isBenefit: false,
          maxValue: 100,
        ),
      ];

      // Act
      final result = await repo.generateTopsisMatrix(
        listAlternative: testAlternatives,
        listCriteria: unnormalizedCriteria,
      );

      // Assert
      final totalWeight = result.matrixs.first.ratings.fold<double>(
        0,
        (sum, rating) => sum + (rating.criteria?.weightPercent ?? 0),
      );
      expect(totalWeight, closeTo(100, 0.01));
    });

    test('should assign IDs to alternatives without IDs', () async {
      final alternativesWithoutIds = [
        WeightedDecisionAlternative(name: 'Alternative 1'),
        WeightedDecisionAlternative(name: 'Alternative 2'),
      ];

      // Act
      final result = await repo.generateTopsisMatrix(
        listAlternative: alternativesWithoutIds,
        listCriteria: testCriteria,
      );

      // Assert
      for (var matrix in result.matrixs) {
        expect(matrix.alternative.id, isNotNull);
        expect(matrix.alternative.id, isNotEmpty);
      }
    });

    test('should assign IDs to criteria without IDs', () async {
      final criteriaWithoutIds = [
        WeightedDecisionCriteria(
          name: 'Criteria 1',
          weightPercent: 50,
          isBenefit: true,
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          name: 'Criteria 2',
          weightPercent: 50,
          isBenefit: false,
          maxValue: 100,
        ),
      ];

      // Act
      final result = await repo.generateTopsisMatrix(
        listAlternative: testAlternatives,
        listCriteria: criteriaWithoutIds,
      );

      // Assert
      for (var matrix in result.matrixs) {
        for (var rating in matrix.ratings) {
          expect(rating.criteria?.id, isNotNull);
          expect(rating.criteria?.id, isNotEmpty);
        }
      }
    });
  });

  group('calculateResult', () {
    final testCriteria = [
      WeightedDecisionCriteria(
        id: 'crt1',
        name: 'Criteria 1',
        weightPercent: 60,
        isBenefit: true,
        maxValue: 100,
      ),
      WeightedDecisionCriteria(
        id: 'crt2',
        name: 'Criteria 2',
        weightPercent: 40,
        isBenefit: false,
        maxValue: 100,
      ),
    ];

    final testMatrix = [
      WeightedDecisionMatrix(
        id: 'matrix1',
        alternative:
            WeightedDecisionAlternative(id: 'alt1', name: 'Alternative 1'),
        ratings: [
          WeightedDecisionRating(
            id: 'rating1',
            criteria: testCriteria[0],
            value: 100,
          ),
          WeightedDecisionRating(
            id: 'rating2',
            criteria: testCriteria[1],
            value: 50,
          ),
        ],
      ),
      WeightedDecisionMatrix(
        id: 'matrix2',
        alternative:
            WeightedDecisionAlternative(id: 'alt2', name: 'Alternative 2'),
        ratings: [
          WeightedDecisionRating(
            id: 'rating3',
            criteria: testCriteria[0],
            value: 80,
          ),
          WeightedDecisionRating(
            id: 'rating4',
            criteria: testCriteria[1],
            value: 60,
          ),
        ],
      ),
    ];

    final rawMatrix = TopsisRawMatrix(
      criterias: testCriteria,
      matrixs: testMatrix,
    );

    test('should successfully calculate TOPSIS result', () async {
      // Act
      final result = await repo.calculateResult(rawMatrix: rawMatrix);

      // Assert
      expect(result, isNotEmpty);
      expect(result.length, equals(testMatrix.length));
      expect(result.first.rank, equals(1));
      expect(result.first.alternative.id, equals('alt1'));
      expect(result.last.rank, equals(2));
    });

    test('should sort results by score in descending order', () async {
      // Act
      final result = await repo.calculateResult(rawMatrix: rawMatrix);

      // Assert
      for (int i = 0; i < result.length - 1; i++) {
        expect(result[i].score, greaterThanOrEqualTo(result[i + 1].score));
      }
    });

    test('should handle equal values and not throw division by zero', () async {
      final equalValueMatrix = [
        WeightedDecisionMatrix(
          id: 'matrix1',
          alternative:
              WeightedDecisionAlternative(id: 'alt1', name: 'Alternative 1'),
          ratings: [
            WeightedDecisionRating(
              id: 'rating1',
              criteria: testCriteria[0],
              value: 50,
            ),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'matrix2',
          alternative:
              WeightedDecisionAlternative(id: 'alt2', name: 'Alternative 2'),
          ratings: [
            WeightedDecisionRating(
              id: 'rating2',
              criteria: testCriteria[0],
              value: 50,
            ),
          ],
        ),
      ];

      final equalRawMatrix = TopsisRawMatrix(
        criterias: [testCriteria[0]],
        matrixs: equalValueMatrix,
      );

      // Act
      final result = await repo.calculateResult(rawMatrix: equalRawMatrix);

      // Assert
      expect(result, isNotEmpty);
      expect(result.first.score, equals(result.last.score));
    });
  });

  group('calculateResultWithExistingMatrix', () {
    final testCriteria = [
      WeightedDecisionCriteria(
        id: 'crt1',
        name: 'Criteria 1',
        weightPercent: 100,
        isBenefit: true,
        maxValue: 100,
      ),
    ];

    final testMatrix = [
      WeightedDecisionMatrix(
        id: 'matrix1',
        alternative:
            WeightedDecisionAlternative(id: 'alt1', name: 'Alternative 1'),
        ratings: [
          WeightedDecisionRating(
            id: 'rating1',
            criteria: testCriteria[0],
            value: 100,
          ),
        ],
      ),
    ];

    final rawMatrix = TopsisRawMatrix(
      criterias: testCriteria,
      matrixs: testMatrix,
    );

    test('should calculate result with valid existing matrix', () async {
      // Act
      final result = await repo.calculateResultWithExistingMatrix(
        rawMatrix: rawMatrix,
      );

      // Assert
      expect(result, isNotEmpty);
      expect(result.first.alternative.id, equals('alt1'));
    });

    test('should assign missing IDs in matrix', () async {
      final matrixWithoutIds = [
        WeightedDecisionMatrix(
          alternative: WeightedDecisionAlternative(name: 'Alternative 1'),
          ratings: [
            WeightedDecisionRating(
              criteria: WeightedDecisionCriteria(
                name: 'Criteria 1',
                weightPercent: 100,
                isBenefit: true,
                maxValue: 100,
              ),
              value: 100,
            ),
          ],
        ),
      ];

      final rawMatrixWithoutIds = TopsisRawMatrix(
        criterias: [matrixWithoutIds.first.ratings.first.criteria!],
        matrixs: matrixWithoutIds,
      );

      // Act
      final result = await repo.calculateResultWithExistingMatrix(
        rawMatrix: rawMatrixWithoutIds,
      );

      // Assert
      expect(result, isNotEmpty);
    });

    test('should throw exception when value exceeds maxValue', () async {
      final invalidMatrix = [
        WeightedDecisionMatrix(
          id: 'matrix1',
          alternative:
              WeightedDecisionAlternative(id: 'alt1', name: 'Alternative 1'),
          ratings: [
            WeightedDecisionRating(
              id: 'rating1',
              criteria: WeightedDecisionCriteria(
                id: 'crt1',
                name: 'Criteria 1',
                weightPercent: 100,
                isBenefit: true,
                maxValue: 100,
              ),
              value: 150, // Exceeds 100
            ),
          ],
        ),
      ];

      final invalidRawMatrix = TopsisRawMatrix(
        criterias: [invalidMatrix.first.ratings.first.criteria!],
        matrixs: invalidMatrix,
      );

      // Act & Assert
      expect(
        () =>
            repo.calculateResultWithExistingMatrix(rawMatrix: invalidRawMatrix),
        throwsException,
      );
    });
  });
}
