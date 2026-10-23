import 'dart:math' as math;

import '../common/decision_input_exception.dart';
import '../common/matrix_validator.dart';
import '../common/weighted_decision_criteria.dart';
import '../common/weighted_decision_matrix.dart';
import '../topsis/topsis_raw_matrix.dart';
import 'critic_weight_result.dart';
import 'entropy_weight_result.dart';

/// Pure Dart synchronous calculator for objective criteria weighting methods:
/// - **Shannon Entropy** ([calculateEntropy])
/// - **CRITIC** (Criteria Importance Through Intercriteria Correlation, [calculateCritic])
class ObjectiveWeightCalculator {
  static const double _zeroTolerance = 1e-12;

  /// Computes objective criteria weights using Shannon Entropy.
  ///
  /// Mathematical definition:
  /// - `p_ij = x_ij / sum_i(x_ij)` (uses raw values; benefit/cost direction is ignored)
  /// - `k = 1 / ln(m)` where `m` is the number of alternatives
  /// - `e_j = -k * sum_i(p_ij * ln(p_ij))` with `0 * ln(0) = 0`
  /// - `d_j = 1 - e_j`
  /// - `w_j = d_j / sum_j(d_j)`
  ///
  /// Edge cases:
  /// - `m < 2`: throws an [Exception].
  /// - Negative value (`x_ij < 0`): throws an [Exception].
  /// - Column sum equals 0 (`sum_i(x_ij) == 0`): throws an [Exception].
  /// - Zero cell values (`x_ij == 0`) are allowed (`0 * ln(0) = 0`).
  /// - All `d_j == 0` (all columns are constant): returns equal weights (`w_j = 1 / n`).
  static EntropyWeightResult calculateEntropy(
    List<WeightedDecisionMatrix> rawMatrix,
  ) {
    final extracted =
        _extractAndValidateMatrix(rawMatrix, methodName: 'Entropy');
    final m = extracted.alternativeIds.length;
    final n = extracted.criteriaIds.length;

    // Validate non-negative values and positive column sums
    final colSums = <String, double>{};
    for (final critId in extracted.criteriaIds) {
      var sum = 0.0;
      for (final altId in extracted.alternativeIds) {
        final val = extracted.values[altId]![critId]!;
        if (val < 0.0) {
          throw DecisionInputException(
            'Entropy weighting does not allow negative values '
            '(found $val for alternative "$altId", criterion "$critId").',
          );
        }
        sum += val;
      }
      if (sum <= 0.0) {
        throw DecisionInputException(
          'Entropy weighting requires column sum > 0 '
          '(criterion "$critId" has column sum $sum).',
        );
      }
      colSums[critId] = sum;
    }

    // 1. Proportion matrix: p_ij = x_ij / sum_i(x_ij)
    final proportionMatrix = <String, Map<String, double>>{};
    for (final altId in extracted.alternativeIds) {
      final rowMap = <String, double>{};
      for (final critId in extracted.criteriaIds) {
        final val = extracted.values[altId]![critId]!;
        rowMap[critId] = val / colSums[critId]!;
      }
      proportionMatrix[altId] = rowMap;
    }

    // 2. Entropy e_j and divergence d_j = 1 - e_j
    final k = 1.0 / math.log(m);
    final entropy = <String, double>{};
    final divergence = <String, double>{};

    for (final critId in extracted.criteriaIds) {
      var sumPLnP = 0.0;
      for (final altId in extracted.alternativeIds) {
        final p = proportionMatrix[altId]![critId]!;
        if (p > 0.0) {
          sumPLnP += p * math.log(p);
        }
      }
      var e = -k * sumPLnP;
      var d = 1.0 - e;
      if (d.abs() <= _zeroTolerance) {
        e = 1.0;
        d = 0.0;
      }
      entropy[critId] = e;
      divergence[critId] = d;
    }

    // 3. Weights w_j = d_j / sum_j(d_j)
    final totalD = divergence.values.fold<double>(0.0, (a, b) => a + b);
    final weights = <String, double>{};
    if (totalD <= _zeroTolerance) {
      final equalWeight = 1.0 / n;
      for (final critId in extracted.criteriaIds) {
        weights[critId] = equalWeight;
      }
    } else {
      for (final critId in extracted.criteriaIds) {
        weights[critId] = divergence[critId]! / totalD;
      }
    }

    return EntropyWeightResult(
      criteriaIds: extracted.criteriaIds,
      proportionMatrix: proportionMatrix,
      entropy: entropy,
      divergence: divergence,
      weights: weights,
    );
  }

