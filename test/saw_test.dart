import 'package:flutter_decision_making/feature/saw/data/datasource/saw_local_datasource.dart';
import 'package:flutter_decision_making/feature/saw/data/repository_impl/saw_repository_impl.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_alternative.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_criteria.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_matrix.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_rating.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SawRepositoryImpl repo;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    repo = SawRepositoryImpl(SawLocalDatasourceImpl());
  });

  group('generateSawMatrix', () {
    final testAlternatives = [
      SawAlternative(id: 'alt1', name: 'Alternative 1'),
      SawAlternative(id: 'alt2', name: 'Alternative 2'),
    ];

    final testCriteria = [
      SawCriteria(
        id: 'crt1',
        name: 'Criteria 1',
        weightPercent: 50,
        isBenefit: true,
        maxValue: 100,
      ),
      SawCriteria(
        id: 'crt2',
        name: 'Criteria 2',
        weightPercent: 50,
        isBenefit: false,
        maxValue: 100,
      ),
    ];

    test('should successfully generate matrix with valid inputs', () async {
      // Act
      final result = await repo.generateSawMatrix(
        listAlternative: testAlternatives,
        listCriteria: testCriteria,
      );

      // Assert
      expect(result, isNotEmpty);
      expect(result.length, equals(testAlternatives.length));
      expect(result.first.ratings.length, equals(testCriteria.length));
    });

    test('should throw exception when alternatives list is empty', () async {
      // Act & Assert
      expect(
        () => repo.generateSawMatrix(
          listAlternative: [],
          listCriteria: testCriteria,
        ),
        throwsException,
      );
    });

    test('should throw exception when criteria list is empty', () async {
      // Act & Assert
      expect(
        () => repo.generateSawMatrix(
          listAlternative: testAlternatives,
          listCriteria: [],
        ),
        throwsException,
      );
    });

    test('should throw exception when criteria weight is negative', () async {
      final invalidCriteria = [
        SawCriteria(
          id: 'crt1',
          name: 'Criteria 1',
          weightPercent: -10,
          isBenefit: true,
          maxValue: 100,
        ),
      ];

      // Act & Assert
      expect(
        () => repo.generateSawMatrix(
          listAlternative: testAlternatives,
          listCriteria: invalidCriteria,
        ),
        throwsException,
      );
    });

    test('should throw exception when total weight is zero', () async {
      final zeroCriteria = [
        SawCriteria(
          id: 'crt1',
          name: 'Criteria 1',
          weightPercent: 0,
          isBenefit: true,
          maxValue: 100,
        ),
      ];

      // Act & Assert
      expect(
        () => repo.generateSawMatrix(
          listAlternative: testAlternatives,
          listCriteria: zeroCriteria,
        ),
        throwsException,
      );
    });

    test('should normalize criteria weights when total is not 100', () async {
      final unnormalizedCriteria = [
        SawCriteria(
          id: 'crt1',
          name: 'Criteria 1',
          weightPercent: 30,
          isBenefit: true,
          maxValue: 100,
        ),
        SawCriteria(
          id: 'crt2',
          name: 'Criteria 2',
          weightPercent: 20,
          isBenefit: false,
          maxValue: 100,
        ),
      ];

      // Act
      final result = await repo.generateSawMatrix(
        listAlternative: testAlternatives,
        listCriteria: unnormalizedCriteria,
      );

      // Assert
      final totalWeight = result.first.ratings.fold<double>(
        0,
        (sum, rating) => sum + (rating.criteria?.weightPercent ?? 0),
      );
      expect(totalWeight, closeTo(100, 0.01));
    });

    test('should assign IDs to alternatives without IDs', () async {
      final alternativesWithoutIds = [
        SawAlternative(name: 'Alternative 1'),
        SawAlternative(name: 'Alternative 2'),
      ];

      // Act
      final result = await repo.generateSawMatrix(
        listAlternative: alternativesWithoutIds,
        listCriteria: testCriteria,
      );

      // Assert
      for (var matrix in result) {
        expect(matrix.alternative.id, isNotNull);
        expect(matrix.alternative.id, isNotEmpty);
      }
    });

    test('should assign IDs to criteria without IDs', () async {
      final criteriaWithoutIds = [
        SawCriteria(
          name: 'Criteria 1',
          weightPercent: 50,
          isBenefit: true,
          maxValue: 100,
        ),
        SawCriteria(
          name: 'Criteria 2',
          weightPercent: 50,
          isBenefit: false,
          maxValue: 100,
        ),
      ];

      // Act
      final result = await repo.generateSawMatrix(
        listAlternative: testAlternatives,
        listCriteria: criteriaWithoutIds,
      );

      // Assert
      for (var matrix in result) {
        for (var rating in matrix.ratings) {
          expect(rating.criteria?.id, isNotNull);
          expect(rating.criteria?.id, isNotEmpty);
        }
      }
    });
  });

  group('calculateSawResult', () {
    final testMatrix = [
      SawMatrix(
        id: 'matrix1',
        alternative: SawAlternative(id: 'alt1', name: 'Alternative 1'),
        ratings: [
          SawRating(
            id: 'rating1',
            criteria: SawCriteria(
              id: 'crt1',
              name: 'Criteria 1',
              weightPercent: 60,
              isBenefit: true,
              maxValue: 100,
            ),
            value: 100,
          ),
          SawRating(
            id: 'rating2',
            criteria: SawCriteria(
              id: 'crt2',
              name: 'Criteria 2',
              weightPercent: 40,
              isBenefit: false,
              maxValue: 100,
            ),
            value: 50,
          ),
        ],
      ),
      SawMatrix(
        id: 'matrix2',
        alternative: SawAlternative(id: 'alt2', name: 'Alternative 2'),
        ratings: [
          SawRating(
            id: 'rating3',
            criteria: SawCriteria(
              id: 'crt1',
              name: 'Criteria 1',
              weightPercent: 60,
              isBenefit: true,
              maxValue: 100,
            ),
            value: 80,
          ),
          SawRating(
            id: 'rating4',
            criteria: SawCriteria(
              id: 'crt2',
              name: 'Criteria 2',
              weightPercent: 40,
              isBenefit: false,
              maxValue: 100,
            ),
            value: 60,
          ),
        ],
      ),
    ];

    test('should successfully calculate SAW result', () async {
      // Act
      final result = await repo.calculateSawResult(matrix: testMatrix);

      // Assert
      expect(result, isNotEmpty);
      expect(result.length, equals(testMatrix.length));
      expect(result.first.rank, equals(1));
      expect(result.last.rank, equals(2));
    });

    test('should sort results by score in descending order', () async {
      // Act
      final result = await repo.calculateSawResult(matrix: testMatrix);

      // Assert
      for (int i = 0; i < result.length - 1; i++) {
        expect(result[i].score, greaterThanOrEqualTo(result[i + 1].score));
      }
    });

    test('should throw exception when matrix is empty', () async {
      // Act & Assert
      expect(
        () => repo.calculateSawResult(matrix: []),
        throwsException,
      );
    });

    test('should throw exception when cost criteria has zero value', () async {
      final invalidMatrix = [
        SawMatrix(
          id: 'matrix1',
          alternative: SawAlternative(id: 'alt1', name: 'Alternative 1'),
          ratings: [
            SawRating(
              id: 'rating1',
              criteria: SawCriteria(
                id: 'crt1',
                name: 'Criteria 1',
                weightPercent: 100,
                isBenefit: false,
                maxValue: 100,
              ),
              value: 0,
            ),
          ],
        ),
      ];

      // Act & Assert
      await expectLater(
        repo.calculateSawResult(matrix: invalidMatrix),
        throwsException,
      );
    });

    test('should handle equal min and max values', () async {
      final equalValueMatrix = [
        SawMatrix(
          id: 'matrix1',
          alternative: SawAlternative(id: 'alt1', name: 'Alternative 1'),
          ratings: [
            SawRating(
              id: 'rating1',
              criteria: SawCriteria(
                id: 'crt1',
                name: 'Criteria 1',
                weightPercent: 100,
                isBenefit: true,
                maxValue: 100,
              ),
              value: 50,
            ),
          ],
        ),
        SawMatrix(
          id: 'matrix2',
          alternative: SawAlternative(id: 'alt2', name: 'Alternative 2'),
          ratings: [
            SawRating(
              id: 'rating2',
              criteria: SawCriteria(
                id: 'crt1',
                name: 'Criteria 1',
                weightPercent: 100,
                isBenefit: true,
                maxValue: 100,
              ),
              value: 50,
            ),
          ],
        ),
      ];

      // Act
      final result = await repo.calculateSawResult(matrix: equalValueMatrix);

      // Assert
      expect(result, isNotEmpty);
      expect(result.first.score, equals(result.last.score));
    });
  });

  group('calculateResultWithExistingMatrix', () {
    test('should calculate result with valid existing matrix', () async {
      final testMatrix = [
        SawMatrix(
          id: 'matrix1',
          alternative: SawAlternative(id: 'alt1', name: 'Alternative 1'),
          ratings: [
            SawRating(
              id: 'rating1',
              criteria: SawCriteria(
                id: 'crt1',
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

      // Act
      final result = await repo.calculateResultWithExistingMatrix(
        sawMatrix: testMatrix,
      );

      // Assert
      expect(result, isNotEmpty);
      expect(result.first.alternative.id, equals('alt1'));
    });

    test('should throw exception when matrix is empty', () async {
      // Act & Assert
      expect(
        () => repo.calculateResultWithExistingMatrix(sawMatrix: []),
        throwsException,
      );
    });

    test('should assign missing IDs in matrix', () async {
      final matrixWithoutIds = [
        SawMatrix(
          alternative: SawAlternative(name: 'Alternative 1'),
          ratings: [
            SawRating(
              criteria: SawCriteria(
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

      // Act
      final result = await repo.calculateResultWithExistingMatrix(
        sawMatrix: matrixWithoutIds,
      );

      // Assert
      expect(result, isNotEmpty);
    });

    test('should normalize weights when total is not 100', () async {
      final unnormalizedMatrix = [
        SawMatrix(
          id: 'matrix1',
          alternative: SawAlternative(id: 'alt1', name: 'Alternative 1'),
          ratings: [
            SawRating(
              id: 'rating1',
              criteria: SawCriteria(
                id: 'crt1',
                name: 'Criteria 1',
                weightPercent: 30,
                isBenefit: true,
                maxValue: 100,
              ),
              value: 100,
            ),
            SawRating(
              id: 'rating2',
              criteria: SawCriteria(
                id: 'crt2',
                name: 'Criteria 2',
                weightPercent: 20,
                isBenefit: true,
                maxValue: 100,
              ),
              value: 80,
            ),
          ],
        ),
      ];

      // Act
      final result = await repo.calculateResultWithExistingMatrix(
        sawMatrix: unnormalizedMatrix,
      );

      // Assert
      expect(result, isNotEmpty);
    });

    test('should throw exception when total weight is zero', () async {
      final zeroWeightMatrix = [
        SawMatrix(
          id: 'matrix1',
          alternative: SawAlternative(id: 'alt1', name: 'Alternative 1'),
          ratings: [
            SawRating(
              id: 'rating1',
              criteria: SawCriteria(
                id: 'crt1',
                name: 'Criteria 1',
                weightPercent: 0,
                isBenefit: true,
                maxValue: 100,
              ),
              value: 100,
            ),
          ],
        ),
      ];

      // Act & Assert
      expect(
        () => repo.calculateResultWithExistingMatrix(
          sawMatrix: zeroWeightMatrix,
        ),
        throwsException,
      );
    });

    test('should throw exception when weight is negative', () async {
      final negativeWeightMatrix = [
        SawMatrix(
          id: 'matrix1',
          alternative: SawAlternative(id: 'alt1', name: 'Alternative 1'),
          ratings: [
            SawRating(
              id: 'rating1',
              criteria: SawCriteria(
                id: 'crt1',
                name: 'Criteria 1',
                weightPercent: -10,
                isBenefit: true,
                maxValue: 100,
              ),
              value: 100,
            ),
          ],
        ),
      ];

      // Act & Assert
      expect(
        () => repo.calculateResultWithExistingMatrix(
          sawMatrix: negativeWeightMatrix,
        ),
        throwsException,
      );
    });
  });

  group('Normalization', () {
    test('should normalize benefit criteria correctly', () async {
      final testMatrix = [
        SawMatrix(
          id: 'matrix1',
          alternative: SawAlternative(id: 'alt1', name: 'Alternative 1'),
          ratings: [
            SawRating(
              id: 'rating1',
              criteria: SawCriteria(
                id: 'crt1',
                name: 'Criteria 1',
                weightPercent: 100,
                isBenefit: true,
                maxValue: 100,
              ),
              value: 100,
            ),
          ],
        ),
        SawMatrix(
          id: 'matrix2',
          alternative: SawAlternative(id: 'alt2', name: 'Alternative 2'),
          ratings: [
            SawRating(
              id: 'rating2',
              criteria: SawCriteria(
                id: 'crt1',
                name: 'Criteria 1',
                weightPercent: 100,
                isBenefit: true,
                maxValue: 100,
              ),
              value: 50,
            ),
          ],
        ),
      ];

      // Act
      final result = await repo.calculateSawResult(matrix: testMatrix);

      // Assert
      expect(result, isNotEmpty);
      expect(result.first.score, greaterThan(result.last.score));
    });

    test('should normalize cost criteria correctly', () async {
      final testMatrix = [
        SawMatrix(
          id: 'matrix1',
          alternative: SawAlternative(id: 'alt1', name: 'Alternative 1'),
          ratings: [
            SawRating(
              id: 'rating1',
              criteria: SawCriteria(
                id: 'crt1',
                name: 'Criteria 1',
                weightPercent: 100,
                isBenefit: false,
                maxValue: 100,
              ),
              value: 50,
            ),
          ],
        ),
        SawMatrix(
          id: 'matrix2',
          alternative: SawAlternative(id: 'alt2', name: 'Alternative 2'),
          ratings: [
            SawRating(
              id: 'rating2',
              criteria: SawCriteria(
                id: 'crt1',
                name: 'Criteria 1',
                weightPercent: 100,
                isBenefit: false,
                maxValue: 100,
              ),
              value: 100,
            ),
          ],
        ),
      ];

      // Act
      final result = await repo.calculateSawResult(matrix: testMatrix);

      // Assert
      expect(result, isNotEmpty);
      expect(result.first.score, greaterThan(result.last.score));
    });
  });
}
