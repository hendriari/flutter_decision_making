import 'dart:isolate';

import 'package:flutter_decision_making/core/decision_making_enums.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_calculate_eigen_vector_alternative_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_calculate_eigen_vector_criteria_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_check_consistency_ratio_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_final_score_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_result_pairwise_matrix_alternative_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_result_pairwise_matrix_criteria_isolated.dart';
import 'package:flutter_decision_making/feature/saw/data/datasource/generate_saw_matrix_isolate.dart';
import 'package:flutter_decision_making/feature/saw/data/datasource/normalize_saw_matrix_isolate.dart';

import 'decision_isolated_message.dart';

void decisionIsolateWorker(SendPort mainSendPort) {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  receivePort.listen((message) async {
    if (message is! DecisionIsolatedMessage) return;

    try {
      final result = await _handleDecisionTask(
        message.algorithm,
        message.command,
        message.payload,
      );
      message.replyPort.send(result);
    } catch (e, st) {
      message.replyPort.send({'error': e.toString(), 'stack': st.toString()});
    }
  });
}

Future<dynamic> _handleDecisionTask(
  DecisionAlgorithm algorithm,
  dynamic command,
  Map<String, dynamic> data,
) async {
  switch (algorithm) {
    case DecisionAlgorithm.ahp:
      return _handleAhpTask(command as AhpProcessingCommand, data);
    case DecisionAlgorithm.saw:
      return _handleSawTask(command as SawProcessingCommand, data);
  }
}

Future<dynamic> _handleAhpTask(
  AhpProcessingCommand command,
  Map<String, dynamic> data,
) async {
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

Future<dynamic> _handleSawTask(
  SawProcessingCommand command,
  Map<String, dynamic> data,
) async {
  switch (command) {
    case SawProcessingCommand.generateSawMatrix:
      return generateSawMatrixIsolate(data: data);
    case SawProcessingCommand.normalizeMatrix:
      return normalizeSawMatrixIsolate(data: data);
  }
}
