import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter_decision_making/core/decision_making_enums.dart';
import 'package:flutter_decision_making/core/decision_making_helper.dart';
import 'package:flutter_decision_making/core/decision_making_performance_profiling.dart';
import 'package:flutter_decision_making/core/isolate/decision_isolate_main.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_calculate_eigen_vector_alternative_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_calculate_eigen_vector_criteria_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_check_consistency_ratio_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_final_score_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_input_pairwise_matrix_alternative_with_compute.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_result_pairwise_matrix_alternative_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_result_pairwise_matrix_criteria_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_result_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/pairwise_comparison_alternative_input_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/mapper/ahp_hierarchy_mapper.dart';
import 'package:flutter_decision_making/feature/ahp/data/mapper/ahp_item_mapper.dart';
import 'package:flutter_decision_making/feature/ahp/data/mapper/ahp_result_mapper.dart';
import 'package:flutter_decision_making/feature/ahp/data/mapper/pairwise_comparison_alternative_input_mapper.dart';
import 'package:flutter_decision_making/feature/ahp/data/mapper/pairwise_comparison_input_mapper.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_hierarchy.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_identification.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_item.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_result.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_alternative_input.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/pairwise_comparison_input.dart';

abstract class AhpLocalDatasource {
  /// TO IDENTIFICATION CRITERIA AND ALTERNATIVE
  Future<AhpIdentification> identification(
    List<AhpItem> criteria,
    List<AhpItem> alternative,
  );

  /// TO GENERATE HIERARCHY STRUCTURE
  Future<List<AhpHierarchy>> generateHierarchy(
    List<AhpItem> criteria,
    List<AhpItem> alternative,
  );

  /// TO GENERATE PAIRWISE INPUTS
  Future<List<PairwiseComparisonInput>> generatePairwiseCriteria(
    List<AhpItem> criteria,
  );

  /// GENERATE PAIRWISE ALTERNATIVE INPUTS
  Future<List<PairwiseAlternativeInput>> generatePairwiseAlternative(
    List<AhpHierarchy> nodes,
  );

  /// GET RESULT AHP
  Future<AhpResult> calculateFinalScore(
    List<AhpHierarchy> hierarchy,
    List<PairwiseComparisonInput> inputsCriteria,
    List<PairwiseAlternativeInput> inputsAlternative,
  );
}

class AhpLocalDatasourceImpl extends AhpLocalDatasource {
  final DecisionMakingHelper _helper;
  final DecisionIsolateMain _isolateMain;

  AhpLocalDatasourceImpl({
    DecisionMakingHelper? helper,
    DecisionIsolateMain? isolateMain,
  })  : _helper = helper ?? DecisionMakingHelper(),
        _isolateMain = isolateMain ?? DecisionIsolateMain.instance;

  bool _useIsolate = false;

  /// IDENTIFICATION DETAIL
  @override
  Future<AhpIdentification> identification(
      List<AhpItem> criteria, List<AhpItem> alternative) async {
    startPerformanceProfiling('identification');

    try {
      _useIsolate = false;

      if (criteria.isEmpty) {
        throw Exception("Criteria can't be empty!");
      }
      if (alternative.isEmpty) {
        throw Exception("Alternative can't be empty!");
      }

      if (criteria.length > 100 || alternative.length > 100) {
        throw Exception(
          "Too much data, please limit the number of criteria/alternatives (max 100 criteria and 100 alternative).",
        );
      }

      final updatedCriteria = List<AhpItem>.generate(criteria.length, (i) {
        final e = criteria[i];
        return (e.id == null || e.id!.isEmpty)
            ? e.copyWith(id: _helper.getCustomUniqueId())
            : e;
      });

      final updateAlternative = List<AhpItem>.generate(alternative.length, (
        i,
      ) {
        final e = alternative[i];
        return (e.id == null || e.id!.isEmpty)
            ? e.copyWith(id: _helper.getCustomUniqueId())
            : e;
      });

      return AhpIdentification(
        criteria: updatedCriteria,
        alternative: updateAlternative,
      );
    } finally {
      endPerformanceProfiling('identification');
    }
  }

  /// GENERATE STRUCTURE HIERARCHY
  @override
  Future<List<AhpHierarchy>> generateHierarchy(
      List<AhpItem> criteria, List<AhpItem> alternative) async {
    startPerformanceProfiling('generate hierarchy');
    try {
      final resultHierarchy = criteria.map((c) {
        return AhpHierarchy(criteria: c, alternative: alternative);
      }).toList();

      return resultHierarchy;
    } catch (e) {
      throw Exception('Failed generate hierarchy $e');
    } finally {
      endPerformanceProfiling('generate hierarchy');
    }
  }

  /// GENERATE PAIRWISE CRITERIA INPUTS
  @override
  Future<List<PairwiseComparisonInput>> generatePairwiseCriteria(
      List<AhpItem> criteria) async {
    startPerformanceProfiling('generate pairwise criteria');
    try {
      final result = <PairwiseComparisonInput>[];

      for (int i = 0; i < criteria.length; i++) {
        for (int j = i + 1; j < criteria.length; j++) {
          result.add(
            PairwiseComparisonInput(
              left: criteria[i],
              right: criteria[j],
              preferenceValue: null,
              isLeftMoreImportant: null,
              id: _helper.getCustomUniqueId(),
            ),
          );
        }
      }

      return result;
    } catch (e) {
      throw Exception('Failed generate pairwise criteria template $e');
    } finally {
      endPerformanceProfiling('generate pairwise criteria');
    }
  }

