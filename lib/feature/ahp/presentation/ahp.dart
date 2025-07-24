import 'dart:developer' as dev;

import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_local_datasource.dart';
import 'package:flutter_decision_making/feature/ahp/data/repository_impl/ahp_repository_impl.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_comparison_scale.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_consistency_ratio.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_hierarchy.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_identification.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_item.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_result.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_alternative_input.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_comparison_input.dart';
import 'package:flutter_decision_making/feature/ahp/domain/repository/ahp_repository.dart';
import 'package:flutter_decision_making/feature/ahp/domain/usecase/calculate_eigen_vector_alternative_usecase.dart';
import 'package:flutter_decision_making/feature/ahp/domain/usecase/calculate_eigen_vector_criteria_usecase.dart';
import 'package:flutter_decision_making/feature/ahp/domain/usecase/check_consistency_ratio_usecase.dart';
import 'package:flutter_decision_making/feature/ahp/domain/usecase/generate_hierarchy_usecase.dart';
import 'package:flutter_decision_making/feature/ahp/domain/usecase/generate_pairwise_alternative_input_usecase.dart';
import 'package:flutter_decision_making/feature/ahp/domain/usecase/generate_pairwise_criteria_input_usecase.dart';
import 'package:flutter_decision_making/feature/ahp/domain/usecase/generate_result_pairwise_matrix_alternative_usecase.dart';
import 'package:flutter_decision_making/feature/ahp/domain/usecase/generate_result_pairwise_matrix_criteria_usecase.dart';
import 'package:flutter_decision_making/feature/ahp/domain/usecase/get_final_score_usecase.dart';
import 'package:flutter_decision_making/feature/ahp/domain/usecase/identification_usecase.dart';

export '/feature/ahp/domain/entities/ahp_comparison_scale.dart';
export '/feature/ahp/domain/entities/ahp_item.dart';
export '/feature/ahp/domain/entities/ahp_result.dart';
export '/feature/ahp/domain/entities/ahp_result_detail.dart';
export '/feature/ahp/domain/entities/pairwise_alternative_input.dart';
export '/feature/ahp/domain/entities/pairwise_comparison_input.dart';

class AHP {
  final AhpRepository _ahpRepository;

  AHP({AhpRepository? ahpRepository})
      : _ahpRepository =
            ahpRepository ?? AhpRepositoryImpl(AhpLocalDatasourceImpl());

  AhpIdentification _currentAhpIdentification = AhpIdentification(
    criteria: [],
    alternative: [],
  );

  /// GENERATE HIERARCHY
  Future<List<AhpHierarchy>> generateHierarchy({
    required List<AhpItem> listCriteria,
    required List<AhpItem> listAlternative,
  }) async {
    final identificationUsecase = IdentificationUsecase(
      _ahpRepository,
    );
    final hierarchyUsecase = GenerateHierarchyUsecase(
      _ahpRepository,
    );

    final identification =
        await identificationUsecase.execute(listCriteria, listAlternative);

    final hierarchy = await hierarchyUsecase.execute(
        criteria: identification.criteria,
        alternative: identification.alternative);

    _currentAhpIdentification = identification;

    return hierarchy;
  }

  /// GENERATE PAIRWISE CRITERIA INPUT
  Future<List<PairwiseComparisonInput>> generateCriteriaInputs() async {
    if (_currentAhpIdentification.criteria.isEmpty) {
      throw Exception(
          'Please generate hierarchy first! need hierarchy nodes to generate criteria inputs');
    }

    final pairCriteriaUseacse =
        GeneratePairwiseCriteriaInputUsecase(_ahpRepository);

    final result =
        await pairCriteriaUseacse.execute(_currentAhpIdentification.criteria);

    return result;
  }

  /// GENERATE PAIRWISE ALTERNATIVE INPUTS
  Future<List<PairwiseAlternativeInput>> generateAlternativeInputs({
    required List<AhpHierarchy> hierarchyNodes,
  }) async {
    if (hierarchyNodes.isEmpty) {
      throw Exception(
          'Please generate hierarchy first! need hierarchy nodes to generate alternative inputs');
    }

    final pairAlternativeUsecase =
        GeneratePairwiseAlternativeInputUsecase(_ahpRepository);

    final result = await pairAlternativeUsecase.execute(hierarchyNodes);

    return result;
  }

