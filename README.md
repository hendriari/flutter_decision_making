[![pub version](https://img.shields.io/pub/v/flutter_decision_making.svg)](https://pub.dev/packages/flutter_decision_making)

## ✨ About

**Flutter package for practical Multi-Criteria Decision Making (MCDM). Providing algorithms such as AHP, SAW, and TOPSIS to help developers perform weighting, evaluation, and ranking of alternatives easily and accurately within their Flutter applications.**

| Status | Algorithm                                                               | Available in version |
|:-------|:------------------------------------------------------------------------|:---------------------|
| ✅      | AHP (Analytic Hierarchy Process)                                        | 1.0.0                |
| ✅     | SAW (Simple Additive Weighting)                                         | 1.1.0                |
| ✅     | TOPSIS (Technique for Order Preference by Similarity to Ideal Solution) | 1.2.0                |

| Feature                                            | Available in version |
|:---------------------------------------------------|:---------------------|
| Self-explaining (detailed) results with `toJson()` | 2.0.0                |
| Weight sensitivity analysis & rank reversal check  | 2.0.0                |
| Pure Dart core ([`decision_making_core`](https://pub.dev/packages/decision_making_core)) | 2.0.0 |

---

## 🎯 Typical Use Cases

Suitable for building decision support features such as:

- HR candidate or promotion selection
- Vendor or project evaluation
- Scholarship or student ranking
- Feature prioritization in product management
- Internal corporate decision-making systems
- Recommendation or comparison apps

---

## 📦 Installation

```bash
flutter pub add flutter_decision_making
```

```dart
import 'package:flutter_decision_making/flutter_decision_making.dart';
```

> Need the algorithms without Flutter (CLI, server, Dart backend)? Use the pure Dart package [`decision_making_core`](https://pub.dev/packages/decision_making_core).

---

## 📚 Usage Guide
You can use this package in two ways depending on your needs:

1. Using all algorithms together  
   Initialize the `FlutterDecisionMaking` class to access all available algorithms.

```dart
late FlutterDecisionMaking _decisionMaking;
AhpResult? _ahpResult;
List<WeightedDecisionResult>? _sawResult;
List<WeightedDecisionResult>? _topsisResult;

@override
void initState() {
  super.initState();
  _decisionMaking = FlutterDecisionMaking();
}

// Usage example:
// for AHP
_ahpResult = await _decisionMaking.ahp.getAhpResult(...);

// for SAW
_sawResult = await _decisionMaking.saw.getSawResult(...);

// for TOPSIS
_topsisResult = await _decisionMaking.topsis.getTopsisResult(...);
```

This is the easiest way if you want to use multiple algorithms in your project.

2. Using a specific algorithm only

If you only need a single algorithm (e.g., AHP), you can import and initialize it directly:

```dart
late AHP _ahp;
AhpResult? _ahpResult;

@override
void initState() {
  super.initState();
  _ahp = AHP();
}

// Usage example:
_ahpResult = await _ahp.getAhpResult(...);

```

---

## 🔍 Explainable Results

Every algorithm can return all intermediate steps, not only the final ranking. Useful for reports, audits and teaching.

```dart
final saw = await _decisionMaking.saw.getSawDetailedResult(matrix: matrix);
saw.normalizedMatrix;   // r_ij
saw.normalizedWeights;  // w_j (sum = 1)
saw.weightedMatrix;     // v_ij
saw.scores;             // final scores and ranks

final topsis = await _decisionMaking.topsis.getTopsisDetailedResult(matrix: topsisMatrix);
topsis.positiveIdeal;   // A+
topsis.negativeIdeal;   // A-
topsis.separationPlus;  // D+
topsis.separationMinus; // D-

final ahp = await _decisionMaking.ahp.getAhpDetailedResult(...);
ahp.criteriaEvaluation; // comparison/normalized matrix, weights, lambda max, CI, RI, CR

final json = saw.toJson(); // every detailed result can be serialized
```

The existing `getSawResult`, `getTopsisResult` and `getAhpResult` are unchanged.

---

## 🧪 Sensitivity Analysis & Rank Reversal (SAW, TOPSIS)

Check how stable a ranking is.

```dart
final result = await _decisionMaking.saw.analyzeSensitivity(matrix: matrix, delta: 0.10);

result.isStable;              // false if any perturbation or removal changes the order
result.sensitivityCases;      // each criterion weight +/- 10% (relative), others rescaled
result.rankReversalCases;     // each alternative removed in turn (needs 3+ alternatives)
```

> Rank reversal is **detected**, not prevented. Results depend on `delta` and on the normalization method of each algorithm. Skipped cases (for example fewer than 3 alternatives) are reported with a reason and are not counted as unstable.

---

## ⚖️ Objective Criteria Weighting (Entropy & CRITIC)

Derive data-driven criteria weights (summing to 1.0) directly from a decision matrix (`m` alternatives by `n` criteria) and apply them to SAW or TOPSIS:

- **Shannon Entropy (`calculateEntropyWeights` / `ObjectiveWeightCalculator.calculateEntropy`):**
  - Uses raw values (`benefit`/`cost` direction is ignored; values must be non-negative): `p_ij = x_ij / sum_i(x_ij)`, `k = 1 / ln(m)`, `e_j = -k * sum_i(p_ij * ln(p_ij))` with `0 * ln(0) = 0`, `d_j = 1 - e_j`, and `w_j = d_j / sum_j(d_j)`.
  - Edge cases: throws an `Exception` if `m < 2`, any value is negative, or a column sum is `0`; `0` cell values are allowed; if all `d_j == 0` (all columns constant), returns equal weights (`1 / n`).
- **CRITIC (`calculateCriticWeights` / `ObjectiveWeightCalculator.calculateCritic`):**
  - Applies min-max normalization per column (`(x - min) / (max - min)` for benefit, `(max - x) / (max - min)` for cost), computes sample standard deviation `sigma_j` (divisor `m - 1`) and the Pearson correlation matrix `R = [r_jk]` between normalized columns, `C_j = sigma_j * sum_k(1 - r_jk)`, and `w_j = C_j / sum_j(C_j)`.
  - Edge cases: throws a `DecisionInputException` if `m < 2`; a constant column (`max == min`) gets normalized values `0.0`, `sigma_j = 0.0`, and `0.0` correlation with other columns; if `sum_j(C_j) == 0`, returns equal weights (`1 / n`).

```dart
final entropy = await _decisionMaking.saw.calculateEntropyWeights(matrix: matrix);
entropy.entropy;     // e_j
entropy.divergence;  // d_j
entropy.weights;     // w_j (sum = 1)

final critic = await _decisionMaking.saw.calculateCriticWeights(matrix: matrix);
critic.standardDeviations; // sigma_j (sample std dev, divisor m - 1)
critic.correlationMatrix;  // Pearson correlation matrix R
critic.informationContent; // C_j
critic.weights;            // w_j (sum = 1)

// Apply objective weights (weightPercent = w_j * 100, benefit/cost preserved) and run SAW:
final weightedMatrix = _decisionMaking.saw.applyObjectiveWeightsToMatrix(
  matrix: matrix,
  weights: entropy.weights,
);
final ranked = await _decisionMaking.saw.getResultWithExistingMatrix(
  sawMatrix: weightedMatrix,
);
```

---

## 📖 Algorithm Docs
For details on how to use the algorithm, you can visit the following documentation.

| Link                                                                                                    | Description                                                                                                                                                                                      |
|:--------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [AHP Doc](https://github.com/hendriari/flutter_decision_making/wiki/Analytic-Hierarchy-Process-(AHP))   | If you need a method that is able to determine weights accurately through pairwise comparisons, validate the consistency of assessments, and work well on subjective or multilevel criteria.     |
| [SAW Doc](https://github.com/hendriari/flutter_decision_making/wiki/Simple-Additive-Weighting-(SAW))    | If you need a simple, fast, easy to calculate, and easy to implement method for ranking alternatives based on criteria weights and values.                                                       |
| [TOPSIS Doc](https://github.com/hendriari/flutter_decision_making/wiki/TOPSIS-(Technique-for-Order-Preference-by-Similarity-to-Ideal-Solution)) | If you need a method that ranks alternatives based on their distance to the ideal best and ideal worst solutions, providing a more discriminative and robust decision-making result.                                                      |

> The wiki pages describe each algorithm. For detailed results, sensitivity analysis and `useIsolate`, see the sections above.

---

## 📈 Performance Profiling

Major method logs:
- Start and end timestamps.
- Execution duration (in milliseconds).

> Useful for debugging and optimization during development.

---

## ⚡ When to Use Isolates (`useIsolate`)

By default all calculations run on the **main thread** (`useIsolate: false`). Isolates are **opt-in** via `useIsolate: true`.

Measured on **Apple Silicon (macOS), `--profile` mode**, public API, median (min–max) of 10 runs after 3 warm-ups:

| Case (alternatives × criteria) | Main thread (ms) | Isolate, warm (ms) | Main thread blocked (ms) |
|:--|:--|:--|:--|
| SAW 80 × 25      | **0.19** (0.18–0.35)    | 4.35 (3.01–5.86)       | 0.85 (0.00–3.03)       |
| SAW 2000 × 50    | **8.71** (8.39–12.27)   | 449.24 (411.99–477.15) | 244.23 (219.73–262.51) |
| TOPSIS 80 × 25   | **0.52** (0.50–0.55)    | 4.02 (3.33–6.18)       | 0.80 (0.00–3.34)       |
| TOPSIS 2000 × 50 | **47.53** (40.32–52.14) | 526.39 (464.34–605.88) | 277.99 (223.17–306.31) |
| AHP 80 × 10      | **31.71** (31.21–52.50) | 51.01 (47.90–66.97)    | 25.84 (23.09–39.94)    |

"Main thread blocked" is estimated with an event-loop lag monitor; values near 0 mean the blocking was below its detection threshold (about 1 ms), not that it is exactly zero. Mobile devices will be slower than these numbers, so profile on your target device.

**Recommendation:** keep the default. Sending data to an isolate costs more (serialization) than the calculation itself in every case measured. Use `useIsolate: true` only if you must keep very large calculations off the UI thread and accept a longer total time. Note that AHP needs n(n-1)/2 pairwise judgments per matrix, so very large AHP inputs are rarely practical for human evaluators.

---

## 🚨 Error Handling

Input validation failures across all algorithms throw `DecisionInputException` (exported from both `flutter_decision_making` and `decision_making_core`, implementing `Exception`). Generic `catch (e)` blocks continue to work seamlessly, while specific validation logic can be caught via `on DecisionInputException`:

```dart
import 'package:flutter_decision_making/flutter_decision_making.dart';

Future<void> evaluate(List<WeightedDecisionMatrix> matrix) async {
  final saw = SAW();
  try {
    final results = await saw.getSawResult(matrix: matrix);
    print('Best alternative: ${results.first.alternative.name}');
  } on DecisionInputException catch (e) {
    // Specifically handle user input or matrix validation errors
    print('Validation error: ${e.message}');
  } catch (e) {
    // Other unexpected exceptions
    print('Error: $e');
  }
}
```

---

## ⬆️ Upgrading from 1.x

- Isolates are no longer used automatically. Pass `useIsolate: true` if you relied on that behaviour.
- `DecisionIsolateMain` and the isolate message/worker types are no longer exported from the main library.
- **TOPSIS in 1.2.0 returned wrong rankings above 80 alternatives or 25 criteria. Upgrade if you use TOPSIS with large inputs.**

See the [CHANGELOG](CHANGELOG.md) for details.

---

## 💡 Want Another Algorithm?

We are continuously improving this package 🚀

If you would like to see a new algorithm (e.g., WP, ELECTRE, MOORA, PROMETHEE, etc.) added:

👉 Please open a discussion:
[![GitHub Discussions](https://img.shields.io/badge/Join-Discussion-2ea44f?logo=github&logoColor=white)](https://github.com/hendriari/flutter_decision_making/discussions)

⚠️ Note:
New algorithms will be prioritized based on:
- Community interest
- Contribution support (PRs are welcome!)
- Maintainer availability

Contributions are highly appreciated 🙌

---
## 🎁 Support Me
[![Ko-Fi](https://badgen.net/badge/icon/ko-fi?icon=kofi&color=red&label)](https://ko-fi.com/hendriari) [![Saweria Badge](https://img.shields.io/badge/Saweria-Donate-orange?style=flat&logo=buymeacoffee&logoColor=white)](https://saweria.co/hendriarii)
 
---

## 🙋‍♂️ Contributing

We welcome all contributions and suggestions!

👉 Open an issue or submit a pull request at [GitHub Repo](https://github.com/hendriari/flutter_decision_making)
