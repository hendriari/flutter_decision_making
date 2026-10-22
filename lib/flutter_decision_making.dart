import 'package:flutter_decision_making/feature/ahp/presentation/ahp.dart';
import 'package:flutter_decision_making/feature/saw/presentation/saw.dart';
import 'package:flutter_decision_making/feature/topsis/presentation/topsis.dart';

export 'package:decision_making_core/decision_making_core.dart'
    show
        AhpComparisonScale,
        AhpConsistencyRatio,
        AhpDetailedResult,
        AhpHierarchy,
        AhpIdentification,
        AhpItem,
        AhpMatrixEvaluation,
        AhpResult,
        AhpResultDetail,
        PairwiseAlternativeInput,
        PairwiseComparisonInput,
        SawDetailedResult,
        TopsisDetailedResult,
        TopsisIdealValue,
        TopsisMatrix,
        TopsisRawMatrix,
        WeightedDecisionAlternative,
        WeightedDecisionCriteria,
        WeightedDecisionMatrix,
        WeightedDecisionRating,
        WeightedDecisionResult;
export 'package:flutter_decision_making/feature/ahp/presentation/ahp.dart';
export 'package:flutter_decision_making/feature/saw/presentation/saw.dart';
export 'package:flutter_decision_making/feature/topsis/presentation/topsis.dart';
export 'package:flutter_decision_making/core/decision_making_utils.dart';

class FlutterDecisionMaking {
  static final FlutterDecisionMaking _instance =
      FlutterDecisionMaking._internal();

  FlutterDecisionMaking._internal()
      : ahp = AHP(),
        saw = SAW(),
        topsis = TOPSIS();

  factory FlutterDecisionMaking() {
    return _instance;
  }

  final AHP ahp;
  final SAW saw;
  final TOPSIS topsis;
}
