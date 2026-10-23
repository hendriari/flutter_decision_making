# decision_making_core

A pure Dart multi-criteria decision-making (MCDM) library implementing **SAW**, **TOPSIS**, and **AHP** algorithms.

- **Zero Flutter dependencies**: Can be used in CLI tools, background workers, backend microservices, or frontend applications.
- **Synchronous & fast**: Pure computational engine without Futures or event loop overhead.
- **Strictly tested**: Validated with golden datasets under a numerical tolerance of 1e-4.

---

## Usage Examples

### 1. Simple Additive Weighting (SAW)

```dart
import 'package:decision_making_core/decision_making_core.dart';

void main() {
  final alternatives = [
    WeightedDecisionAlternative(id: 'a1', name: 'Alternative 1'),
    WeightedDecisionAlternative(id: 'a2', name: 'Alternative 2'),
  ];

  final criteria = [
    WeightedDecisionCriteria(
      id: 'c1',
      name: 'Cost',
      weightPercent: 40,
      isBenefit: false, // Cost criteria
      maxValue: 100,
    ),
    WeightedDecisionCriteria(
      id: 'c2',
      name: 'Quality',
      weightPercent: 60,
      isBenefit: true,  // Benefit criteria
      maxValue: 100,
    ),
  ];

  final matrix = [
    WeightedDecisionMatrix(
      id: 'm1',
      alternative: alternatives[0],
      ratings: [
        WeightedDecisionRating(id: 'r1_1', criteria: criteria[0], value: 40),
        WeightedDecisionRating(id: 'r1_2', criteria: criteria[1], value: 80),
      ],
    ),
    WeightedDecisionMatrix(
      id: 'm2',
      alternative: alternatives[1],
      ratings: [
        WeightedDecisionRating(id: 'r2_1', criteria: criteria[0], value: 60),
        WeightedDecisionRating(id: 'r2_2', criteria: criteria[1], value: 90),
      ],
    ),
  ];

  final results = SawCalculator.calculate(matrix);

  for (final res in results) {
    print('Rank ${res.rank}: ${res.alternative.name} (Score: ${res.score.toStringAsFixed(4)})');
  }

  // To inspect all intermediate matrices and normalized weights:
  // final detailed = SawCalculator.calculateDetailed(matrix);
  // print(detailed.normalizedWeights);
  // print(detailed.toJson());
}
```

### 2. TOPSIS (Similarity to Ideal Solution)

```dart
import 'package:decision_making_core/decision_making_core.dart';

void main() {
  final criteria = [
    WeightedDecisionCriteria(
      id: 'c1',
      name: 'Price',
      weightPercent: 50,
      isBenefit: false,
      maxValue: 100,
    ),
    WeightedDecisionCriteria(
      id: 'c2',
      name: 'Quality',
      weightPercent: 50,
      isBenefit: true,
      maxValue: 100,
    ),
  ];

  final alternatives = [
    WeightedDecisionAlternative(id: 'a1', name: 'Vendor A'),
    WeightedDecisionAlternative(id: 'a2', name: 'Vendor B'),
  ];

  final matrix = [
    WeightedDecisionMatrix(
      id: 'm1',
      alternative: alternatives[0],
      ratings: [
        WeightedDecisionRating(id: 'r1', criteria: criteria[0], value: 30),
        WeightedDecisionRating(id: 'r2', criteria: criteria[1], value: 80),
      ],
    ),
    WeightedDecisionMatrix(
      id: 'm2',
      alternative: alternatives[1],
      ratings: [
        WeightedDecisionRating(id: 'r3', criteria: criteria[0], value: 50),
        WeightedDecisionRating(id: 'r4', criteria: criteria[1], value: 60),
      ],
    ),
  ];

  final rawMatrix = TopsisRawMatrix(criterias: criteria, matrixs: matrix);
  final results = TopsisCalculator.calculate(rawMatrix);

  for (final res in results) {
    print('Rank ${res.rank}: ${res.alternative.name} (Score: ${res.score.toStringAsFixed(4)})');
  }

  // To inspect all intermediate matrices, ideal solutions, and separation measures:
  // final detailed = TopsisCalculator.calculateDetailed(rawMatrix);
  // print(detailed.positiveIdeal);
  // print(detailed.separationPlus);
  // print(detailed.toJson());
}
```

### 3. Analytic Hierarchy Process (AHP)