  /// **************************************************************************

  /// GENERATE PAIRWISE ALTERNATIVE INPUTS
  @override
  Future<List<PairwiseAlternativeInput>> generatePairwiseAlternative(
    List<AhpHierarchy> nodes,
  ) async {
    try {
      const computeThreshold = 15;

      final hierarchyList =
          nodes.map((e) => AhpHierarchyMapper.fromEntity(e).toMap()).toList();

      if (kIsWeb) {
        final result = await generateInputPairwiseAlternative({
          "data": hierarchyList,
        });

        return result
            .map((e) => PairwiseAlternativeInputDto.fromMap(e).toEntity())
            .toList();
      } else {
        List<Map<String, dynamic>> result = [];

        if (nodes.length < computeThreshold) {
          result = await generateInputPairwiseAlternative({
            "data": hierarchyList,
          });
        } else {
          _useIsolate = true;
          result = await _isolateMain.runTask(
            DecisionAlgorithm.ahp,
            AhpProcessingCommand.generateInputPairwiseAlternative,
            {
              "data": hierarchyList,
            },
          );
        }

        return result
            .map((e) => PairwiseAlternativeInputDto.fromMap(e).toEntity())
            .toList();
      }
    } catch (e) {
      _useIsolate = false;
      rethrow;
    }
  }

  /// *************************************************************************

