import 'package:flutter_decision_making/feature/saw/data/dto/saw_alternative_dto.dart';
import 'package:flutter_decision_making/feature/saw/data/dto/saw_criteria_dto.dart';
import 'package:flutter_decision_making/feature/saw/data/dto/saw_matrix_dto.dart';
import 'package:flutter_decision_making/feature/saw/data/dto/saw_rating_dto.dart';
import 'package:uuid/uuid.dart';

/// Generates SAW (Simple Additive Weighting) decision matrix in an isolate.
///
/// This function creates an initial decision matrix structure where each alternative
/// is evaluated against all criteria. The matrix is generated in a separate isolate
/// to prevent UI blocking when dealing with large datasets.
///
/// The process includes:
/// 1. Parsing input data (alternatives and criteria)
/// 2. Validating inputs
/// 3. Normalizing criteria weights to sum to 100%
/// 4. Creating matrix structure with empty ratings (value = 0)
///
/// [data] Map containing required keys:
///   - 'list_criteria': `List<Map<String, dynamic>>` representing criteria
///   - 'list_alternative': `List<Map<String, dynamic>>` representing alternatives
///
/// Returns `List<Map<String, dynamic>>` representing the generated matrix in JSON format
///
/// Throws [Exception] if:
/// - Required keys are missing
/// - Criteria or alternative data is null
/// - Validation fails
/// - An error occurs during matrix generation
Future<List<Map<String, dynamic>>> generateSawMatrixIsolate({
  required Map<String, dynamic> data,
}) async {
  try {
    // Validate required keys exist in input data
    if (!data.containsKey('list_criteria') ||
        !data.containsKey('list_alternative')) {
      throw Exception(
          'Missing required keys: list_criteria or list_alternative');
    }

    final rawCriteria = data['list_criteria'];
    final rawAlternative = data['list_alternative'];

    // Validate data is not null
    if (rawCriteria == null || rawAlternative == null) {
      throw Exception('Criteria or alternative data is null');
    }

    // Extract lists from raw data
    final listCriteria = List<Map<String, dynamic>>.from(rawCriteria);
    final listAlternative = List<Map<String, dynamic>>.from(rawAlternative);

    // Parse JSON data into DTO objects
    final criteriaParsed =
        listCriteria.map((e) => SawCriteriaDto.fromJson(e)).toList();
    final alternativeParsed =
        listAlternative.map((e) => SawAlternativeDto.fromJson(e)).toList();

    // Validate parsed inputs
    _validateInputsIsolate(alternativeParsed, criteriaParsed);

    // Normalize criteria weights to ensure they sum to 100%
    final normalizedCriteria = _normalizeCriteriaWeightsIsolate(criteriaParsed);

    // Generate the decision matrix structure
    final result = _generateMatrixDataIsolate(
      alternativeParsed,
      normalizedCriteria,
    );

    // Convert result to JSON format for returning to main isolate
    return result.map((e) => e.toJson()).toList();
  } catch (e, stackTrace) {
    throw Exception(
        'Failed to generate SAW matrix in isolate: $e\n$stackTrace');
  }
}

/// Validates inputs for matrix generation.
///
/// Performs the following validations:
/// - Alternatives list is not empty
/// - Criteria list is not empty
/// - All criteria weights are non-negative
/// - Total criteria weight is not zero
///
/// [alternatives] List of alternatives to validate
/// [criteria] List of criteria to validate
///
/// Throws [ArgumentError] if any validation fails
void _validateInputsIsolate(
  List<SawAlternativeDto> alternatives,
  List<SawCriteriaDto> criteria,
) {
  // Validate alternatives list is not empty
  if (alternatives.isEmpty) {
    throw ArgumentError('Alternatives list cannot be empty!');
  }

  // Validate criteria list is not empty
  if (criteria.isEmpty) {
    throw ArgumentError('Criteria list cannot be empty!');
  }

  // Validate each criterion has non-negative weight
  for (var c in criteria) {
    if (c.weightPercent < 0) {
      throw ArgumentError(
        'Criteria weight cannot be negative: ${c.name} (${c.weightPercent})',
      );
    }
  }

  // Calculate and validate total weight is not zero
  final totalWeight = criteria.fold<num>(0, (a, b) => a + b.weightPercent);

  if (totalWeight == 0) {
    throw ArgumentError('Total criteria weight cannot be zero.');
  }
}

/// Normalizes criteria weights to sum to 100%.
///
/// If the total weight already equals 100, returns the original list.
/// Otherwise, proportionally adjusts each criterion's weight so that
/// the total equals 100%.
///
/// Formula: normalized_weight = (weight / total_weight) * 100
///
/// [criteria] List of criteria to normalize
///
/// Returns List of criteria with normalized weights
List<SawCriteriaDto> _normalizeCriteriaWeightsIsolate(
  List<SawCriteriaDto> criteria,
) {
  // Calculate total weight
  final totalWeight = criteria.fold<num>(0, (a, b) => a + b.weightPercent);

  // If already 100%, return original list
  if (totalWeight == 100) {
    return criteria;
  }

  // Normalize each criterion's weight proportionally
  return criteria.map((c) {
    final normalized = (c.weightPercent / totalWeight) * 100;
    return c.copyWith(weightPercent: normalized);
  }).toList();
}

/// Generates the decision matrix data structure.
///
/// Creates a matrix where each alternative is paired with ratings for all criteria.
/// Initial rating values are set to 0, to be filled in by the user later.
///
/// Each matrix entry contains:
/// - Unique ID for the matrix entry
/// - An alternative
/// - A list of ratings (one per criterion) with initial value of 0
///
/// [alternatives] List of alternatives to include in the matrix
/// [criteria] List of normalized criteria
///
/// Returns List of SawMatrixDto representing the complete matrix structure
List<SawMatrixDto> _generateMatrixDataIsolate(
  List<SawAlternativeDto> alternatives,
  List<SawCriteriaDto> criteria,
) {
  // Create matrix entry for each alternative
  return alternatives.map((alt) {
    // Create a rating entry for each criterion
    final ratings = criteria.map((crt) {
      return SawRatingDto(
        id: Uuid().v4(),
        criteria: crt,
        value: 0, // Initial value, to be filled by user
      );
    }).toList();

    // Create matrix entry with unique ID, alternative, and all ratings
    return SawMatrixDto(
      id: Uuid().v4(),
      alternative: alt,
      ratings: ratings,
    );
  }).toList();
}
