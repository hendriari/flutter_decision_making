import 'package:flutter_decision_making/core/decision_making_utils.dart';

export 'topsis_utils.dart';

import 'topsis_utils.dart';

class TOPSIS {
  final TopsisRepository _topsisRepository;

  TOPSIS()
      : _topsisRepository = TopsisRepositoryImpl(TopsisLocalDatasourceImpl());

  /// GENERATE TOPSIS MATRIX
  Future<TopsisRawMatrix> generateTopsisMatrix({
    required List<WeightedDecisionAlternative> listAlternative,
    required List<WeightedDecisionCriteria> listCriteria,
  }) async {
    try {
      final matrixUsecase = GenerateTopsisMatrixUsecase(_topsisRepository);

      final result = await matrixUsecase.execute(
        listAlternative: listAlternative,
        listCriteria: listCriteria,
      );

      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// UPDATE TOPSIS MATRIX
  Future<TopsisRawMatrix> updateTopsisMatrix({
    required TopsisRawMatrix currentRawMatrix,
    required String? matrixId,
    required String? ratingsId,
    required double value,
  }) async {
    var updatedList =
        List<WeightedDecisionMatrix>.from(currentRawMatrix.matrixs);

    final matrixIndex = updatedList.indexWhere((m) => m.id == matrixId);
    if (matrixIndex == -1) {
      throw Exception("Matrix not found!");
    }

    final matrix = updatedList[matrixIndex];

    final ratingIndex = matrix.ratings.indexWhere((r) => r.id == ratingsId);
    if (ratingIndex == -1) {
      throw Exception("Rating not found!");
    }

    var updatedRatings = List<WeightedDecisionRating>.from(matrix.ratings);
    updatedRatings[ratingIndex] =
        updatedRatings[ratingIndex].copyWith(value: value);

    updatedList[matrixIndex] = matrix.copyWith(ratings: updatedRatings);

    return currentRawMatrix.copyWith(matrixs: updatedList);
  }

  /// CALCULATE TOPSIS RESULT
  Future<List<WeightedDecisionResult>> getTopsisResult({
    required TopsisRawMatrix matrix,
  }) async {
    try {
      final usecase = CalculateTopsisResultUsecase(_topsisRepository);

      final result = await usecase.execute(rawMatrix: matrix);

      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// CALCULATE RESULT WITH EXISTING MATRIX
  Future<List<WeightedDecisionResult>> getTopsisResultWithExistingMatrix({
    required TopsisRawMatrix matrix,
  }) async {
    try {
      final usecase = CalculateTopsisResultUsecase(_topsisRepository);

      final result = await usecase.execute(rawMatrix: matrix);

      return result;
    } catch (e) {
      rethrow;
    }
  }
}
