import 'alternative_pair.dart';
import 'rank_reversal_case.dart';
import 'sensitivity_analysis_result.dart';
import 'sensitivity_direction.dart';
import 'weight_sensitivity_case.dart';

/// Internal generic engine executing weight sensitivity analysis and rank reversal tests.
class SensitivityCalculator {
  /// Tolerance for floating-point tie comparisons (differences <= 1e-9 are ties).
  static const double tieTolerance = 1e-9;

  /// Executes sensitivity analysis and rank reversal detection given calculation closures.
  static SensitivityAnalysisResult run({
    required List<String> alternativeIds,
    required List<String> criteriaIds,
    required Map<String, double> normalizedWeights,
    required Map<String, double> Function(Map<String, double> weights)
        calculateWithWeights,
    required Map<String, double> Function(String removedAlternativeId)
        calculateWithoutAlternative,
    double delta = 0.1,
  }) {
    if (delta <= 0) {
      throw Exception('Sensitivity delta must be greater than zero.');
    }

    // 1. Base Evaluation
    final baseScores = calculateWithWeights(normalizedWeights);
    final baseRanking = _sortRanking(alternativeIds, baseScores);

    // 2. Weight Sensitivity Analysis
    final sensitivityCases = <WeightSensitivityCase>[];

    for (final critId in criteriaIds) {
      final baseW = normalizedWeights[critId] ?? 0.0;

      for (final direction in const [
        SensitivityDirection.increase,
        SensitivityDirection.decrease,
      ]) {
        if (criteriaIds.length < 2) {
          sensitivityCases.add(
            WeightSensitivityCase(
              criterionId: critId,
              direction: direction,
              delta: delta,
              weights: Map<String, double>.from(normalizedWeights),
              scores: Map<String, double>.from(baseScores),
              ranking: List<String>.from(baseRanking),
              hasOrderChanged: false,
              swappedPairs: const [],
              isSkipped: true,
              skipReason:
                  'Sensitivity analysis requires at least 2 criteria (found 1).',
            ),
          );
          continue;
        }

        final d = direction == SensitivityDirection.increase ? delta : -delta;
        final perturbedW = baseW * (1.0 + d);

        if (perturbedW >= 1.0) {
          sensitivityCases.add(
            WeightSensitivityCase(
              criterionId: critId,
              direction: direction,
              delta: delta,
              weights: Map<String, double>.from(normalizedWeights),
              scores: Map<String, double>.from(baseScores),
              ranking: List<String>.from(baseRanking),
              hasOrderChanged: false,
              swappedPairs: const [],
              isSkipped: true,
              skipReason:
                  "Perturbed weight w_k' ($perturbedW) is greater than or equal to 1.0.",
            ),
          );
          continue;
        }

        if (perturbedW <= 0.0) {
          sensitivityCases.add(
            WeightSensitivityCase(
              criterionId: critId,
              direction: direction,
              delta: delta,
              weights: Map<String, double>.from(normalizedWeights),
              scores: Map<String, double>.from(baseScores),
              ranking: List<String>.from(baseRanking),
              hasOrderChanged: false,
              swappedPairs: const [],
              isSkipped: true,
              skipReason:
                  "Perturbed weight w_k' ($perturbedW) is less than or equal to 0.0.",
            ),
          );
          continue;
        }

        if ((1.0 - baseW).abs() <= tieTolerance) {
          sensitivityCases.add(
            WeightSensitivityCase(
              criterionId: critId,
              direction: direction,
              delta: delta,
              weights: Map<String, double>.from(normalizedWeights),
              scores: Map<String, double>.from(baseScores),
              ranking: List<String>.from(baseRanking),
              hasOrderChanged: false,
              swappedPairs: const [],
              isSkipped: true,
              skipReason: 'Base weight is 1.0.',
            ),
          );
          continue;
        }

        final ratio = (1.0 - perturbedW) / (1.0 - baseW);
        final newWeights = <String, double>{};
        for (final cid in criteriaIds) {
          if (cid == critId) {
            newWeights[cid] = perturbedW;
          } else {
            newWeights[cid] = (normalizedWeights[cid] ?? 0.0) * ratio;
          }
        }

        final newScores = calculateWithWeights(newWeights);
        final newRanking = _sortRanking(alternativeIds, newScores);
        final swapped = _findPairwiseInversions(
          alternativeIds,
          baseScores,
          newScores,
        );

        sensitivityCases.add(
          WeightSensitivityCase(
            criterionId: critId,
            direction: direction,
            delta: delta,
            weights: newWeights,
            scores: newScores,
            ranking: newRanking,
            hasOrderChanged: swapped.isNotEmpty,
            swappedPairs: swapped,
          ),
        );
      }
    }

    // 3. Rank Reversal Detection
    final rankReversalCases = <RankReversalCase>[];
    final int altCount = alternativeIds.length;

    if (altCount < 3) {
      rankReversalCases.add(
        RankReversalCase(
          removedAlternativeId: '',
          scores: const {},
          ranking: const [],
          hasReversal: false,
          reversedPairs: const [],
          isSkipped: true,
          skipReason:
              'Rank reversal requires at least 3 alternatives (found $altCount).',
        ),
      );
    } else {
      for (final remId in alternativeIds) {
        final remainingAltIds =
            alternativeIds.where((id) => id != remId).toList(growable: false);

        final remScores = calculateWithoutAlternative(remId);
        final remRanking = _sortRanking(remainingAltIds, remScores);
        final reversed = _findPairwiseInversions(
          remainingAltIds,
          baseScores,
          remScores,
        );

        rankReversalCases.add(
          RankReversalCase(
            removedAlternativeId: remId,
            scores: remScores,
            ranking: remRanking,
            hasReversal: reversed.isNotEmpty,
            reversedPairs: reversed,
          ),
        );
      }
    }

    // 4. Stability Summary
    final isStable = sensitivityCases.every((c) => !c.hasOrderChanged) &&
        rankReversalCases.every((c) => !c.hasReversal);

    return SensitivityAnalysisResult(
      delta: delta,
      baseRanking: baseRanking,
      baseScores: baseScores,
      sensitivityCases: sensitivityCases,
      rankReversalCases: rankReversalCases,
      isStable: isStable,
    );
  }

