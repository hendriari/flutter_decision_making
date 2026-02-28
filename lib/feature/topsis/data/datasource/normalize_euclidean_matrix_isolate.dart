import "dart:math" as math;

import 'package:flutter_decision_making/flutter_decision_making.dart';

Future<List<Map<String, dynamic>>> normalizeEuclideanMatrixIsolate({
  required Map<String, dynamic> data,
}) async {
  var criteriaDto = (data['criteria'] as List)
      .map((e) => WeightedDecisionCriteriaDto.fromJson(e))
      .toList();
  var matrixDto = (data['matrix'] as List)
      .map((e) => WeightedDecisionMatrixDto.fromJson(e))
      .toList();

  Map<String, double> dividers = {};

  for (var crt in criteriaDto) {
    double sumSquared = 0;
    for (var alt in matrixDto) {
      var rating = alt.ratings.firstWhere((r) => r.criteria?.id == crt.id);
      final ratingValue = (rating.value ?? 0).toDouble();
      sumSquared += math.pow(ratingValue, 2);
    }
    dividers[crt.id!] = math.sqrt(sumSquared);
  }

  var result = matrixDto.map((alt) {
    final normalizedRatings = alt.ratings.map((r) {
      double divider = dividers[r.criteria?.id] ?? 1.0;
      return r.copyWith(
        value: divider == 0 ? 0 : (r.value ?? 0) / divider,
      );
    }).toList();

    return alt.copyWith(ratings: normalizedRatings);
  }).toList();

  return result.map((e) => e.toJson()).toList();
}
