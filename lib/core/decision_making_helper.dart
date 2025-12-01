import 'dart:developer' as dev;

import 'package:uuid/uuid.dart';

/// AHP HELPER
class DecisionMakingHelper {
  /// HELPER TO GET UNIQUE ID
  String getCustomUniqueId() {
    return Uuid().v4();
  }

  void printLog({
    required String message,
    String? logName,
  }) {
    dev.log(message, name: logName ?? 'DECISION MAKING');
  }
}
