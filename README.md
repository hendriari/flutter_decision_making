[![pub version](https://img.shields.io/pub/v/flutter_decision_making.svg)](https://pub.dev/packages/flutter_decision_making)

**Development Status:**

This package is currently under active development. We are committed to continuously enhancing the features and algorithms to support a broader range of decision-making methods. In upcoming versions, we plan to add several popular algorithms such as SAW, TOPSIS, and other methods to provide a richer selection of decision-making techniques.

| TODO | Algorithm                                                               |
|:-----|:------------------------------------------------------------------------|
| ✅    | AHP (Analytic Hierarchy Process)                                        |
|      | SAW (Simple Additive Weighting)                                         |
|      | TOPSIS (Technique for Order Preference by Similarity to Ideal Solution) |

Thank you for your valuable feedback and continued support.

---

A Flutter package for implementing criteria decision-making using the **Analytic Hierarchy Process (AHP)**.

Easily manage criteria, alternatives, pairwise comparisons, consistency checks, and final decision scoring — all in one unified package.

> 🧠 _This package implements the Analytic Hierarchy Process (AHP) originally developed by Thomas L. Saaty._

---

## ✨ Features

- Generate hierarchy from criteria and alternatives
- Pairwise comparisons using Saaty's 1–9 scale
- Requires manual filling of paired comparison values for criteria and alternatives for valid analysis
- Complete validation and exceptions if there are values that have not been filled in
- Consistency Ratio check to ensure logical consistency
- Eigenvector and final score calculation
- Customizable and extendable architecture
- Built-in performance profiling (dev-friendly)

---

## 📚 Usage Guide
Initialize the FlutterDecisionMaking instance before using other methods.

```dart
late FlutterDecisionMaking _decisionMaking;

 @override
  void initState() {
    super.initState();
    _decisionMaking = FlutterDecisionMaking();
 }
```

### 🛠️ User Guide

### 1. Define Criteria and Alternatives

Each item must have a unique ID. If not provided, the package auto-generates it.

```dart
final criteria = [
  Criteria(id: 'c1', name: 'Price'),
  Criteria(id: 'c2', name: 'Quality'),
];

final alternatives = [
  Alternative(id: 'a1', name: 'Product A'),
  Alternative(id: 'a2', name: 'Product B'),
];
```

### 2. Identification, Generate Hierarchy and Generate Pairwise Comparison Input

Validate and prepare your inputs.

```dart
await _decisionMaking.generateHierarchyAndPairwiseTemplate(
listCriteria: criteria,listAlternative: alternatives);
```
After the process is complete, a paired matrix list will be generated:

```dart
List<PairwiseComparisonInput<Criteria>> inputCriteria;

List<PairwiseAlternativeInput> inputAlternative;
```
#### Please ensure that all priority weights are filled in before proceeding to the next step.

### 3. Input Pairwise Matrix and Generate Result

Saaty scale:

#### _You can use custom descriptions for each value when displaying the scale to users, but the numeric values must still conform to the Saaty scale._

#### _The package only accepts values from 1 to 9 for each comparison._

```dart
final List<PairwiseComparisonScale> pairwiseComparisonScales = [
  PairwiseComparisonScale(
    id: '1',
    description: "Equal importance of both elements",
    value: 1,
  ),
  PairwiseComparisonScale(
    id: '2',
    description: "Between equal and slightly more important",
    value: 2,
  ),
  PairwiseComparisonScale(
    id: '3',
    description: "Slightly more important",
    value: 3,
  ),
  PairwiseComparisonScale(
    id: '4',
    description: "Between slightly and moderately more important",
    value: 4,
  ),
  PairwiseComparisonScale(
    id: '5',
    description: "Moderately more important",
    value: 5,
  ),
  PairwiseComparisonScale(
    id: '6',
    description: "Between moderately and strongly more important",
    value: 6,
  ),
  PairwiseComparisonScale(
    id: '7',
    description: "Strongly more important",
    value: 7,
  ),
  PairwiseComparisonScale(
    id: '8',
    description: "Between strongly and extremely more important",
    value: 8,
  ),
  PairwiseComparisonScale(
    id: '9',
    description: "Extremely more important (absolute dominance)",
    value: 9,
  ),
];
```

Call this method to compute the final scores based on input data.

```dart
await _decisionMaking.generateResult()
```
### 🛠️ How AHP Works

#### on generate result, AHP will do

### 1. Generate Pairwise Matrix
Create a pairwise comparison matrix from criteria or alternatives input.

### 2. Calculate Approximate Eigenvector
Calculate priority weights (eigenvector) from the pairwise matrix.

### 3. Check Consistency Ratio
Compute and verify matrix consistency using the Consistency Ratio (CR).

### 4. Calculate Result
Calculate final scores for alternatives based on criteria and alternative weights, including consistency checks.

The result includes:
- Sorted list of alternative scores (`results`)
- Consistency status and ratio for criteria and alternatives
- Additional notes on consistency issues (if any)

```dart
class AhpResult {
  final List<AhpResultDetail> results;
  final bool isConsistentCriteria;
  final double consistencyCriteriaRatio;
  final bool isConsistentAlternative;
  final double consistencyAlternativeRatio;
  final String? note;

  AhpResult({
    required this.results,
    required this.isConsistentCriteria,
    required this.consistencyCriteriaRatio,
    required this.isConsistentAlternative,
    required this.consistencyAlternativeRatio,
    this.note,
  });
}

class AhpResultDetail {
  final String? id;
  final String name;
  final double value;

  AhpResultDetail({
    required this.id,
    required this.name,
    required this.value,
  });
}
```

---
## 🔍 Sample Case

### 1. Pairwise Comparison Matrix

|        | C1    | C2    | C3    |
|--------|-------|-------|-------|
| **C1** | 1.000 | 1.000 | 5.000 |
| **C2** | 1.000 | 1.000 | 7.000 |
| **C3** | 0.200 | 0.143 | 1.000 |

### 2. Matrix Normalization

Column totals:

- C1: 2.200
- C2: 2.143
- C3: 13.000

Normalized matrix:

|        | C1     | C2     | C3     |
|--------|--------|--------|--------|
| **C1** | 0.455  | 0.467  | 0.385  |
| **C2** | 0.455  | 0.467  | 0.538  |
| **C3** | 0.091  | 0.067  | 0.077  |

### 3. Eigenvector (Priority of Each Criterion)

| Criterion | Priority |
|-----------|----------|
| C1        | 0.436    |
| C2        | 0.487    |
| C3        | 0.078    |

**Interpretation:**
- C2 is the most important criterion (48.7%)
- Followed by C1 (43.6%)
- C3 has a low weight (7.8%)

### 4. Consistency Ratio (CR)

#### a. λ_max Value

λ_max = 3.078

#### b. Consistency Index (CI)

CI = (λ_max - n) / (n - 1) = (3.078 - 3) / 2 = 0.039

#### c. Consistency Ratio (CR)

Random Index (RI) for n=3 is 0.58

CR = CI / RI = 0.039 / 0.58 ≈ 0.067

### 5. Conclusion

- **Consistency Ratio (CR) = 0.067 < 0.1**, which means the **level of consistency is still acceptable.**
- The criterion weights can be used for further decision-making.

---

## ⚙️ Architecture Notes

- Uses immutable data classes (`Criteria`, `Alternative`, etc.)
- Unique ID generation via internal `_helper`
- Integrated performance profiling using `Stopwatch`
- Strong validation with helpful exceptions:
  - Duplicate IDs
  - Empty inputs
  - Invalid matrix dimensions

---

## 📈 Performance Profiling

Major method logs:
- Start and end timestamps.
- Execution duration (in milliseconds).

> Useful for debugging and optimization during development.

---
## 📌 Important

#### Because the calculations are performed on the client side, the total number of criteria and alternatives may impact your device’s performance. Please use the data wisely.

---

## 🙋‍♂️ Contributing

We welcome all contributions and suggestions!

👉 Open an issue or submit a pull request at [GitHub Repo](https://github.com/hendriari/flutter_decision_making)
