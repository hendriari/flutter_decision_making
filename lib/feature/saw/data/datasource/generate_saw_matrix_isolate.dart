import 'package:flutter_decision_making/feature/saw/data/dto/saw_alternative_dto.dart';
import 'package:flutter_decision_making/feature/saw/data/dto/saw_criteria_dto.dart';
import 'package:flutter_decision_making/feature/saw/data/dto/saw_matrix_dto.dart';
import 'package:flutter_decision_making/feature/saw/data/dto/saw_rating_dto.dart';
import 'package:uuid/uuid.dart';

Future<List<Map<String, dynamic>>> generateSawMatrixIsolate({
  required Map<String, dynamic> data,
}) async {
  try {
    // Validate input data
    if (!data.containsKey('list_criteria') || !data.containsKey('list_alternative')) {
      throw Exception('Missing required keys: list_criteria or list_alternative');
    }

    final rawCriteria = data['list_criteria'];
    final rawAlternative = data['list_alternative'];

    if (rawCriteria == null || rawAlternative == null) {
      throw Exception('Criteria or alternative data is null');
    }

    final listCriteria = List<Map<String, dynamic>>.from(rawCriteria);
    final listAlternative = List<Map<String, dynamic>>.from(rawAlternative);

    // Parse DTOs
    final criteriaParsed =
    listCriteria.map((e) => SawCriteriaDto.fromJson(e)).toList();
    final alternativeParsed =
    listAlternative.map((e) => SawAlternativeDto.fromJson(e)).toList();

    // Validate parsed data
    _validateInputsIsolate(alternativeParsed, criteriaParsed);

    // Normalize criteria weights if needed
    final normalizedCriteria = _normalizeCriteriaWeightsIsolate(criteriaParsed);

    // Generate matrix
    final result = _generateMatrixDataIsolate(
      alternativeParsed,
      normalizedCriteria,
    );

    return result.map((e) => e.toJson()).toList();
  } catch (e, stackTrace) {
    throw Exception('Failed to generate SAW matrix in isolate: $e\n$stackTrace');
  }
}

/// Validate inputs for matrix generation
void _validateInputsIsolate(
    List<SawAlternativeDto> alternatives,
    List<SawCriteriaDto> criteria,
    ) {
  if (alternatives.isEmpty) {
    throw ArgumentError('Alternatives list cannot be empty!');
  }

  if (criteria.isEmpty) {
    throw ArgumentError('Criteria list cannot be empty!');
  }

  // Validate criteria weights
  for (var c in criteria) {
    if (c.weightPercent < 0) {
      throw ArgumentError(
        'Criteria weight cannot be negative: ${c.name} (${c.weightPercent})',
      );
    }
  }

  final totalWeight = criteria.fold<num>(0, (a, b) => a + b.weightPercent);

  if (totalWeight == 0) {
    throw ArgumentError('Total criteria weight cannot be zero.');
  }
}

/// Normalize criteria weights to sum to 100%
List<SawCriteriaDto> _normalizeCriteriaWeightsIsolate(
    List<SawCriteriaDto> criteria,
    ) {
  final totalWeight = criteria.fold<num>(0, (a, b) => a + b.weightPercent);

  // If already normalized, return as is
  if (totalWeight == 100) {
    return criteria;
  }

  // Log normalization (in isolate, we can't use dev.log, so we just proceed)
  // The main thread should log this before calling isolate

  // Normalize weights
  return criteria.map((c) {
    final normalized = (c.weightPercent / totalWeight) * 100;
    return c.copyWith(weightPercent: normalized);
  }).toList();
}

/// Generate matrix data
List<SawMatrixDto> _generateMatrixDataIsolate(
    List<SawAlternativeDto> alternatives,
    List<SawCriteriaDto> criteria,
    ) {
  return alternatives.map((alt) {
    final ratings = criteria.map((crt) {
      return SawRatingDto(
        id: Uuid().v4(),
        criteria: crt,
        value: 0,
      );
    }).toList();

    return SawMatrixDto(
      id: Uuid().v4(),
      alternative: alt,
      ratings: ratings,
    );
  }).toList();
}

