import 'package:decision_making_core/decision_making_core.dart';
import 'package:flutter_decision_making/feature/saw/data/datasource/saw_local_datasource_impl.dart';
import 'saw_utils.dart';

export 'saw_utils.dart';

class SAW {
  final SawRepository _sawRepository;

  SAW() : _sawRepository = SawRepositoryImpl(SawLocalDatasourceImpl());

  /// GENERATE SAW MATRIX
  Future<List<WeightedDecisionMatrix>> generateSawMatrix({
    required List<WeightedDecisionAlternative> listAlternative,
    required List<WeightedDecisionCriteria> listCriteria,
    bool useIsolate = false,
  }) async {
    try {
      final matrixUsecase = SawGenerateMatrixUsecase(_sawRepository);

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

  /// UPDATE SAW MATRIX
  Future<List<WeightedDecisionMatrix>> updateSawMatrix({
    required List<WeightedDecisionMatrix> currentMatrix,
    required String? matrixId,
    required String? ratingsId,
    required double value,
  }) async {
    var updatedList = List<WeightedDecisionMatrix>.from(currentMatrix);

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

    return updatedList;
  }

  /// CALCULATE SAW RESULT
  Future<List<WeightedDecisionResult>> getSawResult({
    required List<WeightedDecisionMatrix> matrix,
    bool useIsolate = false,
  }) async {
    try {
      final usecase = SawCalculateResultUsecase(_sawRepository);

      final result = await usecase.execute(
        matrix: matrix,
        useIsolate: useIsolate,
      );

      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// CALCULATE RESULT WITH EXISTING MATRIX
  Future<List<WeightedDecisionResult>> getResultWithExistingMatrix({
    required List<WeightedDecisionMatrix> sawMatrix,
    bool useIsolate = false,
  }) async {
    try {
      final usecase =
          SawCalculateResultWithExistingMatrixUsecase(_sawRepository);

      final result = await usecase.execute(
        sawMatrix: sawMatrix,
        useIsolate: useIsolate,
      );

      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// CALCULATE DETAILED SAW RESULT
  ///
  /// Returns a [SawDetailedResult] containing all intermediate computation steps:
  /// initial matrix, normalized matrix (r_ij), normalized weights (w_j),
  /// weighted matrix (v_ij), final scores, and ranks.
  Future<SawDetailedResult> getSawDetailedResult({
    required List<WeightedDecisionMatrix> matrix,
  }) async {
    return SawCalculator.calculateDetailed(matrix);
  }

  /// ANALYZE WEIGHT SENSITIVITY & RANK REVERSAL
  ///
  /// Evaluates systematic +/- [delta] perturbations on each criterion and
  /// tests rank reversal upon alternative removals. Runs synchronously without isolate overhead.
  Future<SensitivityAnalysisResult> analyzeSensitivity({
    required List<WeightedDecisionMatrix> matrix,
    double delta = 0.1,
  }) async {
    return SawCalculator.analyzeSensitivity(matrix, delta: delta);
  }

  /// CALCULATE SHANNON ENTROPY OBJECTIVE WEIGHTS
  ///
  /// Computes objective criteria weights (`w_j` summing to 1.0) and intermediate
  /// values (`p_ij`, `e_j`, `d_j`) using the Shannon Entropy method.
  Future<EntropyWeightResult> calculateEntropyWeights({
    required List<WeightedDecisionMatrix> matrix,
  }) async {
    return ObjectiveWeightCalculator.calculateEntropy(matrix);
  }

  /// CALCULATE CRITIC OBJECTIVE WEIGHTS
  ///
  /// Computes objective criteria weights (`w_j` summing to 1.0) and intermediate
  /// values (`r_ij`, `sigma_j`, `R`, `C_j`) using the CRITIC method.
  Future<CriticWeightResult> calculateCriticWeights({
    required List<WeightedDecisionMatrix> matrix,
  }) async {
    return ObjectiveWeightCalculator.calculateCritic(matrix);
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

  /// APPLY OBJECTIVE WEIGHTS TO SAW MATRIX
  ///
  /// Sets `weightPercent = w_j * 100` on all criteria inside [matrix] so it can
  /// be passed directly to [getResultWithExistingMatrix] or [getSawDetailedResult].
  List<WeightedDecisionMatrix> applyObjectiveWeightsToMatrix({
    required List<WeightedDecisionMatrix> matrix,
    required Map<String, double> weights,
  }) {
    return ObjectiveWeightCalculator.applyWeightsToMatrix(matrix, weights);
  }
}
