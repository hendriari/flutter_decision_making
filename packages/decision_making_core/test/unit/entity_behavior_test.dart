import 'package:decision_making_core/decision_making_core.dart';
import 'package:test/test.dart';

void main() {
  group('Entity Behavior Tests - Common / SAW Entities', () {
    test('WeightedDecisionAlternative equality, hashCode, and copyWith', () {
      final a1 = WeightedDecisionAlternative(id: 'alt1', name: 'Option A');
      final a2 =
          WeightedDecisionAlternative(id: 'alt1', name: 'Different Name');
      final a3 = WeightedDecisionAlternative(id: 'alt2', name: 'Option A');

      expect(a1 == a2, isTrue, reason: 'Equality is based on id');
      expect(a1 == a3, isFalse);
      expect(a1.hashCode, equals(a2.hashCode));

      final copied = a1.copyWith(name: 'Updated Name');
      expect(copied.id, 'alt1');
      expect(copied.name, 'Updated Name');
      expect(copied, equals(a1));
    });

    test('WeightedDecisionCriteria equality, hashCode, and copyWith', () {
      final c1 = WeightedDecisionCriteria(
        id: 'crit1',
        name: 'Price',
        description: 'Cost factor',
        maxValue: 100,
        isBenefit: false,
        weightPercent: 0.4,
      );
      final c2 = WeightedDecisionCriteria(
        id: 'crit1',
        name: 'Cost',
        maxValue: 100,
        isBenefit: true,
        weightPercent: 0.5,
      );
      final c3 = WeightedDecisionCriteria(
        id: 'crit2',
        name: 'Price',
        maxValue: 100,
        isBenefit: false,
        weightPercent: 0.4,
      );

      expect(c1 == c2, isTrue, reason: 'Criteria equality is based on id');
      expect(c1 == c3, isFalse);
      expect(c1.hashCode, equals(c2.hashCode));

      final copied = c1.copyWith(
        name: 'New Price',
        description: 'New Desc',
        maxValue: 200,
        isBenefit: true,
        weightPercent: 0.6,
      );
      expect(copied.id, 'crit1');
      expect(copied.name, 'New Price');
      expect(copied.description, 'New Desc');
      expect(copied.maxValue, 200);
      expect(copied.isBenefit, true);
      expect(copied.weightPercent, 0.6);
      expect(copied, equals(c1));
    });

    test('WeightedDecisionRating equality, hashCode, and copyWith', () {
      final c = WeightedDecisionCriteria(
        id: 'c1',
        name: 'C1',
        maxValue: 100,
        isBenefit: true,
        weightPercent: 1.0,
      );
      final r1 = WeightedDecisionRating(id: 'r1', criteria: c, value: 10.0);
      final r2 = WeightedDecisionRating(id: 'r1', criteria: c, value: 50.0);
      final r3 = WeightedDecisionRating(id: 'r2', criteria: c, value: 10.0);

      expect(r1 == r2, isTrue, reason: 'Rating equality is based on id');
      expect(r1 == r3, isFalse);
      expect(r1.hashCode, equals(r2.hashCode));

      final copied = r1.copyWith(value: 99.0);
      expect(copied.id, 'r1');
      expect(copied.value, 99.0);
      expect(copied.criteria, c);
      expect(copied, equals(r1));
    });

    test('WeightedDecisionMatrix equality, hashCode, and copyWith', () {
      final alt = WeightedDecisionAlternative(id: 'a1', name: 'Alt 1');
      final c = WeightedDecisionCriteria(
        id: 'c1',
        name: 'C1',
        maxValue: 100,
        isBenefit: true,
        weightPercent: 1.0,
      );
      final m1 = WeightedDecisionMatrix(
        id: 'm1',
        alternative: alt,
        ratings: [],
      );
      final m2 = WeightedDecisionMatrix(
        id: 'm1',
        alternative: WeightedDecisionAlternative(id: 'a2', name: 'Alt 2'),
        ratings: [],
      );
      final m3 = WeightedDecisionMatrix(
        id: 'm2',
        alternative: alt,
        ratings: [],
      );

      expect(m1 == m2, isTrue);
      expect(m1 == m3, isFalse);
      expect(m1.hashCode, equals(m2.hashCode));

      final copied = m1.copyWith(ratings: [
        WeightedDecisionRating(id: 'r1', criteria: c, value: 5.0),
      ]);
      expect(copied.id, 'm1');
      expect(copied.ratings.length, 1);
      expect(copied, equals(m1));
    });

    test('WeightedDecisionResult equality, hashCode, and copyWith', () {
      final alt = WeightedDecisionAlternative(id: 'a1', name: 'Alt 1');
      final res1 = WeightedDecisionResult(
        id: 'res1',
        alternative: alt,
        score: 0.85,
        rank: 1,
      );
      final res2 = WeightedDecisionResult(
        id: 'res1',
        alternative: alt,
        score: 0.40,
        rank: 3,
      );
      final res3 = WeightedDecisionResult(
        id: 'res2',
        alternative: alt,
        score: 0.85,
        rank: 1,
      );

      expect(res1 == res2, isTrue);
      expect(res1 == res3, isFalse);
      expect(res1.hashCode, equals(res2.hashCode));

      final copied = res1.copyWith(score: 0.95, rank: 2);
      expect(copied.id, 'res1');
      expect(copied.score, 0.95);
      expect(copied.rank, 2);
      expect(copied, equals(res1));
    });
  });

  group('Entity Behavior Tests - TOPSIS Entities', () {
    test('TopsisIdealValue copyWith', () {
      final ideal = TopsisIdealValue(
        positiveIdeal: {'c1': 10.0},
        negativeIdeal: {'c1': 2.0},
      );
      final copied = ideal.copyWith(
        positiveIdeal: {'c1': 15.0},
      );
      expect(copied.positiveIdeal, {'c1': 15.0});
      expect(copied.negativeIdeal, {'c1': 2.0});
    });

    test('TopsisMatrix properties and inheritance', () {
      final alt = WeightedDecisionAlternative(id: 'a1', name: 'Alt 1');
      final tm = TopsisMatrix(
        alternative: alt,
        ratings: [],
        distancePlus: 1.5,
        distanceMinus: 2.5,
      );

      expect(tm.alternative, alt);
      expect(tm.distancePlus, 1.5);
      expect(tm.distanceMinus, 2.5);
      expect(tm, isA<WeightedDecisionMatrix>());
    });

    test('TopsisRawMatrix copyWith', () {
      final raw = TopsisRawMatrix(
        criterias: [
          WeightedDecisionCriteria(
            id: 'c1',
            name: 'C1',
            maxValue: 100,
            isBenefit: true,
            weightPercent: 1.0,
          ),
        ],
        matrixs: [],
      );
      final copied = raw.copyWith(
        matrixs: [
          WeightedDecisionMatrix(
            id: 'm1',
            alternative: WeightedDecisionAlternative(id: 'a1', name: 'A1'),
            ratings: [],
          ),
        ],
      );
      expect(copied.criterias.length, 1);
      expect(copied.matrixs.length, 1);
    });
  });

  group('Entity Behavior Tests - AHP Entities', () {
    test('AhpItem equality, hashCode, copyWith, and const construction', () {
      const item1 = AhpItem(id: 'item1', name: 'Criteria A', shortName: 'CA');
      const item2 = AhpItem(id: 'item1', name: 'Different Name');
      const item3 = AhpItem(id: 'item2', name: 'Criteria A');

      expect(item1 == item2, isTrue);
      expect(item1 == item3, isFalse);
      expect(item1.hashCode, equals(item2.hashCode));

      final copied = item1.copyWith(name: 'Updated Name', shortName: 'UA');
      expect(copied.id, 'item1');
      expect(copied.name, 'Updated Name');
      expect(copied.shortName, 'UA');
      expect(copied, equals(item1));
    });

    test('AhpComparisonScale equality, hashCode, and copyWith', () {
      final s1 = AhpComparisonScale(id: 's1', description: 'Equal', value: 1);
      final s2 =
          AhpComparisonScale(id: 's1', description: 'Different', value: 9);
      final s3 = AhpComparisonScale(id: 's2', description: 'Equal', value: 1);

      expect(s1 == s2, isTrue);
      expect(s1 == s3, isFalse);
      expect(s1.hashCode, equals(s2.hashCode));

      final copied = s1.copyWith(description: 'Moderately');
      expect(copied.id, 's1');
      expect(copied.description, 'Moderately');
      expect(copied.value, 1);
      expect(copied, equals(s1));
    });

    test('PairwiseComparisonInput equality, hashCode, and copyWith', () {
      final left = AhpItem(id: 'l', name: 'Left');
      final right = AhpItem(id: 'r', name: 'Right');
      final p1 = PairwiseComparisonInput(
        id: 'p1',
        left: left,
        right: right,
        preferenceValue: 3,
        isLeftMoreImportant: true,
      );
      final p2 = PairwiseComparisonInput(
        id: 'p1',
        left: left,
        right: right,
        preferenceValue: 5,
        isLeftMoreImportant: false,
      );
      final p3 = PairwiseComparisonInput(
        id: 'p2',
        left: left,
        right: right,
        preferenceValue: 3,
        isLeftMoreImportant: true,
      );

      expect(p1 == p2, isTrue);
      expect(p1 == p3, isFalse);
      expect(p1.hashCode, equals(p2.hashCode));

      final copied =
          p1.copyWith(preferenceValue: 7, isLeftMoreImportant: false);
      expect(copied.id, 'p1');
      expect(copied.preferenceValue, 7);
      expect(copied.isLeftMoreImportant, false);
      expect(copied, equals(p1));
    });

    test('AhpResultDetail equality and hashCode', () {
      final d1 = AhpResultDetail(id: 'd1', name: 'Alt 1', value: 0.65);
      final d2 = AhpResultDetail(id: 'd1', name: 'Alt X', value: 0.10);
      final d3 = AhpResultDetail(id: 'd2', name: 'Alt 1', value: 0.65);

      expect(d1 == d2, isTrue);
      expect(d1 == d3, isFalse);
      expect(d1.hashCode, equals(d2.hashCode));
    });

    test('PairwiseAlternativeInput copyWith', () {
      final crit = AhpItem(id: 'c1', name: 'Crit 1');
      final input = PairwiseAlternativeInput(
        criteria: crit,
        alternative: [],
      );
      final copied = input.copyWith(
        alternative: [
          PairwiseComparisonInput(
            id: 'pair1',
            left: AhpItem(id: 'a1', name: 'A1'),
            right: AhpItem(id: 'a2', name: 'A2'),
            preferenceValue: 2,
            isLeftMoreImportant: true,
          ),
        ],
      );
      expect(copied.criteria, crit);
      expect(copied.alternative.length, 1);
    });

    test('AhpConsistencyRatio backwards compatibility with optional fields',
        () {
      final cr = AhpConsistencyRatio(
        source: 'criteria',
        ratio: 0.05,
        isConsistent: true,
        lambdaMax: 3.05,
        ci: 0.025,
      );
      expect(cr.source, 'criteria');
      expect(cr.ratio, 0.05);
      expect(cr.isConsistent, true);
      expect(cr.lambdaMax, 3.05);
      expect(cr.ci, 0.025);
    });
  });
}
