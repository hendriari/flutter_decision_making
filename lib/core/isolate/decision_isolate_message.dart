import 'dart:isolate';

import 'package:flutter_decision_making/core/decision_making_enums.dart';

class DecisionIsolateMessage {
  final DecisionAlgorithm algorithm;
  final dynamic command;
  final Map<String, dynamic> payload;
  final SendPort replyPort;

  DecisionIsolateMessage({
    required this.algorithm,
    required this.command,
    required this.payload,
    required this.replyPort,
  });
}
