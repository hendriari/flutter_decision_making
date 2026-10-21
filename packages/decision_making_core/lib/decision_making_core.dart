/// Decision Making Core Library
///
/// Pure Dart implementations of decision-making algorithms:
/// - SAW (Simple Additive Weighting)
/// - TOPSIS (Technique for Order Preference by Similarity to Ideal Solution)
/// - AHP (Analytic Hierarchy Process)
library decision_making_core;

// Common
export 'src/common/matrix_validator.dart';
export 'src/common/weighted_decision_alternative.dart';
export 'src/common/weighted_decision_criteria.dart';
export 'src/common/weighted_decision_matrix.dart';
export 'src/common/weighted_decision_rating.dart';
export 'src/common/weighted_decision_result.dart';

// SAW
export 'src/saw/saw_calculator.dart';

// TOPSIS
export 'src/topsis/topsis_calculator.dart';
export 'src/topsis/topsis_ideal_value.dart';
export 'src/topsis/topsis_matrix.dart';
export 'src/topsis/topsis_raw_matrix.dart';

// AHP
export 'src/ahp/ahp_calculator.dart';
export 'src/ahp/ahp_comparison_scale.dart';
export 'src/ahp/ahp_consistency_ratio.dart';
export 'src/ahp/ahp_hierarchy.dart';
export 'src/ahp/ahp_identification.dart';
export 'src/ahp/ahp_item.dart';
export 'src/ahp/ahp_result.dart';
export 'src/ahp/ahp_result_detail.dart';
export 'src/ahp/pairwise_alternative_input.dart';
export 'src/ahp/pairwise_comparison_input.dart';
