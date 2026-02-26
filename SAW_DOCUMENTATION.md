## 📌 Important

**Since calculations are performed on the client side, the total number of criteria and alternatives may affect your device’s performance. Although this package offloads heavy computations to a separate thread using Isolates, we recommend using data wisely.**

---
## ✨ Features

- Generate decision matrix from criteria and alternatives
- Automatic weight normalization to 100%
- Support for both benefit and cost criteria
- Matrix normalization based on criteria type
- Weighted score calculation with ranking
- Isolate-based processing for large datasets (80+ alternatives or 25+ criteria)
- Comprehensive input validation with detailed error messages
- Built-in performance profiling (dev-friendly)
- Auto-generation of unique IDs for entities
- Helper function to update the rating by returning a new matrix

---
## 🔧 User Guide

**1. Define Criteria and Alternatives**

Each item should have a unique ID. If not provided, the package auto-generates it.

```dart
final criteria = [
  SawCriteria(
    id: 'c1',
    name: 'Price',
    weightPercent: 30,
    isBenefit: false,  // Cost criteria (lower is better)
    maxValue: 1000,
    // description: optional,
  ),
  SawCriteria(
    id: 'c2',
    name: 'Quality',
    weightPercent: 50,
    isBenefit: true,   // Benefit criteria (higher is better)
    maxValue: 10,
    // description: optional,
  ),
  SawCriteria(
    id: 'c3',
    name: 'Durability',
    weightPercent: 20,
    isBenefit: true,
    maxValue: 10,
    // description: optional,
  ),
];

final alternatives = [
  SawAlternative(
    id: 'a1', 
    name: 'Product A', 
    // note: optional,
    ),
  SawAlternative(
    id: 'a2', 
    name: 'Product B',
    // note: optional,
    ),
  SawAlternative(
    id: 'a3', 
    name: 'Product C',
    // note: optional,
    ),
];
```
> _Note: Criteria weights will be automatically normalized to sum to 100% if they don't already._

**2. Generate Decision Matrix**

Create the SAW matrix structure that will hold ratings for each alternative against each criterion.

```dart
List<SawMatrix> matrix = await _saw.generateSawMatrix(
  listAlternative: alternatives,
  listCriteria: criteria,
);
```
> **This matrix structure is essential for the next steps. All ratings are initialized to 0.**

**3. Fill Matrix with Rating Values**

After generating the matrix, you need to fill in the rating values for each alternative-criteria pair. The rating value must not exceed the maxValue defined in each criterion.

```dart
// Example: Update ratings for Product A
matrix = await _saw.updateSawMatrix(
  currentMatrix: matrix,
  matrixId: selectedMatrixId,
  ratingsId: selectedRatingsId,
  value: value // must be number
);

// Repeat for other alternatives...
```
> **Important Validation Rules:**
> - All rating values must be filled (cannot be null)
> - Values cannot exceed the maxValue of their corresponding criteria
> - Cost criteria (isBenefit = false) cannot have zero values

**4. Calculate SAW Results**

Once all ratings are filled, calculate the final scores and rankings.

```dart
List<SawResult> results = await datasource.calculateSawResult(
  matrix: matrix,
);

// Results are automatically sorted by score (highest to lowest)
// and assigned ranks (1 = best)
for (var result in results) {
  print('${result.rank}. ${result.alternative.name}: ${result.score.toStringAsFixed(4)}');
}
```
**Alternative: Calculate with Existing Matrix**

```dart
List<SawResult> results = await datasource.calculateResultWithExistingMatrix(
  matrix: existingMatrix,
);
```

This method will:

- Validate all IDs
- Normalize criteria weights
- Validate rating values
- Calculate results

## 🛠️ How SAW Works

**On generating results, SAW performs these steps:**

**1. Input Validation**

- Checks that alternatives and criteria lists are not empty
- Validates that all criteria weights are non-negative
- Ensures total weight is not zero
- Verifies rating values don't exceed maxValue

**2. Weight Normalization**

- Automatically normalizes criteria weights to sum to 100%
- Proportionally adjusts all weights if needed

**3. Matrix Normalization**

- For benefit criteria (higher is better): `normalized = value / max_value`
- For cost criteria (lower is better): `normalized = min_value / value`
- If all values are equal: `normalized = 1`

**4. Score Calculation**

- Calculates weighted sum for each alternative: `score = Σ(normalized_value × weight)`
- Sorts alternatives by score in descending order
- Assigns ranks (1 = highest score)

```dart
class SawResult {
  final String? id;
  final SawAlternative alternative;
  final double score;           // Weighted sum (0.0 to 1.0)
  final int rank;               // Position in ranking (1 = best)

  SawResult({
    this.id,
    required this.alternative,
    required this.score,
    required this.rank,
  });
}
```

---
## 🔍 Sample Case

