import 'package:decision_making_core/decision_making_core.dart';
import 'package:flutter_decision_making/feature/topsis/domain/usecase/calculate_topsis_result_with_existing_matrix_usecase.dart';

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
    bool useIsolate = false,
  }) async {
    try {
      final matrixUsecase = GenerateTopsisMatrixUsecase(_topsisRepository);

      final result = await matrixUsecase.execute(
        listAlternative: listAlternative,
        listCriteria: listCriteria,
        useIsolate: useIsolate,
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
    bool useIsolate = false,
  }) async {
    try {
      final usecase = CalculateTopsisResultUsecase(_topsisRepository);

      final result = await usecase.execute(
        rawMatrix: matrix,
        useIsolate: useIsolate,
      );

      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// CALCULATE RESULT WITH EXISTING MATRIX
  Future<List<WeightedDecisionResult>> getTopsisResultWithExistingMatrix({
    required TopsisRawMatrix matrix,
    bool useIsolate = false,
  }) async {
    try {
      final usecase =
          CalculateTopsisResultWithExistingMatrixUsecase(_topsisRepository);

      final result = await usecase.execute(
        rawMatrix: matrix,
        useIsolate: useIsolate,
      );

      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// CALCULATE DETAILED TOPSIS RESULT
  ///
  /// Returns a [TopsisDetailedResult] containing all intermediate computation steps:
  /// initial matrix, normalized matrix ($r_{ij}$), normalized weights ($w_j$),
  /// weighted matrix ($v_{ij}$), positive/negative ideal solutions ($A^+$, $A^-$),
  /// separation measures ($D^+$, $D^-$), relative closeness scores ($C_i$), and ranks.
  Future<TopsisDetailedResult> getTopsisDetailedResult({
    required TopsisRawMatrix matrix,
  }) async {
    return TopsisCalculator.calculateDetailed(matrix);
  }
}
