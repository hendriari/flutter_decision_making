// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_decision_making/core/isolate/decision_isolate_main.dart';
import 'package:flutter_decision_making/flutter_decision_making.dart';

import 'data_generator.dart';

class BenchmarkMetric {
  final List<double> samples;

  BenchmarkMetric(this.samples);

  double get median {
    if (samples.isEmpty) return 0.0;
    final sorted = List<double>.from(samples)..sort();
    final middle = sorted.length ~/ 2;
    if (sorted.length % 2 == 1) {
      return sorted[middle];
    } else {
      return (sorted[middle - 1] + sorted[middle]) / 2.0;
    }
  }

  double get min => samples.isEmpty ? 0.0 : samples.reduce(math.min);
  double get max => samples.isEmpty ? 0.0 : samples.reduce(math.max);

  Map<String, dynamic> toJson() => {
        'median': double.parse(median.toStringAsFixed(3)),
        'min': double.parse(min.toStringAsFixed(3)),
        'max': double.parse(max.toStringAsFixed(3)),
        'samples':
            samples.map((e) => double.parse(e.toStringAsFixed(3))).toList(),
      };
}

class BenchmarkCaseResult {
  final String algorithm;
  final int alternatives;
  final int criteria;
  final BenchmarkMetric mainThread;
  final BenchmarkMetric isolateFirstCall;
  final BenchmarkMetric isolateSubsequent;
  final BenchmarkMetric mainThreadBlocked;

  BenchmarkCaseResult({
    required this.algorithm,
    required this.alternatives,
    required this.criteria,
    required this.mainThread,
    required this.isolateFirstCall,
    required this.isolateSubsequent,
    required this.mainThreadBlocked,
  });

  Map<String, dynamic> toJson() => {
        'algorithm': algorithm,
        'size': '${alternatives}x$criteria',
        'alternatives': alternatives,
        'criteria': criteria,
        'mainThread': mainThread.toJson(),
        'isolateFirstCall': isolateFirstCall.toJson(),
        'isolateSubsequent': isolateSubsequent.toJson(),
        'mainThreadBlocked': mainThreadBlocked.toJson(),
      };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
      home: Scaffold(body: Center(child: Text('Running benchmark...')))));

  stdout.writeln('===========================================================');
  stdout.writeln('🚀 STARTING BENCHMARK: flutter_decision_making (Public API)');
  stdout.writeln(
      'Mode: ${kProfileMode ? "profile" : (kReleaseMode ? "release" : "debug")}');
  stdout.writeln('Platform: ${Platform.operatingSystem} (${Platform.version})');
  stdout.writeln('===========================================================');

  final results = <BenchmarkCaseResult>[];

  // Sizes for SAW and TOPSIS
  final sawTopsisSizes = [
    (10, 5),
    (80, 25),
    (200, 25),
    (500, 25),
    (2000, 50),
  ];

  // Sizes for AHP (pairwise comparisons scale quadratically with alternatives)
  final ahpSizes = [
    (10, 5),
    (20, 5),
    (50, 5),
    (80, 10),
  ];

  // 1. Benchmark SAW
  for (final size in sawTopsisSizes) {
    stdout.writeln('\n📊 Benchmarking SAW (${size.$1} x ${size.$2})...');
    final result = await runSawBenchmark(alts: size.$1, crts: size.$2);
    results.add(result);
    _printResult(result);
  }

  // 2. Benchmark TOPSIS
  for (final size in sawTopsisSizes) {
    stdout.writeln('\n📊 Benchmarking TOPSIS (${size.$1} x ${size.$2})...');
    final result = await runTopsisBenchmark(alts: size.$1, crts: size.$2);
    results.add(result);
    _printResult(result);
  }

  // 3. Benchmark AHP
  for (final size in ahpSizes) {
    stdout.writeln('\n📊 Benchmarking AHP (${size.$1} x ${size.$2})...');
    final result = await runAhpBenchmark(alts: size.$1, crts: size.$2);
    results.add(result);
    _printResult(result);
  }

  // Save results
  await saveBenchmarkResults(results);

  stdout.writeln('\n✅ Benchmark complete! Exiting...');
  exit(0);
}

