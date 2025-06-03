import 'dart:core';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter_decision_making/ahp/domain/entities/alternative.dart';
import 'package:flutter_decision_making/ahp/domain/entities/hierarchy.dart';
import 'package:flutter_decision_making/ahp/domain/entities/pairwise_alternative_input.dart';
import 'package:flutter_decision_making/ahp/domain/entities/pairwise_comparison_input.dart';
import 'package:flutter_decision_making/ahp/helper/ahp_helper.dart';

class GeneratePairwiseAlternativeInputUsecase {
  GeneratePairwiseAlternativeInputUsecase();

  Future<List<PairwiseAlternativeInput>> execute(
    List<Hierarchy> nodes,
  ) async =>
      compute(_generatePairwiseAlternativeInIsolate, nodes);
}

List<PairwiseAlternativeInput> _generatePairwiseAlternativeInIsolate(
  List<Hierarchy> nodes,
) {
  final stopwatch = Stopwatch();
  dev.log("🔄 start generate pairwise alternative");
  dev.Timeline.startSync('generate pairwise alternative');
  stopwatch.start();
  try {
    final AhpHelper helper = AhpHelper();
    final result = <PairwiseAlternativeInput>[];

    for (var node in nodes) {
      final alternative = node.alternative;
      final pairwise = <PairwiseComparisonInput<Alternative>>[];

      for (int i = 0; i < alternative.length; i++) {
        for (int j = i + 1; j < alternative.length; j++) {
          pairwise.add(
            PairwiseComparisonInput<Alternative>(
              left: alternative[i],
              right: alternative[j],
              preferenceValue: null,
              isLeftMoreImportant: null,
              id: helper.getCustomUniqueId(),
            ),
          );
        }
      }

      result.add(
        PairwiseAlternativeInput(
            criteria: node.criteria, alternative: pairwise),
      );
    }

    return result;
  } catch (e) {
    throw Exception('Failed generate pairwise alternative: $e');
  } finally {
    dev.Timeline.finishSync();
    stopwatch.stop();
    dev.log(
        "🏁 generate pairwise alternative has been execute - duration : ${stopwatch.elapsedMilliseconds} ms");
  }
}
