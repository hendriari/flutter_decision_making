[![pub version](https://img.shields.io/pub/v/flutter_decision_making.svg)](https://pub.dev/packages/flutter_decision_making)

**Development Status:**

This package is currently under active development. We are committed to continuously enhancing the features and algorithms to support a broader range of decision-making methods. In upcoming versions, we plan to add several popular algorithms such as SAW, TOPSIS, and other methods to provide a richer selection of decision-making techniques.

| Status | Algorithm                                                               | Available in version |
|:-------|:------------------------------------------------------------------------|:---------------------|
| ✅      | AHP (Analytic Hierarchy Process)                                        | 1.0.0                |
| ✅     | SAW (Simple Additive Weighting)                                         | 1.1.0                |
| 🔜     | TOPSIS (Technique for Order Preference by Similarity to Ideal Solution) | 1.2.0 (planned)      |

Thank you for your valuable feedback and continued support.

---

A Flutter package for criteria-based decision making using the **Analytic Hierarchy Process (AHP)** — and more to come.

This package helps you evaluate and prioritize alternatives based on weighted criteria through structured pairwise comparisons and consistency checks.

> 🧠 _This package implements the Analytic Hierarchy Process (AHP) originally developed by Thomas L. Saaty._

---

## 📌 Important

**Since calculations are performed on the client side, the total number of criteria and alternatives may affect your device’s performance. Although this package offloads heavy computations to a separate thread using Isolates, we recommend using data wisely.**

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
You can use this package in two ways depending on your needs:

1. Using all algorithms together  
   Initialize the `FlutterDecisionMaking` class to access all available algorithms (currently AHP).  
   More algorithms such as SAW and TOPSIS are planned for upcoming versions.

```dart
late FlutterDecisionMaking _decisionMaking;
AhpResult? _ahpResult;

@override
void initState() {
  super.initState();
  _decisionMaking = FlutterDecisionMaking();
}

// Usage example:
_ahpResult = await _decisionMaking.ahp.getAhpResult(...);
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

### 🛠️ User Guide

### 1. Define Criteria and Alternatives

Each item must have a unique ID. If not provided, the package auto-generates it.

```dart
final criteria = [
  AhpItem(id: 'c1', name: 'Price'),
  AhpItem(id: 'c2', name: 'Quality'),
];

final alternatives = [
  AhpItem(id: 'a1', name: 'Product A'),
  AhpItem(id: 'a2', name: 'Product B'),
];
```

### 2. Identification and Generate Hierarchy

Validate and prepare your inputs.

```dart
List<AhpHierarchy> hierarchy = await _ahp.generateHierarchy(listCriteria: criteria, listAlternative: alternatives);
```
**This hierarchy structure is essential for the next steps.**

### 3. Generate pairwise matrix inputs for criteria and alternative
```dart
/// Generate pairwise matrix criteria inputs
List<PairwiseComparisonInput> criteriaInputs = await _ahp. generateCriteriaInputs();

/// Generate pairwise matrix alternative inputs
List<PairwiseAlternativeInput> alternativeInputs = await _ahp.generateAlternativeInputs(hierarchyNodes: hierarchy);
```
After completing this process, you can render the alternatives and their corresponding criteria in your UI.

### 4. Input Pairwise Matrix and Generate Result

#### _You can use custom descriptions for each value when displaying the scale to users, but the numeric values must still conform to the Saaty scale._

#### _The package only accepts values from 1 to 9 for each comparison._

Saaty scale:

```dart
final List<AhpComparisonScale> pairwiseComparisonScales = [
  AhpComparisonScale(
    id: '1',
    description: "Equal importance of both elements",
    value: 1,
  ),
  AhpComparisonScale(
    id: '2',
    description: "Between equal and slightly more important",
    value: 2,
  ),
  AhpComparisonScale(
    id: '3',
    description: "Slightly more important",
    value: 3,
  ),
  AhpComparisonScale(
    id: '4',
    description: "Between slightly and moderately more important",
    value: 4,
  ),
  AhpComparisonScale(
    id: '5',
    description: "Moderately more important",
    value: 5,
  ),
  AhpComparisonScale(
    id: '6',
    description: "Between moderately and strongly more important",
    value: 6,
  ),
  AhpComparisonScale(
    id: '7',
    description: "Strongly more important",
    value: 7,
  ),
  AhpComparisonScale(
    id: '8',
    description: "Between strongly and extremely more important",
    value: 8,
  ),
  AhpComparisonScale(
    id: '9',
    description: "Extremely more important (absolute dominance)",
    value: 9,
  ),
];
```

We provide a method to update either criteriaInputs or alternativeInputs. You can use this method to apply updates to the input data as needed.

```dart
/// Update current criteria inputs
criteriaInputs = _ahp.updateCriteriaInputs(criteriaInputs, id: 'c1', scale: 2, isLeftMoreImportant: true);

/// Update current alternative inputs
alternativeInputs = _ahp.updateAlternativeInputs(
    alternativeInputs, 
    criteriaId:'c1', 
    alternativeId: 'a1',
    scale: 3,
    isLeftMoreImportant: false);
```

**Make sure all priority weights in the pairwise matrix are filled in before proceeding to the next step.**

Call this method to compute the final scores based on input data.

```dart
_ahpResult = await _ahp.getAhpResult(
    hierarchy: hierarchy,
    inputsCriteria: criteriaInputs,
    inputsAlternative: alternativeInputs);
```
### 🛠️ How AHP Works

#### on generate result, AHP will do

### 1. Calculate Pairwise Matrix
Calculate pairwise comparison matrix from criteria or alternatives input.

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

## 🙋‍♂️ Contributing

We welcome all contributions and suggestions!

👉 Open an issue or submit a pull request at [GitHub Repo](https://github.com/hendriari/flutter_decision_making)
