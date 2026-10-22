import 'rank_reversal_case.dart';
import 'weight_sensitivity_case.dart';

/// Comprehensive result of weight sensitivity analysis and rank reversal detection.
class SensitivityAnalysisResult {
  /// The relative perturbation fraction used (e.g. 0.1 for 10%).
  final double delta;

  /// Original alternative ranking before perturbations (ordered descending by score).
  final List<String> baseRanking;

  /// Original alternative scores before perturbations keyed by alternative ID.
  final Map<String, double> baseScores;

  /// Systematic +/- delta perturbation cases across all criteria in deterministic order.
  final List<WeightSensitivityCase> sensitivityCases;

  /// Rank reversal cases across every alternative removal (for n >= 3).
  final List<RankReversalCase> rankReversalCases;

  /// Summary indicator: `true` if no ranking changes occurred across any sensitivity cases
  /// and no rank reversals occurred across any alternative removals.
  final bool isStable;

  const SensitivityAnalysisResult({
    required this.delta,
    required this.baseRanking,
    required this.baseScores,
    required this.sensitivityCases,
    required this.rankReversalCases,
    required this.isStable,
  });

  /// Converts this result into a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'delta': delta,
        'base_ranking': List<String>.from(baseRanking),
        'base_scores': Map<String, double>.from(baseScores),
        'sensitivity_cases': sensitivityCases.map((c) => c.toJson()).toList(),
        'rank_reversal_cases':
            rankReversalCases.map((c) => c.toJson()).toList(),
        'is_stable': isStable,
      };
}
