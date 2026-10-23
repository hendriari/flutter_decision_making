import 'package:decision_making_core/decision_making_core.dart';
import 'package:test/test.dart';

TopsisRawMatrix _buildDataset({
  required List<String> altIds,
  required List<String> critIds,
  required List<bool> isBenefits,
  required List<List<double>> values,
  List<double>? initialWeights,
}) {
  final criteria = <WeightedDecisionCriteria>[];
  for (var j = 0; j < critIds.length; j++) {
    var maxVal = 0.0;
    for (var i = 0; i < altIds.length; i++) {
      if (values[i][j] > maxVal) maxVal = values[i][j];
    }
    criteria.add(
      WeightedDecisionCriteria(
        id: critIds[j],
        name: critIds[j].toUpperCase(),
        isBenefit: isBenefits[j],
        weightPercent:
            initialWeights != null ? initialWeights[j] : 100.0 / critIds.length,
        maxValue: maxVal + 1000.0,
      ),
    );
  }

  final rows = <WeightedDecisionMatrix>[];
  for (var i = 0; i < altIds.length; i++) {
    final alt = WeightedDecisionAlternative(
      id: altIds[i],
      name: altIds[i].toUpperCase(),
    );
    final ratings = <WeightedDecisionRating>[];
    for (var j = 0; j < critIds.length; j++) {
      ratings.add(
        WeightedDecisionRating(
          id: 'r_${altIds[i]}_${critIds[j]}',
          criteria: criteria[j],
          value: values[i][j],
        ),
      );
    }
    rows.add(
      WeightedDecisionMatrix(
        id: 'm_${altIds[i]}',
        alternative: alt,
        ratings: ratings,
      ),
    );
  }

  return TopsisRawMatrix(criterias: criteria, matrixs: rows);
}