void _printResult(BenchmarkCaseResult result) {
  stdout.writeln(
      '   - Main Thread:       ${result.mainThread.median.toStringAsFixed(3)} ms (min: ${result.mainThread.min.toStringAsFixed(3)}, max: ${result.mainThread.max.toStringAsFixed(3)})');
  stdout.writeln(
      '   - Isolate (1st call): ${result.isolateFirstCall.median.toStringAsFixed(3)} ms (min: ${result.isolateFirstCall.min.toStringAsFixed(3)}, max: ${result.isolateFirstCall.max.toStringAsFixed(3)})');
  stdout.writeln(
      '   - Isolate (warm):     ${result.isolateSubsequent.median.toStringAsFixed(3)} ms (min: ${result.isolateSubsequent.min.toStringAsFixed(3)}, max: ${result.isolateSubsequent.max.toStringAsFixed(3)})');
  stdout.writeln(
      '   - Main Thread Block: ${result.mainThreadBlocked.median.toStringAsFixed(3)} ms (min: ${result.mainThreadBlocked.min.toStringAsFixed(3)}, max: ${result.mainThreadBlocked.max.toStringAsFixed(3)})');
}

// ==================== LAG MONITOR HELPER ====================
class LagTracker {
  Timer? _timer;
  int _blockedUs = 0;
  int _lastTickUs = 0;

  void start() {
    _blockedUs = 0;
    _lastTickUs = DateTime.now().microsecondsSinceEpoch;
    _timer = Timer.periodic(const Duration(microseconds: 500), (t) {
      final nowUs = DateTime.now().microsecondsSinceEpoch;
      final diff = nowUs - _lastTickUs;
      if (diff > 1200) {
        _blockedUs += (diff - 500);
      }
      _lastTickUs = nowUs;
    });
  }

  int stop(int totalElapsedUs) {
    _timer?.cancel();
    _timer = null;
    if (_blockedUs > totalElapsedUs) {
      return totalElapsedUs;
    }
    return _blockedUs;
  }
}

// ==================== SAW BENCHMARK ====================
Future<BenchmarkCaseResult> runSawBenchmark({
  required int alts,
  required int crts,
}) async {
  final saw = SAW();
  final (_, _, matrix) = BenchmarkDataGenerator.generateDataset(
    alternativesCount: alts,
    criteriaCount: crts,
    seed: 42,
  );

  // Warm-up main thread
  for (int w = 0; w < 3; w++) {
    await saw.getSawResult(matrix: matrix, useIsolate: false);
  }

  // 1. Main Thread (useIsolate: false)
  final mainThreadSamples = <double>[];
  for (int i = 0; i < 10; i++) {
    final sw = Stopwatch()..start();
    await saw.getSawResult(matrix: matrix, useIsolate: false);
    sw.stop();
    mainThreadSamples.add(sw.elapsedMicroseconds / 1000.0);
  }

  // 2. Isolate First Call (Spawn + Execution)
  final isolateFirstCallSamples = <double>[];
  for (int i = 0; i < 10; i++) {
    DecisionIsolateMain.resetInstance();
    final sw = Stopwatch()..start();
    await saw.getSawResult(matrix: matrix, useIsolate: true);
    sw.stop();
    isolateFirstCallSamples.add(sw.elapsedMicroseconds / 1000.0);
  }

  // 3. Isolate Subsequent (Warm) & Main Thread Blocked
  final isolateSubsequentSamples = <double>[];
  final mainThreadBlockedSamples = <double>[];

  // Warm-up worker
  await saw.getSawResult(matrix: matrix, useIsolate: true);

  final tracker = LagTracker();
  for (int i = 0; i < 10; i++) {
    tracker.start();
    final sw = Stopwatch()..start();
    await saw.getSawResult(matrix: matrix, useIsolate: true);
    sw.stop();
    final blockedUs = tracker.stop(sw.elapsedMicroseconds);

    isolateSubsequentSamples.add(sw.elapsedMicroseconds / 1000.0);
    mainThreadBlockedSamples.add(blockedUs / 1000.0);
  }

  DecisionIsolateMain.resetInstance();

  return BenchmarkCaseResult(
    algorithm: 'SAW',
    alternatives: alts,
    criteria: crts,
    mainThread: BenchmarkMetric(mainThreadSamples),
    isolateFirstCall: BenchmarkMetric(isolateFirstCallSamples),
    isolateSubsequent: BenchmarkMetric(isolateSubsequentSamples),
    mainThreadBlocked: BenchmarkMetric(mainThreadBlockedSamples),
  );
}

