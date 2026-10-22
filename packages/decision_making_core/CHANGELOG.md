# Changelog

All notable changes to `decision_making_core` will be documented in this file.

## 0.1.0

### Initial Release
- Pure Dart multi-criteria decision-making (MCDM) computational library (SDK `>=3.0.0 <4.0.0`).
- Zero Flutter dependencies: runs seamlessly in CLI tools, backend servers, Dart frog/Shelf, and frontend frameworks.
- Synchronous calculation engines:
  - **SAW (Simple Additive Weighting):** `SawCalculator.normalize()`, `SawCalculator.calculateScores()`, `SawCalculator.calculate()`, and `SawCalculator.calculateDetailed()` returning `SawDetailedResult` with complete intermediate matrices and `toJson()`.
  - **TOPSIS (Technique for Order Preference by Similarity to Ideal Solution):** `TopsisCalculator.normalizeEuclidean()`, `TopsisCalculator.weightMatrix()`, `TopsisCalculator.calculateIdealSolutions()`, `TopsisCalculator.calculateSeparationDistances()`, `TopsisCalculator.calculateRelativeCloseness()`, `TopsisCalculator.calculate()`, and `TopsisCalculator.calculateDetailed()` returning `TopsisDetailedResult` with complete intermediate matrices, ideal solutions, separation distances, scores, and `toJson()`.
  - **AHP (Analytic Hierarchy Process):** `AhpCalculator.identification()`, `AhpCalculator.generateHierarchy()`, `AhpCalculator.generatePairwiseCriteria()`, `AhpCalculator.generatePairwiseAlternative()`, `AhpCalculator.generateResultPairwiseMatrixCriteria()`, `AhpCalculator.generateResultPairwiseMatrixAlternative()`, `AhpCalculator.calculateEigenVector()`, `AhpCalculator.checkConsistencyRatio()`, `AhpCalculator.calculateFinalScore()`, `AhpCalculator.calculate()`, and `AhpCalculator.calculateDetailed()` returning `AhpDetailedResult` with complete comparison matrices, normalized matrices, weights (w_j), consistency metrics (lambda_max, CI, RI, CR), scores per criteria, and `toJson()`.
- Pure domain models and validation utilities (`MatrixValidator`).
- Comprehensive unit and golden test suite verified with tolerance 1e-4.

### Changed (API)
- **AHP internal helper protection:** `AhpCalculator.getRI`, `riTable`, and `normalizeComparisonMatrix` are marked `@internal` from `package:meta`.