```dart
import 'package:decision_making_core/decision_making_core.dart';

void main() {
  final criteria = [
    AhpItem(id: 'c1', name: 'Cost'),
    AhpItem(id: 'c2', name: 'Quality'),
  ];

  final alternatives = [
    AhpItem(id: 'a1', name: 'Option A'),
    AhpItem(id: 'a2', name: 'Option B'),
  ];

  final hierarchy = AhpCalculator.generateHierarchy(criteria, alternatives);

  // Criteria pairwise comparison (Cost is 2x more important than Quality)
  final criteriaInputs = [
    PairwiseComparisonInput(
      id: 'p1',
      left: criteria[0],
      right: criteria[1],
      preferenceValue: 2,
      isLeftMoreImportant: true,
    ),
  ];

  // Alternatives pairwise comparisons under each criterion
  final alternativeInputs = [
    PairwiseAlternativeInput(
      criteria: criteria[0],
      alternative: [
        PairwiseComparisonInput(
          id: 'alt_cost',
          left: alternatives[0],
          right: alternatives[1],
          preferenceValue: 3,
          isLeftMoreImportant: true,
        ),
      ],
    ),
    PairwiseAlternativeInput(
      criteria: criteria[1],
      alternative: [
        PairwiseComparisonInput(
          id: 'alt_quality',
          left: alternatives[0],
          right: alternatives[1],
          preferenceValue: 2,
          isLeftMoreImportant: false,
        ),
      ],
    ),
  ];

  final result = AhpCalculator.calculate(
    hierarchy: hierarchy,
    inputsCriteria: criteriaInputs,
    inputsAlternative: alternativeInputs,
  );

  print('Criteria Consistent: ${result.isConsistentCriteria} (CR: ${result.consistencyCriteriaRatio})');
  for (final detail in result.results!) {
    print('${detail.name}: ${detail.value.toStringAsFixed(4)}');
  }

  // To inspect all intermediate comparison matrices, weights, and consistency metrics:
  // final detailed = AhpCalculator.calculateDetailed(
  //   hierarchy: hierarchy,
  //   inputsCriteria: criteriaInputs,
  //   inputsAlternative: alternativeInputs,
  // );
  // print(detailed.criteriaWeights);
  // print(detailed.toJson());
}
```

---

## Sensitivity Analysis & Rank Reversal Detection

The library provides automated weight sensitivity analysis and rank reversal detection for **SAW** (`SawCalculator.analyzeSensitivity`) and **TOPSIS** (`TopsisCalculator.analyzeSensitivity`).

> **Note:** This feature **detects** rank reversal phenomena; it does **not** prevent them. Rank reversal is an inherent mathematical characteristic of multi-criteria decision making methods where relative rankings naturally shift due to changing normalization boundaries or ideal reference points when alternatives are added or removed.

### Definitions

1. **Weight Sensitivity:**
   - Evaluates systematic +/- delta (default 10% relative, `delta: 0.10`) perturbations across each criterion in deterministic order (input criteria order, then `+`, then `-`).
   - Formula: `w_k' = w_k * (1 +/- delta)`, while all other criteria weights are rescaled by `(1 - w_k') / (1 - w_k)` so the total weight strictly equals 1.0.
   - If `w_k' >= 1.0`, `w_k' <= 0.0`, or only 1 criterion exists, the case is safely skipped and its reason recorded in `skipReason`.

2. **Pairwise Ranking Changes:**
   - Order change is evaluated strictly pairwise between every alternative pair `(i, j)`: order is considered "changed" if the sign of `(score_i - score_j)` flips and the absolute difference on both sides is `> 1e-9`.
   - Score differences `<= 1e-9` are treated as ties and do not trigger order change.

3. **Rank Reversal Detection:**
   - For datasets with `n >= 3` alternatives, each alternative `r` is removed one by one, scores are recalculated, and the relative ordering among remaining alternatives is compared to their original baseline order.
   - For datasets with `n < 3`, rank reversal testing is skipped and documented in `skipReason`.

4. **Stability Summary (`isStable`):**
   - Returns `true` if and only if no ranking changes occur across all sensitivity perturbation cases and no rank reversals occur upon any alternative removal.

> **Caution & Caveats:**
> Sensitivity and rank reversal behaviors depend directly on the chosen `delta` parameter and the mathematical normalization technique (e.g. min/max boundary normalization in SAW vs Euclidean vector normalization in TOPSIS). Rank reversals can naturally occur in multi-criteria methods when an ideal point or normalization denominator shifts upon alternative removal.

### Example: Sensitivity Analysis (SAW & TOPSIS)

```dart
import 'package:decision_making_core/decision_making_core.dart';

void main() {
  // SAW Sensitivity Analysis
  final sawResult = SawCalculator.analyzeSensitivity(matrix, delta: 0.1);
  print('SAW isStable: ${sawResult.isStable}');
  for (final sCase in sawResult.sensitivityCases) {
    if (sCase.hasOrderChanged) {
      print('Criterion ${sCase.criterionId} ${sCase.direction.symbol}: order changed!');
      for (final pair in sCase.swappedPairs) {
        print('  Swapped pair: ${pair.firstId} <-> ${pair.secondId}');
      }
    }
  }

  // TOPSIS Sensitivity Analysis
  final topsisResult = TopsisCalculator.analyzeSensitivity(rawMatrix, delta: 0.1);
  print('TOPSIS isStable: ${topsisResult.isStable}');
  for (final rCase in topsisResult.rankReversalCases) {
    if (rCase.hasReversal) {
      print('Rank reversal when removing ${rCase.removedAlternativeId}!');
      for (final pair in rCase.reversedPairs) {
        print('  Inverted relative order: ${pair.firstId} <-> ${pair.secondId}');
      }
    }
  }
}
```

---