// ==================== TOPSIS BENCHMARK ====================
Future<BenchmarkCaseResult> runTopsisBenchmark({
  required int alts,
  required int crts,
}) async {
  final topsis = TOPSIS();
  final (altsList, criteria, matrix) = BenchmarkDataGenerator.generateDataset(
    alternativesCount: alts,
    criteriaCount: crts,
    seed: 42,
  );
  final rawMatrix = TopsisRawMatrix(criterias: criteria, matrixs: matrix);

  // Warm-up main thread
  for (int w = 0; w < 3; w++) {
    await topsis.getTopsisResult(matrix: rawMatrix, useIsolate: false);
  }

  // 1. Main Thread (useIsolate: false)
  final mainThreadSamples = <double>[];
  for (int i = 0; i < 10; i++) {
    final sw = Stopwatch()..start();
    await topsis.getTopsisResult(matrix: rawMatrix, useIsolate: false);
    sw.stop();
    mainThreadSamples.add(sw.elapsedMicroseconds / 1000.0);
  }

  // 2. Isolate First Call (Spawn + Execution)
  final isolateFirstCallSamples = <double>[];
  for (int i = 0; i < 10; i++) {
    DecisionIsolateMain.resetInstance();
    final sw = Stopwatch()..start();
    await topsis.getTopsisResult(matrix: rawMatrix, useIsolate: true);
    sw.stop();
    isolateFirstCallSamples.add(sw.elapsedMicroseconds / 1000.0);
  }

  // 3. Isolate Subsequent (Warm) & Main Thread Blocked
  final isolateSubsequentSamples = <double>[];
  final mainThreadBlockedSamples = <double>[];

  // Warm-up worker
  await topsis.getTopsisResult(matrix: rawMatrix, useIsolate: true);

  final tracker = LagTracker();
  for (int i = 0; i < 10; i++) {
    tracker.start();
    final sw = Stopwatch()..start();
    await topsis.getTopsisResult(matrix: rawMatrix, useIsolate: true);
    sw.stop();
    final blockedUs = tracker.stop(sw.elapsedMicroseconds);

    isolateSubsequentSamples.add(sw.elapsedMicroseconds / 1000.0);
    mainThreadBlockedSamples.add(blockedUs / 1000.0);
  }

  DecisionIsolateMain.resetInstance();

  return BenchmarkCaseResult(
    algorithm: 'TOPSIS',
    alternatives: alts,
    criteria: crts,
    mainThread: BenchmarkMetric(mainThreadSamples),
    isolateFirstCall: BenchmarkMetric(isolateFirstCallSamples),
    isolateSubsequent: BenchmarkMetric(isolateSubsequentSamples),
    mainThreadBlocked: BenchmarkMetric(mainThreadBlockedSamples),
  );
}

// ==================== AHP BENCHMARK ====================
Future<BenchmarkCaseResult> runAhpBenchmark({
  required int alts,
  required int crts,
}) async {
  final ahp = AHP();
  final (hierarchy, inputsCriteria, inputsAlternative) =
      BenchmarkDataGenerator.generateAhpDataset(
    alternativesCount: alts,
    criteriaCount: crts,
    seed: 42,
  );

  // Warm-up main thread
  for (int w = 0; w < 3; w++) {
    await ahp.getAhpResult(
      hierarchy: hierarchy,
      inputsCriteria: inputsCriteria,
      inputsAlternative: inputsAlternative,
      useIsolate: false,
    );
  }

  // 1. Main Thread (useIsolate: false)
  final mainThreadSamples = <double>[];
  for (int i = 0; i < 10; i++) {
    final sw = Stopwatch()..start();
    await ahp.getAhpResult(
      hierarchy: hierarchy,
      inputsCriteria: inputsCriteria,
      inputsAlternative: inputsAlternative,
      useIsolate: false,
    );
    sw.stop();
    mainThreadSamples.add(sw.elapsedMicroseconds / 1000.0);
  }

  // 2. Isolate First Call (Spawn + Execution)
  final isolateFirstCallSamples = <double>[];
  for (int i = 0; i < 10; i++) {
    DecisionIsolateMain.resetInstance();
    final sw = Stopwatch()..start();
    await ahp.getAhpResult(
      hierarchy: hierarchy,
      inputsCriteria: inputsCriteria,
      inputsAlternative: inputsAlternative,
      useIsolate: true,
    );
    sw.stop();
    isolateFirstCallSamples.add(sw.elapsedMicroseconds / 1000.0);
  }

  // 3. Isolate Subsequent (Warm) & Main Thread Blocked
  final isolateSubsequentSamples = <double>[];
  final mainThreadBlockedSamples = <double>[];

  // Warm-up worker
  await ahp.getAhpResult(
    hierarchy: hierarchy,
    inputsCriteria: inputsCriteria,
    inputsAlternative: inputsAlternative,
    useIsolate: true,
  );

  final tracker = LagTracker();
  for (int i = 0; i < 10; i++) {
    tracker.start();
    final sw = Stopwatch()..start();
    await ahp.getAhpResult(
      hierarchy: hierarchy,
      inputsCriteria: inputsCriteria,
      inputsAlternative: inputsAlternative,
      useIsolate: true,
    );
    sw.stop();
    final blockedUs = tracker.stop(sw.elapsedMicroseconds);

    isolateSubsequentSamples.add(sw.elapsedMicroseconds / 1000.0);
    mainThreadBlockedSamples.add(blockedUs / 1000.0);
  }

  DecisionIsolateMain.resetInstance();

  return BenchmarkCaseResult(
    algorithm: 'AHP',
    alternatives: alts,
    criteria: crts,
    mainThread: BenchmarkMetric(mainThreadSamples),
    isolateFirstCall: BenchmarkMetric(isolateFirstCallSamples),
    isolateSubsequent: BenchmarkMetric(isolateSubsequentSamples),
    mainThreadBlocked: BenchmarkMetric(mainThreadBlockedSamples),
  );
}

