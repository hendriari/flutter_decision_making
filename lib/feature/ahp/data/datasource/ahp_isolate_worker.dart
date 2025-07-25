import 'dart:isolate';

import 'package:flutter_decision_making/core/decision_making_enums.dart';
import 'package:flutter_decision_making/feature/ahp/domain/entities/ahp_isolated_message.dart';

import 'ahp_calculate_eigen_vector_alternative_isolated.dart';
import 'ahp_calculate_eigen_vector_criteria_isolated.dart';
import 'ahp_check_consistency_ratio_isolated.dart';
import 'ahp_final_score_isolated.dart';
import 'ahp_result_pairwise_matrix_alternative_isolated.dart';
import 'ahp_result_pairwise_matrix_criteria_isolated.dart';

/// AHP ISOLATE WORKER
void ahpIsolateWorker(SendPort mainSendPort) {
  final ReceivePort isolateReceivePort = ReceivePort();
  mainSendPort.send(isolateReceivePort.sendPort);

  isolateReceivePort.listen((message) async {
    if (message is! AhpIsolatedMessage) return;

    try {
      final result = await _handleTask(message.command, message.payload);
      message.replyPort.send(result);
    } catch (e, st) {
      message.replyPort.send('error: $e, stacktrace: $st');
    }
  });
}

Future<dynamic> _handleTask(
    AhpProcessingCommand command, Map<String, dynamic> data) async {
  switch (command) {
    case AhpProcessingCommand.generateResultPairwiseMatrixCriteria:
      return ahpGenerateResultPairwiseMatrixCriteria(data);
    case AhpProcessingCommand.generateResultPairwiseMatrixAlternative:
      return ahpGenerateResultPairwiseMatrixAlternative(data);
    case AhpProcessingCommand.calculateEigenVectorCriteria:
      return ahpCalculateEigenVectorCriteria(data);
    case AhpProcessingCommand.calculateEigenVectorAlternative:
      return ahpCalculateEigenVectorAlternative(data);
    case AhpProcessingCommand.checkConsistencyRatio:
      return ahpCheckConsistencyRatio(data);
    case AhpProcessingCommand.calculateFinalScore:
      return ahpFinalScore(data);
  }
}
