import 'dart:isolate';

import 'package:flutter_decision_making/core/decision_making_enums.dart';

class AhpIsolatedMessage {
  final AhpProcessingCommand command;
  final SendPort replyPort;
  final Map<String, dynamic> payload;

  AhpIsolatedMessage({
    required this.command,
    required this.replyPort,
    required this.payload,
  });
}
