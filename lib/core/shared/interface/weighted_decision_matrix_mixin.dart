import 'dart:developer' as dev;

// import 'package:flutter_decision_making/core/decision_making_enums.dart';
import 'package:flutter_decision_making/core/decision_making_enums.dart';
import 'package:flutter_decision_making/core/decision_making_helper.dart';
import 'package:flutter_decision_making/core/isolate/decision_processing_isolate_command.dart';
import 'package:flutter_decision_making/core/isolate/decision_isolate_main.dart';
import 'package:flutter_decision_making/core/shared/dto/weighted_decision_matrix_dto.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_alternative.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_criteria.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_matrix.dart';
import 'package:flutter_decision_making/core/shared/entity/weighted_decision_rating.dart';

import '../mapper/weighted_decision_alternative_mapper.dart';
import '../mapper/weighted_decision_criteria_mapper.dart';
import '../mapper/weighted_decision_matrix_mapper.dart'
    show WeightedDecisionMatrixMapper;

mixin WeightedDecisionMatrixInterface {
  DecisionMakingHelper get helper;

  DecisionIsolateMain get isolate;

  /// Validates input data for matrix generation.
  ///
  /// Ensures that:
  /// - Alternative and criteria lists are not empty
  /// - All criteria weights are non-negative
  /// - Total weight is not zero
  ///
  /// **Throws:**
  /// - Exception with descriptive message if validation fails
  void validateInputs(
    List<WeightedDecisionAlternative> alternatives,
    List<WeightedDecisionCriteria> criteria,
  ) {
    if (alternatives.isEmpty) {
      throw Exception("Alternatives list cannot be empty!");
    }

    if (criteria.isEmpty) {
      throw Exception("Criteria list cannot be empty!");
    }

    for (var c in criteria) {
      if (c.weightPercent < 0) {
        throw Exception("Criteria weight cannot be negative: ${c.name}");
      }
    }

    final totalWeight = criteria.fold<num>(0, (a, b) => a + b.weightPercent);
    if (totalWeight == 0) {
      throw Exception("Total criteria weight cannot be zero.");
    }
  }

  /// Normalizes criteria weights to sum to exactly 100%.
  ///
  /// If weights already sum to 100, returns the original list.
  /// Otherwise, proportionally adjusts all weights to sum to 100%.
  ///
  /// **Parameters:**
  /// - [criteria]: List of criteria to normalize
  ///
  /// **Returns:** List of criteria with normalized weights
  List<WeightedDecisionCriteria> normalizeCriteriaWeights(
      List<WeightedDecisionCriteria> criteria) {
    final totalWeight = criteria.fold<num>(0, (a, b) => a + b.weightPercent);

    if (totalWeight == 100) {
      return List<WeightedDecisionCriteria>.from(criteria);
    }

    dev.log(
      "[Matrix] Total weight = $totalWeight, auto-normalizing to 100%.",
      name: "DECISION MAKING",
    );

    return criteria.map((c) {
      final normalized = (c.weightPercent / totalWeight) * 100;
      return c.copyWith(weightPercent: normalized);
    }).toList();
  }

  /// Ensures all alternatives have unique IDs.
  ///
  /// Generates new IDs for alternatives that are missing them.
  ///
  /// **Parameters:**
  /// - [alternatives]: List of alternatives to process
  ///
  /// **Returns:** List of alternatives with guaranteed IDs
  List<WeightedDecisionAlternative> ensureIdsForAlternatives(
      List<WeightedDecisionAlternative> alternatives) {
    return alternatives.map((e) {
      return (e.id == null || e.id!.isEmpty)
          ? e.copyWith(id: helper.getCustomUniqueId())
          : e;
    }).toList();
  }

  /// Ensures all criteria have unique IDs.
  ///
  /// Generates new IDs for criteria that are missing them.
  ///
  /// **Parameters:**
  /// - [criteria]: List of criteria to process
  ///
  /// **Returns:** List of criteria with guaranteed IDs
  List<WeightedDecisionCriteria> ensureIdsForCriteria(
      List<WeightedDecisionCriteria> criteria) {
    return criteria.map((e) {
      return (e.id == null || e.id!.isEmpty)
          ? e.copyWith(id: helper.getCustomUniqueId())
          : e;
    }).toList();
  }

  /// Generates matrix using isolate for large datasets.
  ///
  /// Uses a separate isolate to prevent blocking the main thread
  /// when processing large numbers of alternatives or criteria.
  ///
  /// **Parameters:**
  /// - [alternatives]: List of alternatives
  /// - [criteria]: List of criteria
  ///
  /// **Returns:** Generated matrix
  Future<List<WeightedDecisionMatrix>> generateMatrixWithIsolate(
    DecisionAlgorithm algorithm,
    DecisionProcessingIsolateCommand command,
    List<WeightedDecisionAlternative> alternatives,
    List<WeightedDecisionCriteria> criteria,
  ) async {
    final rawResult = await isolate.runTask(
      algorithm,
      command,
      {
        "list_criteria": criteria.map((e) => e.toDto().toJson()).toList(),
        "list_alternative":
            alternatives.map((e) => e.toDto().toJson()).toList(),
      },
    );

    return (rawResult as List)
        .map((e) =>
            WeightedDecisionMatrixDto.fromJson(Map<String, dynamic>.from(e))
                .toEntity())
        .toList();
  }

  /// Generates matrix directly without using isolate.
  ///
  /// Used for smaller datasets where isolate overhead is not justified.
  /// Creates a matrix with initialized ratings (all set to 0).
  ///
  /// **Parameters:**
  /// - [alternatives]: List of alternatives
  /// - [criteria]: List of criteria
  ///
  /// **Returns:** Generated matrix with empty ratings
  List<WeightedDecisionMatrix> generateMatrixDirectly(
    List<WeightedDecisionAlternative> alternatives,
    List<WeightedDecisionCriteria> criteria,
  ) {
    return alternatives.map((alt) {
      final ratings = criteria.map((crt) {
        return WeightedDecisionRating(
          id: helper.getCustomUniqueId(),
          criteria: crt,
          value: 0,
        );
      }).toList();

      return WeightedDecisionMatrix(
        id: helper.getCustomUniqueId(),
        alternative: alt,
        ratings: ratings,
      );
    }).toList();
  }
}
