import 'dart:developer' as dev;

import 'package:flutter_decision_making/ahp/domain/entities/ahp_result.dart';
import 'package:flutter_decision_making/ahp/domain/entities/consistency_ratio.dart';
import 'package:flutter_decision_making/ahp/domain/entities/hierarchy.dart';
import 'package:flutter_decision_making/ahp/domain/entities/pairwise_alternative_input.dart';
import 'package:flutter_decision_making/ahp/domain/entities/pairwise_comparison_input.dart';
import 'package:flutter_decision_making/ahp/domain/entities/pairwise_comparison_scale.dart';
import 'package:flutter_decision_making/ahp/domain/repository/decision_making_repository.dart';
import 'package:flutter_decision_making/ahp/domain/usecase/calculate_eigen_vector_criteria_usecase.dart';
import 'package:flutter_decision_making/ahp/domain/usecase/check_consistency_ratio_usecase.dart';
import 'package:flutter_decision_making/ahp/domain/usecase/generate_hierarchy_usecase.dart';
import 'package:flutter_decision_making/ahp/domain/usecase/generate_pairwise_alternative_input_usecase.dart';
import 'package:flutter_decision_making/ahp/domain/usecase/generate_pairwise_criteria_input_usecase.dart';
import 'package:flutter_decision_making/ahp/domain/usecase/generate_result_pairwise_matrix_criteria_usecase.dart';
import 'package:flutter_decision_making/ahp/domain/usecase/get_final_score_usecase.dart';
import 'package:flutter_decision_making/ahp/domain/usecase/identification_usecase.dart';

import 'ahp/data/desicion_making_repository_impl.dart';
import 'ahp/domain/entities/alternative.dart';
import 'ahp/domain/entities/criteria.dart';
import 'ahp/domain/usecase/calculate_eigen_vector_alternative_usecase.dart';
import 'ahp/domain/usecase/generate_result_pairwise_matrix_alternative_usecase.dart';

export 'ahp/domain/entities/alternative.dart';
export 'ahp/domain/entities/criteria.dart';
export 'ahp/domain/entities/pairwise_alternative_input.dart';
export 'ahp/domain/entities/pairwise_comparison_input.dart';
export 'ahp/domain/entities/pairwise_comparison_scale.dart';

/// MAIN AHP PACKAGE CLASS
class FlutterDecisionMaking {
  final DecisionMakingRepository _decisionMakingRepository;

  FlutterDecisionMaking({DecisionMakingRepository? decisionRepository})
      : _decisionMakingRepository =
            decisionRepository ?? DecisionMakingRepositoryImpl();

  List<Hierarchy> _listHierarchy = [];

  /// HIERARCHY
  List<Hierarchy> get listHierarchy => _listHierarchy;

  List<PairwiseComparisonInput<Criteria>> _listPairwiseCriteriaInput = [];

  /// PAIRWISE CRITERIA
  List<PairwiseComparisonInput<Criteria>> get listPairwiseCriteriaInput =>
      _listPairwiseCriteriaInput;

  List<PairwiseAlternativeInput> _listPairwiseAlternativeInput = [];

  /// PAIRWISE ALTERNATIVE
  List<PairwiseAlternativeInput> get listPairwiseAlternativeInput =>
      _listPairwiseAlternativeInput;

  /// GENERATE HIERARCHY, PAIRWISE INPUT FOR CRITERIA AND ALTERNATIVE
  Future<void> generateHierarchyAndPairwiseTemplate({
    required List<Criteria> listCriteria,
    required List<Alternative> listAlternative,
  }) async {
    final identificationUsecase = IdentificationUsecase(
      _decisionMakingRepository,
    );
    final hierarchyUsecase = GenerateHierarchyUsecase(
      _decisionMakingRepository,
    );
    final pairCriteriaUseacse = GeneratePairwiseCriteriaInputUsecase(
      _decisionMakingRepository,
    );
    final pairAlternativeUsecase = GeneratePairwiseAlternativeInputUsecase();

    /// step 1: identification
    final identification = await identificationUsecase.execute(
      listCriteria,
      listAlternative,
    );

    /// step 2: generate hierarchy structure
    final hierarchy = await hierarchyUsecase.execute(
      criteria: identification.criteria,
      alternative: identification.alternative,
    );

    /// step 3: generate pairwise matrix input
    final pairCriteria = await pairCriteriaUseacse.execute(
      identification.criteria,
    );

    /// step 4: generate pairwise matrix input
    final pairAlternative = await pairAlternativeUsecase.execute(hierarchy);

    /// result
    _listHierarchy = hierarchy;
    _listPairwiseCriteriaInput = pairCriteria;
    _listPairwiseAlternativeInput = pairAlternative;
  }

