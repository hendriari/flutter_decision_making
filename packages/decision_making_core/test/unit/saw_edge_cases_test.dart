import 'package:decision_making_core/decision_making_core.dart';
import 'package:test/test.dart';

void main() {
  group('SAW Edge Cases & Boundary Conditions', () {
    test('Edge Case 1: Zero value on cost criteria throws an Exception', () {
      // Perilaku saat ini: melempar Exception karena kriteria cost melakukan pembagian min / x_ij,
      // sehingga nilai 0 dilarang untuk menghindari pembagian dengan nol.
      final criteria = [
        WeightedDecisionCriteria(
          id: 'c_cost',
          name: 'Cost',
          weightPercent: 100,
          isBenefit: false,
          maxValue: 100,
        ),
      ];
      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'Alt 1'),
        WeightedDecisionAlternative(id: 'a2', name: 'Alt 2'),
      ];

      final matrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(id: 'r1', criteria: criteria[0], value: 0.0),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(
                id: 'r2', criteria: criteria[0], value: 50.0),
          ],
        ),
      ];

      expect(
        () => SawCalculator.calculate(matrix),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Zero value found in cost criteria'),
        )),
      );

      expect(
        () => SawCalculator.calculateDetailed(matrix),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Zero value found in cost criteria'),
        )),
      );
    });

    test('Edge Case 2: Column with identical values normalizes to 1.0', () {
      // Perilaku saat ini: ketika max == min pada suatu kolom kriteria (baik benefit maupun cost),
      // semua alternatif pada kolom tersebut diberi nilai normalisasi tepat 1.0.
      final criteria = [
        WeightedDecisionCriteria(
          id: 'c_benefit_equal',
          name: 'Equal Benefit',
          weightPercent: 50,
          isBenefit: true,
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          id: 'c_cost_equal',
          name: 'Equal Cost',
          weightPercent: 50,
          isBenefit: false,
          maxValue: 100,
        ),
      ];

      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'Alt 1'),
        WeightedDecisionAlternative(id: 'a2', name: 'Alt 2'),
      ];

      final matrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(
                id: 'r1_1', criteria: criteria[0], value: 75.0),
            WeightedDecisionRating(
                id: 'r1_2', criteria: criteria[1], value: 20.0),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(
                id: 'r2_1', criteria: criteria[0], value: 75.0),
            WeightedDecisionRating(
                id: 'r2_2', criteria: criteria[1], value: 20.0),
          ],
        ),
      ];

      final detailed = SawCalculator.calculateDetailed(matrix);

      // Verifikasi tiap sel pada kedua kolom bernilai 1.0
      expect(detailed.normalizedMatrix[0].ratings[0].value, closeTo(1.0, 1e-4));
      expect(detailed.normalizedMatrix[0].ratings[1].value, closeTo(1.0, 1e-4));
      expect(detailed.normalizedMatrix[1].ratings[0].value, closeTo(1.0, 1e-4));
      expect(detailed.normalizedMatrix[1].ratings[1].value, closeTo(1.0, 1e-4));

      // Nilai terbobot per sel = 1.0 * 0.5 = 0.5
      expect(detailed.weightedMatrix[0].ratings[0].value, closeTo(0.5, 1e-4));
      expect(detailed.weightedMatrix[0].ratings[1].value, closeTo(0.5, 1e-4));
      expect(detailed.weightedMatrix[1].ratings[0].value, closeTo(0.5, 1e-4));
      expect(detailed.weightedMatrix[1].ratings[1].value, closeTo(0.5, 1e-4));

      // Skor akhir = 1.0
      expect(detailed.scores[0].score, closeTo(1.0, 1e-4));
      expect(detailed.scores[1].score, closeTo(1.0, 1e-4));
    });

    test(
        'Edge Case 3: Single alternative evaluates correctly to score 1.0 and rank 1',
        () {
      // Perilaku saat ini: evaluasi dengan 1 alternatif diperbolehkan;
      // karena max == min untuk tiap kriteria, nilai ternormalisasi menjadi 1.0
      // dan skor total menjadi 1.0 dengan rank 1.
      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Speed',
          weightPercent: 40,
          isBenefit: true,
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'Cost',
          weightPercent: 60,
          isBenefit: false,
          maxValue: 100,
        ),
      ];

      final alternatives = [
        WeightedDecisionAlternative(id: 'solo', name: 'Solo Candidate'),
      ];

      final matrix = [
        WeightedDecisionMatrix(
          id: 'm_solo',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(
                id: 'r1', criteria: criteria[0], value: 80.0),
            WeightedDecisionRating(
                id: 'r2', criteria: criteria[1], value: 30.0),
          ],
        ),
      ];

      final detailed = SawCalculator.calculateDetailed(matrix);

      expect(detailed.scores.length, 1);
      expect(detailed.scores[0].alternative.id, 'solo');
      expect(detailed.scores[0].rank, 1);
      expect(detailed.scores[0].score, closeTo(1.0, 1e-4));

      expect(detailed.normalizedMatrix[0].ratings[0].value, closeTo(1.0, 1e-4));
      expect(detailed.normalizedMatrix[0].ratings[1].value, closeTo(1.0, 1e-4));

      expect(detailed.weightedMatrix[0].ratings[0].value, closeTo(0.40, 1e-4));
      expect(detailed.weightedMatrix[0].ratings[1].value, closeTo(0.60, 1e-4));
    });

    test(
        'Edge Case 4: Criteria weights not summing to 100 are proportionally rescaled',
        () {
      // Perilaku saat ini: jika total bobot tidak sama dengan 100 (misal: 20 dan 30, total 50),
      // MatrixValidator.normalizeCriteriaWeights mengalikan tiap bobot dengan faktor (100 / totalWeight).
      // Sehingga 20 -> 40% (0.4) dan 30 -> 60% (0.6).
      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Feature A',
          weightPercent: 20, // 20 / 50 = 40%
          isBenefit: true,
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'Feature B',
          weightPercent: 30, // 30 / 50 = 60%
          isBenefit: true,
          maxValue: 100,
        ),
      ];

      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'Alt 1'),
        WeightedDecisionAlternative(id: 'a2', name: 'Alt 2'),
      ];

      final matrix = [
        WeightedDecisionMatrix(
          id: 'm1',
          alternative: alternatives[0],
          ratings: [
            WeightedDecisionRating(
                id: 'r1_1', criteria: criteria[0], value: 100.0),
            WeightedDecisionRating(
                id: 'r1_2', criteria: criteria[1], value: 50.0),
          ],
        ),
        WeightedDecisionMatrix(
          id: 'm2',
          alternative: alternatives[1],
          ratings: [
            WeightedDecisionRating(
                id: 'r2_1', criteria: criteria[0], value: 50.0),
            WeightedDecisionRating(
                id: 'r2_2', criteria: criteria[1], value: 100.0),
          ],
        ),
      ];

      final detailed = SawCalculator.calculateDetailed(matrix);

      // Bobot ternormalisasi: c1 = 0.40, c2 = 0.60
      expect(detailed.normalizedWeights['c1'], closeTo(0.40, 1e-4));
      expect(detailed.normalizedWeights['c2'], closeTo(0.60, 1e-4));

      // Alt 1: c1 = 1.0 (bobot 0.40 -> 0.40), c2 = 0.5 (bobot 0.60 -> 0.30) => total 0.70
      expect(detailed.weightedMatrix[0].ratings[0].value, closeTo(0.40, 1e-4));
      expect(detailed.weightedMatrix[0].ratings[1].value, closeTo(0.30, 1e-4));

      // Alt 2: c1 = 0.5 (bobot 0.40 -> 0.20), c2 = 1.0 (bobot 0.60 -> 0.60) => total 0.80
      expect(detailed.weightedMatrix[1].ratings[0].value, closeTo(0.20, 1e-4));
      expect(detailed.weightedMatrix[1].ratings[1].value, closeTo(0.60, 1e-4));

      // Skor akhir & Rank
      expect(detailed.scores[0].alternative.id, 'a2');
      expect(detailed.scores[0].rank, 1);
      expect(detailed.scores[0].score, closeTo(0.80, 1e-4));

      expect(detailed.scores[1].alternative.id, 'a1');
      expect(detailed.scores[1].rank, 2);
      expect(detailed.scores[1].score, closeTo(0.70, 1e-4));
    });
  });
}
