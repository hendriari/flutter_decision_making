> 🧠 _This package implements the Analytic Hierarchy Process (AHP) originally developed by Thomas L. Saaty._

---

## 📌 Important

**Since calculations are performed on the client side, the total number of criteria and alternatives may affect your device's performance. Although this package offloads heavy computations to a separate thread using Isolates for datasets with more than 15 criteria or alternatives, we recommend using data wisely.**

---
## ✨ Features

- Generate hierarchy from criteria and alternatives
- Pairwise comparisons using Saaty's 1–9 scale
- Built-in Saaty comparison scale (no need to define manually)
- Requires manual filling of paired comparison values for criteria and alternatives for valid analysis
- Complete validation and exceptions if there are values that have not been filled in
- Consistency Ratio check to ensure logical consistency (CR ≤ 0.1 for acceptable results)
- Eigenvector and final score calculation using normalized column averaging method
- Automatic isolate processing for large datasets (>15 items on non-web platforms)
- Customizable and extendable architecture with Clean Architecture pattern
- Built-in performance profiling (dev-friendly)
- Auto-generation of unique IDs for all entities

---
## 🔧 User Guide

**➛ Getting Started**

First, initialize the AHP instance:

---

```dart
final _ahp = AHP();
```
This is your main interface for all AHP operations.

**➛ Step 1: Define Criteria and Alternatives**

Each item must have a unique ID. If not provided, the package auto-generates it.

```dart
final criteria = [
  AhpItem(id: 'c1', name: 'Price'),
  AhpItem(id: 'c2', name: 'Quality'),
  AhpItem(id: 'c3', name: 'Performance'),
];

final alternatives = [
  AhpItem(id: 'a1', name: 'Product A'),
  AhpItem(id: 'a2', name: 'Product B'),
  AhpItem(id: 'a3', name: 'Product C'),
];
```
---
**➛ Step 2: Generate Hierarchy**

Validate and prepare your inputs. This creates the decision structure linking criteria to alternatives.

```dart
List<AhpHierarchy> hierarchy = await _ahp.generateHierarchy(
  listCriteria: criteria, 
  listAlternative: alternatives
);
```

**This hierarchy structure is essential for the next steps.**
- Validates inputs (checks for empty lists)
- Assigns unique IDs to items without IDs
- Stores identification data internally for later use

**Throws:**

- Exception if criteria or alternatives are empty
- Exception if count exceeds 100 items

---

**➛ Step 3: Generate Pairwise Comparison Templates**

Generate templates for both criteria and alternatives that you'll fill with user comparisons.

```dart
/// Generate pairwise matrix criteria inputs
List<PairwiseComparisonInput> criteriaInputs = await _ahp.generateCriteriaInputs();

/// Generate pairwise matrix alternative inputs
List<PairwiseAlternativeInput> alternativeInputs = await _ahp.generateAlternativeInputs(
  hierarchyNodes: hierarchy
);
```
**Important:**

- `generateCriteriaInputs()` must be called AFTER `generateHierarchy()`
- `generateAlternativeInputs()` requires the hierarchy structure

**Number of Comparisons Generated:**

- For n criteria: n(n-1)/2 comparisons
- For n alternatives per criterion: n(n-1)/2 comparisons × number of criteria

Examples:

- 3 criteria = 3 comparisons
- 4 criteria = 6 comparisons
- 5 alternatives × 3 criteria = 10 × 3 = 30 comparisons

After completing this process, you can render the alternatives and their corresponding criteria in your UI.

---

**➛ Step 4: Get Saaty Comparison Scale**

The package provides a built-in Saaty scale that you can use directly in your UI:


```dart
final scales = _ahp.listAhpPairwiseComparisonScale;

// Returns a list of AhpComparisonScale with values 1-9
for (var scale in scales) {
  print('${scale.value}: ${scale.description}');
}
```
**Built-in Saaty Scale:**

| Value | Description                                   |
|-------|-----------------------------------------------|
|1      | Equal importance of both elements             |
|2      | Between equal and slightly more important     |
|3      | Slightly more important                       |
|4      | Between slightly and moderately more important|
|5      | Moderately more important                     |
|6      | Between moderately and strongly more important|
|7      | Strongly more important                       |
|8      | Between strongly and extremely more important |
|9      | Extremely more important (absolute dominance) |

**_You can use custom descriptions for each value when displaying the scale to users, but the numeric values must still conform to the Saaty scale (1-9)._**

