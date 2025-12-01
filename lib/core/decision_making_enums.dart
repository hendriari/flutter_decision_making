enum DecisionAlgorithm {
  ahp,
  saw,
}

enum AhpProcessingCommand {
  generateInputPairwiseAlternative,
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
