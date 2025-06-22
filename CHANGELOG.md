## 1.0.0

* Flutter Decision Making with AHP algorithm initial release.

## 1.0.1
chore:
* Provide documentation
* Pass static analysis
* update README.md

## 1.0.2
update docs

## 1.0.3
* update preference value: only return integer
* update README.md
* feature to reset all internal data and results to initial state

## 1.0.4
* updated README with development note about upcoming support for SAW, TOPSIS, and other algorithms.
* Improved package description in pubspec.yaml to reflect ongoing development and future feature additions.

# 1.0.5

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