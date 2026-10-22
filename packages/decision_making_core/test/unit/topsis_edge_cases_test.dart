import 'package:decision_making_core/decision_making_core.dart';
import 'package:test/test.dart';

void main() {
  group('TOPSIS Edge Cases & Boundary Conditions', () {
    test(
        'Edge Case 1: Column with all zero values avoids division by zero and evaluates cleanly without NaN',
        () {
      // Perilaku saat ini: ketika semua nilai pada suatu kolom kriteria adalah 0.0,
      // pembagi Euclidean menjadi sqrt(0) = 0.0.
      // normalizeEuclidean menangani ini dengan menghasilkan nilai ternormalisasi 0.0 (bukan NaN atau throw).
      final criteria = [
        WeightedDecisionCriteria(
          id: 'c_zero',
          name: 'Zero Criteria',
          weightPercent: 50,
          isBenefit: true,
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          id: 'c_normal',
          name: 'Normal Criteria',
          weightPercent: 50,
          isBenefit: true,
          maxValue: 100,
        ),
      ];

      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'Alt 1'),
        WeightedDecisionAlternative(id: 'a2', name: 'Alt 2'),
      ];

      final raw = TopsisRawMatrix(
        criterias: criteria,
        matrixs: [
          WeightedDecisionMatrix(
            id: 'm1',
            alternative: alternatives[0],
            ratings: [
              WeightedDecisionRating(
                  id: 'r1_1', criteria: criteria[0], value: 0.0),
              WeightedDecisionRating(
                  id: 'r1_2', criteria: criteria[1], value: 10.0),
            ],
          ),
          WeightedDecisionMatrix(
            id: 'm2',
            alternative: alternatives[1],
            ratings: [
              WeightedDecisionRating(
                  id: 'r2_1', criteria: criteria[0], value: 0.0),
              WeightedDecisionRating(
                  id: 'r2_2', criteria: criteria[1], value: 20.0),
            ],
          ),
        ],
      );

      final detailed = TopsisCalculator.calculateDetailed(raw);

      // Verifikasi sel kolom nol bernilai 0.0 tanpa NaN
      expect(detailed.normalizedMatrix[0].ratings[0].value, closeTo(0.0, 1e-4));
      expect(detailed.normalizedMatrix[1].ratings[0].value, closeTo(0.0, 1e-4));
      expect(detailed.normalizedMatrix[0].ratings[0].value!.isNaN, isFalse);

      // Verifikasi ideal solution untuk kolom nol adalah 0.0
      expect(detailed.positiveIdeal['c_zero'], closeTo(0.0, 1e-4));
      expect(detailed.negativeIdeal['c_zero'], closeTo(0.0, 1e-4));

      // Verifikasi skor akhir valid tanpa NaN
      expect(detailed.scores[0].score.isNaN, isFalse);
      expect(detailed.scores[1].score.isNaN, isFalse);
      expect(detailed.scores[0].alternative.id, 'a2');
      expect(detailed.scores[0].score, closeTo(1.0, 1e-4));
      expect(detailed.scores[1].alternative.id, 'a1');
      expect(detailed.scores[1].score, closeTo(0.0, 1e-4));
    });

    test(
        'Edge Case 2: Single alternative results in D+ = D- = 0 and score 0.5 without NaN',
        () {
      // Perilaku saat ini: dengan 1 alternatif, solusi ideal positif dan negatif berhimpit pada titik yang sama (A+ = A-).
      // Akibatnya D+ = 0.0 dan D- = 0.0.
      // Bentuk tak tentu 0 / (0 + 0) ditangani dengan mengembalikan nilai netral 0.5 (bukan NaN).
      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'Quality',
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
        WeightedDecisionAlternative(id: 'solo', name: 'Solo Option'),
      ];

      final raw = TopsisRawMatrix(
        criterias: criteria,
        matrixs: [
          WeightedDecisionMatrix(
            id: 'm_solo',
            alternative: alternatives[0],
            ratings: [
              WeightedDecisionRating(
                  id: 'r1', criteria: criteria[0], value: 50.0),
              WeightedDecisionRating(
                  id: 'r2', criteria: criteria[1], value: 80.0),
            ],
          ),
        ],
      );

      final detailed = TopsisCalculator.calculateDetailed(raw);

      expect(detailed.separationPlus['solo'], closeTo(0.0, 1e-4));
      expect(detailed.separationMinus['solo'], closeTo(0.0, 1e-4));

      expect(detailed.scores.length, 1);
      expect(detailed.scores[0].score.isNaN, isFalse);
      expect(detailed.scores[0].score, closeTo(0.5, 1e-4));
      expect(detailed.scores[0].rank, 1);
    });

    test(
        'Edge Case 3: Column with identical values contributes zero distance and evaluates without NaN',
        () {
      // Perilaku saat ini: ketika suatu kolom memiliki nilai identik untuk semua alternatif (mis. 10.0 dan 10.0),
      // A+ = A- pada kriteria tersebut, sehingga kontribusi jarak kolom terhadap D+ dan D- adalah 0.0.
      // Peringkat ditentukan oleh kolom lainnya yang bervariasi.
      final criteria = [
        WeightedDecisionCriteria(
          id: 'c_same',
          name: 'Identical Criterion',
          weightPercent: 50,
          isBenefit: true,
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          id: 'c_diff',
          name: 'Differentiating Criterion',
          weightPercent: 50,
          isBenefit: true,
          maxValue: 100,
        ),
      ];

      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'Alt 1'),
        WeightedDecisionAlternative(id: 'a2', name: 'Alt 2'),
      ];

      final raw = TopsisRawMatrix(
        criterias: criteria,
        matrixs: [
          WeightedDecisionMatrix(
            id: 'm1',
            alternative: alternatives[0],
            ratings: [
              WeightedDecisionRating(
                  id: 'r1_1', criteria: criteria[0], value: 10.0),
              WeightedDecisionRating(
                  id: 'r1_2', criteria: criteria[1], value: 20.0),
            ],
          ),
          WeightedDecisionMatrix(
            id: 'm2',
            alternative: alternatives[1],
            ratings: [
              WeightedDecisionRating(
                  id: 'r2_1', criteria: criteria[0], value: 10.0),
              WeightedDecisionRating(
                  id: 'r2_2', criteria: criteria[1], value: 40.0),
            ],
          ),
        ],
      );

      final detailed = TopsisCalculator.calculateDetailed(raw);

      // Nilai ternormalisasi kriteria sama: 10 / sqrt(200) = 1 / sqrt(2) ≈ 0.707107
      expect(detailed.normalizedMatrix[0].ratings[0].value,
          closeTo(0.707107, 1e-4));
      expect(detailed.normalizedMatrix[1].ratings[0].value,
          closeTo(0.707107, 1e-4));

      // A+ dan A- pada c_same sama (0.707107 * 0.5 = 0.353553)
      expect(detailed.positiveIdeal['c_same'], closeTo(0.353553, 1e-4));
      expect(detailed.negativeIdeal['c_same'], closeTo(0.353553, 1e-4));

      // Keputusan ditentukan oleh c_diff (a2 lebih tinggi dari a1)
      expect(detailed.scores[0].alternative.id, 'a2');
      expect(detailed.scores[0].score, closeTo(1.0, 1e-4));
      expect(detailed.scores[1].alternative.id, 'a1');
      expect(detailed.scores[1].score, closeTo(0.0, 1e-4));
    });

    test(
        'Edge Case 4: Alternatives with identical distances evaluate to equal scores without NaN',
        () {
      // Perilaku saat ini: ketika dua alternatif memiliki nilai input persis sama,
      // jarak D+ dan D- keduanya identik, sehingga nilai kedekatan relatif sama persis.
      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'C1',
          weightPercent: 50,
          isBenefit: true,
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'C2',
          weightPercent: 50,
          isBenefit: false,
          maxValue: 100,
        ),
      ];

      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'Alt 1'),
        WeightedDecisionAlternative(id: 'a2', name: 'Alt 2'),
        WeightedDecisionAlternative(id: 'a3', name: 'Alt 3'),
      ];

      final raw = TopsisRawMatrix(
        criterias: criteria,
        matrixs: [
          WeightedDecisionMatrix(
            id: 'm1',
            alternative: alternatives[0],
            ratings: [
              WeightedDecisionRating(
                  id: 'r1_1', criteria: criteria[0], value: 40.0),
              WeightedDecisionRating(
                  id: 'r1_2', criteria: criteria[1], value: 20.0),
            ],
          ),
          WeightedDecisionMatrix(
            id: 'm2',
            alternative: alternatives[1],
            ratings: [
              WeightedDecisionRating(
                  id: 'r2_1', criteria: criteria[0], value: 40.0),
              WeightedDecisionRating(
                  id: 'r2_2', criteria: criteria[1], value: 20.0),
            ],
          ),
          WeightedDecisionMatrix(
            id: 'm3',
            alternative: alternatives[2],
            ratings: [
              WeightedDecisionRating(
                  id: 'r3_1', criteria: criteria[0], value: 20.0),
              WeightedDecisionRating(
                  id: 'r3_2', criteria: criteria[1], value: 40.0),
            ],
          ),
        ],
      );

      final detailed = TopsisCalculator.calculateDetailed(raw);

      // a1 dan a2 memiliki D+ dan D- identik
      expect(detailed.separationPlus['a1'],
          closeTo(detailed.separationPlus['a2']!, 1e-4));
      expect(detailed.separationMinus['a1'],
          closeTo(detailed.separationMinus['a2']!, 1e-4));

      // Skor relatif a1 dan a2 sama persis
      expect(detailed.scores[0].score, closeTo(detailed.scores[1].score, 1e-4));
      expect(detailed.scores[0].score.isNaN, isFalse);
      expect(detailed.scores[1].score.isNaN, isFalse);
    });

    test(
        'Edge Case 5: When all alternatives are identical, D+ = D- = 0 resolves to 0.5 for all',
        () {
      // Perilaku saat ini: ketika semua alternatif memiliki nilai matriks yang sama persis,
      // semua titik berhimpit dengan A+ dan A-, sehingga D+ = 0 dan D- = 0 untuk seluruh alternatif.
      // Denominator 0 + 0 = 0 ditangani secara aman dengan menetapkan skor = 0.5 untuk setiap alternatif.
      final criteria = [
        WeightedDecisionCriteria(
          id: 'c1',
          name: 'C1',
          weightPercent: 50,
          isBenefit: true,
          maxValue: 100,
        ),
        WeightedDecisionCriteria(
          id: 'c2',
          name: 'C2',
          weightPercent: 50,
          isBenefit: true,
          maxValue: 100,
        ),
      ];

      final alternatives = [
        WeightedDecisionAlternative(id: 'a1', name: 'Alt 1'),
        WeightedDecisionAlternative(id: 'a2', name: 'Alt 2'),
      ];

      final raw = TopsisRawMatrix(
        criterias: criteria,
        matrixs: [
          WeightedDecisionMatrix(
            id: 'm1',
            alternative: alternatives[0],
            ratings: [
              WeightedDecisionRating(
                  id: 'r1_1', criteria: criteria[0], value: 10.0),
              WeightedDecisionRating(
                  id: 'r1_2', criteria: criteria[1], value: 20.0),
            ],
          ),
          WeightedDecisionMatrix(
            id: 'm2',
            alternative: alternatives[1],
            ratings: [
              WeightedDecisionRating(
                  id: 'r2_1', criteria: criteria[0], value: 10.0),
              WeightedDecisionRating(
                  id: 'r2_2', criteria: criteria[1], value: 20.0),
            ],
          ),
        ],
      );

      final detailed = TopsisCalculator.calculateDetailed(raw);

      expect(detailed.separationPlus['a1'], closeTo(0.0, 1e-4));
      expect(detailed.separationMinus['a1'], closeTo(0.0, 1e-4));
      expect(detailed.separationPlus['a2'], closeTo(0.0, 1e-4));
      expect(detailed.separationMinus['a2'], closeTo(0.0, 1e-4));

      expect(detailed.scores[0].score, closeTo(0.5, 1e-4));
      expect(detailed.scores[1].score, closeTo(0.5, 1e-4));
      expect(detailed.scores[0].score.isNaN, isFalse);
    });
  });
}
