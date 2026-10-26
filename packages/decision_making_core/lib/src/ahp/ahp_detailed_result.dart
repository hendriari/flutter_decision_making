import 'ahp_result.dart';
import 'ahp_result_detail.dart';

/// Matrix evaluation details for an AHP comparison matrix (criteria or alternatives under a criterion).
class AhpMatrixEvaluation {
  /// Unique identifier of the evaluated element (e.g., 'criteria' or criterion ID).
  final String id;

  /// Human-readable name of the evaluated element (e.g., 'Criteria' or criterion name).
  final String name;

  /// Ordered list of item IDs corresponding to rows and columns of the matrix.
  final List<String> itemIds;

  /// Reciprocal pairwise comparison matrix `A`.
  final List<List<double>> comparisonMatrix;

  /// Normalized pairwise comparison matrix `N`, where each element is divided by its column sum.
  final List<List<double>> normalizedMatrix;

  /// Priority weights computed via normalized column averaging (`w`).
  /// Key: item ID.
  /// Value: weight fraction summing to 1.0.
  final Map<String, double> weights;

  /// Maximum eigenvalue approximation (`lambda_max`).
  final double lambdaMax;

  /// Consistency Index (`CI = (lambda_max - n) / (n - 1)`).
  final double ci;

  /// Random Index (`RI`) used for evaluation from Saaty's table.
  final double ri;

  /// Consistency Ratio (`CR = CI / RI`).
  final double cr;

  /// Whether this comparison matrix is considered consistent (`CR <= 0.1`).
  final bool isConsistent;

  const AhpMatrixEvaluation({
    required this.id,
    required this.name,
    required this.itemIds,
    required this.comparisonMatrix,
    required this.normalizedMatrix,
    required this.weights,
    required this.lambdaMax,
    required this.ci,
    required this.ri,
    required this.cr,
    required this.isConsistent,
  });

  /// Converts this matrix evaluation into a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'item_ids': itemIds,
        'comparison_matrix':
            comparisonMatrix.map((row) => List<double>.from(row)).toList(),
        'normalized_matrix':
            normalizedMatrix.map((row) => List<double>.from(row)).toList(),
        'weights': Map<String, double>.from(weights),
        'lambda_max': lambdaMax,
        'ci': ci,
        'ri': ri,
        'cr': cr,
        'is_consistent': isConsistent,
      };
}

/// Detailed result of an Analytic Hierarchy Process (AHP) calculation.
///
/// Contains all intermediate computation steps:
/// - [criteriaEvaluation]: Comparison matrix, normalized matrix, weights, and consistency metrics for criteria.
/// - [alternativeEvaluations]: Map of criteria ID to alternative matrix evaluations under that criterion.
/// - [criteriaWeights]: Map of criteria ID to priority weight fraction (w_j).
/// - [scoresPerCriteria]: Map of criteria ID to alternative priority scores (s_ij).
/// - [weightedScoresPerCriteria]: Map of criteria ID to weighted alternative scores (w_j * s_ij).
/// - [scores]: Final ranked alternatives with synthesized scores (sum_j w_j * s_ij).
/// - [isConsistentCriteria]: Whether criteria comparison satisfies consistency (CR <= 0.1).
/// - [isConsistentAlternative]: Whether all alternative comparisons satisfy consistency (CR <= 0.1).
/// - [isConsistent]: Whether both criteria and all alternative matrices satisfy consistency.
/// - [note]: Descriptive note or warning if any matrix is inconsistent.
class AhpDetailedResult {
  /// Evaluation of criteria comparisons (pairwise matrix, normalized matrix, weights, consistency).
  final AhpMatrixEvaluation criteriaEvaluation;

  /// Evaluations of alternative comparisons per criterion ID.
  /// Key: Criteria ID.
  /// Value: [AhpMatrixEvaluation] for alternatives under that criterion.
  final Map<String, AhpMatrixEvaluation> alternativeEvaluations;

