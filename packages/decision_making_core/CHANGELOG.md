# Changelog

All notable changes to `decision_making_core` will be documented in this file.

## 0.1.0

### Initial Release
- Pure Dart multi-criteria decision-making (MCDM) computational library (SDK `>=3.0.0 <4.0.0`).
- Zero Flutter dependencies: runs seamlessly in CLI tools, backend servers, Dart frog/Shelf, and frontend frameworks.
- Synchronous calculation engines:
  - **SAW (Simple Additive Weighting):** `SawCalculator.normalize()`, `SawCalculator.calculateScores()`, `SawCalculator.calculate()`.
  - **TOPSIS (Technique for Order Preference by Similarity to Ideal Solution):** `TopsisCalculator.normalizeEuclidean()`, `TopsisCalculator.weightMatrix()`, `TopsisCalculator.calculateIdealSolutions()`, `TopsisCalculator.calculateSeparationDistances()`, `TopsisCalculator.calculateRelativeCloseness()`, `TopsisCalculator.calculate()`.
  - **AHP (Analytic Hierarchy Process):** `AhpCalculator.identification()`, `AhpCalculator.generateHierarchy()`, `AhpCalculator.generatePairwiseCriteria()`, `AhpCalculator.generatePairwiseAlternative()`, `AhpCalculator.generateResultPairwiseMatrixCriteria()`, `AhpCalculator.generateResultPairwiseMatrixAlternative()`, `AhpCalculator.calculateEigenVector()`, `AhpCalculator.getRI()`, `AhpCalculator.checkConsistencyRatio()`, `AhpCalculator.calculateFinalScore()`, `AhpCalculator.calculate()`.
- Pure domain models and validation utilities (`MatrixValidator`).
- Comprehensive unit and golden test suite verified with tolerance $10^{-4}$.