Problem: Selecting the best laptop among three options based on Price, Performance, and Battery Life.

**1. Define Criteria**

| Criteria     | Weight | Type    | Max Value  |
|--------------|--------|---------|------------|
| Price        | 35%    | Cost    | 2000       |
| Performance  | 40%    | Benefit | 100        |
| Battery Life | 25%    | Benefit | 200        |

**2. Rate Alternatives (Raw Values)**

|          | Price | Performance | Battery Life |
|----------|-------|-------------|--------------|
| Laptop A | 1500  | 85          | 12           |
| Laptop B | 1200  | 75          | 15           |
| Laptop C | 1800  | 90          | 10           |

**3. Matrix Normalization**

For **Price** (cost criteria): normalized = min_value / value

- Min price = 1200
- Laptop A: 1200/1500 = 0.800
- Laptop B: 1200/1200 = 1.000
- Laptop C: 1200/1800 = 0.667

For **Performance** (benefit criteria): normalized = value / max_value

- Max performance = 90
- Laptop A: 85/90 = 0.944
- Laptop B: 75/90 = 0.833
- Laptop C: 90/90 = 1.000

For **Battery Life** (benefit criteria): normalized = value / max_value

- Max battery = 15
- Laptop A: 12/15 = 0.800
- Laptop B: 15/15 = 1.000
- Laptop C: 10/15 = 0.667

|          | Price | Performance | Battery Life |
|----------|-------|-------------|--------------|
| Laptop A | 0.800 | 0.944       | 0.800        |
| Laptop B | 1.000 | 0.833       | 1.000        |
| Laptop C | 0.667 | 1.000       | 0.667        |

**4. Calculate Weighted Scores**

**Laptop A:**

- Score = (0.800 × 0.35) + (0.944 × 0.40) + (0.800 × 0.25)
- Score = 0.280 + 0.378 + 0.200 = **0.858**

**Laptop B:**

- Score = (1.000 × 0.35) + (0.833 × 0.40) + (1.000 × 0.25)
- Score = 0.350 + 0.333 + 0.250 = **0.933**

**Laptop C:**

- Score = (0.667 × 0.35) + (1.000 × 0.40) + (0.667 × 0.25)
- Score = 0.233 + 0.400 + 0.167 = **0.800**

**5. Final Ranking**

| Rank | Alternative | Score | Conclusion           |
|------|-------------|-------|----------------------|
| 1    | Laptop B    | 0.993 | Best Choice          |
| 2    | Laptop A    | 0.858 | Second Best          |
| 3    | Laptop C    | 0.800 | Last Prefered Option |

**Interpretation:**

- Laptop B is the best choice with the highest score (0.933), offering the best balance of low price and good battery life
- Laptop A ranks second (0.858) with excellent performance but higher price
- Laptop C ranks last (0.800) despite having the best performance, due to its high price and shorter battery life

---

## ⚙️ Architecture Notes

- Uses immutable data classes (`SawAlternative`, `SawCriteria`, `SawMatrix`, etc.)

- Unique ID generation via internal `Uuid Package`

- Integrated performance profiling using `Stopwatch`

- Strong validation with helpful exceptions:
    - Empty lists
    - Invalid weights
    - Missing IDs
    - Zero values in cost criteria
    - Values exceeding maxValue
- Automatic weight normalization to 100%
- Type-safe criterion handling (benefit vs cost)

---

## 🎯 Best Practices

**1. Criteria Definition:**

- Clearly define whether each criterion is benefit or cost type
- Set realistic maxValue for each criterion
- Ensure weights reflect the relative importance of criteria


**2. Rating Values:**

- Use consistent scales across all alternatives for each criterion
- Avoid zero values in cost criteria
- Ensure all values are within the defined maxValue


**3. Performance:**

- The package automatically uses isolates for large datasets
- For web platforms, be mindful of dataset size as isolates are not available
- Consider breaking very large problems into smaller sub-problems


**4. Validation:**

- Let the package auto-generate IDs if you don't need custom ones
- Use calculateResultWithExistingMatrix when working with stored/loaded matrices
- Check exception messages for detailed validation feedback

--- 

## 🚨 Common Errors and Solutions

| Error                                 | Cause                       | Solution                                         |
|---------------------------------------|-----------------------------|--------------------------------------------------|
|"Alternatives list cannot be empty!"   | No alternatives provided    | Add at least one alternative                     |
|"Zero value found in cost criteria"    | Cost criterion has 0 rating | Use positive values for cost criteria            |
|"Value exceeds maximum"                | Rating > maxValue           | Ensure ratings don't exceed criterion's maxValue |
|"Total criteria weight cannot be zero" | All weights are 0           | Set positive weights for criteria                |
|"Weight cannot be negative"            | Negative weight value       | Use only non-negative weights                    |
