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

/// Abstract class defining the contract for AHP (Analytic Hierarchy Process) local data operations.
///
/// This datasource handles the complete AHP algorithm workflow including:
/// - Criteria and alternative identification
/// - Hierarchy structure generation
/// - Pairwise comparison matrix generation
/// - Eigenvalue/eigenvector calculation
/// - Consistency ratio checking
/// - Final score calculation with ranking
abstract class AhpLocalDatasource {
  /// Identifies and validates criteria and alternatives for AHP analysis.
  ///
  /// This is the first step in the AHP process. It ensures all items
  /// have unique IDs and validates input constraints.
  ///
  /// **Parameters:**
  /// - [criteria]: List of decision criteria
  /// - [alternative]: List of decision alternatives
  ///
  /// **Returns:** [AhpIdentification] containing validated criteria and alternatives
  ///
  /// **Throws:**
  /// - Exception if criteria or alternatives are empty
  /// - Exception if count exceeds 100 items
  Future<AhpIdentification> identification(
    List<AhpItem> criteria,
    List<AhpItem> alternative,
  );

  /// Generates the hierarchical structure for AHP analysis.
  ///
  /// Creates a hierarchy where each criteria is linked to all alternatives,
  /// representing the decision structure for pairwise comparisons.
  ///
  /// **Parameters:**
  /// - [criteria]: List of validated criteria
  /// - [alternative]: List of validated alternatives
  ///
  /// **Returns:** List of [AhpHierarchy] nodes
  ///
  /// **Throws:**
  /// - Exception if hierarchy generation fails
  Future<List<AhpHierarchy>> generateHierarchy(
    List<AhpItem> criteria,
    List<AhpItem> alternative,
  );

  /// Generates pairwise comparison templates for criteria.
  ///
  /// Creates all possible pairwise combinations of criteria that need
  /// to be compared. Each comparison will be filled with preference values
  /// during the decision-making process.
  ///
  /// **Parameters:**
  /// - [criteria]: List of criteria to compare
  ///
  /// **Returns:** List of [PairwiseComparisonInput] templates
  ///
  /// **Throws:**
  /// - Exception if generation fails
  Future<List<PairwiseComparisonInput>> generatePairwiseCriteria(
    List<AhpItem> criteria,
  );

  /// Generates pairwise comparison templates for alternatives under each criteria.
  ///
  /// For each criteria in the hierarchy, creates pairwise combinations
  /// of alternatives that need to be compared.
  ///
  /// **Parameters:**
  /// - [nodes]: Hierarchy structure containing criteria and alternatives
  ///
  /// **Returns:** List of [PairwiseAlternativeInput] templates
  ///
  /// **Throws:**
  /// - Exception if generation fails
  Future<List<PairwiseAlternativeInput>> generatePairwiseAlternative(
    List<AhpHierarchy> nodes,
  );

  /// Calculates the final AHP scores and rankings.
  ///
  /// This is the main computation method that:
  /// 1. Generates pairwise comparison matrices for criteria and alternatives
  /// 2. Calculates eigenvectors (priority vectors) for each matrix
  /// 3. Checks consistency ratios to validate comparisons
  /// 4. Computes final weighted scores for each alternative
  /// 5. Ranks alternatives based on their scores
  ///
  /// **Parameters:**
  /// - [hierarchy]: The decision hierarchy structure
  /// - [inputsCriteria]: Completed pairwise comparisons for criteria
  /// - [inputsAlternative]: Completed pairwise comparisons for alternatives
  ///
  /// **Returns:** [AhpResult] containing scores, rankings, and consistency information
  ///
  /// **Throws:**
  /// - Exception if any comparison values are missing
  /// - Exception if consistency ratios are unacceptable
  /// - Exception if calculation fails at any step
  Future<AhpResult> calculateFinalScore(
    List<AhpHierarchy> hierarchy,
    List<PairwiseComparisonInput> inputsCriteria,
    List<PairwiseAlternativeInput> inputsAlternative,
  );
}

/// Implementation of [AhpLocalDatasource] that handles AHP algorithm operations.
///
/// This implementation supports:
/// - Automatic ID generation for all entities
/// - Isolate-based processing for large datasets (>15 criteria or alternatives)
/// - Performance profiling for optimization
/// - Comprehensive validation and error handling
/// - Consistency ratio checking for result validation
///
/// **AHP Process Flow:**
/// 1. Identification → validates and assigns IDs
/// 2. Generate Hierarchy → creates decision structure
/// 3. Generate Pairwise Inputs → creates comparison templates
/// 4. User fills in comparisons (external to this class)
/// 5. Calculate Final Score → computes results
///
/// **Example usage:**
/// ```dart
/// final datasource = AhpLocalDatasourceImpl();
///
/// // Step 1: Identify
/// final identification = await datasource.identification(criteria, alternatives);
///
/// // Step 2: Generate hierarchy
/// final hierarchy = await datasource.generateHierarchy(
///   identification.criteria,
///   identification.alternative,
/// );
///
/// // Step 3: Generate comparison templates
/// final criteriaInputs = await datasource.generatePairwiseCriteria(
///   identification.criteria,
/// );
/// final alternativeInputs = await datasource.generatePairwiseAlternative(hierarchy);
///
/// // Step 4: User fills in comparisons (your UI logic here)
///
/// // Step 5: Calculate results
/// final result = await datasource.calculateFinalScore(
///   hierarchy,
///   criteriaInputs,
///   alternativeInputs,
/// );
/// ```
class AhpLocalDatasourceImpl extends AhpLocalDatasource {
  final DecisionMakingHelper _helper;
  final DecisionIsolateMain _isolateMain;

