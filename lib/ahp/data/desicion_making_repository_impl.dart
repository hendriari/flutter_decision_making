import 'package:flutter_decision_making/ahp/domain/entities/alternative.dart';
import 'package:flutter_decision_making/ahp/domain/entities/criteria.dart';
import 'package:flutter_decision_making/ahp/domain/entities/hierarchy.dart';
import 'package:flutter_decision_making/ahp/domain/entities/identification.dart';
import 'package:flutter_decision_making/ahp/domain/entities/pairwise_comparison_matrix.dart';
import 'package:flutter_decision_making/ahp/domain/repository/decision_making_repository.dart';
import 'package:flutter_decision_making/ahp/helper/ahp_helper.dart';

class DecisionMakingRepositoryImpl extends DecisionMakingRepository {
  final AhpHelper _helper;

  DecisionMakingRepositoryImpl({AhpHelper? helper})
    : _helper = helper ?? AhpHelper();

  static void _validateUniqueId<T>(List<T> items, String Function(T) getId) {
    final seen = <String>{};
    for (var e in items) {
      final id = getId(e);
      if (seen.contains(id)) {
        throw ArgumentError('Duplicate id found');
      }
      seen.add(id);
    }
  }

  @override
  Future<Identification> identification(
    List<Criteria> criteria,
    List<Alternative> alternative,
  ) async {
    try {
      if (criteria.isEmpty) {
        throw ArgumentError("Criteria can't be empty!");
      }
      if (alternative.isEmpty) {
        throw ArgumentError("Alternative can't be empty!");
      }

      if (criteria.length > 50 || alternative.length > 99) {
        throw ArgumentError(
          "Too much data, please limit the number of criteria/alternatives.",
        );
      }

      final updatedCriteria = List<Criteria>.generate(criteria.length, (i) {
        final e = criteria[i];
        return (e.id == null || e.id!.isEmpty)
            ? e.copyWith(id: _helper.getCustomUniqueId())
            : e;
      });

      final updateAlternative = List<Alternative>.generate(alternative.length, (
        i,
      ) {
        final e = alternative[i];
        return (e.id == null || e.id!.isEmpty)
            ? e.copyWith(id: _helper.getCustomUniqueId())
            : e;
      });

      _validateUniqueId<Criteria>(updatedCriteria, (e) => e.id!);
      _validateUniqueId<Alternative>(updateAlternative, (e) => e.id!);

      return Identification(
        criteria: updatedCriteria,
        alternative: updateAlternative,
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<Hierarchy>> generateHierarchy(
    List<Criteria> criteria,
    List<Alternative> alternative,
  ) async {
    try {
      final resultHierarchy =
          criteria.map((c) {
            return Hierarchy(criteria: c, alternative: alternative);
          }).toList();

      return resultHierarchy;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<PairwiseComparisonInput<Criteria>>> generatePairwiseCriteria(
    List<Criteria> criteria,
  ) async {
    try {
      final result = <PairwiseComparisonInput<Criteria>>[];

      for (int i = 0; i < criteria.length; i++) {
        for (int j = i + 1; j < criteria.length; j++) {
          result.add(
            PairwiseComparisonInput<Criteria>(
              left: criteria[i],
              right: criteria[j],
              preferenceValue: null,
              id: _helper.getCustomUniqueId(),
            ),
          );
        }
      }

      return result;
    } catch (e) {
      throw Exception(e);
    }
  }
}