// ==================== SAVE RESULTS ====================
Future<void> saveBenchmarkResults(List<BenchmarkCaseResult> results) async {
  final mode = kProfileMode ? "profile" : (kReleaseMode ? "release" : "debug");
  final dateStr = DateTime.now().toIso8601String().split('T').first;

  // JSON output
  final jsonMap = {
    'date': dateStr,
    'mode': mode,
    'platform': '${Platform.operatingSystem} (${Platform.version})',
    'iterations': 10,
    'warmup': 3,
    'results': results.map((e) => e.toJson()).toList(),
  };

  // Find results directory
  Directory resultsDir = Directory(
      '/Users/hendriari/Project/Flutter-Project/PACKAGE/flutter_decision_making/benchmark/results');
  if (!resultsDir.existsSync()) {
    resultsDir = Directory('benchmark/results');
  }
  if (!resultsDir.existsSync()) {
    resultsDir = Directory('results');
  }
  if (!resultsDir.existsSync()) {
    resultsDir.createSync(recursive: true);
  }

  try {
    final jsonFile = File('${resultsDir.path}/$dateStr-$mode.json');
    await jsonFile
        .writeAsString(const JsonEncoder.withIndent('  ').convert(jsonMap));
    stdout.writeln('💾 JSON results saved to: ${jsonFile.path}');
  } catch (e) {
    stdout.writeln('⚠️ Failed writing JSON file: $e');
  }

  // Markdown output
  final sb = StringBuffer();
  sb.writeln('# Benchmark Results: SAW, TOPSIS & AHP (Public API)');
  sb.writeln();
  sb.writeln('- **Tanggal:** $dateStr');
  sb.writeln('- **Mode:** `$mode`');
  sb.writeln(
      '- **Perangkat / OS:** `${Platform.operatingSystem} (${Platform.version})`');
  sb.writeln('- **Pengulangan:** 10 iterasi (setelah 3x warm-up)');
  sb.writeln();

  for (final algo in ['SAW', 'TOPSIS', 'AHP']) {
    sb.writeln('## Algoritma: $algo ($mode)');
    sb.writeln();
    sb.writeln(
        '| Ukuran (Alt x Crt) | Main Thread (ms)<br>median [min–max] | Isolate 1st Call (ms)<br>median [min–max] | Isolate Warm (ms)<br>median [min–max] | Main Thread Blocked (ms)<br>median [min–max] |');
    sb.writeln('| :--- | :--- | :--- | :--- | :--- |');

    final algoResults = results.where((r) => r.algorithm == algo);
    for (final r in algoResults) {
      final size = '${r.alternatives}×${r.criteria}';
      final mt =
          '${r.mainThread.median.toStringAsFixed(3)} [${r.mainThread.min.toStringAsFixed(3)}–${r.mainThread.max.toStringAsFixed(3)}]';
      final iso1 =
          '${r.isolateFirstCall.median.toStringAsFixed(3)} [${r.isolateFirstCall.min.toStringAsFixed(3)}–${r.isolateFirstCall.max.toStringAsFixed(3)}]';
      final isoW =
          '${r.isolateSubsequent.median.toStringAsFixed(3)} [${r.isolateSubsequent.min.toStringAsFixed(3)}–${r.isolateSubsequent.max.toStringAsFixed(3)}]';
      final block =
          '${r.mainThreadBlocked.median.toStringAsFixed(3)} [${r.mainThreadBlocked.min.toStringAsFixed(3)}–${r.mainThreadBlocked.max.toStringAsFixed(3)}]';
      sb.writeln('| $size | $mt | $iso1 | $isoW | $block |');
    }
    sb.writeln();
  }

  try {
    final mdFile = File('${resultsDir.path}/$dateStr-$mode.md');
    await mdFile.writeAsString(sb.toString());
    stdout.writeln('💾 Markdown results saved to: ${mdFile.path}');
  } catch (e) {
    stdout.writeln('⚠️ Failed writing MD file: $e');
  }

  stdout.writeln('### RAW_JSON_START ###');
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(jsonMap));
  stdout.writeln('### RAW_JSON_END ###');
}
