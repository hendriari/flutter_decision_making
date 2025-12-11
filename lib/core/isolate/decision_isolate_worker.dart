import 'dart:isolate';

import 'package:flutter_decision_making/core/decision_making_enums.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_calculate_eigen_vector_alternative_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_calculate_eigen_vector_criteria_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_check_consistency_ratio_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_final_score_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_input_pairwise_matrix_alternative_with_compute.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_result_pairwise_matrix_alternative_isolated.dart';
import 'package:flutter_decision_making/feature/ahp/data/datasource/ahp_result_pairwise_matrix_criteria_isolated.dart';
import 'package:flutter_decision_making/feature/saw/data/datasource/generate_saw_matrix_isolate.dart';
import 'package:flutter_decision_making/feature/saw/data/datasource/normalize_saw_matrix_isolate.dart';

import 'decision_isolate_message.dart';

/// Entry point for the decision-making worker isolate.
///
/// This function runs in a separate isolate (background thread) to handle
/// computationally intensive decision-making operations without blocking
/// the UI thread.
///
/// **Isolate Architecture:**
///
/// ```
/// Main Thread                Worker Isolate (this function)
/// ===========                ================================
///
/// App UI ◄───────────┐
///    │               │
///    ├─ User Action  │
///    │               │
///    ├─ Create Task ─┼────► Receive Message
///    │               │           │
///    ├─ Send Msg ────┼────►  Identify Algorithm
///    │               │           │
///    │               │      Route to Handler
///    │               │           │
///    │               │      Execute Operation
///    │               │           │
///    │               │      Compute Result
///    │               │           │
///    ◄─ Get Result ──┼──────  Send Back
///    │               │
///    └─ Update UI    │
/// ```
///
/// **Lifecycle:**
///
/// 1. **Spawn**: Main isolate calls `Isolate.spawn(decisionIsolateWorker, ...)`
/// 2. **Handshake**: Worker sends its SendPort to main isolate
/// 3. **Listen**: Worker continuously listens for incoming messages
/// 4. **Process**: For each message, execute requested operation
/// 5. **Reply**: Send result back via message's reply port
/// 6. **Repeat**: Continue listening until isolate is killed
///
/// **Message Flow:**
///
/// Main Isolate sends [DecisionIsolateMessage] containing:
/// - Algorithm type (AHP or SAW)
/// - Command (specific operation)
/// - Payload (input data)
/// - Reply port (for sending results back)
///
/// Worker receives, processes, and replies with either:
/// - Success: The computed result
/// - Error: Map with 'error' and 'stack' keys
///
/// **Parameters:**
/// - [mainSendPort]: The SendPort of the main isolate, used to establish
///                   bidirectional communication by sending back this
///                   isolate's ReceivePort.sendPort
///
/// **Communication Setup:**
/// ```dart
/// // In main isolate:
/// final receivePort = ReceivePort();
/// final isolate = await Isolate.spawn(
///   decisionIsolateWorker,
///   receivePort.sendPort,  // ← This is mainSendPort
/// );
/// final workerSendPort = await receivePort.first;
///
/// // Now both sides can communicate:
/// // Main → Worker: workerSendPort.send(message)
/// // Worker → Main: message.replyPort.send(result)
/// ```
///
/// **Supported Operations:**
///
/// **AHP (Analytic Hierarchy Process):**
/// - Matrix generation (criteria & alternatives)
/// - Eigenvector calculation (priority weights)
/// - Consistency ratio checking
/// - Final score computation
///
/// **SAW (Simple Additive Weighting):**
/// - Decision matrix generation
/// - Matrix normalization
///
/// **Error Handling:**
///
/// All operations are wrapped in try-catch. Errors are serialized
/// and sent back as a map to prevent isolate crashes:
/// ```dart
/// {
///   'error': exception.toString(),
///   'stack': stackTrace.toString()
/// }
/// ```
///
/// The main isolate can detect errors by checking if the result
/// is a Map with an 'error' key.
///
/// **Performance Benefits:**
///
/// By running in a separate isolate:
/// - **UI Responsiveness**: Main thread remains free for user interactions
/// - **Parallel Processing**: Utilizes multiple CPU cores
/// - **No Jank**: Heavy computations don't cause frame drops
/// - **Scalability**: Can spawn multiple isolates for concurrent tasks
///
/// **When to Use:**
///
/// Isolates are beneficial for:
/// - Matrix operations with size > 80×80
/// - Criteria/alternative counts > 25
/// - Operations taking > 16ms (one frame at 60fps)
/// - Batch processing multiple decisions
///
/// For smaller datasets, direct execution on main thread may be faster
/// due to message passing overhead.
///
/// **Example Usage:**
/// ```dart
/// // This function is called automatically by DecisionIsolateMain
/// // You don't call it directly. Instead:
///
/// final isolateManager = DecisionIsolateMain();
///
/// final result = await isolateManager.runTask(
///   DecisionAlgorithm.ahp,
///   AhpProcessingCommand.calculateEigenVectorCriteria,
///   {'matrix': myMatrix},
/// );
/// ```
///
/// **Thread Safety:**
///
/// Each isolate has its own memory heap. No shared state means:
/// - No race conditions
/// - No locks needed within worker
/// - All data must be serializable for message passing
///
/// **Limitations:**
///
/// - Cannot access Flutter UI directly
/// - Cannot share objects with main isolate (must copy)
/// - All data must be primitive types or serializable
/// - Limited to compute operations only
void decisionIsolateWorker(SendPort mainSendPort) {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  receivePort.listen((message) async {
    if (message is! DecisionIsolateMessage) return;

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

/// Routes incoming task to the appropriate algorithm handler.
///
/// This is the main dispatcher that determines which algorithm-specific
/// handler should process the task based on the algorithm type.
///
/// **Routing Logic:**
/// - `DecisionAlgorithm.ahp` → `_handleAhpTask()`
/// - `DecisionAlgorithm.saw` → `_handleSawTask()`
///
/// **Parameters:**
/// - [algorithm]: The decision-making algorithm to use
/// - [command]: Specific operation within the algorithm
/// - [data]: Input data payload for the operation
///
/// **Returns:**
/// The computed result from the algorithm-specific handler.
///
/// **Throws:**
/// Any exception from the underlying algorithm handler is propagated
/// to the caller for error handling.
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

/// Handles all AHP (Analytic Hierarchy Process) operations.
///
/// Routes the command to the specific AHP operation function.
/// Each command corresponds to a step in the AHP methodology.
///
/// **AHP Process Flow:**
///
/// 1. **generateInputPairwiseAlternative**: Create comparison templates
///    - Input: Hierarchy structure
///    - Output: Pairwise comparison templates for user to fill
///
/// 2. **generateResultPairwiseMatrixCriteria**: Build criteria matrix
///    - Input: User-filled criteria comparisons
///    - Output: Square pairwise comparison matrix for criteria
///
/// 3. **generateResultPairwiseMatrixAlternative**: Build alternative matrices
///    - Input: User-filled alternative comparisons per criterion
///    - Output: Square matrices for alternatives under each criterion
///
/// 4. **calculateEigenVectorCriteria**: Compute criteria weights
///    - Input: Criteria pairwise matrix
///    - Output: Priority vector (relative weights) for criteria
///
/// 5. **calculateEigenVectorAlternative**: Compute alternative priorities
///    - Input: Alternative pairwise matrix
///    - Output: Priority vector for alternatives under one criterion
///
/// 6. **checkConsistencyRatio**: Validate comparison consistency
///    - Input: Pairwise matrix and priority vector
///    - Output: Consistency ratio (should be ≤ 0.1)
///
/// 7. **calculateFinalScore**: Compute final decision scores
///    - Input: All priority vectors and consistency data
///    - Output: Final scores and rankings for alternatives
///
/// **Parameters:**
/// - [command]: Specific AHP operation to perform
/// - [data]: Input data required for that operation
///
/// **Returns:**
/// Result specific to the command (matrix, vector, ratio, or scores).
///
/// **Example Commands:**
/// ```dart
/// // Calculate criteria priorities
/// await _handleAhpTask(
///   AhpProcessingCommand.calculateEigenVectorCriteria,
///   {'matrix': criteriaMatrix}
/// );
///
/// // Check consistency
/// await _handleAhpTask(
///   AhpProcessingCommand.checkConsistencyRatio,
///   {
///     'matrix': matrix,
///     'priority_vector': priorities,
///     'source': 'criteria'
///   }
/// );
/// ```
Future<dynamic> _handleAhpTask(
  AhpProcessingCommand command,
  Map<String, dynamic> data,
) async {
  switch (command) {
    case AhpProcessingCommand.generateInputPairwiseAlternative:
      return generateInputPairwiseAlternative(data);
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

/// Handles all SAW (Simple Additive Weighting) operations.
///
/// Routes the command to the specific SAW operation function.
/// SAW is simpler than AHP with fewer processing steps.
///
/// **SAW Process Flow:**
///
/// 1. **generateSawMatrix**: Create decision matrix
///    - Input: List of alternatives and criteria
///    - Output: Matrix where each cell = alternative's value for a criterion
///    - Each row = one alternative
///    - Each column = one criterion
///
/// 2. **normalizeMatrix**: Normalize values to comparable scale
///    - Input: Raw decision matrix with different scales
///    - Output: Normalized matrix with values 0-1
///    - Benefit criteria: normalized = value / max
///    - Cost criteria: normalized = min / value
///
/// After normalization, the main isolate calculates weighted sums
/// and ranks alternatives (this happens outside the worker).
///
/// **Parameters:**
/// - [command]: Specific SAW operation to perform
/// - [data]: Input data required for that operation
///
/// **Returns:**
/// Result specific to the command (matrix or normalized matrix).
///
/// **Example Commands:**
/// ```dart
/// // Generate decision matrix
/// await _handleSawTask(
///   SawProcessingCommand.generateSawMatrix,
///   {
///     'list_criteria': [...],
///     'list_alternative': [...]
///   }
/// );
///
/// // Normalize the matrix
/// await _handleSawTask(
///   SawProcessingCommand.normalizeMatrix,
///   {'matrix': rawMatrix}
/// );
/// ```
///
/// **When SAW Uses Isolates:**
///
/// SAW tasks are routed to isolates when:
/// - Alternative count > 80
/// - Criteria count > 25
/// - Platform is not web (web doesn't support isolates efficiently)
///
/// For smaller datasets, SAW operations run on the main thread.
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
