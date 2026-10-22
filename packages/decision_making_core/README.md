# decision_making_core

A pure Dart multi-criteria decision-making (MCDM) library implementing **SAW**, **TOPSIS**, and **AHP** algorithms.

- **Zero Flutter dependencies**: Can be used in CLI tools, background workers, backend microservices, or frontend applications.
- **Synchronous & fast**: Pure computational engine without Futures or event loop overhead.
- **Strictly tested**: Validated with golden datasets under a numerical tolerance of 1e-4.

---

## Installation

Add `decision_making_core` to your `pubspec.yaml`:

```yaml
dependencies:
  decision_making_core: ^0.1.0
```

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

## Existing Behavior & Edge Cases

The core calculation engines maintain consistent mathematical specifications for edge cases:

- **SAW cost criteria with value 0:** If a cost criterion receives a rating value of `0.0`, an explicit `Exception("Rating value cannot be 0 for cost criteria")` is thrown to prevent division by zero (`min / 0.0`) or infinite scores.
- **TOPSIS all-zero column:** When all alternatives have a value of `0.0` for a criterion (resulting in Euclidean norm = 0.0), each normalized cell safely evaluates to `0.0` instead of `NaN` or divide-by-zero.
- **TOPSIS equidistant alternatives (D+ = D- = 0):** When all alternatives have identical distance to ideal solutions (such as single-alternative datasets or identical rows where `D+ = 0.0` and `D- = 0.0`), the relative closeness formula `D- / (D+ + D-)` safely resolves to a neutral score of `0.5` instead of `NaN`.

---

## License

MIT License. See [LICENSE](LICENSE) for details.
