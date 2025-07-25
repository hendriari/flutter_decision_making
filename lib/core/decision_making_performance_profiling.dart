import 'dart:developer' as dev;

final _stopwatch = Stopwatch();

/// START DEV PERFORMANCE PROFILING
void startPerformanceProfiling(
  String name, {
  String? logName,
}) {
  dev.log("🔄 start $name..", name: logName ?? 'DECISION MAKING');
  dev.Timeline.startSync(name);
  _stopwatch.start();
}

/// END DEV PERFORMANCE PROFILING
void endPerformanceProfiling(
  String name, {
  String? logName,
}) {
  dev.Timeline.finishSync();
  _stopwatch.stop();
  dev.log(
      "🏁 $name has been execute - duration : ${_stopwatch.elapsedMilliseconds} ms",
      name: logName ?? 'DECISION MAKING');
  _stopwatch.reset();
}
