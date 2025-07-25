import 'dart:async';
import 'dart:isolate';

import 'package:flutter_decision_making/core/decision_making_enums.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_isolate_worker.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_isolated_message.dart';

/// AHP MAIN ISOLATE SPAWN
class AhpMainIsolate {
  static final AhpMainIsolate _instance = AhpMainIsolate._internal();

  factory AhpMainIsolate() => _instance;

  AhpMainIsolate._internal();

  late Isolate _isolate;
  late SendPort _sendPort;
  Completer<void>? _isolateReady;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    final portReady = ReceivePort();
    _isolate = await Isolate.spawn(ahpIsolateWorker, portReady.sendPort);
    _sendPort = await portReady.first as SendPort;

    _isolateReady = Completer<void>();
    _isolateReady?.complete();
    _initialized = true;
  }

  Future<dynamic> runTask(
      AhpProcessingCommand command, Map<String, dynamic> data) async {
    await _isolateReady?.future;

    final responsePort = ReceivePort();
    _sendPort.send(AhpIsolatedMessage(
      command: command,
      payload: data,
      replyPort: responsePort.sendPort,
    ));

    final result = await responsePort.first;
    if (result is Map && result.containsKey('error')) {
      throw Exception("Isolate Error: ${result['error']}\n${result['stack']}");
    }
    return result;
  }

  void dispose() {
    _isolate.kill(priority: Isolate.immediate);
    _initialized = false;
  }
}