  /// ************************* COMPARISON SCALE *******************************
  List<PairwiseComparisonScale> _listPairwiseComparisonScale() {
    final now = DateTime.now();
    final result = <PairwiseComparisonScale>[];

    /// you can custom this
    final desc = [
      "Equal importance of both elements",
      "Between equal and slightly more important",
      "Slightly more important",
      "Between slightly and moderately more important",
      "Moderately more important",
      "Between moderately and strongly more important",
      "Strongly more important",
      "Between strongly and extremely more important",
      "Extremely more important (absolute dominance)",
    ];

    for (int i = 0; i < desc.length; i++) {
      result.add(
        PairwiseComparisonScale(
          id: '${now.microsecondsSinceEpoch}_$i',
          description: desc[i],
          value: i + 1,
        ),
      );
    }

    return result;
  }

  /// LIST PAIRWISE COMPARISON SCALE
  List<PairwiseComparisonScale> get listPairwiseComparisonScale =>
      _listPairwiseComparisonScale();

  /// ************ UPDATE CRITERIA OR ALTERNATIVE FROM USER INPUT **************

  /// UPDATE PAIRWISE CRITERIA INPUT
  void updatePairwiseCriteriaValue({
    required String? id,
    required int scale,
    required bool isLeftMoreImportant,
  }) {
    if (_listPairwiseCriteriaInput.isEmpty) {
      throw ArgumentError("Can't update anything, criteria is empty");
    }

    final index = _listPairwiseCriteriaInput.indexWhere((e) => e.id == id);

    if (index == -1) {
      throw ArgumentError("Criteria not found");
    }

    dev.log("✔️ success update criteria preference value");
    _listPairwiseCriteriaInput[index] =
        _listPairwiseCriteriaInput[index].copyWith(
      preferenceValue: scale,
      isLeftMoreImportant: isLeftMoreImportant,
    );
  }

  /// UPDATE ALTERNATIVE VALUE
  void updatePairwiseAlternativeValue({
    required id,
    required alternativeId,
    required int scale,
    required bool isLeftMoreImportant,
  }) {
    if (_listPairwiseAlternativeInput.isEmpty) {
      throw ArgumentError("Can't update anything, alternative is empty");
    }

    final index = _listPairwiseAlternativeInput.indexWhere(
      (e) => e.criteria.id == id,
    );

    if (index == -1) {
      throw ArgumentError("Alternative not found");
    }

    final item = _listPairwiseAlternativeInput[index];

    final updateAlternative = item.alternative.map((e) {
      if (e.id == alternativeId) {
        return e.copyWith(
          preferenceValue: scale,
          isLeftMoreImportant: isLeftMoreImportant,
        );
      }
      return e;
    }).toList();

    dev.log("✔️ success update alternative preference value");
    _listPairwiseAlternativeInput[index] = item.copyWith(
      alternative: updateAlternative,
    );
  }

  /// ******************************* RESULT **********************************

  AhpResult? _ahpResult;

  /// AHP RESULT CALCULATE
  AhpResult? get ahpResult => _ahpResult;

