import 'package:flutter_decision_making/flutter_decision_making.dart';
import 'package:flutter_test/flutter_test.dart';

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
  TestWidgetsFlutterBinding.ensureInitialized();

  final fdm = FlutterDecisionMaking();

  group('Flutter Wrapper Parity - Objective Weighting (Entropy & CRITIC)', () {
    test('SAW Golden 1 via fdm.saw matches reference values and combined SAW',
        () async {
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

      final entropy =
          await fdm.saw.calculateEntropyWeights(matrix: sawGolden1.matrixs);
      expect(entropy.weights['c1'], closeTo(0.285091, 1e-4));
      expect(entropy.weights['c2'], closeTo(0.123963, 1e-4));
      expect(entropy.weights['c3'], closeTo(0.107597, 1e-4));
      expect(entropy.weights['c4'], closeTo(0.483349, 1e-4));

      final critic =
          await fdm.saw.calculateCriticWeights(matrix: sawGolden1.matrixs);
      expect(critic.weights['c1'], closeTo(0.148923, 1e-4));
      expect(critic.weights['c2'], closeTo(0.424127, 1e-4));
      expect(critic.weights['c3'], closeTo(0.269401, 1e-4));
      expect(critic.weights['c4'], closeTo(0.157550, 1e-4));

      // Combined SAW with Entropy weights via wrapper
      final entropyMatrix = fdm.saw.applyObjectiveWeightsToMatrix(
        matrix: sawGolden1.matrixs,
        weights: entropy.weights,
      );
      final sawEntropyRes =
          await fdm.saw.getResultWithExistingMatrix(sawMatrix: entropyMatrix);
      expect(sawEntropyRes[0].alternative.id, 'a1');
      expect(sawEntropyRes[0].score, closeTo(0.976090, 1e-4));
      expect(sawEntropyRes[1].alternative.id, 'a2');
      expect(sawEntropyRes[1].score, closeTo(0.742811, 1e-4));
      expect(sawEntropyRes[2].alternative.id, 'a3');
      expect(sawEntropyRes[2].score, closeTo(0.545390, 1e-4));

      // Combined SAW with CRITIC weights via wrapper
      final criticMatrix = fdm.saw.applyObjectiveWeightsToMatrix(
        matrix: sawGolden1.matrixs,
        weights: critic.weights,
      );
      final sawCriticRes =
          await fdm.saw.getResultWithExistingMatrix(sawMatrix: criticMatrix);
      expect(sawCriticRes[0].alternative.id, 'a1');
      expect(sawCriticRes[0].score, closeTo(0.940133, 1e-4));
      expect(sawCriticRes[1].alternative.id, 'a2');
      expect(sawCriticRes[1].score, closeTo(0.769596, 1e-4));
      expect(sawCriticRes[2].alternative.id, 'a3');
      expect(sawCriticRes[2].score, closeTo(0.745710, 1e-4));
    });

    test(
        'TOPSIS Golden 1 via fdm.topsis matches reference values and combined TOPSIS',
        () async {
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

      final entropy =
          await fdm.topsis.calculateEntropyWeights(matrix: topsisGolden1);
      expect(entropy.weights['c1'], closeTo(0.208504, 1e-4));
      expect(entropy.weights['c2'], closeTo(0.171110, 1e-4));
      expect(entropy.weights['c3'], closeTo(0.451879, 1e-4));
      expect(entropy.weights['c4'], closeTo(0.168507, 1e-4));

      final critic =
          await fdm.topsis.calculateCriticWeights(matrix: topsisGolden1);
      expect(critic.weights['c1'], closeTo(0.189609, 1e-4));
      expect(critic.weights['c2'], closeTo(0.248220, 1e-4));
      expect(critic.weights['c3'], closeTo(0.334268, 1e-4));
      expect(critic.weights['c4'], closeTo(0.227902, 1e-4));

      // Combined TOPSIS with Entropy weights via wrapper
      final entropyTopsis = fdm.topsis.applyObjectiveWeightsToMatrix(
        matrix: topsisGolden1,
        weights: entropy.weights,
      );
      final topsisEntropyRes = await fdm.topsis
          .getTopsisResultWithExistingMatrix(matrix: entropyTopsis);
      expect(
        topsisEntropyRes.map((r) => r.alternative.id).toList(),
        ['a2', 'a4', 'a3', 'a1'],
      );
      expect(topsisEntropyRes[0].score, closeTo(0.739714, 1e-4));
      expect(topsisEntropyRes[1].score, closeTo(0.710553, 1e-4));
      expect(topsisEntropyRes[2].score, closeTo(0.579180, 1e-4));
      expect(topsisEntropyRes[3].score, closeTo(0.177908, 1e-4));

      // Combined TOPSIS with CRITIC weights via wrapper
      final criticTopsis = fdm.topsis.applyObjectiveWeightsToMatrix(
        matrix: topsisGolden1,
        weights: critic.weights,
      );
      final topsisCriticRes = await fdm.topsis
          .getTopsisResultWithExistingMatrix(matrix: criticTopsis);
      expect(
        topsisCriticRes.map((r) => r.alternative.id).toList(),
        ['a4', 'a3', 'a2', 'a1'],
      );
      expect(topsisCriticRes[0].score, closeTo(0.658261, 1e-4));
      expect(topsisCriticRes[1].score, closeTo(0.646048, 1e-4));
      expect(topsisCriticRes[2].score, closeTo(0.609146, 1e-4));
      expect(topsisCriticRes[3].score, closeTo(0.283048, 1e-4));
    });
  });
}
