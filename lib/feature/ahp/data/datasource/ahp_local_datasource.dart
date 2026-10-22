import 'dart:developer' as dev;

import 'package:decision_making_core/decision_making_core.dart';

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
    List<AhpHierarchy> nodes, {
    bool useIsolate = false,
  });

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
  /// - [useIsolate]: Whether to run computations in isolate workers (defaults to false)
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
    List<PairwiseAlternativeInput> inputsAlternative, {
    bool useIsolate = false,
  });
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
  DecisionIsolateMain? _isolateMain;

  /// Gets the isolate manager for heavy computations, lazily initialized.
  DecisionIsolateMain get isolateMain => _isolateMain ??= DecisionIsolateMain();

  /// Creates an instance of [AhpLocalDatasourceImpl].
  ///
  /// **Parameters:**
  /// - [helper]: Helper for utility functions like ID generation (defaults to new instance)
  /// - [isolateMain]: Isolate manager for heavy computations (lazily created if null)
  AhpLocalDatasourceImpl({
    DecisionMakingHelper? helper,
    DecisionIsolateMain? isolateMain,
  })  : _helper = helper ?? DecisionMakingHelper(),
        _isolateMain = isolateMain;

  /// IDENTIFICATION DETAIL
  @override
  Future<AhpIdentification> identification(
      List<AhpItem> criteria, List<AhpItem> alternative) async {
    startPerformanceProfiling('identification');

    try {
      return AhpCalculator.identification(
        criteria,
        alternative,
        idGenerator: () => _helper.getCustomUniqueId(),
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
      return AhpCalculator.generateHierarchy(criteria, alternative);
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
      return AhpCalculator.generatePairwiseCriteria(
        criteria,
        idGenerator: () => _helper.getCustomUniqueId(),
      );
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
    List<AhpHierarchy> nodes, {
    bool useIsolate = false,
  }) async {
    try {
      final hierarchyList =
          nodes.map((e) => AhpHierarchyMapper.fromEntity(e).toMap()).toList();

      List<Map<String, dynamic>> result = [];
      final canUseIsolate = useIsolate && !kIsWeb;

      if (canUseIsolate) {
        result = await isolateMain.runTask(
          DecisionAlgorithm.ahp,
          AhpProcessingIsolateCommand.generateInputPairwiseAlternative,
          {
            "data": hierarchyList,
          },
        );
      } else {
        result = await generateInputPairwiseAlternative({
          "data": hierarchyList,
        });
      }

      return result
          .map((e) => PairwiseAlternativeInputDto.fromMap(e).toEntity())
          .toList();
    } catch (e) {
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
    List<PairwiseAlternativeInput> inputsAlternative, {
    bool useIsolate = false,
  }) async {
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

      final isDirectMode = !useIsolate || kIsWeb;

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

      if (isDirectMode) {
        resultMatrixCriteria = await ahpGenerateResultPairwiseMatrixCriteria({
          'items': crItemList,
          'inputs': crComparisonInput,
        });
      } else {
        resultMatrixCriteria = await isolateMain.runTask(
          DecisionAlgorithm.ahp,
          AhpProcessingIsolateCommand.generateResultPairwiseMatrixCriteria,
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

      if (isDirectMode) {
        eigenVectorCriteria = await ahpCalculateEigenVectorCriteria({
          'matrix': eigenCrMatrixRaw,
        });
      } else {
        eigenVectorCriteria = await isolateMain.runTask(
          DecisionAlgorithm.ahp,
          AhpProcessingIsolateCommand.calculateEigenVectorCriteria,
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

      if (isDirectMode) {
        criteriaConsistencyRatio = await ahpCheckConsistencyRatio({
          "matrix": resultMatrixCriteria,
          "priority_vector": eigenVectorCriteria,
          "source": 'criteria',
        });
      } else {
        criteriaConsistencyRatio = await isolateMain.runTask(
            DecisionAlgorithm.ahp,
            AhpProcessingIsolateCommand.checkConsistencyRatio, {
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

        if (isDirectMode) {
          matrixAlt = await ahpGenerateResultPairwiseMatrixAlternative({
            'items': altItemList,
            'inputs': [altInputs],
          });
        } else {
          matrixAlt = await isolateMain.runTask(
            DecisionAlgorithm.ahp,
            AhpProcessingIsolateCommand.generateResultPairwiseMatrixAlternative,
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

        if (isDirectMode) {
          eigenVectorAlt = await ahpCalculateEigenVectorAlternative({
            'matrix': matrixAlt,
          });
        } else {
          eigenVectorAlt = await isolateMain.runTask(DecisionAlgorithm.ahp,
              AhpProcessingIsolateCommand.calculateEigenVectorAlternative, {
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

        if (isDirectMode) {
          altConsistencyRatio = await ahpCheckConsistencyRatio({
            "matrix": matrixAlt,
            "priority_vector": eigenVectorAlt,
            "source": 'alternative',
          });
        } else {
          altConsistencyRatio = await isolateMain.runTask(DecisionAlgorithm.ahp,
              AhpProcessingIsolateCommand.checkConsistencyRatio, {
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

      if (isDirectMode) {
        rawFinalScore = await ahpFinalScore({
          "eigen_vector_criteria": eigenVectorCriteria,
          "eigen_vector_alternative": allEigenVectorsAlternative,
          "alternative_raw":
              alternativeRawDto.map((e) => e.toMap()).toList(growable: false),
          "consistency_criteria_raw": criteriaConsistencyRatio,
          "consistency_alternative_raw": alternativeConsistencyRatio,
        });
      } else {
        rawFinalScore = await isolateMain.runTask(DecisionAlgorithm.ahp,
            AhpProcessingIsolateCommand.calculateFinalScore, {
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