  /// ************************* COMPARISON SCALE *******************************
  List<AhpComparisonScale> _listPairwiseComparisonScale() {
    final now = DateTime.now();
    final result = <AhpComparisonScale>[];

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
        AhpComparisonScale(
          id: '${now.microsecondsSinceEpoch}_$i',
          description: desc[i],
          value: i + 1,
        ),
      );
    }

    return result;
  }

  /// LIST PAIRWISE COMPARISON SCALE
  List<AhpComparisonScale> get listPairwiseComparisonScale =>
      _listPairwiseComparisonScale();

  /// ************ UPDATE CRITERIA OR ALTERNATIVE FROM USER INPUT **************

  /// UPDATE PAIRWISE CRITERIA INPUT
  List<PairwiseComparisonInput> updateCriteriaInputs(
    List<PairwiseComparisonInput> currentCriteriaInputs, {
    required String? id,
    required int scale,
    required bool isLeftMoreImportant,
  }) {
    return currentCriteriaInputs.map((e) {
      if (e.id == id) {
        return e.copyWith(
          preferenceValue: scale,
          isLeftMoreImportant: isLeftMoreImportant,
        );
      }

      return e;
    }).toList();
  }

  /// UPDATE ALTERNATIVE VALUE
  List<PairwiseAlternativeInput> updateAlternativeInputs(
    List<PairwiseAlternativeInput> currentAlternativeInputs, {
    required String id,
    required String alternativeId,
    required int scale,
    required bool isLeftMoreImportant,
  }) {
    return currentAlternativeInputs.map((e) {
      if (e.criteria.id == id) {
        final updatedAlternatives = e.alternative.map((alt) {
          if (alt.id == alternativeId) {
            return alt.copyWith(
              preferenceValue: scale,
              isLeftMoreImportant: isLeftMoreImportant,
            );
          }
          return alt;
        }).toList();

        return e.copyWith(alternative: updatedAlternatives);
      }
      return e;
    }).toList();
  }

  /// ******************************* RESULT **********************************

  /// CALCULATE PAIRWISE MATRIX, EIGENVECTOR, CONSISTENCY RATIO, OUTPUTS AHP RESULT
  Future<AhpResult> generateResult({
    required List<AhpHierarchy> hierarchy,
    required List<PairwiseComparisonInput> inputsCriteria,
    required List<PairwiseAlternativeInput> inputsAlternative,
  }) async {
    if (inputsCriteria.any((e) => e.preferenceValue == null)) {
      throw Exception("Please complete all values from the criteria scale");
    }

    if (inputsCriteria.any((e) => e.isLeftMoreImportant == null)) {
      throw Exception("Please complete which more important from the criteria");
    }

    if (inputsAlternative
        .any((e) => e.alternative.any((d) => d.preferenceValue == null))) {
      throw Exception("Please complete all values from the alternative scale");
    }

    if (inputsAlternative
        .any((e) => e.alternative.any((d) => d.isLeftMoreImportant == null))) {
      throw Exception(
          "Please complete which more important from the alternative");
    }

    final matrixCriteriaUsecase =
        GenerateResultPairwiseMatrixCriteriaUsecase(_ahpRepository);

    final matrixAlternativeUsecase =
        GenerateResultPairwiseMatrixAlternativeUsecase(_ahpRepository);

    final eigenVectorCriteriaUsecase =
        CalculateEigenVectorCriteriaUsecase(_ahpRepository);

    final eigenVectorAlternativeUsecase =
        CalculateEigenVectorAlternativeUsecase(_ahpRepository);

    final ratioUsecase = CheckConsistencyRatioUsecase(_ahpRepository);

    final getFinalScoreUsecase = GetFinalScoreUsecase(_ahpRepository);

    /// Step 1: Matrix & Eigen Vector for Criteria
    final resultMatrixCriteria = await matrixCriteriaUsecase.execute(
      hierarchy.map((e) => e.criteria).toList(),
      inputsCriteria,
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
    final alternativeConsistencyRatio = <AhpConsistencyRatio>[];

    for (final input in inputsAlternative) {
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
      hierarchy.expand((e) => e.alternative).toList(),
      resultCriteriaRatio,
      alternativeConsistencyRatio,
    );

    dev.log(
        '✅ final score ${finalScore.results.map((e) => '${e.name}: ${e.value}').join(', ')}');

    return finalScore;
  }
}