  /// Weights of criteria by criteria ID (w_j).
  final Map<String, double> criteriaWeights;

  /// Alternative local priority scores per criterion (s_ij).
  /// Key: Criteria ID.
  /// Value: Map of Alternative ID -> local priority score under that criterion.
  final Map<String, Map<String, double>> scoresPerCriteria;

  /// Weighted alternative scores per criterion (v_ij = w_j * s_ij).
  /// Key: Criteria ID.
  /// Value: Map of Alternative ID -> weighted score under that criterion.
  final Map<String, Map<String, double>> weightedScoresPerCriteria;

  /// Final synthesized scores per alternative (sorted by score descending).
  final List<AhpResultDetail> scores;

  /// Whether the criteria comparison is consistent ($CR \le 0.1$).
  final bool isConsistentCriteria;

  /// Whether all alternative comparisons are consistent ($CR \le 0.1$).
  final bool isConsistentAlternative;

  /// Overall consistency status of the hierarchy (both criteria and alternatives consistent).
  final bool isConsistent;

  /// Advisory note regarding consistency checks.
  final String? note;

  const AhpDetailedResult({
    required this.criteriaEvaluation,
    required this.alternativeEvaluations,
    required this.criteriaWeights,
    required this.scoresPerCriteria,
    required this.weightedScoresPerCriteria,
    required this.scores,
    required this.isConsistentCriteria,
    required this.isConsistentAlternative,
    required this.isConsistent,
    this.note,
  });

  /// Convenience getter returning the final ranked results (identical to [AhpResult.results]).
  List<AhpResultDetail> get results => scores;

  /// Criteria pairwise comparison matrix ($A_{\text{criteria}}$).
  List<List<double>> get criteriaComparisonMatrix =>
      criteriaEvaluation.comparisonMatrix;

  /// Criteria normalized comparison matrix ($N_{\text{criteria}}$).
  List<List<double>> get criteriaNormalizedMatrix =>
      criteriaEvaluation.normalizedMatrix;

  /// Alternative pairwise comparison matrices keyed by criteria ID.
  Map<String, List<List<double>>> get alternativeComparisonMatrices =>
      alternativeEvaluations.map((k, v) => MapEntry(k, v.comparisonMatrix));

  /// Alternative normalized comparison matrices keyed by criteria ID.
  Map<String, List<List<double>>> get alternativeNormalizedMatrices =>
      alternativeEvaluations.map((k, v) => MapEntry(k, v.normalizedMatrix));

  /// Converts to an [AhpResult] compatible with the legacy return type.
  AhpResult toAhpResult() => AhpResult(
        results: scores,
        isConsistentCriteria: isConsistentCriteria,
        consistencyCriteriaRatio: criteriaEvaluation.cr,
        isConsistentAlternative: isConsistentAlternative,
        consistencyAlternativeRatio: alternativeEvaluations.isEmpty
            ? 0.0
            : alternativeEvaluations.values
                .map((e) => e.cr)
                .reduce((a, b) => a > b ? a : b),
        note: note,
      );

  /// Converts the detailed result and all intermediate calculation steps into a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'criteria_evaluation': criteriaEvaluation.toJson(),
        'alternative_evaluations': alternativeEvaluations.map(
          (k, v) => MapEntry(k, v.toJson()),
        ),
        'criteria_weights': Map<String, double>.from(criteriaWeights),
        'scores_per_criteria': scoresPerCriteria.map(
          (k, v) => MapEntry(k, Map<String, double>.from(v)),
        ),
        'weighted_scores_per_criteria': weightedScoresPerCriteria.map(
          (k, v) => MapEntry(k, Map<String, double>.from(v)),
        ),
        'scores': scores
            .map((s) => {
                  'id': s.id,
                  'name': s.name,
                  'value': s.value,
                })
            .toList(),
        'is_consistent_criteria': isConsistentCriteria,
        'is_consistent_alternative': isConsistentAlternative,
        'is_consistent': isConsistent,
        'note': note,
      };
}
