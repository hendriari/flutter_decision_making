import 'package:flutter_decision_making/core/decision_making_performance_profiling.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/ahp_item_dto.dart';
import 'package:flutter_decision_making/feature/ahp/data/dto/pairwise_comparison_alternative_input_dto.dart';

/// GENERATE RESULT PAIRWISE MATRIX ALTERNATIVE
Future<List<List<double>>> ahpGenerateResultPairwiseMatrixAlternative(
    Map<String, dynamic> data) async {
  startPerformanceProfiling('generate pairwise matrix alternative');
  try {
    final itemsRaw = List<Map<String, dynamic>>.from(data['items']);
    final inputsRaw = List<Map<String, dynamic>>.from(data['inputs']);

    final itemDto = itemsRaw.map((e) => AhpItemDto.fromMap(e)).toList();
    final inputsDto =
        inputsRaw.map((e) => PairwiseAlternativeInputDto.fromMap(e)).toList();

    if (itemDto.isEmpty) {
      throw ArgumentError('Alternative list is empty');
    }

    if (inputsDto.isEmpty) {
      return List.generate(
        itemDto.length,
        (_) => List.filled(itemDto.length, 1.0),
      );
    }

    final pairwise = inputsDto.first.alternative;

    final matrix = List.generate(
      itemDto.length,
      (_) => List.filled(itemDto.length, 1.0),
    );

    final itemIndexMap = <String, int>{};
    for (int index = 0; index < itemDto.length; index++) {
      final id = itemDto[index].id;
      if (id == null || id.isEmpty) {
        throw Exception('Alternative item has missing ID');
      }
      itemIndexMap[id] = index;
    }

    for (final comparison in pairwise) {
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
  } finally {
    endPerformanceProfiling('generate pairwise matrix alternative');
  }
}
