import 'package:decision_making_core/decision_making_core.dart';
import 'package:test/test.dart';

void main() {
  group('TOPSIS Golden Tests (Tolerance 1e-4)', () {
    test('Case 1: Consistent 4x4 case', () {
      // Label: cross-checked (Python 3.9 + numpy)

      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'Alternative 1'),
        WeightedDecisionAlternative(id: 'a2', name: 'Alternative 2'),
        WeightedDecisionAlternative(id: 'a3', name: 'Alternative 3'),
        WeightedDecisionAlternative(id: 'a4', name: 'Alternative 4'),
      ];

      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Criteria 1',
          weightPercent: 30,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'Criteria 2',
          weightPercent: 20,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c3',
          name: 'Criteria 3',
          weightPercent: 25,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c4',
          name: 'Criteria 4',
          weightPercent: 25,
          isBenefit: false, // Cost criteria
          maxValue: 10,
        ),
      ];

      final rawMatrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(id: 'r1_1', criteria: criteria[0], value: 5),
            WeightedDecisionRating(id: 'r1_2', criteria: criteria[1], value: 8),
            WeightedDecisionRating(id: 'r1_3', criteria: criteria[2], value: 4),
            WeightedDecisionRating(id: 'r1_4', criteria: criteria[3], value: 7),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(id: 'r2_1', criteria: criteria[0], value: 7),
            WeightedDecisionRating(id: 'r2_2', criteria: criteria[1], value: 6),
            WeightedDecisionRating(id: 'r2_3', criteria: criteria[2], value: 8),
            WeightedDecisionRating(id: 'r2_4', criteria: criteria[3], value: 9),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(id: 'r3_1', criteria: criteria[0], value: 8),
            WeightedDecisionRating(id: 'r3_2', criteria: criteria[1], value: 9),
            WeightedDecisionRating(id: 'r3_3', criteria: criteria[2], value: 6),
            WeightedDecisionRating(id: 'r3_4', criteria: criteria[3], value: 6),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm4',
          alternative: alternatives[3],
          ratings: [
            WeightedDecisionRating(id: 'r4_1', criteria: criteria[0], value: 7),
            WeightedDecisionRating(id: 'r4_2', criteria: criteria[1], value: 7),
            WeightedDecisionRating(id: 'r4_3', criteria: criteria[2], value: 7),
            WeightedDecisionRating(id: 'r4_4', criteria: criteria[3], value: 7),
          ],
        ),
      ];

      final topsisMatrix = TopsisRawMatrix(
        criterias: criteria,
        matrixs: rawMatrix,
      );

      final result = TopsisCalculator.calculate(topsisMatrix);

      expect(result.length, 4);

      // Rank 1: Alternative 3 (score: ~0.720097)
      expect(result[0].alternative.id, 'a3');
      expect(result[0].rank, 1);
      expect(result[0].score, closeTo(0.720097, 1e-4));

      // Rank 2: Alternative 4 (score: ~0.655263)
      expect(result[1].alternative.id, 'a4');
      expect(result[1].rank, 2);
      expect(result[1].score, closeTo(0.655263, 1e-4));

      // Rank 3: Alternative 2 (score: ~0.566853)
      expect(result[2].alternative.id, 'a2');
      expect(result[2].rank, 3);
      expect(result[2].score, closeTo(0.566853, 1e-4));

      // Rank 4: Alternative 1 (score: ~0.292655)
      expect(result[3].alternative.id, 'a1');
      expect(result[3].rank, 4);
      expect(result[3].score, closeTo(0.292655, 1e-4));
    });

    test('Case 2: Vendor / Supplier Selection - Multiple Cost Criteria', () {
      // Label: cross-checked (Python 3.9)
      // 3 alternatives, 3 criteria (Quality [Benefit], Price [Cost], Delivery Time [Cost])

      final alternatives = [
        WeightedDecisionAlternative(id: 's1', name: 'Supplier 1'),
        WeightedDecisionAlternative(id: 's2', name: 'Supplier 2'),
        WeightedDecisionAlternative(id: 's3', name: 'Supplier 3'),
      ];

      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Product Quality',
          weightPercent: 50,
          isBenefit: true,
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'Quoted Price',
          weightPercent: 30,
          isBenefit: false, // Cost criteria
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          id: 'c3',
          name: 'Delivery Time',
          weightPercent: 20,
          isBenefit: false, // Cost criteria
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
                id: 'r1_2', criteria: criteria[1], value: 20),
            WeightedDecisionRating(
                id: 'r1_3', criteria: criteria[2], value: 10),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(
                id: 'r2_1', criteria: criteria[0], value: 90),
            WeightedDecisionRating(
                id: 'r2_2', criteria: criteria[1], value: 30),
            WeightedDecisionRating(
                id: 'r2_3', criteria: criteria[2], value: 15),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(
                id: 'r3_1', criteria: criteria[0], value: 70),
            WeightedDecisionRating(
                id: 'r3_2', criteria: criteria[1], value: 15),
            WeightedDecisionRating(id: 'r3_3', criteria: criteria[2], value: 8),
          ],
        ),
      ];

      final topsisMatrix = TopsisRawMatrix(
        criterias: criteria,
        matrixs: rawMatrix,
      );

      final result = TopsisCalculator.calculate(topsisMatrix);

      expect(result.length, 3);

      // Rank 1: Supplier 3 (score: ~0.653390)
      expect(result[0].alternative.id, 's3');
      expect(result[0].rank, 1);
      expect(result[0].score, closeTo(0.653390, 1e-4));

      // Rank 2: Supplier 1 (score: ~0.636796)
      expect(result[1].alternative.id, 's1');
      expect(result[1].rank, 2);
      expect(result[1].score, closeTo(0.636796, 1e-4));

      // Rank 3: Supplier 2 (score: ~0.346610)
      expect(result[2].alternative.id, 's2');
      expect(result[2].rank, 3);
      expect(result[2].score, closeTo(0.346610, 1e-4));
    });

    test('Case 3 (Edge Case): Cost Criteria and Identical Alternatives (Tie)',
        () {
      // Label: cross-checked (Python 3.9)
      // Tests Euclidean distance to ideal solution when two alternatives are identical

      final alternatives = [
        WeightedDecisionAlternative(id: 'altA', name: 'Alternative A'),
        WeightedDecisionAlternative(id: 'altB', name: 'Alternative B'),
        WeightedDecisionAlternative(id: 'altC', name: 'Alternative C'),
      ];

      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Cost',
          weightPercent: 50,
          isBenefit: false, // Cost
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'Quality',
          weightPercent: 50,
          isBenefit: true, // Benefit
          maxValue: 100,
        ),
      ];

      final rawMatrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(
                id: 'r1_1', criteria: criteria[0], value: 30),
            WeightedDecisionRating(
                id: 'r1_2', criteria: criteria[1], value: 80),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(
                id: 'r2_1', criteria: criteria[0], value: 30),
            WeightedDecisionRating(
                id: 'r2_2', criteria: criteria[1], value: 80),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(
                id: 'r3_1', criteria: criteria[0], value: 50),
            WeightedDecisionRating(
                id: 'r3_2', criteria: criteria[1], value: 60),
          ],
        ),
      ];

      final topsisMatrix = TopsisRawMatrix(
        criterias: criteria,
        matrixs: rawMatrix,
      );

      final result = TopsisCalculator.calculate(topsisMatrix);

      expect(result.length, 3);

      // Both Alt A and Alt B achieve the ideal solution with score 1.000000
      expect(result[0].score, closeTo(1.000000, 1e-4));
      expect(result[1].score, closeTo(1.000000, 1e-4));

      // Perilaku saat ini: rank unik sekuensial (1, 2, 3, ...), urutan alternatif seri mengikuti urutan input pada ukuran data kecil.
      // Catatan: List.sort Dart tidak dijamin stabil, sehingga urutan alternatif seri pada data besar tidak dijamin.
      // Item terbuka: putuskan semantik rank saat seri (rank sama vs rank unik) dan tiebreak eksplisit.
      expect(result[0].alternative.id, 'altA');
      expect(result[0].rank, 1);
      expect(result[1].alternative.id, 'altB');
      expect(result[1].rank, 2);

      // Alt C is closest to negative ideal solution with score 0.000000
      expect(result[2].alternative.id, 'altC');
      expect(result[2].rank, 3);
      expect(result[2].score, closeTo(0.000000, 1e-4));
    });
  });

  group('TOPSIS Detailed Results Tests - Intermediate Values (Tolerance 1e-4)',
      () {
    test('Case 1: Intermediate values for consistent 4x4 case', () {
      // Label: cross-checked (Python 3.9)

      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'Alternative 1'),
        WeightedDecisionAlternative(id: 'a2', name: 'Alternative 2'),
        WeightedDecisionAlternative(id: 'a3', name: 'Alternative 3'),
        WeightedDecisionAlternative(id: 'a4', name: 'Alternative 4'),
      ];

      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Criteria 1',
          weightPercent: 30,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'Criteria 2',
          weightPercent: 20,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c3',
          name: 'Criteria 3',
          weightPercent: 25,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c4',
          name: 'Criteria 4',
          weightPercent: 25,
          isBenefit: false, // Cost criteria
          maxValue: 10,
        ),
      ];

      final rawMatrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(id: 'r1_1', criteria: criteria[0], value: 5),
            WeightedDecisionRating(id: 'r1_2', criteria: criteria[1], value: 8),
            WeightedDecisionRating(id: 'r1_3', criteria: criteria[2], value: 4),
            WeightedDecisionRating(id: 'r1_4', criteria: criteria[3], value: 7),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(id: 'r2_1', criteria: criteria[0], value: 7),
            WeightedDecisionRating(id: 'r2_2', criteria: criteria[1], value: 6),
            WeightedDecisionRating(id: 'r2_3', criteria: criteria[2], value: 8),
            WeightedDecisionRating(id: 'r2_4', criteria: criteria[3], value: 9),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(id: 'r3_1', criteria: criteria[0], value: 8),
            WeightedDecisionRating(id: 'r3_2', criteria: criteria[1], value: 9),
            WeightedDecisionRating(id: 'r3_3', criteria: criteria[2], value: 6),
            WeightedDecisionRating(id: 'r3_4', criteria: criteria[3], value: 6),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm4',
          alternative: alternatives[3],
          ratings: [
            WeightedDecisionRating(id: 'r4_1', criteria: criteria[0], value: 7),
            WeightedDecisionRating(id: 'r4_2', criteria: criteria[1], value: 7),
            WeightedDecisionRating(id: 'r4_3', criteria: criteria[2], value: 7),
            WeightedDecisionRating(id: 'r4_4', criteria: criteria[3], value: 7),
          ],
        ),
      ];

      final topsisMatrix = TopsisRawMatrix(
        criterias: criteria,
        matrixs: rawMatrix,
      );

      final detailed = TopsisCalculator.calculateDetailed(topsisMatrix);

      // 1. Initial matrix check
      expect(detailed.initialMatrix.length, 4);

      // 2. Normalized weights check
      expect(detailed.normalizedWeights['c1'], closeTo(0.300000, 1e-4));
      expect(detailed.normalizedWeights['c2'], closeTo(0.200000, 1e-4));
      expect(detailed.normalizedWeights['c3'], closeTo(0.250000, 1e-4));
      expect(detailed.normalizedWeights['c4'], closeTo(0.250000, 1e-4));

      // 3. Euclidean normalized matrix check (per cell)
      // Row 0 (a1): [0.365636, 0.527504, 0.311400, 0.477396]
      expect(detailed.normalizedMatrix[0].ratings[0].value,
          closeTo(0.365636, 1e-4));
      expect(detailed.normalizedMatrix[0].ratings[1].value,
          closeTo(0.527504, 1e-4));
      expect(detailed.normalizedMatrix[0].ratings[2].value,
          closeTo(0.311400, 1e-4));
      expect(detailed.normalizedMatrix[0].ratings[3].value,
          closeTo(0.477396, 1e-4));

      // Row 1 (a2): [0.511891, 0.395628, 0.622799, 0.613795]
      expect(detailed.normalizedMatrix[1].ratings[0].value,
          closeTo(0.511891, 1e-4));
      expect(detailed.normalizedMatrix[1].ratings[1].value,
          closeTo(0.395628, 1e-4));
      expect(detailed.normalizedMatrix[1].ratings[2].value,
          closeTo(0.622799, 1e-4));
      expect(detailed.normalizedMatrix[1].ratings[3].value,
          closeTo(0.613795, 1e-4));

      // Row 2 (a3): [0.585018, 0.593442, 0.467099, 0.409197]
      expect(detailed.normalizedMatrix[2].ratings[0].value,
          closeTo(0.585018, 1e-4));
      expect(detailed.normalizedMatrix[2].ratings[1].value,
          closeTo(0.593442, 1e-4));
      expect(detailed.normalizedMatrix[2].ratings[2].value,
          closeTo(0.467099, 1e-4));
      expect(detailed.normalizedMatrix[2].ratings[3].value,
          closeTo(0.409197, 1e-4));

      // Row 3 (a4): [0.511891, 0.461566, 0.544949, 0.477396]
      expect(detailed.normalizedMatrix[3].ratings[0].value,
          closeTo(0.511891, 1e-4));
      expect(detailed.normalizedMatrix[3].ratings[1].value,
          closeTo(0.461566, 1e-4));
      expect(detailed.normalizedMatrix[3].ratings[2].value,
          closeTo(0.544949, 1e-4));
      expect(detailed.normalizedMatrix[3].ratings[3].value,
          closeTo(0.477396, 1e-4));

      // 4. Weighted matrix check (per cell)
      // Row 0 (a1): [0.109691, 0.105501, 0.077850, 0.119349]
      expect(
          detailed.weightedMatrix[0].ratings[0].value, closeTo(0.109691, 1e-4));
      expect(
          detailed.weightedMatrix[0].ratings[1].value, closeTo(0.105501, 1e-4));
      expect(
          detailed.weightedMatrix[0].ratings[2].value, closeTo(0.077850, 1e-4));
      expect(
          detailed.weightedMatrix[0].ratings[3].value, closeTo(0.119349, 1e-4));

      // Row 1 (a2): [0.153567, 0.079126, 0.155700, 0.153449]
      expect(
          detailed.weightedMatrix[1].ratings[0].value, closeTo(0.153567, 1e-4));
      expect(
          detailed.weightedMatrix[1].ratings[1].value, closeTo(0.079126, 1e-4));
      expect(
          detailed.weightedMatrix[1].ratings[2].value, closeTo(0.155700, 1e-4));
      expect(
          detailed.weightedMatrix[1].ratings[3].value, closeTo(0.153449, 1e-4));

      // Row 2 (a3): [0.175505, 0.118688, 0.116775, 0.102299]
      expect(
          detailed.weightedMatrix[2].ratings[0].value, closeTo(0.175505, 1e-4));
      expect(
          detailed.weightedMatrix[2].ratings[1].value, closeTo(0.118688, 1e-4));
      expect(
          detailed.weightedMatrix[2].ratings[2].value, closeTo(0.116775, 1e-4));
      expect(
          detailed.weightedMatrix[2].ratings[3].value, closeTo(0.102299, 1e-4));

      // Row 3 (a4): [0.153567, 0.092313, 0.136237, 0.119349]
      expect(
          detailed.weightedMatrix[3].ratings[0].value, closeTo(0.153567, 1e-4));
      expect(
          detailed.weightedMatrix[3].ratings[1].value, closeTo(0.092313, 1e-4));
      expect(
          detailed.weightedMatrix[3].ratings[2].value, closeTo(0.136237, 1e-4));
      expect(
          detailed.weightedMatrix[3].ratings[3].value, closeTo(0.119349, 1e-4));

      // 5. Positive and Negative Ideal Solutions check
      expect(detailed.positiveIdeal['c1'], closeTo(0.175505, 1e-4));
      expect(detailed.positiveIdeal['c2'], closeTo(0.118688, 1e-4));
      expect(detailed.positiveIdeal['c3'], closeTo(0.155700, 1e-4));
      expect(
          detailed.positiveIdeal['c4'], closeTo(0.102299, 1e-4)); // Cost: min

      expect(detailed.negativeIdeal['c1'], closeTo(0.109691, 1e-4));
      expect(detailed.negativeIdeal['c2'], closeTo(0.079126, 1e-4));
      expect(detailed.negativeIdeal['c3'], closeTo(0.077850, 1e-4));
      expect(
          detailed.negativeIdeal['c4'], closeTo(0.153449, 1e-4)); // Cost: max

      // 6. Separation distances check (D+ and D-)
      expect(detailed.separationPlus['a1'], closeTo(0.104196, 1e-4));
      expect(detailed.separationPlus['a2'], closeTo(0.068285, 1e-4));
      expect(detailed.separationPlus['a3'], closeTo(0.038925, 1e-4));
      expect(detailed.separationPlus['a4'], closeTo(0.042970, 1e-4));

      expect(detailed.separationMinus['a1'], closeTo(0.043110, 1e-4));
      expect(detailed.separationMinus['a2'], closeTo(0.089363, 1e-4));
      expect(detailed.separationMinus['a3'], closeTo(0.100141, 1e-4));
      expect(detailed.separationMinus['a4'], closeTo(0.081676, 1e-4));

      // 7. Relative closeness scores and ranks check
      expect(detailed.scores[0].alternative.id, 'a3');
      expect(detailed.scores[0].rank, 1);
      expect(detailed.scores[0].score, closeTo(0.720097, 1e-4));

      expect(detailed.scores[1].alternative.id, 'a4');
      expect(detailed.scores[1].rank, 2);
      expect(detailed.scores[1].score, closeTo(0.655263, 1e-4));

      expect(detailed.scores[2].alternative.id, 'a2');
      expect(detailed.scores[2].rank, 3);
      expect(detailed.scores[2].score, closeTo(0.566853, 1e-4));

      expect(detailed.scores[3].alternative.id, 'a1');
      expect(detailed.scores[3].rank, 4);
      expect(detailed.scores[3].score, closeTo(0.292655, 1e-4));

      // 8. JSON serialization check
      final json = detailed.toJson();
      expect(json['initial_matrix'], isA<List>());
      expect(json['normalized_matrix'], isA<List>());
      expect(json['normalized_weights'], isA<Map>());
      expect(json['weighted_matrix'], isA<List>());
      expect(json['positive_ideal'], isA<Map>());
      expect(json['negative_ideal'], isA<Map>());
      expect(json['separation_plus'], isA<Map>());
      expect(json['separation_minus'], isA<Map>());
      expect(json['scores'], isA<List>());
    });

    test(
        'Case 2: Intermediate values for vendor selection (Multiple Cost Criteria)',
        () {
      // Label: cross-checked (Python 3.9)

      final alternatives = [
        WeightedDecisionAlternative(id: 's1', name: 'Supplier 1'),
        WeightedDecisionAlternative(id: 's2', name: 'Supplier 2'),
        WeightedDecisionAlternative(id: 's3', name: 'Supplier 3'),
      ];

      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Product Quality',
          weightPercent: 50,
          isBenefit: true,
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'Quoted Price',
          weightPercent: 30,
          isBenefit: false, // Cost criteria
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          id: 'c3',
          name: 'Delivery Time',
          weightPercent: 20,
          isBenefit: false, // Cost criteria
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
                id: 'r1_2', criteria: criteria[1], value: 20),
            WeightedDecisionRating(
                id: 'r1_3', criteria: criteria[2], value: 10),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(
                id: 'r2_1', criteria: criteria[0], value: 90),
            WeightedDecisionRating(
                id: 'r2_2', criteria: criteria[1], value: 30),
            WeightedDecisionRating(
                id: 'r2_3', criteria: criteria[2], value: 15),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(
                id: 'r3_1', criteria: criteria[0], value: 70),
            WeightedDecisionRating(
                id: 'r3_2', criteria: criteria[1], value: 15),
            WeightedDecisionRating(id: 'r3_3', criteria: criteria[2], value: 8),
          ],
        ),
      ];

      final topsisMatrix = TopsisRawMatrix(
        criterias: criteria,
        matrixs: rawMatrix,
      );

      final detailed = TopsisCalculator.calculateDetailed(topsisMatrix);

      // Normalized weights: 0.5, 0.3, 0.2
      expect(detailed.normalizedWeights['c1'], closeTo(0.500000, 1e-4));
      expect(detailed.normalizedWeights['c2'], closeTo(0.300000, 1e-4));
      expect(detailed.normalizedWeights['c3'], closeTo(0.200000, 1e-4));

      // Positive Ideal: c1=0.323081, c2=0.115233 (min cost), c3=0.081123 (min cost)
      expect(detailed.positiveIdeal['c1'], closeTo(0.323081, 1e-4));
      expect(detailed.positiveIdeal['c2'], closeTo(0.115233, 1e-4));
      expect(detailed.positiveIdeal['c3'], closeTo(0.081123, 1e-4));

      // Negative Ideal: c1=0.251285, c2=0.230466 (max cost), c3=0.152106 (max cost)
      expect(detailed.negativeIdeal['c1'], closeTo(0.251285, 1e-4));
      expect(detailed.negativeIdeal['c2'], closeTo(0.230466, 1e-4));
      expect(detailed.negativeIdeal['c3'], closeTo(0.152106, 1e-4));

      // Separation distances:
      // s1: D+=0.056351, D-=0.098798
      expect(detailed.separationPlus['s1'], closeTo(0.056351, 1e-4));
      expect(detailed.separationMinus['s1'], closeTo(0.098798, 1e-4));

      // s2: D+=0.135341, D-=0.071796
      expect(detailed.separationPlus['s2'], closeTo(0.135341, 1e-4));
      expect(detailed.separationMinus['s2'], closeTo(0.071796, 1e-4));

      // s3: D+=0.071796, D-=0.135341
      expect(detailed.separationPlus['s3'], closeTo(0.071796, 1e-4));
      expect(detailed.separationMinus['s3'], closeTo(0.135341, 1e-4));

      // Final rankings:
      expect(detailed.scores[0].alternative.id, 's3');
      expect(detailed.scores[0].rank, 1);
      expect(detailed.scores[0].score, closeTo(0.653390, 1e-4));

      expect(detailed.scores[1].alternative.id, 's1');
      expect(detailed.scores[1].rank, 2);
      expect(detailed.scores[1].score, closeTo(0.636796, 1e-4));

      expect(detailed.scores[2].alternative.id, 's2');
      expect(detailed.scores[2].rank, 3);
      expect(detailed.scores[2].score, closeTo(0.346610, 1e-4));
    });

    test(
        'Case 1: Halved criteria weights (15/10/12.5/12.5) produce normalizedWeights [0.3, 0.2, 0.25, 0.25] and identical intermediate values and calculate() scores',
        () {
      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'Alternative 1'),
        WeightedDecisionAlternative(id: 'a2', name: 'Alternative 2'),
        WeightedDecisionAlternative(id: 'a3', name: 'Alternative 3'),
        WeightedDecisionAlternative(id: 'a4', name: 'Alternative 4'),
      ];

      final standardCriteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Criteria 1',
          weightPercent: 30,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'Criteria 2',
          weightPercent: 20,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c3',
          name: 'Criteria 3',
          weightPercent: 25,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c4',
          name: 'Criteria 4',
          weightPercent: 25,
          isBenefit: false,
          maxValue: 10,
        ),
      ];

      final halvedCriteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Criteria 1',
          weightPercent: 15,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'Criteria 2',
          weightPercent: 10,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c3',
          name: 'Criteria 3',
          weightPercent: 12.5,
          isBenefit: true,
          maxValue: 10,
        ),
        WeightedDecisionCriteria(
          id: 'c4',
          name: 'Criteria 4',
          weightPercent: 12.5,
          isBenefit: false,
          maxValue: 10,
        ),
      ];

      final rawMatrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(
                id: 'r1_1', criteria: standardCriteria[0], value: 5),
            WeightedDecisionRating(
                id: 'r1_2', criteria: standardCriteria[1], value: 8),
            WeightedDecisionRating(
                id: 'r1_3', criteria: standardCriteria[2], value: 4),
            WeightedDecisionRating(
                id: 'r1_4', criteria: standardCriteria[3], value: 7),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(
                id: 'r2_1', criteria: standardCriteria[0], value: 7),
            WeightedDecisionRating(
                id: 'r2_2', criteria: standardCriteria[1], value: 6),
            WeightedDecisionRating(
                id: 'r2_3', criteria: standardCriteria[2], value: 8),
            WeightedDecisionRating(
                id: 'r2_4', criteria: standardCriteria[3], value: 9),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(
                id: 'r3_1', criteria: standardCriteria[0], value: 8),
            WeightedDecisionRating(
                id: 'r3_2', criteria: standardCriteria[1], value: 9),
            WeightedDecisionRating(
                id: 'r3_3', criteria: standardCriteria[2], value: 6),
            WeightedDecisionRating(
                id: 'r3_4', criteria: standardCriteria[3], value: 6),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm4',
          alternative: alternatives[3],
          ratings: [
            WeightedDecisionRating(
                id: 'r4_1', criteria: standardCriteria[0], value: 7),
            WeightedDecisionRating(
                id: 'r4_2', criteria: standardCriteria[1], value: 7),
            WeightedDecisionRating(
                id: 'r4_3', criteria: standardCriteria[2], value: 7),
            WeightedDecisionRating(
                id: 'r4_4', criteria: standardCriteria[3], value: 7),
          ],
        ),
      ];

      final halvedRawMatrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(
                id: 'r1_1', criteria: halvedCriteria[0], value: 5),
            WeightedDecisionRating(
                id: 'r1_2', criteria: halvedCriteria[1], value: 8),
            WeightedDecisionRating(
                id: 'r1_3', criteria: halvedCriteria[2], value: 4),
            WeightedDecisionRating(
                id: 'r1_4', criteria: halvedCriteria[3], value: 7),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(
                id: 'r2_1', criteria: halvedCriteria[0], value: 7),
            WeightedDecisionRating(
                id: 'r2_2', criteria: halvedCriteria[1], value: 6),
            WeightedDecisionRating(
                id: 'r2_3', criteria: halvedCriteria[2], value: 8),
            WeightedDecisionRating(
                id: 'r2_4', criteria: halvedCriteria[3], value: 9),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm3',
          alternative: alternatives[2],
          ratings: [
            WeightedDecisionRating(
                id: 'r3_1', criteria: halvedCriteria[0], value: 8),
            WeightedDecisionRating(
                id: 'r3_2', criteria: halvedCriteria[1], value: 9),
            WeightedDecisionRating(
                id: 'r3_3', criteria: halvedCriteria[2], value: 6),
            WeightedDecisionRating(
                id: 'r3_4', criteria: halvedCriteria[3], value: 6),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm4',
          alternative: alternatives[3],
          ratings: [
            WeightedDecisionRating(
                id: 'r4_1', criteria: halvedCriteria[0], value: 7),
            WeightedDecisionRating(
                id: 'r4_2', criteria: halvedCriteria[1], value: 7),
            WeightedDecisionRating(
                id: 'r4_3', criteria: halvedCriteria[2], value: 7),
            WeightedDecisionRating(
                id: 'r4_4', criteria: halvedCriteria[3], value: 7),
          ],
        ),
      ];

      final standardDetailed = TopsisCalculator.calculateDetailed(
        TopsisRawMatrix(criterias: standardCriteria, matrixs: rawMatrix),
      );
      final halvedDetailed = TopsisCalculator.calculateDetailed(
        TopsisRawMatrix(criterias: halvedCriteria, matrixs: halvedRawMatrix),
      );
      final calculatedScores = TopsisCalculator.calculate(
        TopsisRawMatrix(criterias: halvedCriteria, matrixs: halvedRawMatrix),
      );

      // Verify normalizedWeights are [0.3, 0.2, 0.25, 0.25]
      expect(halvedDetailed.normalizedWeights['c1'], closeTo(0.3, 1e-4));
      expect(halvedDetailed.normalizedWeights['c2'], closeTo(0.2, 1e-4));
      expect(halvedDetailed.normalizedWeights['c3'], closeTo(0.25, 1e-4));
      expect(halvedDetailed.normalizedWeights['c4'], closeTo(0.25, 1e-4));

      // Verify intermediate values match standard 30/20/25/25
      // 1. weightedMatrix
      for (int i = 0; i < standardDetailed.weightedMatrix.length; i++) {
        for (int j = 0;
            j < standardDetailed.weightedMatrix[i].ratings.length;
            j++) {
          expect(
            halvedDetailed.weightedMatrix[i].ratings[j].value,
            closeTo(standardDetailed.weightedMatrix[i].ratings[j].value!, 1e-4),
          );
        }
      }

      // 2. ideal values
      for (final key in standardDetailed.positiveIdeal.keys) {
        expect(halvedDetailed.positiveIdeal[key],
            closeTo(standardDetailed.positiveIdeal[key]!, 1e-4));
        expect(halvedDetailed.negativeIdeal[key],
            closeTo(standardDetailed.negativeIdeal[key]!, 1e-4));
      }

      // 3. separationPlus and separationMinus
      for (final key in standardDetailed.separationPlus.keys) {
        expect(halvedDetailed.separationPlus[key],
            closeTo(standardDetailed.separationPlus[key]!, 1e-4));
        expect(halvedDetailed.separationMinus[key],
            closeTo(standardDetailed.separationMinus[key]!, 1e-4));
      }

      // 4. scores identical to calculate()
      expect(halvedDetailed.scores.length, calculatedScores.length);
      for (int i = 0; i < calculatedScores.length; i++) {
        expect(halvedDetailed.scores[i].alternative.id,
            calculatedScores[i].alternative.id);
        expect(halvedDetailed.scores[i].rank, calculatedScores[i].rank);
        expect(halvedDetailed.scores[i].score,
            closeTo(calculatedScores[i].score, 1e-4));
      }
    });
  });
}
