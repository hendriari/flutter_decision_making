/// Decision Making Core Library
///
/// Pure Dart implementations of decision-making algorithms:
/// - SAW (Simple Additive Weighting)
/// - TOPSIS (Technique for Order Preference by Similarity to Ideal Solution)
/// - AHP (Analytic Hierarchy Process)
library;

// Common
export 'src/common/decision_input_exception.dart';
export 'src/common/matrix_validator.dart';
export 'src/common/weighted_decision_alternative.dart';
export 'src/common/weighted_decision_criteria.dart';
export 'src/common/weighted_decision_matrix.dart';
export 'src/common/weighted_decision_rating.dart';
export 'src/common/weighted_decision_result.dart';

// SAW
export 'src/saw/saw_calculator.dart';
export 'src/saw/saw_detailed_result.dart';

// TOPSIS
export 'src/topsis/topsis_calculator.dart';
export 'src/topsis/topsis_detailed_result.dart';
export 'src/topsis/topsis_ideal_value.dart';
export 'src/topsis/topsis_matrix.dart';
export 'src/topsis/topsis_raw_matrix.dart';

// Sensitivity & Rank Reversal
export 'src/sensitivity/alternative_pair.dart';
export 'src/sensitivity/rank_reversal_case.dart';
export 'src/sensitivity/sensitivity_analysis_result.dart';
export 'src/sensitivity/sensitivity_direction.dart';
export 'src/sensitivity/weight_sensitivity_case.dart';

// Objective Weighting (Entropy & CRITIC)
export 'src/weighting/critic_weight_result.dart';
export 'src/weighting/entropy_weight_result.dart';
export 'src/weighting/objective_weight_calculator.dart';

// AHP
export 'src/ahp/ahp_calculator.dart';
export 'src/ahp/ahp_comparison_scale.dart';
export 'src/ahp/ahp_consistency_ratio.dart';
export 'src/ahp/ahp_detailed_result.dart';
export 'src/ahp/ahp_hierarchy.dart';
export 'src/ahp/ahp_identification.dart';
export 'src/ahp/ahp_item.dart';
export 'src/ahp/ahp_result.dart';
export 'src/ahp/ahp_result_detail.dart';
export 'src/ahp/pairwise_alternative_input.dart';
export 'src/ahp/pairwise_comparison_input.dart';
