## Unreleased

### Proposed version: 1.3.0

### Breaking changes
- **Isolate execution is now opt-in.** The automatic isolate threshold (>80 alternatives / >25 criteria) was removed. All calculation methods accept `useIsolate` (default `false`). In profile-mode benchmarks on Apple Silicon, the main-thread path was roughly 8–50x faster than the isolate path for SAW and TOPSIS up to 2000x50 (see README).
- **Isolate internals are no longer exported** from `package:flutter_decision_making/flutter_decision_making.dart` (`DecisionIsolateMain`, isolate message and worker files). Migration: pass `useIsolate: true` to the public API; if you need the manager itself, import `package:flutter_decision_making/core/isolate/decision_isolate_main.dart`.

### Added
- New pure Dart package `decision_making_core` (`packages/decision_making_core`) with synchronous SAW, TOPSIS and AHP calculators. The Flutter package delegates its calculations to it.
- Entity types from the core are exported selectively from the main barrel.
- `TOPSIS`, `TopsisRawMatrix` and related types are now exported from the main barrel.
- **Detailed self-explaining SAW results (`SawDetailedResult`):** Added `SawCalculator.calculateDetailed` and `SAW.getSawDetailedResult` returning all intermediate calculation steps: input matrix, cell-normalized matrix ($r_{ij}$), normalized weights ($w_j$), weighted cell matrix ($v_{ij}$), and final scores/ranks with JSON serialization support (`toJson()`).
- **Detailed self-explaining TOPSIS results (`TopsisDetailedResult`):** Added `TopsisCalculator.calculateDetailed` and `TOPSIS.getTopsisDetailedResult` returning all intermediate calculation steps: input matrix, Euclidean-normalized matrix ($r_{ij}$), normalized weights ($w_j$), weighted cell matrix ($v_{ij}$), positive/negative ideal solutions ($A^+, A^-$), separation distances ($D^+, D^-$), and final relative closeness scores/ranks with JSON serialization support (`toJson()`).
- **Detailed self-explaining AHP results (`AhpDetailedResult`, `AhpMatrixEvaluation`):** Added `AhpCalculator.calculateDetailed` and `AHP.getAhpDetailedResult` returning all intermediate comparison matrices, normalized matrices, weights ($w_j$), consistency metrics ($\lambda_{\max}, CI, RI, CR$), per-criteria local priority scores, weighted scores, and final synthesized scores with JSON serialization support (`toJson()`).

### Fixed / Behavior changes
- **TOPSIS ranking was wrong in 1.2.0 for datasets above 80 alternatives or 25 criteria**, because the isolate worker called the SAW normalization instead of the Euclidean one.
- Removed a dead TOPSIS isolate command (`normalizeMatrix`).
- **SAW cost criteria with value 0:** Throws explicit `Exception` instead of producing infinite or undefined weights when dividing by zero in `minValue / rating.value`.
- **TOPSIS all-zero column:** When an entire criteria column contains 0 values, the Euclidean divider $\sqrt{\sum x_{ij}^2} = 0$ is safely handled by yielding normalized value `0.0` per cell instead of dividing by zero or producing `NaN`.
- **TOPSIS indeterminate relative closeness ($D^+ = D^- = 0$):** When all alternatives have identical distance to ideal solutions (such as single alternative datasets or identical alternative values), the indeterminate form $\frac{0}{0 + 0}$ safely resolves to a neutral relative closeness score of `0.5` instead of `NaN`.
- **AHP internal helper protection:** `AhpCalculator.getRI`, `riTable`, and `normalizeComparisonMatrix` are marked `@internal` from `package:meta`.

### Release order
1. Publish `decision_making_core` (0.1.0).
2. Remove `dependency_overrides` from the root, `example/` and `benchmark/` pubspecs.
3. Publish `flutter_decision_making`.

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