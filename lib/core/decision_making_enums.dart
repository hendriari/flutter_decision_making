import 'package:flutter_decision_making/core/isolate/decision_processing_isolate_command.dart';

enum DecisionAlgorithm {
  ahp,
  saw,
  topsis,
}

enum AhpProcessingIsolateCommand {
  generateInputPairwiseAlternative,
  generateResultPairwiseMatrixCriteria,
  calculateEigenVectorCriteria,
  generateResultPairwiseMatrixAlternative,
  calculateEigenVectorAlternative,
  checkConsistencyRatio,
  calculateFinalScore
}

enum SawProcessingIsolateCommand implements DecisionProcessingIsolateCommand {
  generateMatrix,
  normalizeMatrix,
}

enum TopsisProcessingIsolateCommand implements DecisionProcessingIsolateCommand {
  generateMatrix,
  normalizeMatrix,
}
