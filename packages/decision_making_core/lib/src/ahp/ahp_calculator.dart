import 'dart:math';

import 'package:meta/meta.dart';

import 'ahp_consistency_ratio.dart';
import 'ahp_detailed_result.dart';
import 'ahp_hierarchy.dart';
import 'ahp_identification.dart';
import 'ahp_item.dart';
import 'ahp_result.dart';
import 'ahp_result_detail.dart';
import 'pairwise_alternative_input.dart';
import 'pairwise_comparison_input.dart';

/// Pure Dart implementation of Analytic Hierarchy Process (AHP) calculations.
class AhpCalculator {
  /// Random Index (RI) table based on Saaty (1980) for n = 1..15.
  /// For n > 15, fallback is 1.59.
  @internal
  static const Map<int, double> riTable = {
    1: 0.0,
    2: 0.0,
    3: 0.58,
    4: 0.90,
    5: 1.12,
    6: 1.24,
    7: 1.32,
    8: 1.41,
    9: 1.45,
    10: 1.49,
    11: 1.51,
    12: 1.48,
    13: 1.56,
    14: 1.57,
    15: 1.59,
  };

  /// Gets the Random Index (RI) for matrix size [n].
  @internal
  static double getRI(int n) {
    return riTable[n] ?? 1.59;
  }

  /// Default ID generator.
  static String _defaultIdGenerator() {
    return '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(100000)}';
  }

  /// Validates criteria and alternatives, ensuring unique IDs and size limits.
  static AhpIdentification identification(
    List<AhpItem> criteria,
    List<AhpItem> alternative, {
    String Function()? idGenerator,
  }) {
    if (criteria.isEmpty) {
      throw Exception("Criteria can't be empty!");
    }
    if (alternative.isEmpty) {
      throw Exception("Alternative can't be empty!");
    }

    if (criteria.length > 100 || alternative.length > 100) {
      throw Exception(
        'Too much data, please limit the number of criteria/alternatives (max 100 criteria and 100 alternative).',
      );
    }

    final gen = idGenerator ?? _defaultIdGenerator;

    final updatedCriteria = List<AhpItem>.generate(criteria.length, (i) {
      final e = criteria[i];
      return (e.id == null || e.id!.isEmpty) ? e.copyWith(id: gen()) : e;
    });

    final updatedAlternative = List<AhpItem>.generate(alternative.length, (i) {
      final e = alternative[i];
      return (e.id == null || e.id!.isEmpty) ? e.copyWith(id: gen()) : e;
    });

    return AhpIdentification(
      criteria: updatedCriteria,
      alternative: updatedAlternative,
    );
  }

  /// Generates the hierarchical structure linking criteria to alternatives.
  static List<AhpHierarchy> generateHierarchy(
    List<AhpItem> criteria,
    List<AhpItem> alternative,
  ) {
    return criteria.map((c) {
      return AhpHierarchy(criteria: c, alternative: alternative);
    }).toList();
  }

  /// Generates pairwise comparison input templates for criteria.
  static List<PairwiseComparisonInput> generatePairwiseCriteria(
    List<AhpItem> criteria, {
    String Function()? idGenerator,
  }) {
    final gen = idGenerator ?? _defaultIdGenerator;
    final result = <PairwiseComparisonInput>[];

    for (int i = 0; i < criteria.length; i++) {
      for (int j = i + 1; j < criteria.length; j++) {
        result.add(
          PairwiseComparisonInput(
            id: gen(),
            left: criteria[i],
            right: criteria[j],
            preferenceValue: null,
            isLeftMoreImportant: null,
          ),
        );
      }
    }

    return result;
  }

  /// Generates pairwise comparison input templates for alternatives under each criterion.
  static List<PairwiseAlternativeInput> generatePairwiseAlternative(
    List<AhpHierarchy> nodes, {
    String Function(int nodeIndex, int i, int j)? idGenerator,
  }) {
    final result = <PairwiseAlternativeInput>[];

    for (int nodeIdx = 0; nodeIdx < nodes.length; nodeIdx++) {
      final node = nodes[nodeIdx];
      final alternative = node.alternative;
      final pairwise = <PairwiseComparisonInput>[];

      for (int i = 0; i < alternative.length; i++) {
        for (int j = i + 1; j < alternative.length; j++) {
          final id = idGenerator != null
              ? idGenerator(nodeIdx, i, j)
              : '${i}_${j}_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(100000)}';

          pairwise.add(
            PairwiseComparisonInput(
              id: id,
              left: alternative[i],
              right: alternative[j],
              preferenceValue: null,
              isLeftMoreImportant: null,
            ),
          );
        }
      }

      result.add(
        PairwiseAlternativeInput(
          criteria: node.criteria,
          alternative: pairwise,
        ),
      );
    }

    return result;
  }