  /// Computes objective criteria weights using CRITIC
  /// (Criteria Importance Through Intercriteria Correlation).
  ///
  /// Mathematical definition:
  /// - Min-max normalization per column:
  ///   - Benefit: `r_ij = (x_ij - min_j) / (max_j - min_j)`
  ///   - Cost: `r_ij = (max_j - x_ij) / (max_j - min_j)`
  /// - `sigma_j`: sample standard deviation (divisor `m - 1`) of normalized column `j`
  /// - `R = [r_jk]`: Pearson correlation matrix between normalized columns
  /// - `C_j = sigma_j * sum_k(1 - r_jk)`
  /// - `w_j = C_j / sum_j(C_j)`
  ///
  /// Edge cases:
  /// - `m < 2`: throws an [Exception].
  /// - Constant column (`max_j == min_j`): normalized values are `0.0`, `sigma_j = 0.0`,
  ///   and its correlation with other columns (`j != k`) is `0.0`.
  /// - `sum_j(C_j) == 0`: returns equal weights (`w_j = 1 / n`).
  static CriticWeightResult calculateCritic(
    List<WeightedDecisionMatrix> rawMatrix,
  ) {
    final extracted =
        _extractAndValidateMatrix(rawMatrix, methodName: 'CRITIC');
    final m = extracted.alternativeIds.length;
    final n = extracted.criteriaIds.length;

    // 1. Min-max normalization per column
    final normalizedMatrix = <String, Map<String, double>>{
      for (final altId in extracted.alternativeIds) altId: <String, double>{},
    };
    final isConstantColumn = <String, bool>{};

    for (final critId in extracted.criteriaIds) {
      final isBenefit = extracted.criteriaMap[critId]!.isBenefit;
      var minVal = double.infinity;
      var maxVal = double.negativeInfinity;

      for (final altId in extracted.alternativeIds) {
        final v = extracted.values[altId]![critId]!;
        if (v < minVal) minVal = v;
        if (v > maxVal) maxVal = v;
      }

      final range = maxVal - minVal;
      if (range.abs() <= _zeroTolerance) {
        isConstantColumn[critId] = true;
        for (final altId in extracted.alternativeIds) {
          normalizedMatrix[altId]![critId] = 0.0;
        }
      } else {
        isConstantColumn[critId] = false;
        for (final altId in extracted.alternativeIds) {
          final v = extracted.values[altId]![critId]!;
          final norm = isBenefit ? (v - minVal) / range : (maxVal - v) / range;
          normalizedMatrix[altId]![critId] = norm;
        }
      }
    }

    // 2. Sample standard deviation sigma_j (divisor m - 1) and centered deviations
    final means = <String, double>{};
    final sumSquares = <String, double>{};
    final standardDeviations = <String, double>{};

    for (final critId in extracted.criteriaIds) {
      if (isConstantColumn[critId]!) {
        means[critId] = 0.0;
        sumSquares[critId] = 0.0;
        standardDeviations[critId] = 0.0;
        continue;
      }

      var sum = 0.0;
      for (final altId in extracted.alternativeIds) {
        sum += normalizedMatrix[altId]![critId]!;
      }
      final mean = sum / m;
      means[critId] = mean;

      var sq = 0.0;
      for (final altId in extracted.alternativeIds) {
        final diff = normalizedMatrix[altId]![critId]! - mean;
        sq += diff * diff;
      }
      sumSquares[critId] = sq;
      standardDeviations[critId] = math.sqrt(sq / (m - 1));
    }

    // 3. Pearson correlation matrix R
    final correlationMatrix = <String, Map<String, double>>{};
    for (final critJ in extracted.criteriaIds) {
      final rowCorr = <String, double>{};
      for (final critK in extracted.criteriaIds) {
        if (critJ == critK) {
          rowCorr[critK] = isConstantColumn[critJ]! ? 0.0 : 1.0;
          continue;
        }
        if (isConstantColumn[critJ]! || isConstantColumn[critK]!) {
          rowCorr[critK] = 0.0;
          continue;
        }

        final sqJ = sumSquares[critJ]!;
        final sqK = sumSquares[critK]!;
        final denom = math.sqrt(sqJ * sqK);
        if (denom <= _zeroTolerance) {
          rowCorr[critK] = 0.0;
          continue;
        }

        final meanJ = means[critJ]!;
        final meanK = means[critK]!;
        var cov = 0.0;
        for (final altId in extracted.alternativeIds) {
          final dJ = normalizedMatrix[altId]![critJ]! - meanJ;
          final dK = normalizedMatrix[altId]![critK]! - meanK;
          cov += dJ * dK;
        }
        rowCorr[critK] = (cov / denom).clamp(-1.0, 1.0);
      }
      correlationMatrix[critJ] = rowCorr;
    }

    // 4. Information content C_j = sigma_j * sum_k(1 - r_jk)
    final informationContent = <String, double>{};
    for (final critJ in extracted.criteriaIds) {
      final sigmaJ = standardDeviations[critJ]!;
      if (sigmaJ <= _zeroTolerance) {
        informationContent[critJ] = 0.0;
        continue;
      }
      var conflictSum = 0.0;
      for (final critK in extracted.criteriaIds) {
        conflictSum += 1.0 - correlationMatrix[critJ]![critK]!;
      }
      var cJ = sigmaJ * conflictSum;
      if (cJ.abs() <= _zeroTolerance) {
        cJ = 0.0;
      }
      informationContent[critJ] = cJ;
    }

    // 5. Weights w_j = C_j / sum_j(C_j)
    final totalC = informationContent.values.fold<double>(0.0, (a, b) => a + b);
    final weights = <String, double>{};
    if (totalC <= _zeroTolerance) {
      final equalWeight = 1.0 / n;
      for (final critId in extracted.criteriaIds) {
        weights[critId] = equalWeight;
      }
    } else {
      for (final critId in extracted.criteriaIds) {
        weights[critId] = informationContent[critId]! / totalC;
      }
    }

    return CriticWeightResult(
      criteriaIds: extracted.criteriaIds,
      normalizedMatrix: normalizedMatrix,
      standardDeviations: standardDeviations,
      correlationMatrix: correlationMatrix,
      informationContent: informationContent,
      weights: weights,
    );
  }

