# Changelog

All notable changes to `decision_making_core` will be documented in this file.

## 0.1.0

### Initial Release
- Pure Dart multi-criteria decision-making (MCDM) computational library (SDK `>=3.0.0 <4.0.0`).
- Zero Flutter dependencies: runs seamlessly in CLI tools, backend servers, Dart frog/Shelf, and frontend frameworks.
- Synchronous calculation engines:
  - **SAW (Simple Additive Weighting):** `SawCalculator.normalize()`, `SawCalculator.calculateScores()`, `SawCalculator.calculate()`, and `SawCalculator.calculateDetailed()` returning `SawDetailedResult` with complete intermediate matrices and `toJson()`.
  - **TOPSIS (Technique for Order Preference by Similarity to Ideal Solution):** `TopsisCalculator.normalizeEuclidean()`, `TopsisCalculator.weightMatrix()`, `TopsisCalculator.calculateIdealSolutions()`, `TopsisCalculator.calculateSeparationDistances()`, `TopsisCalculator.calculateRelativeCloseness()`, `TopsisCalculator.calculate()`, and `TopsisCalculator.calculateDetailed()` returning `TopsisDetailedResult` with complete intermediate matrices, ideal solutions, separation distances, scores, and `toJson()`.
  - **AHP (Analytic Hierarchy Process):** `AhpCalculator.identification()`, `AhpCalculator.generateHierarchy()`, `AhpCalculator.generatePairwiseCriteria()`, `AhpCalculator.generatePairwiseAlternative()`, `AhpCalculator.generateResultPairwiseMatrixCriteria()`, `AhpCalculator.generateResultPairwiseMatrixAlternative()`, `AhpCalculator.calculateEigenVector()`, `AhpCalculator.checkConsistencyRatio()`, `AhpCalculator.calculateFinalScore()`, `AhpCalculator.calculate()`, and `AhpCalculator.calculateDetailed()` returning `AhpDetailedResult` with complete comparison matrices, normalized matrices, weights ($w_j$), consistency metrics ($\lambda_{\max}, CI, RI, CR$), scores per criteria, and `toJson()`.
- Pure domain models and validation utilities (`MatrixValidator`).
- Comprehensive unit and golden test suite verified with tolerance $10^{-4}$.

### Behavior changes & Edge Case Hardening
- **SAW (Cost criteria with value 0):** Throws explicit `Exception("Rating value cannot be 0 for cost criteria")` preventing division by zero or infinite scores.
- **TOPSIS (All-zero criteria column):** When an entire criteria column consists of 0.0 values (Euclidean norm = 0.0), normalized cells safely evaluate to `0.0` instead of `NaN` or divide-by-zero.
- **TOPSIS ($D^+ = D^- = 0$):** When all alternatives are equidistant to the ideal solution (e.g. single alternative or identical matrix rows), the indeterminate form $\frac{0}{0+0}$ evaluates safely to a neutral closeness score of `0.5` without `NaN`.
- **AHP (Internal helper protection):** `AhpCalculator.getRI`, `riTable`, and `normalizeComparisonMatrix` are marked `@internal` from `package:meta`.
