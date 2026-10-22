import 'package:decision_making_core/decision_making_core.dart';
import 'package:test/test.dart';

void main() {
  group('SAW Golden Tests (Tolerance 1e-4)', () {
    test('Case 1: Mixed benefit and cost 3x4 case', () {
      // Label: cross-checked (Python 3.9 + numpy)

      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'Alternative 1'),
        WeightedDecisionAlternative(id: 'a2', name: 'Alternative 2'),
        WeightedDecisionAlternative(id: 'a3', name: 'Alternative 3'),
      ];

      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Investment Cost',
          weightPercent: 25,
          isBenefit: false,
          maxValue: 250,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'Market Share',
          weightPercent: 25,
          isBenefit: true,
          maxValue: 5,
        ),
        WeightedDecisionCriteria(
          id: 'c3',
          name: 'Capacity',
          weightPercent: 25,
          isBenefit: true,
          maxValue: 5000,
        ),
        WeightedDecisionCriteria(
          id: 'c4',
          name: 'Risk Level',
          weightPercent: 25,
          isBenefit: false,
          maxValue: 5,
        ),
      ];

      final rawMatrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(
                id: 'r1_1', criteria: criteria[0], value: 100),
            WeightedDecisionRating(id: 'r1_2', criteria: criteria[1], value: 3),
            WeightedDecisionRating(
                id: 'r1_3', criteria: criteria[2], value: 3500),
            WeightedDecisionRating(
                id: 'r1_4', criteria: criteria[3], value: 1.5),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(
                id: 'r2_1', criteria: criteria[0], value: 150),
            WeightedDecisionRating(id: 'r2_2', criteria: criteria[1], value: 2),
            WeightedDecisionRating(
                id: 'r2_3', criteria: criteria[2], value: 4500),
            WeightedDecisionRating(
                id: 'r2_4', criteria: criteria[3], value: 2.0),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(
                id: 'r3_1', criteria: criteria[0], value: 200),
            WeightedDecisionRating(id: 'r3_2', criteria: criteria[1], value: 3),
            WeightedDecisionRating(
                id: 'r3_3', criteria: criteria[2], value: 3000),
            WeightedDecisionRating(
                id: 'r3_4', criteria: criteria[3], value: 3.5),
          ],
        ),
      ];

      final result = SawCalculator.calculate(rawMatrix);

      expect(result.length, 3);

      // Verify rankings and scores
      expect(result[0].alternative.id, 'a1');
      expect(result[0].rank, 1);
      expect(result[0].score, closeTo(0.944444, 1e-4));

      expect(result[1].alternative.id, 'a2');
      expect(result[1].rank, 2);
      expect(result[1].score, closeTo(0.770833, 1e-4));

      expect(result[2].alternative.id, 'a3');
      expect(result[2].rank, 3);
      expect(result[2].score, closeTo(0.648810, 1e-4));
    });

    test('Case 2: Employee Performance Evaluation - All Benefit', () {
      // Label: cross-checked (Python 3.9)
      // 4 alternatives, 3 benefit criteria

      final alternatives = [
        WeightedDecisionAlternative(id: 'e1', name: 'Employee 1'),
        WeightedDecisionAlternative(id: 'e2', name: 'Employee 2'),
        WeightedDecisionAlternative(id: 'e3', name: 'Employee 3'),
        WeightedDecisionAlternative(id: 'e4', name: 'Employee 4'),
      ];

      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Technical Skill',
          weightPercent: 40,
          isBenefit: true,
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'Communication',
          weightPercent: 30,
          isBenefit: true,
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          id: 'c3',
          name: 'Attitude',
          weightPercent: 30,
          isBenefit: true,
          maxValue: 100,
        ),
      ];

      final rawMatrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(
                id: 'r1_1', criteria: criteria[0], value: 80),
            WeightedDecisionRating(
                id: 'r1_2', criteria: criteria[1], value: 70),
            WeightedDecisionRating(
                id: 'r1_3', criteria: criteria[2], value: 90),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(
                id: 'r2_1', criteria: criteria[0], value: 90),
            WeightedDecisionRating(
                id: 'r2_2', criteria: criteria[1], value: 80),
            WeightedDecisionRating(
                id: 'r2_3', criteria: criteria[2], value: 70),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(
                id: 'r3_1', criteria: criteria[0], value: 75),
            WeightedDecisionRating(
                id: 'r3_2', criteria: criteria[1], value: 90),
            WeightedDecisionRating(
                id: 'r3_3', criteria: criteria[2], value: 85),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm4',
          alternative: alternatives[3],
          ratings: [
            WeightedDecisionRating(
                id: 'r4_1', criteria: criteria[0], value: 85),
            WeightedDecisionRating(
                id: 'r4_2', criteria: criteria[1], value: 60),
            WeightedDecisionRating(
                id: 'r4_3', criteria: criteria[2], value: 80),
          ],
        ),
      ];

      final result = SawCalculator.calculate(rawMatrix);

      expect(result.length, 4);

      // Rank 1: Employee 3 (0.916667)
      expect(result[0].alternative.id, 'e3');
      expect(result[0].rank, 1);
      expect(result[0].score, closeTo(0.916667, 1e-4));

      // Rank 2: Employee 2 (0.900000)
      expect(result[1].alternative.id, 'e2');
      expect(result[1].rank, 2);
      expect(result[1].score, closeTo(0.900000, 1e-4));

      // Rank 3: Employee 1 (0.888889)
      expect(result[2].alternative.id, 'e1');
      expect(result[2].rank, 3);
      expect(result[2].score, closeTo(0.888889, 1e-4));

      // Rank 4: Employee 4 (0.844444)
      expect(result[3].alternative.id, 'e4');
      expect(result[3].rank, 4);
      expect(result[3].score, closeTo(0.844444, 1e-4));
    });

    test('Case 3 (Edge Case): Cost Criteria and Identical Alternatives (Tie)',
        () {
      // Label: cross-checked (Python 3.9)
      // Tests cost criteria normalization and handling of tied alternatives

      final alternatives = [
        WeightedDecisionAlternative(id: 'altA', name: 'Alternative A'),
        WeightedDecisionAlternative(id: 'altB', name: 'Alternative B'),
        WeightedDecisionAlternative(id: 'altC', name: 'Alternative C'),
      ];

      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Price',
          weightPercent: 50,
          isBenefit: false, // Cost criteria
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'Quality',
          weightPercent: 50,
          isBenefit: true, // Benefit criteria
          maxValue: 100,
        ),
      ];

      // altA and altB have identical values
      final rawMatrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(
                id: 'r1_1', criteria: criteria[0], value: 40),
            WeightedDecisionRating(
                id: 'r1_2', criteria: criteria[1], value: 80),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(
                id: 'r2_1', criteria: criteria[0], value: 40),
            WeightedDecisionRating(
                id: 'r2_2', criteria: criteria[1], value: 80),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(
                id: 'r3_1', criteria: criteria[0], value: 60),
            WeightedDecisionRating(
                id: 'r3_2', criteria: criteria[1], value: 60),
          ],
        ),
      ];

      final result = SawCalculator.calculate(rawMatrix);

      expect(result.length, 3);

      // Tied top alternatives should both have perfect 1.000000 score
      expect(result[0].score, closeTo(1.000000, 1e-4));
      expect(result[1].score, closeTo(1.000000, 1e-4));

      // Perilaku saat ini: rank unik sekuensial (1, 2, 3, ...), urutan alternatif seri mengikuti urutan input pada ukuran data kecil.
      // Catatan: List.sort Dart tidak dijamin stabil, sehingga urutan alternatif seri pada data besar tidak dijamin.
      // Item terbuka: putuskan semantik rank saat seri (rank sama vs rank unik) dan tiebreak eksplisit.
      expect(result[0].alternative.id, 'altA');
      expect(result[0].rank, 1);
      expect(result[1].alternative.id, 'altB');
      expect(result[1].rank, 2);

      // Lower alternative: Alt C with score 0.708333
      expect(result[2].alternative.id, 'altC');
      expect(result[2].rank, 3);
      expect(result[2].score, closeTo(0.708333, 1e-4));
    });
  });

  group('SAW Detailed Results Tests - Intermediate Values (Tolerance 1e-4)', () {
    test('Case 1: Intermediate values for mixed benefit and cost 3x4 case', () {
      // Label: cross-checked (Python 3.9)

      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'Alternative 1'),
        WeightedDecisionAlternative(id: 'a2', name: 'Alternative 2'),
        WeightedDecisionAlternative(id: 'a3', name: 'Alternative 3'),
      ];

      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Investment Cost',
          weightPercent: 25,
          isBenefit: false,
          maxValue: 250,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'Market Share',
          weightPercent: 25,
          isBenefit: true,
          maxValue: 5,
        ),
        WeightedDecisionCriteria(
          id: 'c3',
          name: 'Capacity',
          weightPercent: 25,
          isBenefit: true,
          maxValue: 5000,
        ),
        WeightedDecisionCriteria(
          id: 'c4',
          name: 'Risk Level',
          weightPercent: 25,
          isBenefit: false,
          maxValue: 5,
        ),
      ];

      final rawMatrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(
                id: 'r1_1', criteria: criteria[0], value: 100),
            WeightedDecisionRating(id: 'r1_2', criteria: criteria[1], value: 3),
            WeightedDecisionRating(
                id: 'r1_3', criteria: criteria[2], value: 3500),
            WeightedDecisionRating(
                id: 'r1_4', criteria: criteria[3], value: 1.5),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(
                id: 'r2_1', criteria: criteria[0], value: 150),
            WeightedDecisionRating(id: 'r2_2', criteria: criteria[1], value: 2),
            WeightedDecisionRating(
                id: 'r2_3', criteria: criteria[2], value: 4500),
            WeightedDecisionRating(
                id: 'r2_4', criteria: criteria[3], value: 2.0),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(
                id: 'r3_1', criteria: criteria[0], value: 200),
            WeightedDecisionRating(id: 'r3_2', criteria: criteria[1], value: 3),
            WeightedDecisionRating(
                id: 'r3_3', criteria: criteria[2], value: 3000),
            WeightedDecisionRating(
                id: 'r3_4', criteria: criteria[3], value: 3.5),
          ],
        ),
      ];

      final detailed = SawCalculator.calculateDetailed(rawMatrix);

      // 1. Initial matrix check
      expect(detailed.initialMatrix.length, 3);
      expect(detailed.initialMatrix[0].ratings[0].value, 100);
      expect(detailed.initialMatrix[1].ratings[2].value, 4500);

      // 2. Normalized weights check (each is 0.25, sum is 1.0)
      expect(detailed.normalizedWeights['c1'], closeTo(0.250000, 1e-4));
      expect(detailed.normalizedWeights['c2'], closeTo(0.250000, 1e-4));
      expect(detailed.normalizedWeights['c3'], closeTo(0.250000, 1e-4));
      expect(detailed.normalizedWeights['c4'], closeTo(0.250000, 1e-4));

      // 3. Normalized matrix check (per cell, r_ij)
      // Row 0 (a1): [1.0, 1.0, 0.777778, 1.0]
      expect(detailed.normalizedMatrix[0].ratings[0].value,
          closeTo(1.000000, 1e-4));
      expect(detailed.normalizedMatrix[0].ratings[1].value,
          closeTo(1.000000, 1e-4));
      expect(detailed.normalizedMatrix[0].ratings[2].value,
          closeTo(0.777778, 1e-4));
      expect(detailed.normalizedMatrix[0].ratings[3].value,
          closeTo(1.000000, 1e-4));

      // Row 1 (a2): [0.666667, 0.666667, 1.0, 0.75]
      expect(detailed.normalizedMatrix[1].ratings[0].value,
          closeTo(0.666667, 1e-4));
      expect(detailed.normalizedMatrix[1].ratings[1].value,
          closeTo(0.666667, 1e-4));
      expect(detailed.normalizedMatrix[1].ratings[2].value,
          closeTo(1.000000, 1e-4));
      expect(detailed.normalizedMatrix[1].ratings[3].value,
          closeTo(0.750000, 1e-4));

      // Row 2 (a3): [0.5, 1.0, 0.666667, 0.428571]
      expect(detailed.normalizedMatrix[2].ratings[0].value,
          closeTo(0.500000, 1e-4));
      expect(detailed.normalizedMatrix[2].ratings[1].value,
          closeTo(1.000000, 1e-4));
      expect(detailed.normalizedMatrix[2].ratings[2].value,
          closeTo(0.666667, 1e-4));
      expect(detailed.normalizedMatrix[2].ratings[3].value,
          closeTo(0.428571, 1e-4));

      // 4. Weighted matrix check (per cell, v_ij = r_ij * w_j)
      // Row 0 (a1): [0.25, 0.25, 0.194444, 0.25]
      expect(detailed.weightedMatrix[0].ratings[0].value,
          closeTo(0.250000, 1e-4));
      expect(detailed.weightedMatrix[0].ratings[1].value,
          closeTo(0.250000, 1e-4));
      expect(detailed.weightedMatrix[0].ratings[2].value,
          closeTo(0.194444, 1e-4));
      expect(detailed.weightedMatrix[0].ratings[3].value,
          closeTo(0.250000, 1e-4));

      // Row 1 (a2): [0.166667, 0.166667, 0.25, 0.1875]
      expect(detailed.weightedMatrix[1].ratings[0].value,
          closeTo(0.166667, 1e-4));
      expect(detailed.weightedMatrix[1].ratings[1].value,
          closeTo(0.166667, 1e-4));
      expect(detailed.weightedMatrix[1].ratings[2].value,
          closeTo(0.250000, 1e-4));
      expect(detailed.weightedMatrix[1].ratings[3].value,
          closeTo(0.187500, 1e-4));

      // Row 2 (a3): [0.125, 0.25, 0.166667, 0.107143]
      expect(detailed.weightedMatrix[2].ratings[0].value,
          closeTo(0.125000, 1e-4));
      expect(detailed.weightedMatrix[2].ratings[1].value,
          closeTo(0.250000, 1e-4));
      expect(detailed.weightedMatrix[2].ratings[2].value,
          closeTo(0.166667, 1e-4));
      expect(detailed.weightedMatrix[2].ratings[3].value,
          closeTo(0.107143, 1e-4));

      // 5. Final scores & rankings check
      expect(detailed.scores.length, 3);
      expect(detailed.results.length, 3);
      expect(detailed.scores[0].alternative.id, 'a1');
      expect(detailed.scores[0].rank, 1);
      expect(detailed.scores[0].score, closeTo(0.944444, 1e-4));

      expect(detailed.scores[1].alternative.id, 'a2');
      expect(detailed.scores[1].rank, 2);
      expect(detailed.scores[1].score, closeTo(0.770833, 1e-4));

      expect(detailed.scores[2].alternative.id, 'a3');
      expect(detailed.scores[2].rank, 3);
      expect(detailed.scores[2].score, closeTo(0.648810, 1e-4));

      // 6. JSON serialization check
      final json = detailed.toJson();
      expect(json['initial_matrix'], isA<List>());
      expect(json['normalized_matrix'], isA<List>());
      expect(json['normalized_weights'], isA<Map>());
      expect(json['weighted_matrix'], isA<List>());
      expect(json['scores'], isA<List>());
      expect(json['normalized_weights']['c1'], closeTo(0.25, 1e-4));
    });

    test('Case 2: Intermediate values for employee performance (All Benefit)', () {
      // Label: cross-checked (Python 3.9)

      final alternatives = [
        WeightedDecisionAlternative(id: 'e1', name: 'Employee 1'),
        WeightedDecisionAlternative(id: 'e2', name: 'Employee 2'),
        WeightedDecisionAlternative(id: 'e3', name: 'Employee 3'),
        WeightedDecisionAlternative(id: 'e4', name: 'Employee 4'),
      ];

      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Technical Skill',
          weightPercent: 40,
          isBenefit: true,
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'Communication',
          weightPercent: 30,
          isBenefit: true,
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          id: 'c3',
          name: 'Problem Solving',
          weightPercent: 30,
          isBenefit: true,
          maxValue: 100,
        ),
      ];

      final rawMatrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(
                id: 'r1_1', criteria: criteria[0], value: 80),
            WeightedDecisionRating(
                id: 'r1_2', criteria: criteria[1], value: 70),
            WeightedDecisionRating(
                id: 'r1_3', criteria: criteria[2], value: 90),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(
                id: 'r2_1', criteria: criteria[0], value: 90),
            WeightedDecisionRating(
                id: 'r2_2', criteria: criteria[1], value: 80),
            WeightedDecisionRating(
                id: 'r2_3', criteria: criteria[2], value: 70),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(
                id: 'r3_1', criteria: criteria[0], value: 75),
            WeightedDecisionRating(
                id: 'r3_2', criteria: criteria[1], value: 90),
            WeightedDecisionRating(
                id: 'r3_3', criteria: criteria[2], value: 85),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm4',
          alternative: alternatives[3],
          ratings: [
            WeightedDecisionRating(
                id: 'r4_1', criteria: criteria[0], value: 85),
            WeightedDecisionRating(
                id: 'r4_2', criteria: criteria[1], value: 60),
            WeightedDecisionRating(
                id: 'r4_3', criteria: criteria[2], value: 80),
          ],
        ),
      ];

      final detailed = SawCalculator.calculateDetailed(rawMatrix);

      // Normalized weights: 0.4, 0.3, 0.3
      expect(detailed.normalizedWeights['c1'], closeTo(0.400000, 1e-4));
      expect(detailed.normalizedWeights['c2'], closeTo(0.300000, 1e-4));
      expect(detailed.normalizedWeights['c3'], closeTo(0.300000, 1e-4));

      // Normalized matrix:
      // Row 0 (e1): [0.888889, 0.777778, 1.000000]
      expect(detailed.normalizedMatrix[0].ratings[0].value, closeTo(0.888889, 1e-4));
      expect(detailed.normalizedMatrix[0].ratings[1].value, closeTo(0.777778, 1e-4));
      expect(detailed.normalizedMatrix[0].ratings[2].value, closeTo(1.000000, 1e-4));

      // Row 1 (e2): [1.000000, 0.888889, 0.777778]
      expect(detailed.normalizedMatrix[1].ratings[0].value, closeTo(1.000000, 1e-4));
      expect(detailed.normalizedMatrix[1].ratings[1].value, closeTo(0.888889, 1e-4));
      expect(detailed.normalizedMatrix[1].ratings[2].value, closeTo(0.777778, 1e-4));

      // Row 2 (e3): [0.833333, 1.000000, 0.944444]
      expect(detailed.normalizedMatrix[2].ratings[0].value, closeTo(0.833333, 1e-4));
      expect(detailed.normalizedMatrix[2].ratings[1].value, closeTo(1.000000, 1e-4));
      expect(detailed.normalizedMatrix[2].ratings[2].value, closeTo(0.944444, 1e-4));

      // Row 3 (e4): [0.944444, 0.666667, 0.888889]
      expect(detailed.normalizedMatrix[3].ratings[0].value, closeTo(0.944444, 1e-4));
      expect(detailed.normalizedMatrix[3].ratings[1].value, closeTo(0.666667, 1e-4));
      expect(detailed.normalizedMatrix[3].ratings[2].value, closeTo(0.888889, 1e-4));

      // Weighted matrix:
      // Row 0 (e1): [0.355556, 0.233333, 0.300000]
      expect(detailed.weightedMatrix[0].ratings[0].value, closeTo(0.355556, 1e-4));
      expect(detailed.weightedMatrix[0].ratings[1].value, closeTo(0.233333, 1e-4));
      expect(detailed.weightedMatrix[0].ratings[2].value, closeTo(0.300000, 1e-4));

      // Row 1 (e2): [0.400000, 0.266667, 0.233333]
      expect(detailed.weightedMatrix[1].ratings[0].value, closeTo(0.400000, 1e-4));
      expect(detailed.weightedMatrix[1].ratings[1].value, closeTo(0.266667, 1e-4));
      expect(detailed.weightedMatrix[1].ratings[2].value, closeTo(0.233333, 1e-4));

      // Row 2 (e3): [0.333333, 0.300000, 0.283333]
      expect(detailed.weightedMatrix[2].ratings[0].value, closeTo(0.333333, 1e-4));
      expect(detailed.weightedMatrix[2].ratings[1].value, closeTo(0.300000, 1e-4));
      expect(detailed.weightedMatrix[2].ratings[2].value, closeTo(0.283333, 1e-4));

      // Row 3 (e4): [0.377778, 0.200000, 0.266667]
      expect(detailed.weightedMatrix[3].ratings[0].value, closeTo(0.377778, 1e-4));
      expect(detailed.weightedMatrix[3].ratings[1].value, closeTo(0.200000, 1e-4));
      expect(detailed.weightedMatrix[3].ratings[2].value, closeTo(0.266667, 1e-4));

      // Scores:
      expect(detailed.scores[0].alternative.id, 'e3');
      expect(detailed.scores[0].rank, 1);
      expect(detailed.scores[0].score, closeTo(0.916667, 1e-4));

      expect(detailed.scores[1].alternative.id, 'e2');
      expect(detailed.scores[1].rank, 2);
      expect(detailed.scores[1].score, closeTo(0.900000, 1e-4));

      expect(detailed.scores[2].alternative.id, 'e1');
      expect(detailed.scores[2].rank, 3);
      expect(detailed.scores[2].score, closeTo(0.888889, 1e-4));

      expect(detailed.scores[3].alternative.id, 'e4');
      expect(detailed.scores[3].rank, 4);
      expect(detailed.scores[3].score, closeTo(0.844444, 1e-4));
    });
  });
}