  /// Applies objective weights (`weightPercent = w_j * 100`) to a list of [criteria],
  /// preserving each criterion's benefit/cost flag and other metadata.
  static List<WeightedDecisionCriteria> applyWeightsToCriteria(
    List<WeightedDecisionCriteria> criteria,
    Map<String, double> weights,
  ) {
    return criteria.map((c) {
      final id = c.id;
      if (id == null || id.isEmpty) {
        throw DecisionInputException('Criteria ID cannot be null or empty.');
      }
      final w = weights[id];
      if (w == null) {
        throw DecisionInputException('Missing weight for criterion ID "$id".');
      }
      return c.copyWith(weightPercent: w * 100.0);
    }).toList();
  }

  /// Applies objective weights (`weightPercent = w_j * 100`) to all criteria
  /// inside [rawMatrix], returning a new matrix ready for SAW calculation.
  static List<WeightedDecisionMatrix> applyWeightsToMatrix(
    List<WeightedDecisionMatrix> rawMatrix,
    Map<String, double> weights,
  ) {
    return rawMatrix.map((row) {
      final updatedRatings = row.ratings.map((r) {
        final c = r.criteria;
        if (c == null) {
          throw DecisionInputException(
            'Rating on ${row.alternative.name} has no criteria.',
          );
        }
        final id = c.id;
        if (id == null || id.isEmpty) {
          throw DecisionInputException('Criteria ID cannot be null or empty.');
        }
        final w = weights[id];
        if (w == null) {
          throw DecisionInputException(
              'Missing weight for criterion ID "$id".');
        }
        return r.copyWith(
          criteria: c.copyWith(weightPercent: w * 100.0),
        );
      }).toList();
      return row.copyWith(ratings: updatedRatings);
    }).toList();
  }

