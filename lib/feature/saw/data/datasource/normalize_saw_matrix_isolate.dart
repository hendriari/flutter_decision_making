import 'package:decision_making_core/decision_making_core.dart';
import 'package:flutter_decision_making/core/shared/dto/weighted_decision_matrix_dto.dart';
import 'package:flutter_decision_making/core/shared/mapper/weighted_decision_matrix_mapper.dart';

/// Normalizes weighted decision matrix in an isolate using core SawCalculator.
///
/// [data] Map containing key 'matrix' with value `List<Map<String, dynamic>>`
///        which is the JSON representation of list of WeightedDecisionMatrixDto
///
/// Returns `List<Map<String, dynamic>>` normalized result in JSON format
///
/// Throws [Exception] if:
/// - Matrix is empty
/// - An error occurs during normalization
Future<List<Map<String, dynamic>>> normalizeWeightedMatrixIsolate({
  required Map<String, dynamic> data,
}) async {
  try {
    final rawListMatrix = List<Map<String, dynamic>>.from(
      data['matrix'] ?? const [],
    );

    if (rawListMatrix.isEmpty) {
      throw Exception('Matrix cannot be empty!');
    }

    // Parse JSON into DTO objects
    final listMatrix = rawListMatrix
        .map((e) => WeightedDecisionMatrixDto.fromJson(e))
        .toList();

    // Delegate calculation to decision_making_core
    final entities = listMatrix.map((e) => e.toEntity()).toList();
    final normalized = SawCalculator.normalize(entities);

    // Convert back to JSON format
    return normalized.map((e) => e.toDto().toJson()).toList();
  } catch (e) {
    if (e is DecisionInputException) rethrow;
    throw Exception('Failed to normalize matrix in isolate: $e');
  }
}
