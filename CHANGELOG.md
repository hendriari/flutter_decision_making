## 2.0.0

### Breaking changes
- **Isolate execution is now opt-in.** The automatic isolate threshold (>80 alternatives / >25 criteria) was removed. All calculation methods accept `useIsolate` (default `false`). In profile-mode benchmarks on Apple Silicon, the main-thread path was roughly 8–50x faster than the isolate path for SAW and TOPSIS up to 2000x50 (see README).
- **Isolate internals are no longer exported** from `package:flutter_decision_making/flutter_decision_making.dart` (`DecisionIsolateMain`, isolate message and worker files). Migration: pass `useIsolate: true` to the public API; if you need the manager itself, import `package:flutter_decision_making/core/isolate/decision_isolate_main.dart`.

### Added
- New pure Dart package `decision_making_core` (`packages/decision_making_core`) with synchronous SAW, TOPSIS and AHP calculators. The Flutter package delegates its calculations to it.
- Entity types from the core are exported selectively from the main barrel.
- `TOPSIS`, `TopsisRawMatrix` and related types are now exported from the main barrel.
- **Detailed self-explaining SAW results (`SawDetailedResult`):** Added `SawCalculator.calculateDetailed` and `SAW.getSawDetailedResult` returning all intermediate calculation steps: input matrix, cell-normalized matrix (r_ij), normalized weights (w_j), weighted cell matrix (v_ij), and final scores/ranks with JSON serialization support (`toJson()`).
- **Detailed self-explaining TOPSIS results (`TopsisDetailedResult`):** Added `TopsisCalculator.calculateDetailed` and `TOPSIS.getTopsisDetailedResult` returning all intermediate calculation steps: input matrix, Euclidean-normalized matrix (r_ij), normalized weights (w_j), weighted cell matrix (v_ij), positive/negative ideal solutions (A+, A-), separation distances (D+, D-), and final relative closeness scores/ranks with JSON serialization support (`toJson()`).
- **Detailed self-explaining AHP results (`AhpDetailedResult`, `AhpMatrixEvaluation`):** Added `AhpCalculator.calculateDetailed` and `AHP.getAhpDetailedResult` returning all intermediate comparison matrices, normalized matrices, weights (w_j), consistency metrics (lambda_max, CI, RI, CR), per-criteria local priority scores, weighted scores, and final synthesized scores with JSON serialization support (`toJson()`).
- **Weight sensitivity analysis & rank reversal detection (SAW & TOPSIS):** Added `SawCalculator.analyzeSensitivity`, `TopsisCalculator.analyzeSensitivity`, `SAW.analyzeSensitivity`, and `TOPSIS.analyzeSensitivity` returning `SensitivityAnalysisResult` with systematic +/- delta perturbations, pairwise ranking change detection, alternative removal rank reversal tests, and JSON serialization support (`toJson()`).
- Exported sensitivity entities: `AlternativePair`, `RankReversalCase`, `SensitivityAnalysisResult`, `SensitivityDirection`, and `WeightSensitivityCase`.

### Fixed
- **TOPSIS ranking was wrong in 1.2.0 for datasets above 80 alternatives or 25 criteria**, because the isolate worker called the SAW normalization instead of the Euclidean one.
- Removed a dead TOPSIS isolate command (`normalizeMatrix`).

---

## 1.2.0

### Updated
* make shared function to generate matrix for SAW and TOPSIS
* added algorithm TOPSIS (Technique for Order Preference by Similarity to Ideal Solution)

---

## 1.1.2

### Updated
* add support me on ko-fi, saweria to readme

---

## 1.1.1

### Updated
* adding Simple Additive Weighting (SAW) algorithm
* main isolate manager, make to multi-command isolate
* minimum flutter version
* minor update AHP

---

## 1.0.6

### Updated
* update README.md
* Refactored AHP feature for improved maintainability and performance
* On mobile and desktop platforms, replaced compute with Isolate.spawn for heavy processing tasks:
    - `generateResultPairwiseMatrixCriteria`
    - `generateResultPairwiseMatrixAlternative`
    - `calculateEigenVectorCriteria`
    - `calculateEigenVectorAlternative`
    - `checkConsistencyRatio`
    - `ahpFinalScore`

---

## 1.0.5

### Changed
- Refactor feature AHP.

### Added
- Added isolate-based heavy processing for:
    - `generatePairwiseAlternativeInput`
    - `generateResultPairwiseMatrixCriteria`
    - `generateResultPairwiseMatrixAlternative`
    - `calculateEigenVectorCriteria`
    - `calculateEigenVectorAlternative`
    - `checkConsistencyRatio`

---

## 1.0.4

* updated README with development note about upcoming support for SAW, TOPSIS, and other algorithms.
* Improved package description in pubspec.yaml to reflect ongoing development and future feature additions.

---

## 1.0.3

* update preference value: only return integer
* update README.md
* feature to reset all internal data and results to initial state

---

## 1.0.2

update docs

---

## 1.0.1

chore:
* Provide documentation
* Pass static analysis
* update README.md

---

## 1.0.0

* Flutter Decision Making with AHP algorithm initial release.