import 'package:flutter_decision_making/feature/saw/data/datasource/saw_local_datasource.dart';
import 'package:flutter_decision_making/feature/saw/data/repository_impl/saw_repository_impl.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_alternative.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_criteria.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_matrix.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_rating.dart';
import 'package:flutter_decision_making/feature/saw/domain/entities/saw_result.dart';
import 'package:flutter_decision_making/feature/saw/domain/repository/saw_repository.dart';
import 'package:flutter_decision_making/feature/saw/domain/usecase/saw_calculate_result_usecase.dart';
import 'package:flutter_decision_making/feature/saw/domain/usecase/saw_calculate_result_with_existing_matrix_usecase.dart';
import 'package:flutter_decision_making/feature/saw/domain/usecase/saw_generate_pairwise_matrix_usecase.dart';

export 'saw_utils.dart';

class SAW {
  final SawRepository _sawRepository;

  SAW() : _sawRepository = SawRepositoryImpl(SawLocalDatasourceImpl());

  /// GENERATE SAW MATRIX
  Future<List<SawMatrix>> generateSawMatrix({
    required List<SawAlternative> listAlternative,
    required List<SawCriteria> listCriteria,
  }) async {
    try {
      final matrixUsecase = SawGenerateMatrixUsecase(_sawRepository);

      final result = await matrixUsecase.execute(
        listAlternative: listAlternative,
        listCriteria: listCriteria,
      );

      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// UPDATE SAW MATRIX
  Future<List<SawMatrix>> updateSawMatrix({
    required List<SawMatrix> currentMatrix,
    required String? matrixId,
    required String? ratingsId,
    required num value,
  }) async {
    var updatedList = List<SawMatrix>.from(currentMatrix);

    final matrixIndex = updatedList.indexWhere((m) => m.id == matrixId);
    if (matrixIndex == -1) {
      throw Exception("Matrix not found!");
    }

    final matrix = updatedList[matrixIndex];

    final ratingIndex = matrix.ratings.indexWhere((r) => r.id == ratingsId);
    if (ratingIndex == -1) {
      throw Exception("Rating not found!");
    }

    var updatedRatings = List<SawRating>.from(matrix.ratings);
    updatedRatings[ratingIndex] =
        updatedRatings[ratingIndex].copyWith(value: value);

    updatedList[matrixIndex] = matrix.copyWith(ratings: updatedRatings);

    return updatedList;
  }

  /// CALCULATE SAW RESULT
  Future<List<SawResult>> calculateSawResult({
    required List<SawMatrix> matrix,
  }) async {
    try {
      final usecase = SawCalculateResultUsecase(_sawRepository);

      final result = await usecase.execute(matrix: matrix);

      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// CALCULATE RESULT WITH EXISTING MATRIX
  Future<List<SawResult>> calculateResultWithExistingMatrix({
    required List<SawMatrix> sawMatrix,
  }) async {
    try {
      final usecase =
          SawCalculateResultWithExistingMatrixUsecase(_sawRepository);

      final result = await usecase.execute(sawMatrix: sawMatrix);

      return result;
    } catch (e) {
      rethrow;
    }
  }
}
