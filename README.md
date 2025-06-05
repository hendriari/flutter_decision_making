[![pub version](https://img.shields.io/pub/v/flutter_decision_making.svg)](https://pub.dev/packages/flutter_decision_making)


A Flutter package for implementing multi-criteria decision-making using the **Analytic Hierarchy Process (AHP)**.

Easily manage criteria, alternatives, pairwise comparisons, consistency checks, and final decision scoring — all in one unified package.

> 🧠 _This package implements the Analytic Hierarchy Process (AHP) originally developed by Thomas L. Saaty._

---

## ✨ Features

- 🏗 Generate hierarchy from criteria and alternatives
- ⚖️ Pairwise comparisons using Saaty's 1–9 scale
- ✅ Consistency Ratio check to ensure logical consistency
- 📊 Eigenvector and final score calculation
- 🔧 Customizable and extendable architecture
- 🛠 Built-in performance profiling (dev-friendly)

---

## 🚀 Getting Started
Initialize the FlutterDecisionMaking instance before using other methods.

```dart
late FlutterDecisionMaking _decisionMaking;

 @override
  void initState() {
    super.initState();
    _decisionMaking = FlutterDecisionMaking();
```

## 📚 Usage Guide

### 🛠️ User Role

### 1. 🧱 Define Criteria and Alternatives

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

### 2. 🧮 Identification, Generate Hierarchy and Generate Pairwise Comparison Input

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

### 3. 🔁 Generate Result

Call this method to compute the final scores based on input data.

```dart
await _decisionMaking.generateResult()
```
### 🛠️ AHP Role

#### on generate result, AHP will do

### 1. 🧮 Generate Pairwise Matrix
Create a pairwise comparison matrix from criteria or alternatives input.

### 2. 🧮 Calculate Approximate Eigenvector
Calculate priority weights (eigenvector) from the pairwise matrix.

### 3. 🧮 Check Consistency Ratio
Compute and verify matrix consistency using the Consistency Ratio (CR).

### 4. 🧮 Calculate Result
Calculate final scores for alternatives based on criteria and alternative weights, including consistency checks.

The result includes:
- Sorted list of alternative scores (`results`)
- Consistency status and ratio for criteria and alternatives
- Additional notes on consistency issues (if any)

```dart
final ahpResult = AhpResult(
        results: ahpResultDetail..sort((a, b) => b.value.compareTo(a.value)), // list result
        isConsistentCriteria: consistencyCriteria.isConsistent, /// boolean
        consistencyCriteriaRatio: consistencyCriteria.ratio, // double
        isConsistentAlternative: alternativesConsistency[0].isConsistent, // boolean
        consistencyAlternativeRatio: alternativesConsistency[0].ratio, // double
        note: note, // string
      );
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

- 🧩 Uses immutable data classes (`Criteria`, `Alternative`, etc.)
- 🔑 Unique ID generation via internal `_helper`
- ⏱ Integrated performance profiling using `Stopwatch`
- 🧼 Strong validation with helpful exceptions:
  - Duplicate IDs
  - Empty inputs
  - Invalid matrix dimensions

---

## 📈 Performance Profiling

Every major method logs:
- ⏱ Start and end timestamps.
- ⌛ Execution duration (in milliseconds).

> Great for debugging and optimization during development.

---
## 📌 Important

#### Because the calculations are performed on the client side, the total number of criteria and alternatives may impact your device’s performance. Please use the data wisely.

---

## 🙋‍♂️ Contributing

We welcome all contributions and suggestions!

👉 Open an issue or submit a pull request at [GitHub Repo](https://github.com/hendriari/flutter_decision_making)
