import 'package:flutter_decision_making/feature/ahp/presentation/ahp.dart';
import 'package:flutter_decision_making/feature/saw/presentation/saw.dart';

export 'package:flutter_decision_making/core/isolate/decision_isolate_worker.dart';
export 'package:flutter_decision_making/core/isolate/decision_isolate_message.dart';
export 'package:flutter_decision_making/core/isolate/decision_isolate_main.dart';
export 'package:flutter_decision_making/feature/ahp/presentation/ahp.dart';
export 'package:flutter_decision_making/feature/saw/presentation/saw.dart';

class FlutterDecisionMaking {
  final AHP ahp;
  final SAW saw;

  FlutterDecisionMaking({AHP? ahp, SAW? saw})
      : ahp = ahp ?? AHP(),
        saw = saw ?? SAW();
}
