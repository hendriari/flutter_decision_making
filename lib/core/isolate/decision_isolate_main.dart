import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_decision_making/core/decision_making_enums.dart';
import 'package:flutter_decision_making/core/decision_making_helper.dart';
import 'package:synchronized/synchronized.dart';

import 'decision_isolate_message.dart';
import 'decision_isolate_worker.dart';

/// Enterprise-grade isolate manager with auto-dispose, idle timeout,
/// active task tracking, and full lifecycle control.
///
/// Features:
/// - Singleton + lazy initialization
/// - Auto dispose on app pause/detach/idle
/// - Thread-safe with `synchronized` package
/// - Active task counter prevents premature disposal
/// - Comprehensive debug status with `getStatus()`
/// - Safe reset & force dispose options
/// - Per-task timeout control
/// - Crash-resistant with `errorsAreFatal: false`
///
/// Example:
/// ```dart
/// final isolate = DecisionMainIsolate();
///
/// // Run task (auto-init if needed)
/// final result = await isolate.runTask(
///   DecisionAlgorithm.saw,
///   SawProcessingCommand.generateMatrix,
///   {'data': myData},
///   timeout: Duration(seconds: 10),
/// );
///
/// // Check status
/// print(isolate.getStatus());
///
/// // Force cleanup
/// isolate.dispose(force: true);
/// ```
class DecisionIsolateMain with WidgetsBindingObserver {
  static final DecisionIsolateMain instance = DecisionIsolateMain._internal();

  factory DecisionIsolateMain() => instance;

  DecisionIsolateMain._internal() {
    _setupAutoDispose();
  }

  Isolate? _isolate;
  SendPort? _sendPort;
  Completer<void>? _initCompleter;
  final _lock = Lock();
  Timer? _idleTimer;
  final _helper = DecisionMakingHelper();
  DateTime? _lastUsed;
  DateTime? _spawnTime;
  int _activeTasks = 0;
  int _totalTasksCompleted = 0;
  final String _debugId =
      DateTime.now().microsecondsSinceEpoch.toRadixString(16);
  final _logName = 'Decision Making Isolate';

  static const Duration _idleTimeout = Duration(minutes: 5);
  static const Duration _idleCheckInterval = Duration(minutes: 1);