## Objective Weighting (Shannon Entropy & CRITIC)

When subjective criteria weights are unavailable or data-driven objectivity is required, `decision_making_core` provides two objective weighting methods via `ObjectiveWeightCalculator`:

1. **Shannon Entropy (`ObjectiveWeightCalculator.calculateEntropy`):**
   - Computes proportions per column from raw values: `p_ij = x_ij / sum_i(x_ij)` (benefit/cost direction is ignored; all values must be non-negative).
   - Computes entropy per criterion: `e_j = -k * sum_i(p_ij * ln(p_ij))` where `k = 1 / ln(m)` and `0 * ln(0) = 0`.
   - Computes degree of divergence: `d_j = 1 - e_j`.
   - Normalizes weights: `w_j = d_j / sum_j(d_j)`.
   - Returns `EntropyWeightResult` containing `proportionMatrix`, `entropy`, `divergence`, `weights`, and `toJson()`.

2. **CRITIC (`ObjectiveWeightCalculator.calculateCritic`):**
   - Applies min-max normalization per column:
     - Benefit: `r_ij = (x_ij - min_j) / (max_j - min_j)`
     - Cost: `r_ij = (max_j - x_ij) / (max_j - min_j)`
   - Computes sample standard deviation `sigma_j` (divisor `m - 1`) for each normalized column.
   - Computes the Pearson correlation matrix `R = [r_jk]` between normalized columns.
   - Computes information content: `C_j = sigma_j * sum_k(1 - r_jk)`.
   - Normalizes weights: `w_j = C_j / sum_j(C_j)`.
   - Returns `CriticWeightResult` containing `normalizedMatrix`, `standardDeviations`, `correlationMatrix`, `informationContent`, `weights`, and `toJson()`.

### Objective Weighting Edge Cases (No NaN Guarantee)

- **Entropy:**
  - `m < 2` (fewer than 2 alternatives): throws an `Exception`.
  - Negative value (`x_ij < 0`): throws an `Exception`.
  - Column sum equals 0 (`sum_i(x_ij) == 0`): throws an `Exception`.
  - Zero cell value (`x_ij == 0` with positive column sum): allowed (`0 * ln(0) = 0`).
  - All `d_j == 0` (all columns constant): returns equal weights (`w_j = 1 / n`).
- **CRITIC:**
  - `m < 2` (fewer than 2 alternatives): throws an `Exception`.
  - Constant column (`max_j == min_j`): normalized values are `0.0`, `sigma_j = 0.0`, and correlation with other columns is `0.0`.
  - `sum_j(C_j) == 0` (all columns constant or perfectly correlated): returns equal weights (`w_j = 1 / n`).

### Example: Combined Objective Weighting with SAW and TOPSIS

```dart
import 'package:decision_making_core/decision_making_core.dart';

void main() {
  // 1. Calculate Entropy and CRITIC objective weights from a decision matrix
  final entropyResult = ObjectiveWeightCalculator.calculateEntropy(matrix);
  print('Entropy weights: ${entropyResult.weights}'); // sums to 1.0
  print('Entropy e_j: ${entropyResult.entropy}');
  print('Divergence d_j: ${entropyResult.divergence}');

  final criticResult = ObjectiveWeightCalculator.calculateCritic(matrix);
  print('CRITIC weights: ${criticResult.weights}'); // sums to 1.0
  print('CRITIC sigma_j: ${criticResult.standardDeviations}');
  print('CRITIC C_j: ${criticResult.informationContent}');

  // 2. Apply objective weights to criteria list (weightPercent = w_j * 100, benefit/cost preserved)
  final updatedCriteria = entropyResult.applyToCriteria(criteria);

  // 3. Apply directly to SAW matrix and calculate ranked results
  final sawMatrixWithEntropy = entropyResult.applyToMatrix(matrix);
  final sawResults = SawCalculator.calculate(sawMatrixWithEntropy);

  // 4. Apply directly to TOPSIS raw matrix and calculate ranked results
  final topsisWithCritic = criticResult.applyToTopsisRawMatrix(rawMatrix);
  final topsisResults = TopsisCalculator.calculate(topsisWithCritic);
}
```

---

## Existing Behavior & Edge Cases

The core calculation engines maintain consistent mathematical specifications for edge cases:

- **SAW cost criteria with value 0:** If a cost criterion receives a rating value of `0.0`, an explicit `Exception("Rating value cannot be 0 for cost criteria")` is thrown to prevent division by zero (`min / 0.0`) or infinite scores.
- **TOPSIS all-zero column:** When all alternatives have a value of `0.0` for a criterion (resulting in Euclidean norm = 0.0), each normalized cell safely evaluates to `0.0` instead of `NaN` or divide-by-zero.
- **TOPSIS equidistant alternatives (D+ = D- = 0):** When all alternatives have identical distance to ideal solutions (such as single-alternative datasets or identical rows where `D+ = 0.0` and `D- = 0.0`), the relative closeness formula `D- / (D+ + D-)` safely resolves to a neutral score of `0.5` instead of `NaN`.

---

## License

MIT License. See [LICENSE](LICENSE) for details.
