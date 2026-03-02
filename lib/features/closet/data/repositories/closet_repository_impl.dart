import 'package:dartz/dartz.dart';
import 'package:fitsy/core/error/exceptions.dart';
import 'package:fitsy/core/error/failures.dart';
import 'package:fitsy/features/closet/data/datasources/closet_remote_datasource.dart';
import 'package:fitsy/features/closet/domain/entities/cloth.dart';
import 'package:fitsy/features/closet/domain/repositories/closet_repository.dart';

class ClosetRepositoryImpl implements ClosetRepository {
  final ClosetRemoteDataSource remoteDataSource;

  ClosetRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Cloth>> addCloth({
    required String imagePath,
    required String userId,
  }) async {
    try {
      final cloth = await remoteDataSource.addCloth(imagePath: imagePath, userId: userId);
      return Right(cloth);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Cloth>>> getClothes({
    required String userId,
    String? category,
  }) async {
    try {
      final clothes = await remoteDataSource.getClothes(userId: userId, category: category);
      return Right(clothes);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
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
    try {
      final cloth = await remoteDataSource.updateCloth(
        userId: userId,
        clothId: clothId,
        category: category,
        subcategory: subcategory,
        color: color,
        season: season,
        tags: tags,
        isActive: isActive,
      );
      return Right(cloth);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