  // ========== AUTO DISPOSE SETUP ==========
  void _setupAutoDispose() {
    WidgetsBinding.instance.addObserver(this);
    _startIdleChecker();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _helper.printLog(
            message: '[$_debugId] 📱 App paused → check dispose in 30s',
            logName: _logName);
        _tryDisposeOnPause();
        break;
      case AppLifecycleState.detached:
        _helper.printLog(
            message: '[$_debugId] 🛑 App detached → force dispose',
            logName: _logName);
        dispose(force: true);
        break;
      case AppLifecycleState.resumed:
        _helper.printLog(
            message: '[$_debugId] ✅ App resumed', logName: _logName);
        break;
      default:
        break;
    }
  }

  void _tryDisposeOnPause() {
    Future.delayed(const Duration(seconds: 30), () {
      if (_isolate != null && _activeTasks == 0) {
        _helper.printLog(
            message: '[$_debugId] 💤 No active tasks → auto-dispose',
            logName: _logName);
        dispose();
      } else if (_activeTasks > 0) {
        _helper.printLog(
            message:
                '[$_debugId] ⚠️  $_activeTasks tasks active → skip dispose',
            logName: _logName);
      }
    });
  }

  void _startIdleChecker() {
    _idleTimer?.cancel();
    _idleTimer = Timer.periodic(_idleCheckInterval, (timer) {
      if (_lastUsed == null || _isolate == null || _activeTasks > 0) return;

      final idle = DateTime.now().difference(_lastUsed!);
      if (idle > _idleTimeout) {
        _helper.printLog(
            message: '[$_debugId] 💤 Idle ${idle.inMinutes}min → dispose',
            logName: _logName);
        dispose();
        timer.cancel();
      }
    });
  }

  void _markUsed() {
    _lastUsed = DateTime.now();
  }

  // ========== INITIALIZATION ==========
  /// Initialize the isolate if not already running.
  /// Thread-safe and lazy. Safe to call multiple times.
  Future<void> init() async {
    _markUsed();

    if (_isolate != null && _sendPort != null) {
      return _initCompleter!.future;
    }

    return _lock.synchronized(() async {
      // Double-check after acquiring lock
      if (_isolate != null && _sendPort != null) {
        return _initCompleter!.future;
      }

      _initCompleter = Completer<void>();
      final receivePort = ReceivePort();

      try {
        _helper.printLog(
            message: '[$_debugId] 🚀 Spawning isolate...', logName: _logName);
        _isolate = await Isolate.spawn(
          decisionIsolateWorker,
          receivePort.sendPort,
          debugName: 'DecisionIsolate-$_debugId',
          errorsAreFatal: false,
          onError: receivePort.sendPort,
          onExit: receivePort.sendPort,
        );

        final response = await receivePort.first.timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            receivePort.close();
            _isolate?.kill(priority: Isolate.immediate);
            throw TimeoutException('Isolate spawn timeout after 5s');
          },
        );

        // Handle different response types
        if (response is SendPort) {
          _sendPort = response;
        } else if (response is List) {
          // onError sends [error, stackTrace]
          final error = response.isNotEmpty ? response[0] : 'Unknown error';
          final stack = response.length > 1 ? response[1] : '';
          throw Exception('Isolate spawn error: $error\n$stack');
        } else {
          throw Exception(
              'Unexpected isolate response: ${response.runtimeType}\n$response');
        }

        _spawnTime = DateTime.now();
        _initCompleter!.complete();
        _startIdleChecker();
        _helper.printLog(
            message: '[$_debugId] ✅ Initialized successfully',
            logName: _logName);
      } catch (e, st) {
        _helper.printLog(
            message: '[$_debugId] ❌ Init failed: $e', logName: _logName);
        _initCompleter!.completeError(e, st);
        _cleanup();
        rethrow;
      } finally {
        receivePort.close();
      }
    });
  }

  // ========== RUN TASK ==========
  /// Run a decision-making task in the isolate.
  ///
  /// Automatically initializes the isolate if needed.
  ///
  /// Parameters:
  /// - [algorithm]: The decision algorithm to use
  /// - [command]: The specific command/operation
  /// - [data]: Payload data for the operation
  /// - [timeout]: Maximum duration before throwing [TimeoutException]
  ///
  /// Throws:
  /// - [TimeoutException] if task exceeds [timeout]
  /// - [StateError] if isolate fails to initialize
  /// - [Exception] if isolate returns an error
  Future<dynamic> runTask(
    DecisionAlgorithm algorithm,
    dynamic command,
    Map<String, dynamic> data, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    _activeTasks++;
    final taskId = DateTime.now().microsecond;

    try {
      _markUsed();
      await init();

      if (_sendPort == null) {
        throw StateError('Isolate not initialized');
      }

      final responsePort = ReceivePort();

      try {
        final message = DecisionIsolateMessage(
          algorithm: algorithm,
          command: command,
          payload: data,
          replyPort: responsePort.sendPort,
        );

        _helper.printLog(
            message: '[$_debugId] 📤 Task #$taskId → $algorithm.$command',
            logName: _logName);
        _sendPort!.send(message);

        final result = await responsePort.first.timeout(
          timeout,
          onTimeout: () {
            throw TimeoutException(
                'Task #$taskId timeout after ${timeout.inSeconds}s: $algorithm.$command');
          },
        );

        if (result is Map && result.containsKey('error')) {
          throw Exception('Isolate Task Error (#$taskId):\n'
              '${result['error']}\n'
              '${result['stack'] ?? ''}');
        }

        _totalTasksCompleted++;
        _helper.printLog(
            message: '[$_debugId] ✅ Task #$taskId completed',
            logName: _logName);
        return result;
      } finally {
        responsePort.close();
      }
    } catch (e) {
      _helper.printLog(
          message: '[$_debugId] ❌ Task #$taskId failed: $e', logName: _logName);
      rethrow;
    } finally {
      _activeTasks--;
      if (_activeTasks < 0) {
        _helper.printLog(
            message: '[$_debugId] ⚠️  WARNING: _activeTasks went negative!',
            logName: _logName);
        _activeTasks = 0;
      }
    }
  }

  // ========== CLEANUP ==========
  void _cleanup() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sendPort = null;
    _initCompleter = null;
    _lastUsed = null;
    _spawnTime = null;
  }

  /// Dispose the isolate and free resources.
  ///
  /// By default, disposal is skipped if tasks are running.
  /// Set [force] = true to kill even with active tasks.
  ///
  /// This method is automatically called on app pause/detach.
  void dispose({bool force = false}) {
    if (_isolate == null) return;

    if (!force && _activeTasks > 0) {
      _helper.printLog(
          message:
              '[$_debugId] ⚠️  SKIP dispose: $_activeTasks tasks still active',
          logName: _logName);
      return;
    }

    if (force && _activeTasks > 0) {
      _helper.printLog(
          message:
              '[$_debugId] ⚠️  Force disposing with $_activeTasks active tasks!',
          logName: _logName);
    }

    _helper.printLog(
        message: '[$_debugId] 🧹 Disposing (force: $force)...',
        logName: _logName);
    _idleTimer?.cancel();
    _idleTimer = null;
    _cleanup();
    _activeTasks = 0;
    WidgetsBinding.instance.removeObserver(this);
  }

  // ========== UTILITY ==========
  /// Reset and reinitialize the isolate.
  ///
  /// Useful for recovering from errors or applying configuration changes.
  Future<void> reset() async {
    _helper.printLog(message: '[$_debugId] 🔄 Resetting...', logName: _logName);
    dispose(force: true);
    _setupAutoDispose();
    await init();
  }

  /// Get comprehensive status information for debugging and monitoring.
  ///
  /// Returns a map with:
  /// - `id`: Unique isolate identifier
  /// - `initialized`: Whether isolate is running
  /// - `activeTasks`: Number of tasks currently executing
  /// - `totalCompleted`: Total tasks completed since spawn
  /// - `lastUsed`: ISO timestamp of last activity
  /// - `spawnTime`: ISO timestamp when isolate was created
  /// - `uptimeSeconds`: How long isolate has been running
  /// - `idleMinutes`: Minutes since last activity
  /// - `willDisposeIn`: Estimated time until auto-dispose
  /// - `isPaused`: Whether isolate is idle but initialized
  Map<String, dynamic> getStatus() {
    final now = DateTime.now();
    final idle =
        _lastUsed != null ? now.difference(_lastUsed!).inMinutes : null;
    final uptime =
        _spawnTime != null ? now.difference(_spawnTime!).inSeconds : null;

    return {
      'id': _debugId,
      'initialized': _isolate != null,
      'activeTasks': _activeTasks,
      'totalCompleted': _totalTasksCompleted,
      'lastUsed': _lastUsed?.toIso8601String(),
      'spawnTime': _spawnTime?.toIso8601String(),
      'uptimeSeconds': uptime,
      'idleMinutes': idle,
      'willDisposeIn': idle != null && idle < _idleTimeout.inMinutes
          ? '${_idleTimeout.inMinutes - idle} min'
          : 'N/A',
      'isPaused': _activeTasks == 0 && _isolate != null,
    };
  }
}