  /// Generates a pairwise comparison matrix from criteria items and completed inputs.
  static List<List<double>> generateResultPairwiseMatrixCriteria(
    List<AhpItem> items,
    List<PairwiseComparisonInput> inputs,
  ) {
    final matrix = List.generate(
      items.length,
      (_) => List.filled(items.length, 1.0),
    );

    final itemIndexMap = <String, int>{};
    for (int index = 0; index < items.length; index++) {
      final id = items[index].id;
      if (id == null || id.isEmpty) {
        throw Exception('Item with missing ID found');
      }
      itemIndexMap[id] = index;
    }

    for (final e in inputs) {
      final i = itemIndexMap[e.left.id];
      final j = itemIndexMap[e.right.id];
      final value = e.preferenceValue?.toDouble() ?? 1.0;

      if (i == null || j == null) {
        throw Exception('One or both items not found in the list');
      }

      if (value <= 0) {
        throw Exception('Comparison value must be greater than zero');
      }

      if (e.isLeftMoreImportant == true) {
        matrix[i][j] = value;
        matrix[j][i] = 1 / value;
      } else {
        matrix[i][j] = 1 / value;
        matrix[j][i] = value;
      }
    }

    return matrix;
  }

  /// Generates a pairwise comparison matrix from alternative items and completed comparisons.
  static List<List<double>> generateResultPairwiseMatrixAlternative(
    List<AhpItem> items,
    List<PairwiseComparisonInput> comparisons,
  ) {
    if (items.isEmpty) {
      throw ArgumentError('Alternative list is empty');
    }

    if (comparisons.isEmpty) {
      return List.generate(
        items.length,
        (_) => List.filled(items.length, 1.0),
      );
    }

    final matrix = List.generate(
      items.length,
      (_) => List.filled(items.length, 1.0),
    );

    final itemIndexMap = <String, int>{};
    for (int index = 0; index < items.length; index++) {
      final id = items[index].id;
      if (id == null || id.isEmpty) {
        throw Exception('Alternative item has missing ID');
      }
      itemIndexMap[id] = index;
    }

    for (final comparison in comparisons) {
      final i = itemIndexMap[comparison.left.id];
      final j = itemIndexMap[comparison.right.id];

      if (i == null || j == null) {
        throw Exception('Alternative not found in list');
      }

      final value = comparison.preferenceValue?.toDouble() ?? 1.0;
      if (value <= 0) {
        throw Exception('Comparison value must be greater than zero');
      }

      if (comparison.isLeftMoreImportant == true) {
        matrix[i][j] = value;
        matrix[j][i] = 1 / value;
      } else {
        matrix[i][j] = 1 / value;
        matrix[j][i] = value;
      }
    }

    return matrix;
  }

  /// Normalizes a reciprocal comparison matrix by dividing each element by its column sum.
  @internal
  static List<List<double>> normalizeComparisonMatrix(
    List<List<double>> matrix,
  ) {
    final int n = matrix.length;
    if (n == 0) return [];

    final colSums = List.filled(n, 0.0);
    for (int j = 0; j < n; j++) {
      for (int i = 0; i < n; i++) {
        colSums[j] += matrix[i][j];
      }
    }

    final normalized = List.generate(
      n,
      (i) => List.generate(
        n,
        (j) => colSums[j] == 0.0 ? 0.0 : matrix[i][j] / colSums[j],
      ),
    );

    return normalized;
  }

  /// Calculates the priority vector (eigenvector approximation) via normalized column averaging.
  static List<double> calculateEigenVector(List<List<double>> matrix) {
    final int n = matrix.length;
    if (n == 0) return [];

    // Step 1: Column sums
    final colSums = List.filled(n, 0.0);
    for (int j = 0; j < n; j++) {
      for (int i = 0; i < n; i++) {
        colSums[j] += matrix[i][j];
      }
    }

    // Step 2: Normalize and calculate row averages
    final priorities = List.filled(n, 0.0);
    for (int i = 0; i < n; i++) {
      double sum = 0.0;
      for (int j = 0; j < n; j++) {
        sum += matrix[i][j] / colSums[j];
      }
      priorities[i] = sum / n;
    }

    return priorities;
  }