  /// Applies objective weights (`weightPercent = w_j * 100`) to [rawMatrix],
  /// returning a new [TopsisRawMatrix] ready for TOPSIS calculation.
  static TopsisRawMatrix applyWeightsToTopsisMatrix(
    TopsisRawMatrix rawMatrix,
    Map<String, double> weights,
  ) {
    return TopsisRawMatrix(
      criterias: applyWeightsToCriteria(rawMatrix.criterias, weights),
      matrixs: applyWeightsToMatrix(rawMatrix.matrixs, weights),
    );
  }

  static _ExtractedMatrix _extractAndValidateMatrix(
    List<WeightedDecisionMatrix> rawMatrix, {
    required String methodName,
  }) {
    MatrixValidator.validateMatrixValues(rawMatrix);

    final m = rawMatrix.length;
    if (m < 2) {
      throw DecisionInputException(
        '$methodName weighting requires at least 2 alternatives (found $m).',
      );
    }

    final firstRow = rawMatrix.first;
    if (firstRow.ratings.isEmpty) {
      throw DecisionInputException('Criteria list cannot be empty!');
    }

    final criteriaIds = <String>[];
    final criteriaMap = <String, WeightedDecisionCriteria>{};

    for (final rating in firstRow.ratings) {
      final c = rating.criteria;
      if (c == null) {
        throw DecisionInputException(
            'Found rating without criteria! Data invalid.');
      }
      final cid = c.id;
      if (cid == null || cid.isEmpty) {
        throw DecisionInputException(
            'Found rating without criteria ID! Data invalid.');
      }
      if (criteriaMap.containsKey(cid)) {
        throw DecisionInputException(
          'Duplicate criterion ID "$cid" found in row for alternative '
          '"${firstRow.alternative.id ?? firstRow.alternative.name}".',
        );
      }
      criteriaIds.add(cid);
      criteriaMap[cid] = c;
    }

    final alternativeIds = <String>[];
    final values = <String, Map<String, double>>{};

    for (final row in rawMatrix) {
      final altId = row.alternative.id;
      if (altId == null || altId.isEmpty) {
        throw DecisionInputException(
            'Found alternative without ID! Data invalid.');
      }
      if (values.containsKey(altId)) {
        throw DecisionInputException(
            'Duplicate alternative ID "$altId" found in matrix.');
      }
      alternativeIds.add(altId);

      final rowValues = <String, double>{};
      for (final rating in row.ratings) {
        final cid = rating.criteria?.id;
        if (cid == null || cid.isEmpty) {
          throw DecisionInputException(
              'Found rating without criteria ID! Data invalid.');
        }
        if (rowValues.containsKey(cid)) {
          throw DecisionInputException(
            'Duplicate criterion ID "$cid" found in row for alternative "$altId".',
          );
        }
        final v = rating.value;
        if (v == null || v.isNaN || v.isInfinite) {
          throw DecisionInputException(
            'Invalid value for alternative "$altId", criterion "$cid".',
          );
        }
        rowValues[cid] = v;
      }

      for (final cid in criteriaIds) {
        if (!rowValues.containsKey(cid)) {
          throw DecisionInputException(
            'Missing rating for alternative "$altId", criterion "$cid".',
          );
        }
      }

      values[altId] = rowValues;
    }

    return _ExtractedMatrix(
      alternativeIds: alternativeIds,
      criteriaIds: criteriaIds,
      criteriaMap: criteriaMap,
      values: values,
    );
  }
}

class _ExtractedMatrix {
  final List<String> alternativeIds;
  final List<String> criteriaIds;
  final Map<String, WeightedDecisionCriteria> criteriaMap;
  final Map<String, Map<String, double>> values;

  const _ExtractedMatrix({
    required this.alternativeIds,
    required this.criteriaIds,
    required this.criteriaMap,
    required this.values,
  });
}
