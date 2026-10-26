## 📌 Important

**All calculations are performed client-side using pure Dart via `decision_making_core`. By default, calculations run synchronously on the main thread (`useIsolate: false`), which executes in under 1 ms for typical datasets (e.g. 80 alternatives × 25 criteria takes ~0.52 ms on Apple Silicon in profile mode; mobile devices will be slower). Isolate processing is opt-in via `useIsolate: true` for heavy background operations where keeping the UI thread unblocked is desired, though message serialization adds a modest overhead.**

---

## ✨ Features

- Generate decision matrix from criteria and alternatives
- Automatic weight normalization to 100%
- Support for both benefit and cost criteria
- **Euclidean Vector Normalization** for matrix scaling
- **Positive Ideal (A+) and Negative Ideal (A-) Solutions**
- **Euclidean Distance Separation Measures** (D+ and D-)
- **Relative Closeness Coefficient** (C_i) for final ranking
- **Detailed intermediate computation steps** via `getTopsisDetailedResult` (`TopsisDetailedResult`)
- **Sensitivity analysis & rank reversal evaluation** via `analyzeSensitivity` (`SensitivityAnalysisResult`)
- **Objective criteria weighting** via Shannon Entropy (`calculateEntropyWeights`) and CRITIC (`calculateCriticWeights`)
- Helper functions to apply objective weights to criteria lists or matrices
- JSON serialization (`toJson()`) on all result and detailed models
- Comprehensive input validation throwing dedicated `DecisionInputException`
- Opt-in Isolate-based background processing (`useIsolate: true`, default `false`)
- Built-in performance profiling (dev-friendly)
- Auto-generation of unique IDs for entities

---

## 🔧 User Guide

### 1. Initialize TOPSIS and Define Inputs

Each criterion and alternative should have a unique ID. If omitted, the package auto-generates one.

```dart
import 'package:flutter_decision_making/flutter_decision_making.dart';

final topsis = TOPSIS();

final criteria = [
  WeightedDecisionCriteria(
    id: 'c1',
    name: 'Price',
    weightPercent: 40,
    isBenefit: false, // Cost criterion (lower is better)
    maxValue: 2000,
  ),
  WeightedDecisionCriteria(
    id: 'c2',
    name: 'Performance',
    weightPercent: 60,
    isBenefit: true, // Benefit criterion (higher is better)
    maxValue: 100,
  ),
];

final alternatives = [
  WeightedDecisionAlternative(id: 'a1', name: 'Product A'),
  WeightedDecisionAlternative(id: 'a2', name: 'Product B'),
];
```

### 2. Generate and Fill Decision Matrix

```dart
// Generate the initial TOPSIS raw matrix
TopsisRawMatrix rawMatrix = await topsis.generateTopsisMatrix(
  listAlternative: alternatives,
  listCriteria: criteria,
  useIsolate: false, // Default is false (main thread)
);

// Update matrix values with ratings
rawMatrix = await topsis.updateTopsisMatrix(
  currentRawMatrix: rawMatrix,
  matrixId: rawMatrix.matrixs[0].id,
  ratingsId: rawMatrix.matrixs[0].ratings[0].id,
  value: 1500.0,
);
```

### 3. Calculate Final Scores and Rankings

```dart
try {
  List<WeightedDecisionResult> results = await topsis.getTopsisResult(
    matrix: rawMatrix,
    useIsolate: false,
  );

  for (final res in results) {
    print('${res.rank}. ${res.alternative.name}: ${res.score.toStringAsFixed(4)}');
  }
} on DecisionInputException catch (e) {
  print('Validation failed: ${e.message}');
}
```

Or calculate directly with an existing pre-filled raw matrix:

```dart
List<WeightedDecisionResult> results = await topsis.getTopsisResultWithExistingMatrix(
  matrix: rawMatrix,
  useIsolate: false,
);
```

### 4. Detailed Results (Intermediate Computation Steps)

To inspect all intermediate mathematical steps, use `getTopsisDetailedResult`:

```dart
TopsisDetailedResult detailed = await topsis.getTopsisDetailedResult(
  matrix: rawMatrix,
);

// Access intermediate stages
print('Euclidean normalized matrix rows: ${detailed.normalizedMatrix.length}');
print('Normalized weights (sum to 1.0): ${detailed.normalizedWeights}');
print('Weighted matrix rows: ${detailed.weightedMatrix.length}');
print('Positive Ideal Solution (A+): ${detailed.positiveIdeal}');
print('Negative Ideal Solution (A-): ${detailed.negativeIdeal}');
print('Separation from A+ (D+): ${detailed.separationPlus}');
print('Separation from A- (D-): ${detailed.separationMinus}');
print('Final relative closeness scores: ${detailed.scores.map((s) => '${s.rank}: ${s.score}')}');

// Full serializable JSON map
Map<String, dynamic> jsonMap = detailed.toJson();
```

### 5. Sensitivity Analysis & Rank Reversal

