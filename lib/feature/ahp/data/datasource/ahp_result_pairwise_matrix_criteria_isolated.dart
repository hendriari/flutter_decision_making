import 'package:flutter_decision_making/core/decision_making_performance_profiling.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_item_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/pairwise_comparison_input_dto.dart';

/// GENERATE RESULT PAIRWISE MATRIX CRITERIA
Future<List<List<double>>> ahpGenerateResultPairwiseMatrixCriteria(
    Map<String, dynamic> data) async {
  startPerformanceProfiling('generate result pairwise matrix criteria');

  try {
    final itemsRaw = List<Map<String, dynamic>>.from(data['items']);
    final inputsRaw = List<Map<String, dynamic>>.from(data['inputs']);

    final inputsDto =
        inputsRaw.map((e) => PairwiseComparisonInputDto.fromMap(e)).toList();
    final itemDto = itemsRaw.map((e) => AhpItemDto.fromMap(e)).toList();

    final matrix = List.generate(
      itemDto.length,
      (_) => List.filled(itemDto.length, 1.0),
    );

    final itemIndexMap = <String, int>{};
    for (int index = 0; index < itemDto.length; index++) {
      final id = itemDto[index].id;
      if (id == null || id.isEmpty) {
        throw Exception('Item with missing ID found');
      }
      itemIndexMap[id] = index;
    }

    for (final e in inputsDto) {
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
  } finally {
    endPerformanceProfiling('generate result pairwise matrix criteria');
  }
}
