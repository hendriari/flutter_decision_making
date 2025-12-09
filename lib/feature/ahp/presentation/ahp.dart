import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_local_datasource.dart';
import 'package:flutter_decision_making/feature/ahp/data/repository_impl/ahp_repository_impl.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_comparison_scale.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_hierarchy.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_identification.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_item.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_result.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_alternative_input.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_comparison_input.dart';
import 'package:flutter_decision_making/feature/ahp/domain/repository/ahp_repository.dart';
import 'package:flutter_decision_making/feature/ahp/domain/usecase/ahp_calculate_final_score_usecase.dart';
import 'package:flutter_decision_making/feature/ahp/domain/usecase/ahp_generate_hierarchy_usecase.dart';
import 'package:flutter_decision_making/feature/ahp/domain/usecase/ahp_generate_pairwise_alternative_input_usecase.dart';
import 'package:flutter_decision_making/feature/ahp/domain/usecase/ahp_generate_pairwise_criteria_input_usecase.dart';
import 'package:flutter_decision_making/feature/ahp/domain/usecase/ahp_identification_usecase.dart';

export '/feature/ahp/domain/entities/ahp_comparison_scale.dart';
export '/feature/ahp/domain/entities/ahp_hierarchy.dart';
export '/feature/ahp/domain/entities/ahp_item.dart';
export '/feature/ahp/domain/entities/ahp_result.dart';
export '/feature/ahp/domain/entities/ahp_result_detail.dart';
export '/feature/ahp/domain/entities/pairwise_alternative_input.dart';
export '/feature/ahp/domain/entities/pairwise_comparison_input.dart';

class AHP {
  static final AHP _instance = AHP._internal();

  factory AHP() => _instance;

  AHP._internal()
      : _ahpRepository = AhpRepositoryImpl(AhpLocalDatasourceImpl());

  final AhpRepository _ahpRepository;

  AhpIdentification _currentAhpIdentification = AhpIdentification(
    criteria: [],
    alternative: [],
  );

  /// GENERATE HIERARCHY
  Future<List<AhpHierarchy>> generateHierarchy({
    required List<AhpItem> listCriteria,
    required List<AhpItem> listAlternative,
  }) async {
    try {
      if (listCriteria.isEmpty) {
        throw Exception("Criteria can't be empty!");
      }

      if (listAlternative.isEmpty) {
        throw Exception("Alternative can't be empty!");
      }

      final identificationUsecase = AhpIdentificationUsecase(
        _ahpRepository,
      );
      final hierarchyUsecase = AhpGenerateHierarchyUsecase(
        _ahpRepository,
      );

      final identification =
          await identificationUsecase.execute(listCriteria, listAlternative);

      final hierarchy = await hierarchyUsecase.execute(
          criteria: identification.criteria,
          alternative: identification.alternative);

      _currentAhpIdentification = identification;

      return hierarchy;
    } catch (e) {
      rethrow;
    }
  }

  /// GENERATE PAIRWISE CRITERIA INPUT
  Future<List<PairwiseComparisonInput>> generateCriteriaInputs() async {
    if (_currentAhpIdentification.criteria.isEmpty) {
      throw Exception(
          'Please generate hierarchy first! need hierarchy nodes to generate criteria inputs');
    }

    final pairCriteriaUseacse =
        AhpGeneratePairwiseCriteriaInputUsecase(_ahpRepository);

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
        AhpGeneratePairwiseAlternativeInputUsecase(_ahpRepository);

    final result = await pairAlternativeUsecase.execute(hierarchyNodes);

    return result;
  }

  /// ************************* COMPARISON SCALE *******************************
  List<AhpComparisonScale> _listAhpPairwiseComparisonScale() {
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
  List<AhpComparisonScale> get listAhpPairwiseComparisonScale =>
      _listAhpPairwiseComparisonScale();

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
    required String? criteriaId,
    required String? alternativeId,
    required int scale,
    required bool isLeftMoreImportant,
  }) {
    return currentAlternativeInputs.map((e) {
      if (e.criteria.id == criteriaId) {
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
  /// AHP RESULT
  Future<AhpResult> getAhpResult({
    required List<AhpHierarchy> hierarchy,
    required List<PairwiseComparisonInput> inputsCriteria,
    required List<PairwiseAlternativeInput> inputsAlternative,
  }) async {
    final resultUsecase = AhpCalculateFinalScore(_ahpRepository);

    final result = await resultUsecase.execute(
      hierarchy: hierarchy,
      inputsCriteria: inputsCriteria,
      inputsAlternative: inputsAlternative,
    );

    return result;
  }
}
