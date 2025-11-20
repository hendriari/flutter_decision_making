enum DecisionAlgorithm {
  ahp,
  saw,
}

enum AhpProcessingCommand {
  generateResultPairwiseMatrixCriteria,
  calculateEigenVectorCriteria,
  generateResultPairwiseMatrixAlternative,
  calculateEigenVectorAlternative,
  checkConsistencyRatio,
  calculateFinalScore
}

enum SawProcessingCommand {
  generateSawMatrix,
  normalizeMatrix,
}
