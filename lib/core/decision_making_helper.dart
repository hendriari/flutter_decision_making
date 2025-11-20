import 'package:uuid/uuid.dart';

/// AHP HELPER
class DecisionMakingHelper {
  /// HELPER TO GET UNIQUE ID
  String getCustomUniqueId() {
    return Uuid().v4();
  }
}
