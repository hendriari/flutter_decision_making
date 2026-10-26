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
      throw DecisionInputException("Matrix not found!");
    }

    final matrix = updatedList[matrixIndex];

    final ratingIndex = matrix.ratings.indexWhere((r) => r.id == ratingsId);
    if (ratingIndex == -1) {
      throw DecisionInputException("Rating not found!");
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
  /// initial matrix, normalized matrix (r_ij), normalized weights (w_j),
  /// weighted matrix (v_ij), positive/negative ideal solutions (A+, A-),
  /// separation measures (D+, D-), relative closeness scores (C_i), and ranks.
  Future<TopsisDetailedResult> getTopsisDetailedResult({
    required TopsisRawMatrix matrix,
  }) async {
    return TopsisCalculator.calculateDetailed(matrix);
  }

  /// ANALYZE WEIGHT SENSITIVITY & RANK REVERSAL
  ///
  /// Evaluates systematic +/- [delta] perturbations on each criterion and
  /// tests rank reversal upon alternative removals. Runs synchronously without isolate overhead.
  Future<SensitivityAnalysisResult> analyzeSensitivity({
    required TopsisRawMatrix matrix,
    double delta = 0.1,
  }) async {
    return TopsisCalculator.analyzeSensitivity(matrix, delta: delta);
  }

  /// CALCULATE SHANNON ENTROPY OBJECTIVE WEIGHTS
  ///
  /// Computes objective criteria weights (`w_j` summing to 1.0) and intermediate
  /// values (`p_ij`, `e_j`, `d_j`) using the Shannon Entropy method.
  Future<EntropyWeightResult> calculateEntropyWeights({
    required TopsisRawMatrix matrix,
  }) async {
    return ObjectiveWeightCalculator.calculateEntropy(matrix.matrixs);
  }

  /// CALCULATE CRITIC OBJECTIVE WEIGHTS
  ///
  /// Computes objective criteria weights (`w_j` summing to 1.0) and intermediate
  /// values (`r_ij`, `sigma_j`, `R`, `C_j`) using the CRITIC method.
  Future<CriticWeightResult> calculateCriticWeights({
    required TopsisRawMatrix matrix,
  }) async {
    return ObjectiveWeightCalculator.calculateCritic(matrix.matrixs);
  }

  /// APPLY OBJECTIVE WEIGHTS TO CRITERIA LIST
  ///
  /// Sets `weightPercent = w_j * 100` for each criterion while preserving
  /// its benefit/cost type and other attributes.
  List<WeightedDecisionCriteria> applyObjectiveWeightsToCriteria({
    required List<WeightedDecisionCriteria> listCriteria,
    required Map<String, double> weights,
  }) {
    return ObjectiveWeightCalculator.applyWeightsToCriteria(
      listCriteria,
      weights,
    );
  }

  /// APPLY OBJECTIVE WEIGHTS TO TOPSIS RAW MATRIX
  ///
  /// Sets `weightPercent = w_j * 100` on [matrix] so it can be passed directly
  /// to [getTopsisResultWithExistingMatrix] or [getTopsisDetailedResult].
  TopsisRawMatrix applyObjectiveWeightsToMatrix({
    required TopsisRawMatrix matrix,
    required Map<String, double> weights,
  }) {
    return ObjectiveWeightCalculator.applyWeightsToTopsisMatrix(
      matrix,
      weights,
    );
  }
}