---

**➛ Step 5: Fill Pairwise Comparisons**

Use the update methods to fill in user comparisons. These methods return updated copies of the input lists.

**Update Criteria Comparisons:**

```dart
// User selects that criteria 'c1' is moderately more important than 'c2' (scale: 5)
criteriaInputs = _ahp.updateCriteriaInputs(
  criteriaInputs, 
  id: 'c1',  // ID of the comparison (not the criteria)
  scale: 5, 
  isLeftMoreImportant: true
);
```

**Update Alternative Comparisons:**

```dart
// User selects that alternative 'a1' is slightly more important than 'a2' 
// when evaluated under criteria 'c1'
alternativeInputs = _ahp.updateAlternativeInputs(
  alternativeInputs, 
  criteriaId: 'c1',      // Which criterion these alternatives are being compared under
  alternativeId: 'a1',   // ID of the comparison
  scale: 3,
  isLeftMoreImportant: false
);
```

**Important Notes:**

- The `id` parameter in `updateCriteriaInputs` refers to the comparison ID, not the criteria ID
- The `alternativeId` parameter refers to the comparison ID within the alternatives list
- `isLeftMoreImportant` determines the direction: `true` = left item is preferred, `false` = right item is preferred
- Both methods return new lists; assign the result back to your variables

**Make sure all pairwise comparison values are filled in before proceeding to the next step.**

---

**➛ Step 6: Calculate Results**

Once all comparisons are complete, calculate the final AHP scores:

```dart
AhpResult result = await _ahp.getAhpResult(
  hierarchy: hierarchy,
  inputsCriteria: criteriaInputs,
  inputsAlternative: alternativeInputs
);

// Access results
for (var item in result.results) {
  print('${item.name}: ${item.value.toStringAsFixed(4)}');
}

// Check consistency
if (result.isConsistentCriteria && result.isConsistentAlternative) {
  print('All comparisons are consistent!');
} else {
  print('Warning: ${result.note}');
}
```

**Validation Before Calculation:**

The method validates that:

- All preferenceValue fields are filled (not null)
- All isLeftMoreImportant flags are set (not null)

**Throws:**

- Exception: "Please complete all values from the criteria scale"
- Exception: "Please complete which more important from the criteria"
- Exception: "Please complete all values from the alternative scale"
- Exception: "Please complete which more important from the alternative"

---

## 🛠️ How AHP Works

**When generating results, AHP performs these steps:**

**➛ 1. Generate Pairwise Comparison Matrices**
- For criteria: one n×n matrix where n = number of criteria
- For alternatives: m matrices where m = number of criteria, each with size k×k where k = number of alternatives

**Matrix Properties:**

- Diagonal elements = 1.0 (item compared to itself)
- Reciprocal: if matrix[i][j] = x, then matrix[j][i] = 1/x
- Positive values only (typically 1/9 to 9)

**Example Matrix (3 criteria):**

|   | C1    | C2    | C3    |
|---|-------|-------|-------|
|C1 | 1.000 | 3.000 | 5.000 |
|C2 | 0.333 | 1.000 | 2.000 |
|C3 | 0.200 | 0.500 | 1.000 |

---

**➛ 2. Calculate Eigenvectors (Priority Vectors)**

Uses the **Normalized Column Averaging Method**:

1. Calculate column sums: `colSum[j] = Σ(matrix[i][j])` for all i
2. Normalize each column: `normalized[i][j] = matrix[i][j] / colSum[j]`
3. Calculate row averages: `priority[i] = (Σ(normalized[i][j])) / n` for all j

This produces priority weights that sum to 1.0.

**Example Calculation:**

From the matrix above:

- Column sums: [1.533, 4.500, 8.000]
- After normalization and averaging: [0.633, 0.260, 0.107]
- Interpretation: C1 is most important (63.3%), followed by C2 (26.0%), then C3 (10.7%)

---

**➛ 3. Check Consistency Ratio (CR)**

Validates the logical consistency of pairwise comparisons.

**Formula:**

```
λmax = (1/n) × Σ(weightedSum[i] / priority[i])
CI = (λmax - n) / (n - 1)
CR = CI / RI
```

Where:

- λmax = maximum eigenvalue
- CI = Consistency Index
- RI = Random Index (from Saaty's table, varies by matrix size)

**Random Index (RI) Table:**

| n | 1-2 | 3     | 4     | 5     | 6     | 7     | 8     | 9     | 10    | 11    | 12    | 13    | 14    | 15+ |
|---|-----|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-----|
| RI| 0.0 | 0.58  | 0.90  | 1.12  | 1.24  | 1.32  | 1.41  | 1.45  | 1.49  | 1.51  | 1.48  | 1.56  | 1.57  | 1.59|

**Acceptability Criteria:**

- **CR ≤ 0.1**: Acceptable consistency ✅
- **0.1 < CR ≤ 0.2**: Marginal, consider revising ⚠️
- **CR > 0.2**: Unacceptable, must revise ❌

**Note**: The code uses epsilon comparison (`(cr - 0.1) > 1e-5`) to handle floating-point precision issues.

---

**➛ 4. Calculate Final Scores**

Combines criteria weights with alternative priorities:

**Formula:**

```
Score(alternative_i) = Σ(weight_criteria_j × priority_alternative_i_under_criteria_j)
```

For each alternative:

- Multiply its priority under each criterion by that criterion's weight
- Sum all weighted priorities
- Sort alternatives by final score (highest first)

---

**➛ 5. Result Structure**

The result includes comprehensive information:

```dart
class AhpResult {
  final List<AhpResultDetail> results;        // Sorted alternatives with scores
  final bool isConsistentCriteria;            // Criteria consistency status
  final double consistencyCriteriaRatio;      // CR for criteria
  final bool isConsistentAlternative;         // Worst alternative consistency status
  final double consistencyAlternativeRatio;   // Highest CR among alternatives
  final String? note;                         // Warning message if inconsistent
}

class AhpResultDetail {
  final String? id;
  final String name;
  final double value;  // Final score (0.0 to 1.0)
}
```

**Note Field:**

If any inconsistencies are detected (CR > 0.1), the `note` field contains a detailed message:

- Which comparisons are inconsistent (criteria/alternatives)
- Their CR values
- Recommendation to revise assessments

---

## 🔍 Sample Case

**Problem**: Selecting the best smartphone among three options based on Price, Camera Quality, and Battery Life.

**➛ 1. Define Problem**

Criteria:

- Price (how affordable it is)
- Camera Quality (photo/video capabilities)
- Battery Life (how long it lasts)

Alternatives:

- Phone A: Budget-friendly, decent camera, excellent battery
- Phone B: Mid-range price, excellent camera, good battery
- Phone C: Expensive, good camera, average battery

---

**➛ 2. Pairwise Comparison Matrix - Criteria**

User judgments:

- Camera Quality is moderately more important than Price (scale: 5)
- Camera Quality is strongly more important than Battery Life (scale: 7)
- Price is slightly more important than Battery Life (scale: 3)

**Resulting Matrix:**

|         | Price    | Camera  | Battery |
|---------|----------|---------|---------|
|Price    | 1.000    | 0.200   | 3.000   |
|Camera   | 5.000    | 1.000   | 7.000   |
|Battery  | 0.333    | 0.143   | 1.000   |

---

**➛ 3. Matrix Normalization - Criteria**

**Column totals:**

- Price: 6.333
- Camera: 1.343
- Battery: 11.000

**Normalized matrix:**

|         | Price    | Camera  | Battery |
|---------|----------|---------|---------|
|Price    | 0.158    | 0.149   | 0.273   |
|Camera   | 0.789    | 0.745   | 0.636   |
|Battery  | 0.053    | 0.106   | 0.091   |

---

**➛ 4. Eigenvector (Criteria Priority Weights)**

Row averages of normalized matrix:

| Criterion | Priority | Percentage |
|-----------|----------|------------|
|Price      | 0.193    | 19.3%      |
|Camera     | 0.723    | 72.3%      |
|Battery    | 0.083    | 8.3%       |

**Interpretation:**

- Camera Quality is the most important factor (72.3%)
- Price is moderately important (19.3%)
- Battery Life has low importance (8.3%)

---

**➛ 5. Consistency Ratio (CR) - Criteria**

**Calculation:**

a. Weighted sums:

- Price: (1.000 × 0.193) + (0.200 × 0.723) + (3.000 × 0.083) = 0.586
- Camera: (5.000 × 0.193) + (1.000 × 0.723) + (7.000 × 0.083) = 2.229
- Battery: (0.333 × 0.193) + (0.143 × 0.723) + (1.000 × 0.083) = 0.251

b. λmax = (0.586/0.193 + 2.229/0.723 + 0.251/0.083) / 3 = 3.082

c. CI = (3.082 - 3) / (3 - 1) = 0.041

d. CR = 0.041 / 0.58 = 0.071

**Result**: CR = 0.071 < 0.1 ✅ **Acceptable consistency!**

---

**➛ 6. Alternative Comparisons (simplified)**

For each criterion, compare alternatives:

**Under Price criterion**:

- Phone A is strongly preferred over Phone B (scale: 7)
- Phone A is extremely preferred over Phone C (scale: 9)
- Phone B is moderately preferred over Phone C (scale: 5)

Resulting priorities: A = 0.717, B = 0.217, C = 0.066

**Under Camera criterion**:

- Phone B is strongly preferred over Phone A (scale: 7)
- Phone B is moderately preferred over Phone C (scale: 5)
- Phone C is slightly preferred over Phone A (scale: 3)

Resulting priorities: A = 0.123, B = 0.717, C = 0.160

**Under Battery criterion**:

- Phone A is strongly preferred over Phone B (scale: 7)
- Phone A is extremely preferred over Phone C (scale: 9)
- Phone B is moderately preferred over Phone C (scale: 5)

Resulting priorities: A = 0.717, B = 0.217, C = 0.066

---

**➛ 7. Final Score Calculation**

**Formula**: Score = (Price weight × Price priority) + (Camera weight × Camera priority) + (Battery weight × Battery priority)

**Phone A**:

- Score = (0.193 × 0.717) + (0.723 × 0.123) + (0.083 × 0.717)
- Score = 0.138 + 0.089 + 0.060 = **0.287**

**Phone B**:

- Score = (0.193 × 0.217) + (0.723 × 0.717) + (0.083 × 0.217)
- Score = 0.042 + 0.518 + 0.018 = **0.578**

**Phone C**:

- Score = (0.193 × 0.066) + (0.723 × 0.160) + (0.083 × 0.066)
- Score = 0.013 + 0.116 + 0.005 = **0.134**

---

**➛ 8. Final Ranking**

| Rank | Alternative | Score |  Conclusion                                            |
|------|-------------|-------|--------------------------------------------------------|
|1     | Phone B     | 0.578 | Best choice - Excellent camera outweighs higher price  |
|2     | Phone A     | 0.287 | Second best - Good budget option but camera is weak    |
|3     | Phone C     | 0.134 | Least preferred - High price without enough advantages |

---

**➛ 9. Consistency Check Summary**

**Criteria Consistency:**

CR = 0.071 ✅ Acceptable

**Alternative Consistency (assume all acceptable):**

Under Price: CR = 0.045 ✅
Under Camera: CR = 0.052 ✅
Under Battery: CR = 0.045 ✅

**Overall**: All comparisons are consistent. The results are reliable for decision-making.

---

## ⚙️ Architecture Notes

**Design Patterns**

- Clean Architecture: Separates data, domain, and presentation layers
- Repository Pattern: Abstracts data source access
- Use Case Pattern: Encapsulates business logic for each operation
- Immutable Data Classes: All entities use immutable patterns with copyWith()

**Key Components**

- AHP Class: Main interface wrapping all functionality
- AhpLocalDatasource: Core algorithm implementation
- AhpRepository: Repository interface for data operations
- Use Cases: Individual operations (identification, hierarchy generation, calculation, etc.)
- DTOs & Mappers: Data transfer objects for isolate communication

**Internal State Management**

The `AHP` class maintains internal state:

```dart
AhpIdentification _currentAhpIdentification
```

This stores validated criteria and alternatives after `generateHierarchy()` is called, allowing subsequent operations without re-passing this data.

**Performance Optimizations**

- Unique ID Generation: Uses `DecisionMakingHelper.getCustomUniqueId()`
- Integrated Performance Profiling: All major operations tracked with `Stopwatch`
- Automatic Isolate Usage:
    - Triggered when criteria OR alternatives > 15 items
    - Only on non-web platforms (web doesn't support isolates)
    - Flag `_useIsolate` controls processing mode
- Efficient Matrix Operations: O(n²) algorithms for eigenvector calculation

**Validation & Error Handling**

Strong validation at every step:

- Empty input checks
- Duplicate ID detection
- Matrix dimension validation
- Consistency ratio validation
- Null value checks
- Helpful exception messages with context

**Consistency Tolerance**

Uses epsilon comparison for floating-point:

```
if ((cr - 0.1) > 1e-5)  // Not just: if (cr > 0.1)
```

This prevents false negatives from floating-point precision issues.

---

## 🎯 Best Practices

**1. Data Preparation**

- Limit to 15 or fewer items for optimal web performance
- Use meaningful names for criteria and alternatives
- Provide IDs if you need specific identification (otherwise auto-generated)
- Keep hierarchy depth simple (criteria → alternatives, no sub-criteria)

**2. Making Comparisons**

- Be consistent: If A > B and B > C, then A should be > C
- Use appropriate scale values: Don't overuse extreme values (9)
- Take your time: Thoughtful comparisons produce better results
- Review CR: If CR > 0.1, revise your judgments

**3. Scale Usage Guidelines**

| Value | Description                                |
|-------|--------------------------------------------|
|1      | Elements are equally important             |
|2-3    | One element is slightly more important     |
|4-5    | One element is moderately more important   |
|6-7    | One element is strongly more important     |
|8-9    | One element dominates the other            |

**4. Interpreting Results**

- Scores are relative, not absolute measures
- Small differences in scores may not be meaningful
- Check consistency before making final decisions
- Consider the context - numbers don't tell the whole story

**5. Performance Considerations**

- For web apps: Keep criteria + alternatives ≤ 30 total
- For mobile/desktop: Up to 100 items supported
- Large datasets: Consider breaking into sub-problems
- Isolate threshold: Automatically handled at 15+ items

**6. Error Prevention**

```dart
try {
  final result = await _ahp.getAhpResult(
    hierarchy: hierarchy,
    inputsCriteria: criteriaInputs,
    inputsAlternative: alternativeInputs,
  );
  
  if (!result.isConsistentCriteria || !result.isConsistentAlternative) {
    // Handle inconsistency
    showWarning(result.note);
  }
  
  // Use results
  displayResults(result.results);
  
} catch (e) {
  // Handle errors gracefully
  showError('Failed to calculate: $e');
}
```

---

## 🚨 Error Handling

**Common Errors and Solutions**

| Error Message                     | When It Occurs                                                  | Solution                                 |
|-----------------------------------|-----------------------------------------------------------------|------------------------------------------|
|"Criteria can't be empty!"         | Calling `generateHierarchy()` with empty criteria list          | Provide at least one criterion           |
|"Alternative can't be empty!"      | Calling `generateHierarchy()` with empty alternatives list      | Provide at least one alternative         |
|"Too much data, please limit..."   | Criteria or alternatives exceed 100 items                       | Reduce the number of items to ≤100       |
|"Please generate hierarchy first!" | Calling `generateCriteriaInputs()` before `generateHierarchy()` | Call `generateHierarchy()` first         |
|"Please complete all values..."    | Calculating results with unfilled comparisons                   | Fill all comparison values               |
|"Matrix must be square..."         | Internal error in eigenvector calculation                       | Check for data corruption                |
|"Alternative matrix is empty"      | No alternatives provided for final score                        | Ensure alternatives are properly defined |

**Handling Consistency Warnings**

When CR > 0.1, the result will include:

- `isConsistentCriteria` or `isConsistentAlternative` = false
- `note` field with detailed explanation

**Recommended Actions:**

1. Review the specific comparisons mentioned in the note
2. Check for logical inconsistencies (e.g., A>B, B>C, but C>A)
3. Revise judgments to be more consistent
4. Recalculate results

```dart
if (!result.isConsistentCriteria) {
  print('Criteria comparisons are inconsistent!');
  print('CR: ${result.consistencyCriteriaRatio}');
  print(result.note);
  // Prompt user to revise criteria comparisons
}
```

---

## 📚 Additional Resources

**Further Reading**

- Saaty, T.L. (1980). The Analytic Hierarchy Process. McGraw-Hill.
- Saaty, T.L. (2008). "Decision making with the analytic hierarchy process." International Journal of Services Sciences.

**When to Use AHP**

**✅ Good for:**

- Multi-criteria decision problems
- Subjective judgments needed
- Hierarchy of objectives exists
- Need for consistency checking
- Stakeholder consensus building

**❌ Not ideal for:**

- Purely objective data (use weighted sum instead)
- Real-time decisions (computation intensive)
- Extremely large datasets (>100 items)
  -Simple binary choices