  /// CALCULATE PAIRWISE MATRIX, EIGENVECTOR, CONSISTENCY RATIO, OUTPUTS AHP RESULT
  Future<void> generateResult() async {
    if (_listPairwiseCriteriaInput.any((e) => e.preferenceValue == null)) {
      throw ArgumentError("Please complete all values from the criteria scale");
    }

    if (_listPairwiseCriteriaInput.any((e) => e.isLeftMoreImportant == null)) {
      throw ArgumentError(
          "Please complete which more important from the criteria");
    }

    if (_listPairwiseAlternativeInput
        .any((e) => e.alternative.any((d) => d.preferenceValue == null))) {
      throw ArgumentError(
          "Please complete all values from the alternative scale");
    }

    if (_listPairwiseAlternativeInput
        .any((e) => e.alternative.any((d) => d.isLeftMoreImportant == null))) {
      throw ArgumentError(
          "Please complete which more important from the alternative");
    }

    final matrixCriteriaUsecase =
        GenerateResultPairwiseMatrixCriteriaUsecase(_decisionMakingRepository);

    final matrixAlternativeUsecase =
        GenerateResultPairwiseMatrixAlternativeUsecase(
            _decisionMakingRepository);

    final eigenVectorCriteriaUsecase =
        CalculateEigenVectorCriteriaUsecase(_decisionMakingRepository);

    final eigenVectorAlternativeUsecase =
        CalculateEigenVectorAlternativeUsecase(_decisionMakingRepository);

    final ratioUsecase =
        CheckConsistencyRatioUsecase(_decisionMakingRepository);

    final getFinalScoreUsecase =
        GetFinalScoreUsecase(_decisionMakingRepository);

    /// Step 1: Matrix & Eigen Vector for Criteria
    final resultMatrixCriteria = await matrixCriteriaUsecase.execute(
      _listHierarchy.map((e) => e.criteria).toList(),
      _listPairwiseCriteriaInput,
    );
    dev.log('✅ matrix criteria $resultMatrixCriteria \n');

    final resultEigenVectorCriteria =
        await eigenVectorCriteriaUsecase.execute(resultMatrixCriteria);
    dev.log('✅ eigen vector criteria $resultEigenVectorCriteria \n');

    final resultCriteriaRatio = await ratioUsecase.execute(
        resultMatrixCriteria, resultEigenVectorCriteria, 'criteria');
    dev.log('✅ criteria ratio ${resultCriteriaRatio.ratio} \n');

    /// Step 2: Matrix & Eigen Vector for each Alternative per Criteria
    final allEigenVectorsAlternative = <List<double>>[];
    final allMatrixAlternatives = <List<List<double>>>[];
    final alternativeConsistencyRatio = <ConsistencyRatio>[];

    for (final input in _listPairwiseAlternativeInput) {
      final matrixAlt = await matrixAlternativeUsecase.execute(
        input.alternative.expand((e) => [e.left, e.right]).toSet().toList(),
        [input],
      );

      allMatrixAlternatives.add(matrixAlt);
      dev.log('✅ matrix alternative (${input.criteria.name}): $matrixAlt \n');

      final eigenAlt = await eigenVectorAlternativeUsecase.execute(matrixAlt);
      allEigenVectorsAlternative.add(eigenAlt);
      dev.log(
          '✅ eigen vector alternative (${input.criteria.name}): $eigenAlt \n');

      final ratioAlt = await ratioUsecase.execute(matrixAlt, eigenAlt,
          'alternative for criteria ${input.criteria.name}');
      dev.log(
          '✅ alternative ratio (${input.criteria.name}): ${ratioAlt.ratio} \n');
      alternativeConsistencyRatio.add(ratioAlt);
    }

    /// Step 3: Final score = eigen criteria .dot. eigen alternative per criteria
    final finalScore = await getFinalScoreUsecase.execute(
      resultEigenVectorCriteria,
      allEigenVectorsAlternative,
      _listHierarchy.expand((e) => e.alternative).toList(),
      resultCriteriaRatio,
      alternativeConsistencyRatio,
    );

    dev.log(
        '✅ final score ${finalScore.results.map((e) => '${e.name}: ${e.value}').join(', ')}');
    _ahpResult = finalScore;
  }

  /// Reset all internal data and results to initial state
  void reset() {
    _listPairwiseCriteriaInput.clear();
    _listPairwiseAlternativeInput.clear();
    _listHierarchy.clear();
    _ahpResult = null;
  }
}