  /// Sorts alternative IDs descending by score. Ties (abs diff <= 1e-9) are resolved
  /// deterministically by their original index in [allAltIds].
  static List<String> _sortRanking(
    List<String> altIds,
    Map<String, double> scores,
  ) {
    final sorted = List<String>.from(altIds);
    sorted.sort((a, b) {
      final sA = scores[a] ?? 0.0;
      final sB = scores[b] ?? 0.0;
      final diff = sB - sA;
      if (diff.abs() > tieTolerance) {
        return diff > 0 ? 1 : -1;
      }
      return altIds.indexOf(a).compareTo(altIds.indexOf(b));
    });
    return sorted;
  }

  /// Detects pairwise order inversions between [baseScores] and [newScores].
  ///
  /// For every pair (i, j), order is changed if the sign of (score_i - score_j) flips
  /// and the absolute difference on both sides is > 1e-9.
  static List<AlternativePair> _findPairwiseInversions(
    List<String> altIds,
    Map<String, double> baseScores,
    Map<String, double> newScores,
  ) {
    final inverted = <AlternativePair>[];

    for (int i = 0; i < altIds.length; i++) {
      for (int j = i + 1; j < altIds.length; j++) {
        final idI = altIds[i];
        final idJ = altIds[j];

        final diffBase = (baseScores[idI] ?? 0.0) - (baseScores[idJ] ?? 0.0);
        final diffNew = (newScores[idI] ?? 0.0) - (newScores[idJ] ?? 0.0);

        if (diffBase.abs() > tieTolerance && diffNew.abs() > tieTolerance) {
          if ((diffBase > 0 && diffNew < 0) || (diffBase < 0 && diffNew > 0)) {
            inverted.add(AlternativePair(idI, idJ));
          }
        }
      }
    }

    return inverted;
  }
}