  /// Calculates the Consistency Ratio (CR) to validate comparison consistency.
  static AhpConsistencyRatio checkConsistencyRatio(
    List<List<double>> matrix,
    List<double> priorityVector,
    String source,
  ) {
    final int n = matrix.length;

    if (n == 0 || priorityVector.isEmpty || priorityVector.length != n) {
      throw ArgumentError(
        'Matrix and priority vector must be non-empty and of the same size.',
      );
    }

    if (priorityVector.any((e) => e == 0)) {
      throw ArgumentError(
        'Priority vector contains zero, cannot divide by zero.',
      );
    }

    // Step 1: Weighted sums (matrix * priorityVector)
    final weightedSums = List.filled(n, 0.0);
    for (int i = 0; i < n; i++) {
      double sum = 0.0;
      for (int j = 0; j < n; j++) {
        sum += matrix[i][j] * priorityVector[j];
      }
      weightedSums[i] = sum;
    }

    // Step 2: Calculate λmax
    double lambdaMax = 0.0;
    for (int i = 0; i < n; i++) {
      lambdaMax += weightedSums[i] / priorityVector[i];
    }
    lambdaMax /= n;

    // Step 3: Consistency Index (CI)
    final double ci = n == 1 ? 0.0 : (lambdaMax - n) / (n - 1);

    // Step 4: Random Index (RI) and CR
    final ri = getRI(n);
    if (ri == 0) {
      return AhpConsistencyRatio(
        source: source,
        ratio: 0.0,
        isConsistent: true,
        lambdaMax: lambdaMax,
        ci: ci,
        ri: ri,
      );
    }

    final cr = ci / ri;
    final isConsistent = (cr - 0.1) <= 1e-5;

    return AhpConsistencyRatio(
      source: source,
      ratio: cr,
      isConsistent: isConsistent,
      lambdaMax: lambdaMax,
      ci: ci,
      ri: ri,
    );
  }

  /// Calculates final scores by synthesizing criteria weights and alternative priorities.
  static AhpResult calculateFinalScore({
    required List<double> eigenVectorCriteria,
    required List<List<double>> eigenVectorsAlternative,
    required List<AhpItem> alternatives,
    required AhpConsistencyRatio consistencyCriteria,
    required List<AhpConsistencyRatio> consistencyAlternatives,
  }) {
    if (eigenVectorsAlternative.isEmpty ||
        eigenVectorsAlternative.first.isEmpty) {
      throw Exception('Alternative matrix is empty.');
    }

    final int altCount = eigenVectorsAlternative.first.length;
    final int criteriaCount = eigenVectorCriteria.length;

    // Calculate final scores: Σ(criteria_weight * alternative_priority)
    final resultScores = List.filled(altCount, 0.0);
    for (int i = 0; i < altCount; i++) {
      for (int j = 0; j < criteriaCount; j++) {
        resultScores[i] +=
            eigenVectorCriteria[j] * eigenVectorsAlternative[j][i];
      }
    }

    final details = <AhpResultDetail>[];
    for (int i = 0; i < altCount; i++) {
      details.add(
        AhpResultDetail(
          id: alternatives[i].id,
          name: alternatives[i].name,
          value: resultScores[i],
        ),
      );
    }

    final sortedConsistencyAlts = List<AhpConsistencyRatio>.from(
      consistencyAlternatives,
    )..sort((a, b) => b.ratio.compareTo(a.ratio));

    String? note = !consistencyCriteria.isConsistent ||
            consistencyAlternatives.any((e) => e.isConsistent == false)
        ? '''
Thank you for completing the assessment process. Based on the consistency check, the resulting Consistency Ratio (CR) exceeds the acceptable threshold of 0.1.
As a result, the current assessment does not meet the expected level of consistency and therefore cannot yet be considered valid.
We recommend reviewing and revising the assessment to ensure that the resulting analysis is more accurate and reliable for decision-making.
Detail:
${!consistencyCriteria.isConsistent ? '* inconsistency on criteria' : ''}
${consistencyAlternatives.any((e) => e.isConsistent == false) ? '* Inconsistency on alternatives per criteria:\n${consistencyAlternatives.where((e) => !e.isConsistent).map((e) => '- ${e.source}: ${e.ratio}').join('\n')}' : ''}
'''
        : null;

    final sortedResults = details..sort((a, b) => b.value.compareTo(a.value));

    final worstAlt = sortedConsistencyAlts.isNotEmpty
        ? sortedConsistencyAlts.first
        : AhpConsistencyRatio(
            source: 'alternative',
            ratio: 0.0,
            isConsistent: true,
          );

    return AhpResult(
      results: sortedResults,
      isConsistentCriteria: consistencyCriteria.isConsistent,
      consistencyCriteriaRatio: consistencyCriteria.ratio,
      isConsistentAlternative: worstAlt.isConsistent,
      consistencyAlternativeRatio: worstAlt.ratio,
      note: note,
    );
  }

