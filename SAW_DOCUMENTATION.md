## 📌 Important

**All calculations are performed client-side using pure Dart via `decision_making_core`. By default, calculations run synchronously on the main thread (`useIsolate: false`), which executes in under 1 ms for typical datasets (e.g. 80 alternatives × 25 criteria takes ~0.19 ms on Apple Silicon in profile mode; mobile devices will be slower). Isolate processing is opt-in via `useIsolate: true` for heavy background operations where keeping the UI thread unblocked is desired, though message serialization adds a modest overhead.**

---

## ✨ Features

- Generate decision matrix from criteria and alternatives
- Automatic weight normalization to 100%
- Support for both benefit and cost criteria
- Matrix normalization based on criteria type (benefit: max divider; cost: min divider)
- Weighted score calculation with descending ranking
- **Detailed intermediate computation steps** via `getSawDetailedResult` (`SawDetailedResult`)
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

### 1. Initialize SAW and Define Inputs

Each criterion and alternative should have a unique ID. If omitted, the package auto-generates one.

```dart
import 'package:flutter_decision_making/flutter_decision_making.dart';

final saw = SAW();

final criteria = [
  WeightedDecisionCriteria(
    id: 'c1',
    name: 'Price',
    weightPercent: 30,
    isBenefit: false, // Cost criterion (lower is better)
    maxValue: 2000,
  ),
  WeightedDecisionCriteria(
    id: 'c2',
    name: 'Quality',
    weightPercent: 50,
    isBenefit: true, // Benefit criterion (higher is better)
    maxValue: 100,
  ),
  WeightedDecisionCriteria(
    id: 'c3',
    name: 'Durability',
    weightPercent: 20,
    isBenefit: true, // Benefit criterion (higher is better)
    maxValue: 10,
  ),
];

final alternatives = [
  WeightedDecisionAlternative(id: 'a1', name: 'Product A'),
  WeightedDecisionAlternative(id: 'a2', name: 'Product B'),
  WeightedDecisionAlternative(id: 'a3', name: 'Product C'),
];
```

### 2. Generate and Fill Decision Matrix

```dart
// Generate the initial matrix (ratings initialized to 0.0)
List<WeightedDecisionMatrix> matrix = await saw.generateSawMatrix(
  listAlternative: alternatives,
  listCriteria: criteria,
  useIsolate: false, // Default is false (main thread)
);

// Update matrix values with ratings
matrix = await saw.updateSawMatrix(
  currentMatrix: matrix,
  matrixId: matrix[0].id,
  ratingsId: matrix[0].ratings[0].id,
  value: 1500.0,
);
```

### 3. Calculate Final Scores and Rankings

```dart
try {
  List<WeightedDecisionResult> results = await saw.getSawResult(
    matrix: matrix,
    useIsolate: false,
  );

  for (final res in results) {
    print('${res.rank}. ${res.alternative.name}: ${res.score.toStringAsFixed(4)}');
  }
} on DecisionInputException catch (e) {
  print('Validation failed: ${e.message}');
}
```

Or calculate directly with an existing pre-filled matrix:

```dart
List<WeightedDecisionResult> results = await saw.getResultWithExistingMatrix(
  sawMatrix: matrix,
  useIsolate: false,
);
```

### 4. Detailed Results (Intermediate Computation Steps)

To inspect all intermediate mathematical steps, use `getSawDetailedResult`:

```dart
SawDetailedResult detailed = await saw.getSawDetailedResult(
  matrix: matrix,
);

// Access intermediate stages
print('Original matrix alternatives: ${detailed.initialMatrix.length}');
print('Normalized weights (sum to 1.0): ${detailed.normalizedWeights}');
print('First alternative normalized ratings: ${detailed.normalizedMatrix.first.ratings.map((r) => r.value)}');
print('First alternative weighted ratings: ${detailed.weightedMatrix.first.ratings.map((r) => r.value)}');
print('Final ranked scores: ${detailed.scores.map((s) => '${s.rank}: ${s.score}')}');

// Full serializable JSON map
Map<String, dynamic> jsonMap = detailed.toJson();
```

### 5. Sensitivity Analysis & Rank Reversal

Evaluate how resilient the rankings are when criteria weights change, and check for rank reversal when alternatives are removed:

```dart
SensitivityAnalysisResult sensitivity = await saw.analyzeSensitivity(
  matrix: matrix,
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
EntropyWeightResult entropy = await saw.calculateEntropyWeights(
  matrix: matrix,
);
print('Entropy weights: ${entropy.weights}');
print('Entropy dispersion d_j: ${entropy.divergence}');
Map<String, dynamic> entropyJson = entropy.toJson();

// 2. CRITIC weighting
CriticWeightResult critic = await saw.calculateCriticWeights(
  matrix: matrix,
);
print('CRITIC weights: ${critic.weights}');
print('CRITIC standard deviations: ${critic.standardDeviations}');
Map<String, dynamic> criticJson = critic.toJson();

// Apply objective weights to criteria definition:
List<WeightedDecisionCriteria> updatedCriteria = saw.applyObjectiveWeightsToCriteria(
  listCriteria: criteria,
  weights: entropy.weights,
);

// Or apply directly to the decision matrix:
List<WeightedDecisionMatrix> weightedMatrix = saw.applyObjectiveWeightsToMatrix(
  matrix: matrix,
  weights: entropy.weights,
);

// Run calculation with the objectively weighted matrix
SawDetailedResult result = await saw.getSawDetailedResult(matrix: weightedMatrix);
```

---

## ⚡ When to Use Isolates (`useIsolate`)

- **Default (`useIsolate: false`):** Runs on the current thread. Measured on **Apple Silicon (macOS) in `--profile` mode**, pure Dart calculations complete in **0.19 ms** (0.18–0.35 ms) for 80 × 25 and **8.71 ms** (8.39–12.27 ms) for 2000 × 50. Note that mobile devices will be slower than these numbers, so profile on your target device.
- **Opt-in (`useIsolate: true`):** Spawns a background Dart Isolate. Use this when calculating extremely large matrices (thousands of alternatives) where you must guarantee zero UI thread jank, keeping in mind that data serialization to and from the isolate takes more time than the calculation itself.
- **Web Platform:** Isolates are not supported on Flutter Web; calculations run safely on the main thread automatically.

---

## 🛠️ Mathematical Method

1. **Weight Normalization:**
   `w_j = weightPercent_j / sum(weightPercent)` (sums to 1.0).

2. **Matrix Normalization:**
   - Benefit criteria: `r_ij = x_ij / max_i(x_ij)`
   - Cost criteria: `r_ij = min_i(x_ij) / x_ij`
   - Constant column: `r_ij = 1.0`

3. **Weighted Scores:**
   - Weighted score: `score_i = sum_j (r_ij * w_j)`
   - Sorted in descending order with 1-based ranks.

---

## 🚨 Error Handling

All input validation failures throw `DecisionInputException` (implements `Exception`).

```dart
try {
  await saw.getSawResult(matrix: matrix);
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
- `Total criteria weight cannot be zero!`
- `Criteria weights cannot be negative.`
- `Zero value found in cost criteria!` (division by zero prevention)
- `Value exceeds maximum value!` (rating exceeds `criterion.maxValue`)
- `Matrix not found!` / `Rating not found!` (ID lookups)
