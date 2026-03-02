import 'package:dartz/dartz.dart';
import 'package:fitsy/core/error/failures.dart';
import 'package:fitsy/features/closet/domain/entities/cloth.dart';
import 'package:fitsy/features/closet/domain/repositories/closet_repository.dart';

class MockClosetRepository implements ClosetRepository {
  Either<Failure, Cloth>? addClothResult;
  Either<Failure, List<Cloth>>? getClothesResult;
  Either<Failure, Cloth>? updateClothResult;

  // Captured call arguments for verification
  String? capturedImagePath;
  String? capturedUserId;
  String? capturedCategory;
  String? capturedClothId;

  @override
  Future<Either<Failure, Cloth>> addCloth({
    required String imagePath,
    required String userId,
  }) async {
    capturedImagePath = imagePath;
    capturedUserId = userId;
    return addClothResult!;
  }

  @override
  Future<Either<Failure, List<Cloth>>> getClothes({
    required String userId,
    String? category,
  }) async {
    capturedUserId = userId;
    capturedCategory = category;
    return getClothesResult!;
  }

  @override
  Future<Either<Failure, Cloth>> updateCloth({
    required String userId,
    required String clothId,
    String? category,
    String? subcategory,
    List<String>? color,
    List<String>? season,
    List<String>? tags,
    bool? isActive,
  }) async {
    capturedUserId = userId;
    capturedClothId = clothId;
    capturedCategory = category;
    return updateClothResult!;
  }
}
