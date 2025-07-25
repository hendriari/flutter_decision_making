import 'dart:math';

import 'package:flutter_decision_making/core/decision_making_performance_profiling.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_hierarchy_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/pairwise_comparison_alternative_input_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/pairwise_comparison_input_dto.dart';

Future<List<Map<String, dynamic>>> generateInputPairwiseAlternative(
  List<Map<String, dynamic>> rawDtoList,
) async {
  startPerformanceProfiling('generate pairwise alternative');

  try {
    final dtoList = rawDtoList.map((e) => AhpHierarchyDto.fromMap(e)).toList();

    final result = <PairwiseAlternativeInputDto>[];

    for (var dto in dtoList) {
      final alternative = dto.alternative;
      final pairwise = <PairwiseComparisonInputDto>[];

      for (int i = 0; i < alternative.length; i++) {
        for (int j = i + 1; j < alternative.length; j++) {
          pairwise.add(
            PairwiseComparisonInputDto(
              id: '${i}_${j}_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(100000)}',
              left: alternative[i],
              right: alternative[j],
              preferenceValue: null,
              isLeftMoreImportant: null,
            ),
          );
        }
      }

      result.add(
        PairwiseAlternativeInputDto(
          criteria: dto.criteria,
          alternative: pairwise,
        ),
      );
    }
    return result.map((e) => e.toMap()).toList();
  } catch (e) {
    throw Exception('Failed generate pairwise alternative: $e');
  } finally {
    endPerformanceProfiling('generate pairwise alternative');
  }
}
