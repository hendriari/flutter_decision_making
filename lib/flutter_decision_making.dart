import 'package:flutter_decision_making/ahp/domain/entities/hierarchy.dart';
import 'package:flutter_decision_making/ahp/domain/entities/pairwise_alternative_input.dart';
import 'package:flutter_decision_making/ahp/domain/entities/pairwise_comparison_matrix.dart';
import 'package:flutter_decision_making/ahp/domain/entities/pairwise_comparison_scale.dart';
import 'package:flutter_decision_making/ahp/domain/repository/decision_making_repository.dart';
import 'package:flutter_decision_making/ahp/domain/usecase/generate_hierarchy_usecase.dart';
import 'package:flutter_decision_making/ahp/domain/usecase/generate_pairwise_alternative_usecase.dart';
import 'package:flutter_decision_making/ahp/domain/usecase/generate_pairwise_criteria_usecase.dart';
import 'package:flutter_decision_making/ahp/domain/usecase/identification_usecase.dart';

import 'ahp/data/desicion_making_repository_impl.dart';
import 'ahp/domain/entities/alternative.dart';
import 'ahp/domain/entities/criteria.dart';

export 'ahp/domain/entities/alternative.dart';
export 'ahp/domain/entities/criteria.dart';
export 'ahp/domain/entities/pairwise_comparison_matrix.dart';

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
    final pairCriteriaUseacse = GeneratePairwiseCriteriaUsecase(
      _decisionMakingRepository,
    );
    final pairAlternativeUsecase = GeneratePairwiseAlternativeUsecase();

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

    _listPairwiseCriteriaInput[index] = _listPairwiseCriteriaInput[index]
        .copyWith(preferenceValue: value);
  }


  ///
  void updatePairwiseAlternativeValue({
    required criteriaId,
    required alternativeId,
    required PairwiseComparisonScale value,
  }) {
    if (_listPairwiseAlternativeInput.isEmpty) {
      throw ArgumentError("Can't update anything, alternative is empty");
    }

    final index = _listPairwiseAlternativeInput.indexWhere(
      (e) => e.criteria.id == criteriaId,
    );

    if (index == -1) {
      throw ArgumentError("Alternative not found");
    }

    final item = _listPairwiseAlternativeInput[index];

    final updateAlternative =
        item.alternative.map((e) {
          if (e.id == alternativeId) {
            return e.copyWith(preferenceValue: value);
          }
          return e;
        }).toList();

    _listPairwiseAlternativeInput[index] = item.copyWith(
      alternative: updateAlternative,
    );
  }
}
