import 'dart:math';

import 'package:flutter_decision_making/flutter_decision_making.dart';

class BenchmarkDataGenerator {
  static (
    List<WeightedDecisionAlternative>,
    List<WeightedDecisionCriteria>,
    List<WeightedDecisionMatrix>
  ) generateDataset({
    required int alternativesCount,
    required int criteriaCount,
    int seed = 42,
  }) {
    final rng = Random(seed);

    final rawWeights =
        List.generate(criteriaCount, (_) => 10.0 + rng.nextDouble() * 90.0);
    final totalRawWeight = rawWeights.fold<double>(0.0, (sum, w) => sum + w);
    final normalizedWeights =
        rawWeights.map((w) => (w / totalRawWeight) * 100.0).toList();

    final criteria = List.generate(criteriaCount, (j) {
      final isBenefit = rng.nextDouble() < 0.7; // 70% benefit, 30% cost
      return WeightedDecisionCriteria(
        id: 'c_$j',
        name: 'Criteria $j',
        weightPercent: normalizedWeights[j],
        isBenefit: isBenefit,
        maxValue: 100.0,
      );
    });

    final alternatives = List.generate(
      alternativesCount,
      (i) => WeightedDecisionAlternative(id: 'a_$i', name: 'Alternative $i'),
    );

    final matrix = List.generate(alternativesCount, (i) {
      final ratings = List.generate(criteriaCount, (j) {
        final val = 10.0 + rng.nextDouble() * 90.0;
        return WeightedDecisionRating(
          id: 'r_${i}_$j',
          criteria: criteria[j],
          value: val,
        );
      });
      return WeightedDecisionMatrix(
        id: 'm_$i',
        alternative: alternatives[i],
        ratings: ratings,
      );
    });

    return (alternatives, criteria, matrix);
  }

  static (
    List<AhpHierarchy>,
    List<PairwiseComparisonInput>,
    List<PairwiseAlternativeInput>
  ) generateAhpDataset({
    required int alternativesCount,
    required int criteriaCount,
    int seed = 42,
  }) {
    final rng = Random(seed);

    final criteriaItems = List.generate(
      criteriaCount,
      (j) => AhpItem(id: 'c_$j', name: 'Criteria $j'),
    );

    final altItems = List.generate(
      alternativesCount,
      (i) => AhpItem(id: 'a_$i', name: 'Alternative $i'),
    );

    final hierarchy = List.generate(
      criteriaCount,
      (j) => AhpHierarchy(criteria: criteriaItems[j], alternative: altItems),
    );

    final inputsCriteria = <PairwiseComparisonInput>[];
    for (int j1 = 0; j1 < criteriaCount; j1++) {
      for (int j2 = j1 + 1; j2 < criteriaCount; j2++) {
        inputsCriteria.add(
          PairwiseComparisonInput(
            id: 'pc_${j1}_$j2',
            left: criteriaItems[j1],
            right: criteriaItems[j2],
            preferenceValue: rng.nextInt(9) + 1,
            isLeftMoreImportant: rng.nextBool(),
          ),
        );
      }
    }

    final inputsAlternative = <PairwiseAlternativeInput>[];
    for (int j = 0; j < criteriaCount; j++) {
      final pairInputs = <PairwiseComparisonInput>[];
      for (int i1 = 0; i1 < alternativesCount; i1++) {
        for (int i2 = i1 + 1; i2 < alternativesCount; i2++) {
          pairInputs.add(
            PairwiseComparisonInput(
              id: 'pa_${j}_${i1}_$i2',
              left: altItems[i1],
              right: altItems[i2],
              preferenceValue: rng.nextInt(9) + 1,
              isLeftMoreImportant: rng.nextBool(),
            ),
          );
        }
      }
      inputsAlternative.add(
        PairwiseAlternativeInput(
          criteria: criteriaItems[j],
          alternative: pairInputs,
        ),
      );
    }

    return (hierarchy, inputsCriteria, inputsAlternative);
  }
}
