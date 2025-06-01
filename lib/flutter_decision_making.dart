import 'dart:developer' as dev;

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
export 'ahp/domain/entities/pairwise_comparison_input.dart';

class FlutterDecisionMaking {
  final DecisionMakingRepository _decisionMakingRepository;

  FlutterDecisionMaking({DecisionMakingRepository? decisionRepository})
      : _decisionMakingRepository =
            decisionRepository ?? DecisionMakingRepositoryImpl();

  /// HIERARCHY
  List<Hierarchy> _listHierarchy = [];

  List<Hierarchy> get listHierarchy => _listHierarchy;

  /// PAIRWISE CRITERIA
  List<PairwiseComparisonInput<Criteria>> _listPairwiseCriteriaInput = [];

  List<PairwiseComparisonInput<Criteria>> get listPairwiseCriteriaInput =>
      _listPairwiseCriteriaInput;

  /// PAIRWISE ALTERNATIVE
  List<PairwiseAlternativeInput> _listPairwiseAlternativeInput = [];

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

    final identification = await identificationUsecase.execute(
      listCriteria,
      listAlternative,
    );

    final hierarchy = await hierarchyUsecase.execute(
      criteria: identification.criteria,
      alternative: identification.alternative,
    );

    final pairCriteria = await pairCriteriaUseacse.execute(
      identification.criteria,
    );

    final pairAlternative = await pairAlternativeUsecase.execute(hierarchy);

    _listHierarchy = hierarchy;
    _listPairwiseCriteriaInput = pairCriteria;
    _listPairwiseAlternativeInput = pairAlternative;
  }

  /// ************************* COMPARISON SCALE *******************************
  List<PairwiseComparisonScale> _listPairwiseComparisonScale() {
    final now = DateTime.now();
    final result = <PairwiseComparisonScale>[];

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

  List<PairwiseComparisonScale> get listPairwiseComparisonScale =>
      _listPairwiseComparisonScale();

  /// ************ UPDATE CRITERIA OR ALTERNATIVE FROM USER INPUT **************

  /// UPDATE PAIRWISE CRITERIA INPUT
  void updatePairwiseCriteriaValue({
    required String? id,
    required PairwiseComparisonScale value,
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
        _listPairwiseCriteriaInput[index].copyWith(preferenceValue: value);
  }

  /// UPDATE ALTERNATIVE VALUE
  void updatePairwiseAlternativeValue({
    required id,
    required alternativeId,
    required PairwiseComparisonScale value,
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
        return e.copyWith(preferenceValue: value);
      }
      return e;
    }).toList();

    dev.log("✔️ success update alternative preference value");
    _listPairwiseAlternativeInput[index] = item.copyWith(
      alternative: updateAlternative,
    );
  }

  /// ******************************* RESULT **********************************

  Future<void> generateResult() async {
    if (_listPairwiseCriteriaInput
        .any((e) => e.preferenceValue?.value == null)) {
      throw ArgumentError("Please complete all values from the criteria scale");
    }

    if (_listPairwiseAlternativeInput.any(
        (e) => e.alternative.any((d) => d.preferenceValue?.value == null))) {
      throw ArgumentError(
          "Please complete all values from the alternative scale");
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

    final getFinalScore = GetFinalScoreUsecase(_decisionMakingRepository);

    /// --------------------------- CRITERIA -----------------------------------
    final resultMatrixCriteria = await matrixCriteriaUsecase.execute(
      _listHierarchy.map((e) => e.criteria).toList(),
      _listPairwiseCriteriaInput,
    );
    dev.log('✅ matrix criteria $resultMatrixCriteria \n');

    final resultVectorCriteria =
        await eigenVectorCriteriaUsecase.execute(resultMatrixCriteria);
    dev.log('✅ eigen vector criteria $resultVectorCriteria \n');

    final resultCriteriaRatio = await ratioUsecase.execute(
        resultMatrixCriteria, resultVectorCriteria, 'criteria');
    dev.log('✅ criteria ratio $resultCriteriaRatio \n');

    /// ------------------------- ALTERNATIVE ---------------------------------
    List<List<List<double>>> listMatrixAlternativePerCriteria = [];
    List<List<double>> listEigenVectorAlternativePerCriteria = [];

    for (int i = 0; i < _listHierarchy.length; i++) {
      final hierarchyItem = _listHierarchy[i];
      final alternatives = hierarchyItem.alternative;

      final pairwiseInputForCriteria = _listPairwiseAlternativeInput.firstWhere(
        (e) => e.criteria.id == hierarchyItem.criteria.id,
        orElse: () => throw Exception(
            'Pairwise alternative input for criteria ${hierarchyItem.criteria.id} not found'),
      );

      final matrixAlternative = await matrixAlternativeUsecase.execute(
        alternatives,
        [pairwiseInputForCriteria],
      );
      dev.log('✅ matrix alternative $matrixAlternative \n');

      listMatrixAlternativePerCriteria.add(matrixAlternative);

      final eigenVectorAlternative =
          await eigenVectorAlternativeUsecase.execute(matrixAlternative);
      dev.log('✅ eigen vector alternative $eigenVectorAlternative \n');

      listEigenVectorAlternativePerCriteria.add(eigenVectorAlternative);

      final ratio = await ratioUsecase.execute(
        matrixAlternative,
        eigenVectorAlternative,
        'alternative',
      );

      dev.log(
          '✅ alternative ratio for criteria ${hierarchyItem.criteria.name}: $ratio \n');
    }

    final finalScore = await getFinalScore.execute(
      resultVectorCriteria,
      listMatrixAlternativePerCriteria,
      listEigenVectorAlternativePerCriteria,
    );
    dev.log('✅ final score $finalScore \n');
  }
}