Evaluate how resilient the rankings are when criteria weights change, and check for rank reversal when alternatives are removed:

```dart
SensitivityAnalysisResult sensitivity = await topsis.analyzeSensitivity(
  matrix: rawMatrix,
  delta: 0.1, // Perturbation amount: +/- 10% (default: 0.1)
);

// Inspect weight perturbation results per criterion
for (final sCase in sensitivity.sensitivityCases) {
  print('Criterion ${sCase.criterionId} ${sCase.direction.symbol}: order changed = ${sCase.hasOrderChanged}');
}

// Inspect rank reversal upon dropping individual alternatives
for (final rCase in sensitivity.rankReversalCases) {
  print('Removed ${rCase.removedAlternativeId}: reversal detected = ${rCase.hasReversal}');
}

// Check overall stability (no rank flips under any perturbation or removal)
print('Is system stable: ${sensitivity.isStable}');

// Convert entire sensitivity report to JSON
Map<String, dynamic> sensJson = sensitivity.toJson();
```

### 6. Objective Criteria Weighting (Entropy & CRITIC)

When subjective weights are not known in advance, compute objective weights directly from the decision matrix:

```dart
// 1. Shannon Entropy weighting
EntropyWeightResult entropy = await topsis.calculateEntropyWeights(
  matrix: rawMatrix,
);
print('Entropy weights: ${entropy.weights}');
print('Entropy dispersion d_j: ${entropy.divergence}');
Map<String, dynamic> entropyJson = entropy.toJson();

// 2. CRITIC weighting
CriticWeightResult critic = await topsis.calculateCriticWeights(
  matrix: rawMatrix,
);
print('CRITIC weights: ${critic.weights}');
print('CRITIC standard deviations: ${critic.standardDeviations}');
Map<String, dynamic> criticJson = critic.toJson();

// Apply objective weights to criteria definition:
List<WeightedDecisionCriteria> updatedCriteria = topsis.applyObjectiveWeightsToCriteria(
  listCriteria: criteria,
  weights: entropy.weights,
);

// Or apply directly to the raw matrix:
TopsisRawMatrix weightedRawMatrix = topsis.applyObjectiveWeightsToMatrix(
  matrix: rawMatrix,
  weights: entropy.weights,
);

// Run calculation with the objectively weighted matrix
TopsisDetailedResult result = await topsis.getTopsisDetailedResult(matrix: weightedRawMatrix);
```

---

## ⚡ When to Use Isolates (`useIsolate`)

- **Default (`useIsolate: false`):** Runs on the current thread. Measured on **Apple Silicon (macOS) in `--profile` mode**, pure Dart calculations complete in **0.52 ms** (0.50–0.55 ms) for 80 × 25 and **47.53 ms** (40.32–52.14 ms) for 2000 × 50. Note that mobile devices will be slower than these numbers, so profile on your target device.
- **Opt-in (`useIsolate: true`):** Spawns a background Dart Isolate. Use this when calculating extremely large matrices (thousands of alternatives) where you must guarantee zero UI thread jank, keeping in mind that data serialization to and from the isolate takes more time than the calculation itself.
- **Web Platform:** Isolates are not supported on Flutter Web; calculations run safely on the main thread automatically.

---

## 🛠️ Mathematical Method

1. **Euclidean Vector Normalization:**
   `r_ij = x_ij / sqrt(sum_k(x_kj^2))` for each column `j`.

2. **Weighted Normalized Matrix:**
   `v_ij = r_ij * w_j` where `w_j = weightPercent_j / sum(weightPercent)`.

3. **Ideal Solutions:**
   - Benefit criteria: `A+ = max_i(v_ij)`, `A- = min_i(v_ij)`
   - Cost criteria: `A+ = min_i(v_ij)`, `A- = max_i(v_ij)`

4. **Separation Distances:**
   - Distance from Positive Ideal: `D_i^+ = sqrt(sum_j((v_ij - A_j^+)^2))`
   - Distance from Negative Ideal: `D_i^- = sqrt(sum_j((v_ij - A_j^-)^2))`

5. **Relative Closeness Coefficient:**
   - Score: `C_i = D_i^- / (D_i^+ + D_i^-)`
   - Values range between 0.0 and 1.0 (higher is better). Sorted in descending order.

---

## 🚨 Error Handling

All input validation failures throw `DecisionInputException` (implements `Exception`).

```dart
try {
  await topsis.getTopsisResult(matrix: rawMatrix);
} on DecisionInputException catch (e) {
  // Handle invalid user input
  print('Validation error: ${e.message}');
} catch (e) {
  // Other unexpected errors
  print('Unexpected error: $e');
}
```

### Common Validation Rules
- `Alternatives list cannot be empty!`
- `Criteria list cannot be empty!`
- `Matrix cannot be empty!`
- `Total criteria weight cannot be zero!`
- `Criteria weights cannot be negative.`
- `Value exceeds maximum value!` (rating exceeds `criterion.maxValue`)
- `Matrix not found!` / `Rating not found!` (ID lookups)