void main() {
  group('Objective Weighting (Entropy & CRITIC) - Golden Reference Tests', () {
    // -------------------------------------------------------------------------
    // 1. SAW Golden 1: X = [[100,3,3500,1.5],[150,2,4500,2.0],[200,3,3000,3.5]]
    //    benefit = [cost, benefit, benefit, cost]
    // -------------------------------------------------------------------------
    final sawGolden1 = _buildDataset(
      altIds: ['a1', 'a2', 'a3'],
      critIds: ['c1', 'c2', 'c3', 'c4'],
      isBenefits: [false, true, true, false],
      values: [
        [100.0, 3.0, 3500.0, 1.5],
        [150.0, 2.0, 4500.0, 2.0],
        [200.0, 3.0, 3000.0, 3.5],
      ],
    );

    test('SAW Golden 1 - Entropy weights and intermediate values', () {
      final result =
          ObjectiveWeightCalculator.calculateEntropy(sawGolden1.matrixs);

      expect(result.criteriaIds, ['c1', 'c2', 'c3', 'c4']);

      // Entropy e_j: [0.965634, 0.985057, 0.987030, 0.941735]
      expect(result.entropy['c1'], closeTo(0.965634, 1e-4));
      expect(result.entropy['c2'], closeTo(0.985057, 1e-4));
      expect(result.entropy['c3'], closeTo(0.987030, 1e-4));
      expect(result.entropy['c4'], closeTo(0.941735, 1e-4));

      // Divergence d_j: [0.034366, 0.014943, 0.012970, 0.058265]
      expect(result.divergence['c1'], closeTo(0.034366, 1e-4));
      expect(result.divergence['c2'], closeTo(0.014943, 1e-4));
      expect(result.divergence['c3'], closeTo(0.012970, 1e-4));
      expect(result.divergence['c4'], closeTo(0.058265, 1e-4));

      // Weights w_j: [0.285091, 0.123963, 0.107597, 0.483349]
      expect(result.weights['c1'], closeTo(0.285091, 1e-4));
      expect(result.weights['c2'], closeTo(0.123963, 1e-4));
      expect(result.weights['c3'], closeTo(0.107597, 1e-4));
      expect(result.weights['c4'], closeTo(0.483349, 1e-4));

      final weightSum =
          result.weights.values.fold<double>(0.0, (a, b) => a + b);
      expect(weightSum, closeTo(1.0, 1e-9));

      // Proportion matrix p_ij
      expect(
          result.proportionMatrix['a1']!['c1'], closeTo(100.0 / 450.0, 1e-4));
      expect(
          result.proportionMatrix['a2']!['c1'], closeTo(150.0 / 450.0, 1e-4));
      expect(
          result.proportionMatrix['a3']!['c1'], closeTo(200.0 / 450.0, 1e-4));

      final json = result.toJson();
      expect(json['criteria_ids'], ['c1', 'c2', 'c3', 'c4']);
      expect((json['weights'] as Map)['c1'], closeTo(0.285091, 1e-4));
    });

    test('SAW Golden 1 - CRITIC weights and intermediate values', () {
      final result =
          ObjectiveWeightCalculator.calculateCritic(sawGolden1.matrixs);

      expect(result.criteriaIds, ['c1', 'c2', 'c3', 'c4']);

      // Sample standard deviation sigma_j: [0.500000, 0.577350, 0.509175, 0.520416]
      expect(result.standardDeviations['c1'], closeTo(0.500000, 1e-4));
      expect(result.standardDeviations['c2'], closeTo(0.577350, 1e-4));
      expect(result.standardDeviations['c3'], closeTo(0.509175, 1e-4));
      expect(result.standardDeviations['c4'], closeTo(0.520416, 1e-4));

      // Information content C_j: [0.855952, 2.437724, 1.548416, 0.905537]
      expect(result.informationContent['c1'], closeTo(0.855952, 1e-4));
      expect(result.informationContent['c2'], closeTo(2.437724, 1e-4));
      expect(result.informationContent['c3'], closeTo(1.548416, 1e-4));
      expect(result.informationContent['c4'], closeTo(0.905537, 1e-4));

      // Weights w_j: [0.148923, 0.424127, 0.269401, 0.157550]
      expect(result.weights['c1'], closeTo(0.148923, 1e-4));
      expect(result.weights['c2'], closeTo(0.424127, 1e-4));
      expect(result.weights['c3'], closeTo(0.269401, 1e-4));
      expect(result.weights['c4'], closeTo(0.157550, 1e-4));

      final weightSum =
          result.weights.values.fold<double>(0.0, (a, b) => a + b);
      expect(weightSum, closeTo(1.0, 1e-9));

      // Correlation matrix symmetry & diagonal = 1
      for (final cj in result.criteriaIds) {
        expect(result.correlationMatrix[cj]![cj], closeTo(1.0, 1e-9));
        for (final ck in result.criteriaIds) {
          expect(
            result.correlationMatrix[cj]![ck],
            closeTo(result.correlationMatrix[ck]![cj]!, 1e-9),
          );
        }
      }

      final json = result.toJson();
      expect(json['criteria_ids'], ['c1', 'c2', 'c3', 'c4']);
      expect((json['weights'] as Map)['c2'], closeTo(0.424127, 1e-4));
    });

    // -------------------------------------------------------------------------
    // 2. TOPSIS Golden 1: X = [[5,8,4,7],[7,6,8,9],[8,9,6,6],[7,7,7,7]]
    //    tipe = [benefit, benefit, benefit, cost]
    // -------------------------------------------------------------------------
    final topsisGolden1 = _buildDataset(
      altIds: ['a1', 'a2', 'a3', 'a4'],
      critIds: ['c1', 'c2', 'c3', 'c4'],
      isBenefits: [true, true, true, false],
      values: [
        [5.0, 8.0, 4.0, 7.0],
        [7.0, 6.0, 8.0, 9.0],
        [8.0, 9.0, 6.0, 6.0],
        [7.0, 7.0, 7.0, 7.0],
      ],
    );

    test('TOPSIS Golden 1 - Entropy weights and intermediate values', () {
      final result =
          ObjectiveWeightCalculator.calculateEntropy(topsisGolden1.matrixs);

      expect(result.criteriaIds, ['c1', 'c2', 'c3', 'c4']);

      // Entropy e_j: [0.990173, 0.991936, 0.978703, 0.992058]
      expect(result.entropy['c1'], closeTo(0.990173, 1e-4));
      expect(result.entropy['c2'], closeTo(0.991936, 1e-4));
      expect(result.entropy['c3'], closeTo(0.978703, 1e-4));
      expect(result.entropy['c4'], closeTo(0.992058, 1e-4));

      // Divergence d_j: [0.009827, 0.008064, 0.021297, 0.007942]
      expect(result.divergence['c1'], closeTo(0.009827, 1e-4));
      expect(result.divergence['c2'], closeTo(0.008064, 1e-4));
      expect(result.divergence['c3'], closeTo(0.021297, 1e-4));
      expect(result.divergence['c4'], closeTo(0.007942, 1e-4));

      // Weights w_j: [0.208504, 0.171110, 0.451879, 0.168507]
      expect(result.weights['c1'], closeTo(0.208504, 1e-4));
      expect(result.weights['c2'], closeTo(0.171110, 1e-4));
      expect(result.weights['c3'], closeTo(0.451879, 1e-4));
      expect(result.weights['c4'], closeTo(0.168507, 1e-4));

      final weightSum =
          result.weights.values.fold<double>(0.0, (a, b) => a + b);
      expect(weightSum, closeTo(1.0, 1e-9));
    });

    test('TOPSIS Golden 1 - CRITIC weights and intermediate values', () {
      final result =
          ObjectiveWeightCalculator.calculateCritic(topsisGolden1.matrixs);

      expect(result.criteriaIds, ['c1', 'c2', 'c3', 'c4']);

      // Sample standard deviation sigma_j: [0.419435, 0.430331, 0.426956, 0.419435]
      expect(result.standardDeviations['c1'], closeTo(0.419435, 1e-4));
      expect(result.standardDeviations['c2'], closeTo(0.430331, 1e-4));
      expect(result.standardDeviations['c3'], closeTo(0.426956, 1e-4));
      expect(result.standardDeviations['c4'], closeTo(0.419435, 1e-4));

      // Information content C_j: [0.872541, 1.142254, 1.538229, 1.048756]
      expect(result.informationContent['c1'], closeTo(0.872541, 1e-4));
      expect(result.informationContent['c2'], closeTo(1.142254, 1e-4));
      expect(result.informationContent['c3'], closeTo(1.538229, 1e-4));
      expect(result.informationContent['c4'], closeTo(1.048756, 1e-4));

      // Weights w_j: [0.189609, 0.248220, 0.334268, 0.227902]
      expect(result.weights['c1'], closeTo(0.189609, 1e-4));
      expect(result.weights['c2'], closeTo(0.248220, 1e-4));
      expect(result.weights['c3'], closeTo(0.334268, 1e-4));
      expect(result.weights['c4'], closeTo(0.227902, 1e-4));

      final weightSum =
          result.weights.values.fold<double>(0.0, (a, b) => a + b);
      expect(weightSum, closeTo(1.0, 1e-9));
    });

    // -------------------------------------------------------------------------
    // 3. Dataset S2: X = [[5,1,5],[2,7,9],[9,6,8],[4,2,5]]
    //    tipe = [benefit, benefit, cost]
    // -------------------------------------------------------------------------
    final datasetS2 = _buildDataset(
      altIds: ['a1', 'a2', 'a3', 'a4'],
      critIds: ['c1', 'c2', 'c3'],
      isBenefits: [true, true, false],
      values: [
        [5.0, 1.0, 5.0],
        [2.0, 7.0, 9.0],
        [9.0, 6.0, 8.0],
        [4.0, 2.0, 5.0],
      ],
    );

    test('Dataset S2 - Entropy weights and intermediate values', () {
      final result =
          ObjectiveWeightCalculator.calculateEntropy(datasetS2.matrixs);

      expect(result.criteriaIds, ['c1', 'c2', 'c3']);

      // Entropy e_j: [0.907490, 0.838711, 0.974692]
      expect(result.entropy['c1'], closeTo(0.907490, 1e-4));
      expect(result.entropy['c2'], closeTo(0.838711, 1e-4));
      expect(result.entropy['c3'], closeTo(0.974692, 1e-4));

      // Divergence d_j: [0.092510, 0.161289, 0.025308]
      expect(result.divergence['c1'], closeTo(0.092510, 1e-4));
      expect(result.divergence['c2'], closeTo(0.161289, 1e-4));
      expect(result.divergence['c3'], closeTo(0.025308, 1e-4));

      // Weights w_j: [0.331449, 0.577875, 0.090675]
      expect(result.weights['c1'], closeTo(0.331449, 1e-4));
      expect(result.weights['c2'], closeTo(0.577875, 1e-4));
      expect(result.weights['c3'], closeTo(0.090675, 1e-4));
    });

    test('Dataset S2 - CRITIC weights and intermediate values', () {
      final result =
          ObjectiveWeightCalculator.calculateCritic(datasetS2.matrixs);

      expect(result.criteriaIds, ['c1', 'c2', 'c3']);

      // Sample standard deviation sigma_j: [0.420560, 0.490653, 0.515388]
      expect(result.standardDeviations['c1'], closeTo(0.420560, 1e-4));
      expect(result.standardDeviations['c2'], closeTo(0.490653, 1e-4));
      expect(result.standardDeviations['c3'], closeTo(0.515388, 1e-4));

      // Information content C_j: [0.824945, 1.447507, 1.540301]
      expect(result.informationContent['c1'], closeTo(0.824945, 1e-4));
      expect(result.informationContent['c2'], closeTo(1.447507, 1e-4));
      expect(result.informationContent['c3'], closeTo(1.540301, 1e-4));

      // Weights w_j: [0.216365, 0.379649, 0.403987]
      expect(result.weights['c1'], closeTo(0.216365, 1e-4));
      expect(result.weights['c2'], closeTo(0.379649, 1e-4));
      expect(result.weights['c3'], closeTo(0.403987, 1e-4));
    });
  });

  group('Objective Weighting - Mathematical Invariants', () {
    test(
        'Scaling columns by positive constants does not change Entropy weights',
        () {
      final base = _buildDataset(
        altIds: ['a1', 'a2', 'a3', 'a4'],
        critIds: ['c1', 'c2', 'c3'],
        isBenefits: [true, true, false],
        values: [
          [5.0, 1.0, 5.0],
          [2.0, 7.0, 9.0],
          [9.0, 6.0, 8.0],
          [4.0, 2.0, 5.0],
        ],
      );

      // Multiply column 1 by 3.5, column 2 by 100.0, column 3 by 0.25
      final scaled = _buildDataset(
        altIds: ['a1', 'a2', 'a3', 'a4'],
        critIds: ['c1', 'c2', 'c3'],
        isBenefits: [true, true, false],
        values: [
          [5.0 * 3.5, 1.0 * 100.0, 5.0 * 0.25],
          [2.0 * 3.5, 7.0 * 100.0, 9.0 * 0.25],
          [9.0 * 3.5, 6.0 * 100.0, 8.0 * 0.25],
          [4.0 * 3.5, 2.0 * 100.0, 5.0 * 0.25],
        ],
      );

      final resBase = ObjectiveWeightCalculator.calculateEntropy(base.matrixs);
      final resScaled =
          ObjectiveWeightCalculator.calculateEntropy(scaled.matrixs);

      for (final cid in resBase.criteriaIds) {
        expect(resScaled.entropy[cid], closeTo(resBase.entropy[cid]!, 1e-9));
        expect(
          resScaled.divergence[cid],
          closeTo(resBase.divergence[cid]!, 1e-9),
        );
        expect(resScaled.weights[cid], closeTo(resBase.weights[cid]!, 1e-9));
        for (final aid in ['a1', 'a2', 'a3', 'a4']) {
          expect(
            resScaled.proportionMatrix[aid]![cid],
            closeTo(resBase.proportionMatrix[aid]![cid]!, 1e-9),
          );
        }
      }
    });

    test(
        'Permuting row (alternative) order does not change Entropy or CRITIC weights',
        () {
      final original = _buildDataset(
        altIds: ['a1', 'a2', 'a3', 'a4'],
        critIds: ['c1', 'c2', 'c3', 'c4'],
        isBenefits: [true, true, true, false],
        values: [
          [5.0, 8.0, 4.0, 7.0],
          [7.0, 6.0, 8.0, 9.0],
          [8.0, 9.0, 6.0, 6.0],
          [7.0, 7.0, 7.0, 7.0],
        ],
      );

      // Permuted row order: a3, a1, a4, a2
      final permuted = _buildDataset(
        altIds: ['a3', 'a1', 'a4', 'a2'],
        critIds: ['c1', 'c2', 'c3', 'c4'],
        isBenefits: [true, true, true, false],
        values: [
          [8.0, 9.0, 6.0, 6.0],
          [5.0, 8.0, 4.0, 7.0],
          [7.0, 7.0, 7.0, 7.0],
          [7.0, 6.0, 8.0, 9.0],
        ],
      );

      final entOrig =
          ObjectiveWeightCalculator.calculateEntropy(original.matrixs);
      final entPerm =
          ObjectiveWeightCalculator.calculateEntropy(permuted.matrixs);

      final critOrig =
          ObjectiveWeightCalculator.calculateCritic(original.matrixs);
      final critPerm =
          ObjectiveWeightCalculator.calculateCritic(permuted.matrixs);

      for (final cid in ['c1', 'c2', 'c3', 'c4']) {
        expect(entPerm.entropy[cid], closeTo(entOrig.entropy[cid]!, 1e-9));
        expect(
          entPerm.divergence[cid],
          closeTo(entOrig.divergence[cid]!, 1e-9),
        );
        expect(entPerm.weights[cid], closeTo(entOrig.weights[cid]!, 1e-9));

        expect(
          critPerm.standardDeviations[cid],
          closeTo(critOrig.standardDeviations[cid]!, 1e-9),
        );
        expect(
          critPerm.informationContent[cid],
          closeTo(critOrig.informationContent[cid]!, 1e-9),
        );
        expect(critPerm.weights[cid], closeTo(critOrig.weights[cid]!, 1e-9));
      }
    });
  });

  group('Combined Usage: SAW and TOPSIS with Entropy & CRITIC on Golden 1', () {
    final sawGolden1 = _buildDataset(
      altIds: ['a1', 'a2', 'a3'],
      critIds: ['c1', 'c2', 'c3', 'c4'],
      isBenefits: [false, true, true, false],
      values: [
        [100.0, 3.0, 3500.0, 1.5],
        [150.0, 2.0, 4500.0, 2.0],
        [200.0, 3.0, 3000.0, 3.5],
      ],
      initialWeights: [25.0, 25.0, 25.0, 25.0],
    );

    final topsisGolden1 = _buildDataset(
      altIds: ['a1', 'a2', 'a3', 'a4'],
      critIds: ['c1', 'c2', 'c3', 'c4'],
      isBenefits: [true, true, true, false],
      values: [
        [5.0, 8.0, 4.0, 7.0],
        [7.0, 6.0, 8.0, 9.0],
        [8.0, 9.0, 6.0, 6.0],
        [7.0, 7.0, 7.0, 7.0],
      ],
      initialWeights: [30.0, 20.0, 25.0, 25.0],
    );

    test('SAW Golden 1 with Entropy weights (SAW & TOPSIS evaluation)', () {
      final entropy =
          ObjectiveWeightCalculator.calculateEntropy(sawGolden1.matrixs);
      final weightedMatrix = entropy.applyToMatrix(sawGolden1.matrixs);

      // Verify original matrix was not mutated
      expect(
          sawGolden1.matrixs.first.ratings.first.criteria!.weightPercent, 25.0);

      // Verify applyToCriteria preserves benefit/cost and sets weightPercent = w_j * 100
      final updatedCriteria = entropy.applyToCriteria(sawGolden1.criterias);
      expect(updatedCriteria[0].isBenefit, isFalse);
      expect(updatedCriteria[1].isBenefit, isTrue);
      expect(updatedCriteria[0].weightPercent, closeTo(28.5091, 1e-2));
      expect(updatedCriteria[1].weightPercent, closeTo(12.3963, 1e-2));
      expect(updatedCriteria[2].weightPercent, closeTo(10.7597, 1e-2));
      expect(updatedCriteria[3].weightPercent, closeTo(48.3349, 1e-2));

      // SAW calculation with Entropy weights
      final sawDetailed = SawCalculator.calculateDetailed(weightedMatrix);
      final sawScores = {
        for (final r in sawDetailed.scores) r.alternative.id!: r.score
      };
      final sawRanking =
          sawDetailed.scores.map((r) => r.alternative.id!).toList();

      expect(sawScores['a1'], closeTo(0.976090, 1e-4));
      expect(sawScores['a2'], closeTo(0.742811, 1e-4));
      expect(sawScores['a3'], closeTo(0.545390, 1e-4));
      expect(sawRanking, ['a1', 'a2', 'a3']);

      // TOPSIS calculation on SAW Golden 1 with Entropy weights
      final topsisRaw = entropy.applyToTopsisRawMatrix(sawGolden1);
      final topsisDetailed = TopsisCalculator.calculateDetailed(topsisRaw);
      final topsisScores = {
        for (final r in topsisDetailed.scores) r.alternative.id!: r.score
      };
      final topsisRanking =
          topsisDetailed.scores.map((r) => r.alternative.id!).toList();

      expect(topsisScores['a1'], closeTo(0.937371, 1e-4));
      expect(topsisScores['a2'], closeTo(0.686219, 1e-4));
      expect(topsisScores['a3'], closeTo(0.095711, 1e-4));
      expect(topsisRanking, ['a1', 'a2', 'a3']);
    });

    test('SAW Golden 1 with CRITIC weights (SAW & TOPSIS evaluation)', () {
      final critic =
          ObjectiveWeightCalculator.calculateCritic(sawGolden1.matrixs);
      final weightedMatrix = critic.applyToMatrix(sawGolden1.matrixs);

      final sawDetailed = SawCalculator.calculateDetailed(weightedMatrix);
      final sawScores = {
        for (final r in sawDetailed.scores) r.alternative.id!: r.score
      };
      final sawRanking =
          sawDetailed.scores.map((r) => r.alternative.id!).toList();

      expect(sawScores['a1'], closeTo(0.940133, 1e-4));
      expect(sawScores['a2'], closeTo(0.769596, 1e-4));
      expect(sawScores['a3'], closeTo(0.745710, 1e-4));
      expect(sawRanking, ['a1', 'a2', 'a3']);

      final topsisRaw = critic.applyToTopsisRawMatrix(sawGolden1);
      final topsisDetailed = TopsisCalculator.calculateDetailed(topsisRaw);
      final topsisScores = {
        for (final r in topsisDetailed.scores) r.alternative.id!: r.score
      };
      final topsisRanking =
          topsisDetailed.scores.map((r) => r.alternative.id!).toList();

      expect(topsisScores['a1'], closeTo(0.757367, 1e-4));
      expect(topsisScores['a2'], closeTo(0.477031, 1e-4));
      expect(topsisScores['a3'], closeTo(0.448525, 1e-4));
      expect(topsisRanking, ['a1', 'a2', 'a3']);
    });

    test('TOPSIS Golden 1 with Entropy weights (TOPSIS & SAW evaluation)', () {
      final entropy =
          ObjectiveWeightCalculator.calculateEntropy(topsisGolden1.matrixs);
      final weightedTopsis = entropy.applyToTopsisRawMatrix(topsisGolden1);

      // TOPSIS calculation with Entropy weights
      final topsisDetailed = TopsisCalculator.calculateDetailed(weightedTopsis);
      final topsisScores = {
        for (final r in topsisDetailed.scores) r.alternative.id!: r.score
      };
      final topsisRanking =
          topsisDetailed.scores.map((r) => r.alternative.id!).toList();

      expect(topsisScores['a2'], closeTo(0.739714, 1e-4));
      expect(topsisScores['a4'], closeTo(0.710553, 1e-4));
      expect(topsisScores['a3'], closeTo(0.579180, 1e-4));
      expect(topsisScores['a1'], closeTo(0.177908, 1e-4));
      expect(topsisRanking, ['a2', 'a4', 'a3', 'a1']);

      // SAW calculation on TOPSIS Golden 1 with Entropy weights
      final sawDetailed = SawCalculator.calculateDetailed(
        entropy.applyToMatrix(topsisGolden1.matrixs),
      );
      final sawScores = {
        for (final r in sawDetailed.scores) r.alternative.id!: r.score
      };
      final sawRanking =
          sawDetailed.scores.map((r) => r.alternative.id!).toList();

      expect(sawScores['a3'], closeTo(0.887030, 1e-4));
      expect(sawScores['a2'], closeTo(0.860731, 1e-4));
      expect(sawScores['a4'], closeTo(0.855355, 1e-4));
      expect(sawScores['a1'], closeTo(0.652787, 1e-4));
      expect(sawRanking, ['a3', 'a2', 'a4', 'a1']);
    });

    test('TOPSIS Golden 1 with CRITIC weights (TOPSIS & SAW evaluation)', () {
      final critic =
          ObjectiveWeightCalculator.calculateCritic(topsisGolden1.matrixs);
      final weightedTopsis = critic.applyToTopsisRawMatrix(topsisGolden1);

      // TOPSIS calculation with CRITIC weights
      final topsisDetailed = TopsisCalculator.calculateDetailed(weightedTopsis);
      final topsisScores = {
        for (final r in topsisDetailed.scores) r.alternative.id!: r.score
      };
      final topsisRanking =
          topsisDetailed.scores.map((r) => r.alternative.id!).toList();

      expect(topsisScores['a4'], closeTo(0.658261, 1e-4));
      expect(topsisScores['a3'], closeTo(0.646048, 1e-4));
      expect(topsisScores['a2'], closeTo(0.609146, 1e-4));
      expect(topsisScores['a1'], closeTo(0.283048, 1e-4));
      expect(topsisRanking, ['a4', 'a3', 'a2', 'a1']);

      // SAW calculation on TOPSIS Golden 1 with CRITIC weights
      final sawDetailed = SawCalculator.calculateDetailed(
        critic.applyToMatrix(topsisGolden1.matrixs),
      );
      final sawScores = {
        for (final r in sawDetailed.scores) r.alternative.id!: r.score
      };
      final sawRanking =
          sawDetailed.scores.map((r) => r.alternative.id!).toList();

      expect(sawScores['a3'], closeTo(0.916433, 1e-4));
      expect(sawScores['a4'], closeTo(0.846798, 1e-4));
      expect(sawScores['a2'], closeTo(0.817591, 1e-4));
      expect(sawScores['a1'], closeTo(0.701625, 1e-4));
      expect(sawRanking, ['a3', 'a4', 'a2', 'a1']);
    });
  });
}