  /// Full end-to-end synchronous AHP calculation pipeline.
  static AhpResult calculate({
    required List<AhpHierarchy> hierarchy,
    required List<PairwiseComparisonInput> inputsCriteria,
    required List<PairwiseAlternativeInput> inputsAlternative,
  }) {
    return calculateDetailed(
      hierarchy: hierarchy,
      inputsCriteria: inputsCriteria,
      inputsAlternative: inputsAlternative,
    ).toAhpResult();
  }

  /// Full synchronous AHP calculation pipeline returning detailed intermediate steps.
  ///
  /// Returns an [AhpDetailedResult] containing comparison matrices, normalized matrices,
  /// priority weights ($w_j$), consistency metrics ($\lambda_{\max}$, $CI$, $RI$, $CR$),
  /// local priority scores per criterion, and final synthesized scores.
  static AhpDetailedResult calculateDetailed({
    required List<AhpHierarchy> hierarchy,
    required List<PairwiseComparisonInput> inputsCriteria,
    required List<PairwiseAlternativeInput> inputsAlternative,
  }) {
    if (inputsCriteria.any((e) => e.preferenceValue == null)) {
      throw Exception('Please complete all values from the criteria scale');
    }
    if (inputsCriteria.any((e) => e.isLeftMoreImportant == null)) {
      throw Exception('Please complete which more important from the criteria');
    }
    if (inputsAlternative
        .any((e) => e.alternative.any((d) => d.preferenceValue == null))) {
      throw Exception('Please complete all values from the alternative scale');
    }
    if (inputsAlternative
        .any((e) => e.alternative.any((d) => d.isLeftMoreImportant == null))) {
      throw Exception(
          'Please complete which more important from the alternative');
    }

    for (final h in hierarchy) {
      if (h.criteria.id == null || h.criteria.id!.isEmpty) {
        throw Exception('Found criteria without ID! Data invalid.');
      }
      for (final a in h.alternative) {
        if (a.id == null || a.id!.isEmpty) {
          throw Exception('Found alternative without ID! Data invalid.');
        }
      }
    }
    for (final p in inputsCriteria) {
      if (p.left.id == null ||
          p.left.id!.isEmpty ||
          p.right.id == null ||
          p.right.id!.isEmpty) {
        throw Exception('Found criteria without ID! Data invalid.');
      }
    }
    for (final input in inputsAlternative) {
      if (input.criteria.id == null || input.criteria.id!.isEmpty) {
        throw Exception('Found criteria without ID! Data invalid.');
      }
      for (final p in input.alternative) {
        if (p.left.id == null ||
            p.left.id!.isEmpty ||
            p.right.id == null ||
            p.right.id!.isEmpty) {
          throw Exception('Found alternative without ID! Data invalid.');
        }
      }
    }

    // 1. Criteria Matrix, Normalized Matrix & Priority Vector
    final itemCriteria =
        hierarchy.map((e) => e.criteria).toList(growable: false);
    final criteriaIds =
        itemCriteria.map((c) => c.id!).toList(growable: false);
    final matrixCriteria = generateResultPairwiseMatrixCriteria(
      itemCriteria,
      inputsCriteria,
    );
    final normalizedMatrixCriteria = normalizeComparisonMatrix(matrixCriteria);
    final eigenVectorCriteria = calculateEigenVector(matrixCriteria);
    final consistencyCriteria = checkConsistencyRatio(
      matrixCriteria,
      eigenVectorCriteria,
      'criteria',
    );

    final criteriaWeights = <String, double>{};
    for (int i = 0; i < itemCriteria.length; i++) {
      criteriaWeights[itemCriteria[i].id!] = eigenVectorCriteria[i];
    }

    final criteriaEvaluation = AhpMatrixEvaluation(
      id: 'criteria',
      name: 'Criteria',
      itemIds: criteriaIds,
      comparisonMatrix: matrixCriteria,
      normalizedMatrix: normalizedMatrixCriteria,
      weights: criteriaWeights,
      lambdaMax: consistencyCriteria.lambdaMax ?? 0.0,
      ci: consistencyCriteria.ci ?? 0.0,
      ri: consistencyCriteria.ri ?? getRI(itemCriteria.length),
      cr: consistencyCriteria.ratio,
      isConsistent: consistencyCriteria.isConsistent,
    );

    // 2. Alternative Matrices & Priority Vectors per Criterion
    final alternativeEvaluations = <String, AhpMatrixEvaluation>{};
    final scoresPerCriteria = <String, Map<String, double>>{};
    final weightedScoresPerCriteria = <String, Map<String, double>>{};
    final allConsistencyAlternatives = <AhpConsistencyRatio>[];

    for (final input in inputsAlternative) {
      final critId = input.criteria.id!;
      final itemAlternative = input.alternative
          .expand((e) => [e.left, e.right])
          .toSet()
          .toList(growable: false);
      final altIds =
          itemAlternative.map((a) => a.id!).toList(growable: false);

      final matrixAlt = generateResultPairwiseMatrixAlternative(
        itemAlternative,
        input.alternative,
      );
      final normalizedMatrixAlt = normalizeComparisonMatrix(matrixAlt);
      final eigenVectorAlt = calculateEigenVector(matrixAlt);
      final consistencyAlt = checkConsistencyRatio(
        matrixAlt,
        eigenVectorAlt,
        input.criteria.name,
      );

      final altWeights = <String, double>{};
      for (int i = 0; i < itemAlternative.length; i++) {
        altWeights[itemAlternative[i].id!] = eigenVectorAlt[i];
      }

      scoresPerCriteria[critId] = altWeights;

      alternativeEvaluations[critId] = AhpMatrixEvaluation(
        id: critId,
        name: input.criteria.name,
        itemIds: altIds,
        comparisonMatrix: matrixAlt,
        normalizedMatrix: normalizedMatrixAlt,
        weights: altWeights,
        lambdaMax: consistencyAlt.lambdaMax ?? 0.0,
        ci: consistencyAlt.ci ?? 0.0,
        ri: consistencyAlt.ri ?? getRI(itemAlternative.length),
        cr: consistencyAlt.ratio,
        isConsistent: consistencyAlt.isConsistent,
      );

      allConsistencyAlternatives.add(consistencyAlt);
    }

    // 3. Extract unique list of alternatives
    final alternatives =
        hierarchy.expand((e) => e.alternative).toSet().toList(growable: false);
    final int altCount = alternatives.length;
    final int criteriaCount = itemCriteria.length;

    // 4. Synthesize final scores
    final resultScores = List.filled(altCount, 0.0);
    for (int i = 0; i < altCount; i++) {
      final altId = alternatives[i].id!;
      for (int j = 0; j < criteriaCount; j++) {
        final critId = itemCriteria[j].id!;
        final critWeight = criteriaWeights[critId] ?? 0.0;
        final altPriority = scoresPerCriteria[critId]?[altId] ?? 0.0;
        final weightedScore = critWeight * altPriority;

        weightedScoresPerCriteria
            .putIfAbsent(critId, () => <String, double>{})[altId] = weightedScore;
        resultScores[i] += weightedScore;
      }
    }

    final details = <AhpResultDetail>[];
    for (int i = 0; i < altCount; i++) {
      details.add(
        AhpResultDetail(
          id: alternatives[i].id,
          name: alternatives[i].name,
          value: resultScores[i],
        ),
      );
    }

    final sortedResults = details..sort((a, b) => b.value.compareTo(a.value));

    // Consistency Note
    final isConsistentCriteria = consistencyCriteria.isConsistent;
    final isConsistentAlternative =
        allConsistencyAlternatives.every((e) => e.isConsistent);
    final isConsistent = isConsistentCriteria && isConsistentAlternative;

    String? note = !isConsistent
        ? '''
Thank you for completing the assessment process. Based on the consistency check, the resulting Consistency Ratio (CR) exceeds the acceptable threshold of 0.1.
As a result, the current assessment does not meet the expected level of consistency and therefore cannot yet be considered valid.
We recommend reviewing and revising the assessment to ensure that the resulting analysis is more accurate and reliable for decision-making.
Detail:
${!isConsistentCriteria ? '* inconsistency on criteria' : ''}
${!isConsistentAlternative ? '* Inconsistency on alternatives per criteria:\n${allConsistencyAlternatives.where((e) => !e.isConsistent).map((e) => '- ${e.source}: ${e.ratio}').join('\n')}' : ''}
'''
        : null;

    return AhpDetailedResult(
      criteriaEvaluation: criteriaEvaluation,
      alternativeEvaluations: alternativeEvaluations,
      criteriaWeights: criteriaWeights,
      scoresPerCriteria: scoresPerCriteria,
      weightedScoresPerCriteria: weightedScoresPerCriteria,
      scores: sortedResults,
      isConsistentCriteria: isConsistentCriteria,
      isConsistentAlternative: isConsistentAlternative,
      isConsistent: isConsistent,
      note: note,
    );
  }
}