  /// GET AHP RESULT
  @override
  Future<AhpResult> calculateFinalScore(
    List<AhpHierarchy> hierarchy,
    List<PairwiseComparisonInput> inputsCriteria,
    List<PairwiseAlternativeInput> inputsAlternative,
  ) async {
    try {
      if (inputsCriteria.any((e) => e.preferenceValue == null)) {
        throw Exception("Please complete all values from the criteria scale");
      }

      if (inputsCriteria.any((e) => e.isLeftMoreImportant == null)) {
        throw Exception(
            "Please complete which more important from the criteria");
      }

      if (inputsAlternative
          .any((e) => e.alternative.any((d) => d.preferenceValue == null))) {
        throw Exception(
            "Please complete all values from the alternative scale");
      }

      if (inputsAlternative.any(
          (e) => e.alternative.any((d) => d.isLeftMoreImportant == null))) {
        throw Exception(
            "Please complete which more important from the alternative");
      }

      bool withIsolate = (_useIsolate == false) || kIsWeb;

      /// [CRITERIA]
      /// GENERATE RESULT MATRIX CRITERIA
      List<List<double>> resultMatrixCriteria = [[]];
      final itemCriteria =
          hierarchy.map((e) => e.criteria).toList(growable: false);

      final crItemList = itemCriteria
          .map((e) => AhpItemMapper.fromEntity(e).toMap())
          .toList(growable: false);

      final crComparisonInput = inputsCriteria
          .map((e) => PairwiseComparisonInputMapper.fromEntity(e).toMap())
          .toList(growable: false);

      if (withIsolate) {
        resultMatrixCriteria = await ahpGenerateResultPairwiseMatrixCriteria({
          'items': crItemList,
          'inputs': crComparisonInput,
        });
      } else {
        resultMatrixCriteria = await _isolateMain.runTask(
          DecisionAlgorithm.ahp,
          AhpProcessingCommand.generateResultPairwiseMatrixCriteria,
          {
            'items': crItemList,
            'inputs': crComparisonInput,
          },
        );
      }

      dev.log('✅ matrix criteria $resultMatrixCriteria \n',
          name: 'DECISION MAKING');

      /// CALCULATE EIGEN VECTOR CRITERIA
      final eigenCrMatrixRaw = resultMatrixCriteria
          .map((e) => e.cast<dynamic>())
          .toList(growable: false);

      List<double> eigenVectorCriteria = [];

      if (withIsolate) {
        eigenVectorCriteria = await ahpCalculateEigenVectorCriteria({
          'matrix': eigenCrMatrixRaw,
        });
      } else {
        eigenVectorCriteria = await _isolateMain.runTask(
          DecisionAlgorithm.ahp,
          AhpProcessingCommand.calculateEigenVectorCriteria,
          {
            'matrix': eigenCrMatrixRaw,
          },
        );
      }

      dev.log('✅ eigen vector criteria $eigenVectorCriteria \n',
          name: 'DECISION MAKING');

      /// CHECK CRITERIA CONSISTENCY RATIO
      Map<String, dynamic> criteriaConsistencyRatio = {};

      if (withIsolate) {
        criteriaConsistencyRatio = await ahpCheckConsistencyRatio({
          "matrix": resultMatrixCriteria,
          "priority_vector": eigenVectorCriteria,
          "source": 'criteria',
        });
      } else {
        criteriaConsistencyRatio = await _isolateMain.runTask(
            DecisionAlgorithm.ahp, AhpProcessingCommand.checkConsistencyRatio, {
          "matrix": resultMatrixCriteria,
          "priority_vector": eigenVectorCriteria,
          "source": 'criteria',
        });
      }

      dev.log('✅ criteria ratio ${criteriaConsistencyRatio['ratio']} \n',
          name: 'DECISION MAKING');

      /// [ALTERNATIVE]
      final allEigenVectorsAlternative = <List<double>>[];
      final allMatrixAlternatives = <List<List<double>>>[];
      final alternativeConsistencyRatio = <Map<String, dynamic>>[];

      for (var input in inputsAlternative) {
        final itemAlternative = input.alternative
            .expand((e) => [e.left, e.right])
            .toSet()
            .toList(growable: false);

        final altItemList = itemAlternative
            .map((e) => AhpItemMapper.fromEntity(e).toMap())
            .toList(growable: false);

        final altInputs =
            PairwiseAlternativeInputMapper.fromEntity(input).toMap();

        /// GENERATE RESULT MATRIX ALTERNATIVE
        List<List<double>> matrixAlt = [[]];

        if (withIsolate) {
          matrixAlt = await ahpGenerateResultPairwiseMatrixAlternative({
            'items': altItemList,
            'inputs': [altInputs],
          });
        } else {
          matrixAlt = await _isolateMain.runTask(
            DecisionAlgorithm.ahp,
            AhpProcessingCommand.generateResultPairwiseMatrixAlternative,
            {
              'items': altItemList,
              'inputs': [altInputs],
            },
          );
        }

        allMatrixAlternatives.add(matrixAlt);
        dev.log('✅ matrix alternative (${input.criteria.name}): $matrixAlt \n',
            name: 'DECISION MAKING');

        /// CALCULATE EIGEN VECTOR ALTERNATIVE
        List<double> eigenVectorAlt = [];

        if (withIsolate) {
          eigenVectorAlt = await ahpCalculateEigenVectorAlternative({
            'matrix': matrixAlt,
          });
        } else {
          eigenVectorAlt = await _isolateMain.runTask(DecisionAlgorithm.ahp,
              AhpProcessingCommand.calculateEigenVectorAlternative, {
            'matrix': matrixAlt,
          });
        }

        allEigenVectorsAlternative.add(eigenVectorAlt);
        dev.log(
            '✅ eigen vector alternative (${input.criteria.name}): $eigenVectorAlt \n',
            name: 'DECISION MAKING');

        /// CHECK ALTERNATIVE CONSISTENCY RATIO
        Map<String, dynamic> altConsistencyRatio = {};

        if (withIsolate) {
          altConsistencyRatio = await ahpCheckConsistencyRatio({
            "matrix": matrixAlt,
            "priority_vector": eigenVectorAlt,
            "source": 'alternative',
          });
        } else {
          altConsistencyRatio = await _isolateMain.runTask(
              DecisionAlgorithm.ahp,
              AhpProcessingCommand.checkConsistencyRatio, {
            "matrix": matrixAlt,
            "priority_vector": eigenVectorAlt,
            "source": 'alternative',
          });
        }

        alternativeConsistencyRatio.add(altConsistencyRatio);
        dev.log(
            '✅ alternative ratio (${input.criteria.name}): ${altConsistencyRatio['ratio']} \n',
            name: 'DECISION MAKING');
      }

      final alternativeRaw =
          hierarchy.expand((e) => e.alternative).toList(growable: false);

      final alternativeRawDto = alternativeRaw
          .map((e) => AhpItemMapper.fromEntity(e))
          .toList(growable: false);

      Map<String, dynamic> rawFinalScore = {};

      if (withIsolate) {
        rawFinalScore = await ahpFinalScore({
          "eigen_vector_criteria": eigenVectorCriteria,
          "eigen_vector_alternative": allEigenVectorsAlternative,
          "alternative_raw":
              alternativeRawDto.map((e) => e.toMap()).toList(growable: false),
          "consistency_criteria_raw": criteriaConsistencyRatio,
          "consistency_alternative_raw": alternativeConsistencyRatio,
        });
      } else {
        rawFinalScore = await _isolateMain.runTask(
            DecisionAlgorithm.ahp, AhpProcessingCommand.calculateFinalScore, {
          "eigen_vector_criteria": eigenVectorCriteria,
          "eigen_vector_alternative": allEigenVectorsAlternative,
          "alternative_raw":
              alternativeRawDto.map((e) => e.toMap()).toList(growable: false),
          "consistency_criteria_raw": criteriaConsistencyRatio,
          "consistency_alternative_raw": alternativeConsistencyRatio,
        });
      }

      final result = AhpResultDto.fromMap(rawFinalScore);

      dev.log(
          '✅ final score ${result.results?.map((e) => '${e.name}: ${e.value}').join(', ')}',
          name: 'DECISION MAKING');

      return result.toEntity();
    } catch (e) {
      dev.log('Failed calculate result: $e', name: 'DECISION MAKING');
      rethrow;
    } finally {
      dev.log('Done calculate result AHP', name: 'DECISION MAKING');
    }
  }
}
