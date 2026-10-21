import 'package:decision_making_core/decision_making_core.dart';

void main() {
  print('=== Simple Additive Weighting (SAW) Example ===');

  final alternatives = [
    WeightedDecisionAlternative(id: 'a1', name: 'Vendor 1'),
    WeightedDecisionAlternative(id: 'a2', name: 'Vendor 2'),
  ];

  final criteria = [
    WeightedDecisionCriteria(
      id: 'c1',
      name: 'Cost',
      weightPercent: 40,
      isBenefit: false,
      maxValue: 100,
    ),
    WeightedDecisionCriteria(
      id: 'c2',
      name: 'Quality',
      weightPercent: 60,
      isBenefit: true,
      maxValue: 100,
    ),
  ];

  final matrix = [
    WeightedDecisionMatrix(
      id: 'm1',
      alternative: alternatives[0],
      ratings: [
        WeightedDecisionRating(id: 'r1', criteria: criteria[0], value: 40),
        WeightedDecisionRating(id: 'r2', criteria: criteria[1], value: 80),
      ],
    ),
    WeightedDecisionMatrix(
      id: 'm2',
      alternative: alternatives[1],
      ratings: [
        WeightedDecisionRating(id: 'r3', criteria: criteria[0], value: 60),
        WeightedDecisionRating(id: 'r4', criteria: criteria[1], value: 90),
      ],
    ),
  ];

  final sawResults = SawCalculator.calculate(matrix);
  for (final res in sawResults) {
    print('Rank ${res.rank}: ${res.alternative.name} - Score: ${res.score.toStringAsFixed(4)}');
  }

  print('\n=== TOPSIS Example ===');
  final rawMatrix = TopsisRawMatrix(criterias: criteria, matrixs: matrix);
  final topsisResults = TopsisCalculator.calculate(rawMatrix);
  for (final res in topsisResults) {
    print('Rank ${res.rank}: ${res.alternative.name} - Score: ${res.score.toStringAsFixed(4)}');
  }
}
