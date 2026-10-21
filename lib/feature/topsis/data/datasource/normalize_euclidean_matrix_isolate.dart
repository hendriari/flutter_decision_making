import 'package:decision_making_core/decision_making_core.dart';
import 'package:flutter_decision_making/flutter_decision_making.dart';

/// Normalizes matrix using Euclidean vector normalization in an isolate using core TopsisCalculator.
Future<List<Map<String, dynamic>>> normalizeEuclideanMatrixIsolate({
  required Map<String, dynamic> data,
}) async {
  final criteriaDto = (data['criteria'] as List)
      .map((e) => WeightedDecisionCriteriaDto.fromJson(e))
      .toList();
  final matrixDto = (data['matrix'] as List)
      .map((e) => WeightedDecisionMatrixDto.fromJson(e))
      .toList();

  final entities = matrixDto.map((e) => e.toEntity()).toList();
  final criteria = criteriaDto.map((e) => e.toEntity()).toList();

  final normalized = TopsisCalculator.normalizeEuclidean(
    matrix: entities,
    criteria: criteria,
  );

  return normalized.map((e) => e.toDto().toJson()).toList();
}
