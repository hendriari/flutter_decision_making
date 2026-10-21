# decision_making_core

A pure Dart multi-criteria decision-making (MCDM) library implementing **SAW**, **TOPSIS**, and **AHP** algorithms.

- **Zero Flutter dependencies**: Can be used in CLI tools, background workers, backend microservices, or frontend applications.
- **Synchronous & fast**: Pure computational engine without Futures or event loop overhead.
- **Strictly tested**: Validated with golden datasets under a numerical tolerance of $10^{-4}$.

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
}
```

---

## License

MIT License. See [LICENSE](LICENSE) for details.