  /// Creates an instance of [AhpLocalDatasourceImpl].
  ///
  /// **Parameters:**
  /// - [helper]: Helper for utility functions like ID generation (defaults to new instance)
  /// - [isolateMain]: Isolate manager for heavy computations (defaults to new instance)
  AhpLocalDatasourceImpl({
    DecisionMakingHelper? helper,
    DecisionIsolateMain? isolateMain,
  })  : _helper = helper ?? DecisionMakingHelper(),
        _isolateMain = isolateMain ?? DecisionIsolateMain();

  /// Flag indicating whether isolate processing is being used.
  ///
  /// Set to true when processing large datasets to prevent UI blocking.
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
  ///
  /// This method orchestrates the complete AHP calculation process:
  ///
  /// **Step 1: Validation**
  /// - Ensures all pairwise comparison values are filled
  /// - Checks that importance flags are set
  ///
  /// **Step 2: Criteria Analysis**
  /// - Generates pairwise comparison matrix for criteria
  /// - Calculates eigenvector (priority vector) for criteria weights
  /// - Checks consistency ratio to validate criteria comparisons
  ///
  /// **Step 3: Alternative Analysis (for each criteria)**
  /// - Generates pairwise comparison matrix for alternatives
  /// - Calculates eigenvector for alternative priorities
  /// - Checks consistency ratio for each criteria's comparisons
  ///
  /// **Step 4: Final Score Calculation**
  /// - Combines criteria weights with alternative priorities
  /// - Calculates weighted scores for each alternative
  /// - Ranks alternatives based on final scores
  ///
  /// **Consistency Ratio:**
  /// A CR < 0.1 indicates acceptable consistency in comparisons.
  /// Higher values suggest inconsistent judgments that should be reviewed.
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
      ///
      /// Converts pairwise comparisons into a square matrix where
      /// matrix[i][j] represents how much criteria i is preferred over criteria j.
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

      dev.log('[AHP] ✅ matrix criteria $resultMatrixCriteria \n',
          name: 'DECISION MAKING');

      /// CALCULATE EIGEN VECTOR CRITERIA
      ///
      /// Computes the principal eigenvector of the criteria matrix.
      /// This vector represents the relative weights/priorities of each criteria.
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

      dev.log('[AHP] ✅ eigen vector criteria $eigenVectorCriteria \n',
          name: 'DECISION MAKING');

      /// CHECK CRITERIA CONSISTENCY RATIO
      ///
      /// Calculates the Consistency Ratio (CR) to measure the consistency
      /// of the pairwise comparisons. CR should be < 0.1 for acceptable results.
      ///
      /// CR = CI / RI where:
      /// - CI (Consistency Index) = (λmax - n) / (n - 1)
      /// - RI (Random Index) = predefined value based on matrix size
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

      dev.log('[AHP] ✅ criteria ratio ${criteriaConsistencyRatio['ratio']} \n',
          name: 'DECISION MAKING');

      /// [ALTERNATIVE]
      /// Process each criteria's alternative comparisons
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
        ///
        /// Creates pairwise comparison matrix for alternatives under this criteria.
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
        dev.log(
            '[AHP] ✅ matrix alternative (${input.criteria.name}): $matrixAlt \n',
            name: 'DECISION MAKING');

        /// CALCULATE EIGEN VECTOR ALTERNATIVE
        ///
        /// Computes priority vector for alternatives under this criteria.
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
            '[AHP] ✅ eigen vector alternative (${input.criteria.name}): $eigenVectorAlt \n',
            name: 'DECISION MAKING');

        /// CHECK ALTERNATIVE CONSISTENCY RATIO
        ///
        /// Validates the consistency of alternative comparisons for this criteria.
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
            '[AHP] ✅ alternative ratio (${input.criteria.name}): ${altConsistencyRatio['ratio']} \n',
            name: 'DECISION MAKING');
      }

      final alternativeRaw =
          hierarchy.expand((e) => e.alternative).toList(growable: false);

      final alternativeRawDto = alternativeRaw
          .map((e) => AhpItemMapper.fromEntity(e))
          .toList(growable: false);

      /// CALCULATE FINAL SCORE
      ///
      /// Combines criteria weights with alternative priorities to compute
      /// final scores for each alternative:
      ///
      /// Score(alternative) = Σ(criteria_weight × alternative_priority_for_criteria)
      ///
      /// Alternatives are then ranked by their final scores.
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
          '[AHP] ✅ final score ${result.results?.map((e) => '${e.name}: ${e.value}').join(', ')}',
          name: 'DECISION MAKING');

      return result.toEntity();
    } catch (e) {
      dev.log('[AHP] Failed calculate result: $e', name: 'DECISION MAKING');
      rethrow;
    } finally {
      dev.log('[AHP] Done calculate result AHP', name: 'DECISION MAKING');
    }
  }
}
