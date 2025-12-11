import 'dart:isolate';

import 'package:flutter_decision_making/core/decision_making_enums.dart';

/// Message payload for communication between main isolate and worker isolate.
///
/// This class encapsulates all information needed to execute a decision-making
/// task in a separate isolate and return results to the main isolate.
///
/// **Isolate Communication Pattern:**
///
/// In Dart, isolates don't share memory - they communicate by passing messages.
/// This class serves as the standardized message format for all decision-making
/// operations, ensuring type-safe and structured communication.
///
/// **Message Flow:**
/// ```
/// Main Isolate                    Worker Isolate
///     |                                |
///     |---> DecisionIsolateMessage --->|
///     |     (algorithm, command, data) |
///     |                                |
///     |                           [Process]
///     |                                |
///     |<--- Result via replyPort <-----|
///     |                                |
/// ```
///
/// **Why Isolates?**
///
/// Heavy computational tasks (matrix operations, eigenvector calculations)
/// can block the UI thread. By running these in isolates:
/// - UI remains responsive
/// - Utilizes multiple CPU cores
/// - Prevents app freezing during calculations
///
/// **Architecture:**
///
/// 1. **Main isolate** creates message with task details and reply port
/// 2. **Worker isolate** receives message, processes task
/// 3. **Result** is sent back through the reply port
/// 4. **Main isolate** receives result and continues execution
///
/// **Fields:**
///
/// - [algorithm]: Specifies which decision-making algorithm to use (AHP or SAW)
/// - [command]: The specific operation within that algorithm to execute
/// - [payload]: Input data required for the operation (matrices, vectors, etc.)
/// - [replyPort]: SendPort for the worker to send results back to the main isolate
///
/// **Example Usage:**
/// ```dart
/// // In main isolate
/// final receivePort = ReceivePort();
///
/// final message = DecisionIsolateMessage(
///   algorithm: DecisionAlgorithm.ahp,
///   command: AhpProcessingCommand.calculateEigenVectorCriteria,
///   payload: {
///     'matrix': [
///       [1.0, 3.0, 5.0],
///       [0.33, 1.0, 2.0],
///       [0.2, 0.5, 1.0]
///     ]
///   },
///   replyPort: receivePort.sendPort,
/// );
///
/// // Send to worker isolate
/// workerSendPort.send(message);
///
/// // Wait for result
/// final result = await receivePort.first;
/// print('Eigenvector: $result');
/// ```
///
/// **Supported Algorithms:**
/// - `DecisionAlgorithm.ahp`: Analytic Hierarchy Process
/// - `DecisionAlgorithm.saw`: Simple Additive Weighting
///
/// **AHP Commands:**
/// - `generateInputPairwiseAlternative`: Create comparison templates
/// - `generateResultPairwiseMatrixCriteria`: Build criteria matrix
/// - `generateResultPairwiseMatrixAlternative`: Build alternative matrix
/// - `calculateEigenVectorCriteria`: Compute criteria weights
/// - `calculateEigenVectorAlternative`: Compute alternative priorities
/// - `checkConsistencyRatio`: Validate comparison consistency
/// - `calculateFinalScore`: Compute final decision scores
///
/// **SAW Commands:**
/// - `generateSawMatrix`: Create decision matrix
/// - `normalizeMatrix`: Normalize values for calculation
///
/// **Payload Requirements:**
///
/// The payload map must contain all data required by the specific command.
/// Structure varies by command - refer to individual command documentation
/// for required keys and value types.
///
/// **Error Handling:**
///
/// If the worker encounters an error, it sends back a map with 'error' key:
/// ```dart
/// {
///   'error': 'Error message here',
///   'stack': 'Stack trace here'
/// }
/// ```
///
/// The main isolate should check for this error format and handle appropriately.
///
/// **Performance Considerations:**
///
/// - Message passing has overhead - use isolates for computationally heavy tasks
/// - Small calculations may be faster on main isolate
/// - Threshold typically: matrix size > 80 or criteria count > 25
/// - Serialization cost increases with payload size
///
/// **Thread Safety:**
///
/// This message is immutable by design (all fields are final).
/// Once created, it cannot be modified, ensuring thread-safe communication.
class DecisionIsolateMessage {
  /// The decision-making algorithm to execute.
  ///
  /// Determines which algorithm handler will process this message.
  /// Currently supported: AHP (Analytic Hierarchy Process) and SAW (Simple Additive Weighting).
  final DecisionAlgorithm algorithm;

  /// The specific command/operation to perform within the algorithm.
  ///
  /// Type varies based on [algorithm]:
  /// - For AHP: [AhpProcessingCommand]
  /// - For SAW: [SawProcessingCommand]
  final dynamic command;

  /// Input data required for the operation.
  ///
  /// Structure and required keys depend on the specific [command].
  /// Typically contains matrices, vectors, items, or configuration data.
  ///
  /// Example payloads:
  /// - Matrix calculation: `{'matrix': [[1.0, 2.0], [0.5, 1.0]]}`
  /// - Item processing: `{'items': [...], 'inputs': [...]}`
  final Map<String, dynamic> payload;

  /// Port for sending results back to the main isolate.
  ///
  /// The worker isolate uses this port to send:
  /// - Successful results (the computed data)
  /// - Error responses (map with 'error' and 'stack' keys)
  final SendPort replyPort;

  /// Creates a new decision isolate message.
  ///
  /// All parameters are required to ensure proper message structure
  /// and guarantee that results can be sent back to the caller.
  DecisionIsolateMessage({
    required this.algorithm,
    required this.command,
    required this.payload,
    required this.replyPort,
  });
}
