## 📌 Important

**Since calculations are performed on the client side, the total number of criteria and alternatives may affect your device’s performance. Although this package offloads heavy computations to a separate thread using Isolates, we recommend using data wisely.**

---
## ✨ Features

- Generate decision matrix from criteria and alternatives
- Automatic weight normalization to 100%
- Support for both benefit and cost criteria
- **Euclidean Normalization** for matrix scaling
- **Ideal Solution Identification** (Positive A+ and Negative A-)
- **Separation Measure** calculation (Euclidean Distance)
- **Relative Closeness** calculation for final ranking
- Isolate-based processing for large datasets (80+ alternatives or 25+ criteria)
- Comprehensive input validation with detailed error messages
- Built-in performance profiling (dev-friendly)
- Auto-generation of unique IDs for entities

---
## 🔧 User Guide

**1. Define Criteria and Alternatives**

Each item should have a unique ID. If not provided, the package auto-generates it.

```dart
final criteria = [
  WeightedDecisionCriteria(
    id: 'c1',
    name: 'Price',
    weightPercent: 30,
    isBenefit: false,  // Cost criteria (lower is better)
    maxValue: 1000,
  ),
  WeightedDecisionCriteria(
    id: 'c2',
    name: 'Quality',
    weightPercent: 50,
    isBenefit: true,   // Benefit criteria (higher is better)
    maxValue: 10,
  ),
];

final alternatives = [
  WeightedDecisionAlternative(id: 'a1', name: 'Product A'),
  WeightedDecisionAlternative(id: 'a2', name: 'Product B'),
];
```

**2. Generate Decision Matrix**

Create the TOPSIS matrix structure.

```dart
TopsisRawMatrix rawMatrix = await _topsis.generateTopsisMatrix(
  listAlternative: alternatives,
  listCriteria: criteria,
);
```

**3. Fill Matrix with Rating Values**

Fill in the rating values for each alternative-criteria pair. Values must not exceed the `maxValue`.

**4. Calculate TOPSIS Results**

Once all ratings are filled, calculate the final scores and rankings.

```dart
List<WeightedDecisionResult> results = await datasource.calculateResult(
  rawMatrix: rawMatrix,
);

// Results are sorted by closeness coefficient (highest to lowest)
for (var result in results) {
  print('${result.rank}. ${result.alternative.name}: ${result.score.toStringAsFixed(4)}');
}
```

---
## 🛠️ How TOPSIS Works

**The algorithm follows these steps:**

**1. Euclidean Normalization**
Scales the values so the sum of squares in each column is 1.
`r_ij = x_ij / sqrt(Σ x_ij²)`

**2. Weighted Normalized Matrix**
Multiplies normalized values by criteria weights.
`v_ij = w_j * r_ij`

**3. Ideal Solutions (A+ and A-)**
- **Benefit Criteria**: A+ = Max(v), A- = Min(v)
- **Cost Criteria**: A+ = Min(v), A- = Max(v)

**4. Separation Measures (Distance)**
Calculates Euclidean distance to ideal solutions.
- `D+ = sqrt(Σ (v_ij - A+j)²)`
- `D- = sqrt(Σ (v_ij - A-j)²)`

**5. Relative Closeness (Score)**
Calculates the final score (Preference Value).
`Score = D- / (D+ + D-)`

---
## 🔍 Sample Case

Problem: Selecting a laptop based on Price (Cost) and Performance (Benefit).

**1. Raw Data**
- Laptop A: Price 1500, Performance 85
- Laptop B: Price 1200, Performance 75

**2. Euclidean Normalization**
- Price Divider: `sqrt(1500² + 1200²) = 1920.94`
- Performance Divider: `sqrt(85² + 75²) = 113.36`

Normalized Matrix:
- Laptop A: Price 0.781, Performance 0.750
- Laptop B: Price 0.625, Performance 0.661

**3. Weighted Matrix (Weight: Price 40%, Performance 60%)**
- Laptop A: Price 0.312, Performance 0.450
- Laptop B: Price 0.250, Performance 0.397

**4. Ideal Solutions**
- Price (Cost): A+ = 0.250 (Min), A- = 0.312 (Max)
- Perf (Benefit): A+ = 0.450 (Max), A- = 0.397 (Min)

**5. Distances & Final Score**
- **Laptop A**: D+ = 0.062, D- = 0.053 -> Score = **0.461**
- **Laptop B**: D+ = 0.053, D- = 0.062 -> Score = **0.539**

**Result**: Laptop B is preferred because it has a higher relative closeness to the ideal solution.

---
## 🚨 Common Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| "Bad state: No element" | Matrix/Criteria ID mismatch | Ensure IDs are consistent or use `calculateResultWithExistingMatrix` |
| "Value exceeds maximum" | Rating > maxValue | Check input against criterion's maxValue |
| "Total weight cannot be zero" | Sum of weights = 0 | Provide valid positive weights |
