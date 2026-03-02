import 'package:dartz/dartz.dart';
import 'package:fitsy/core/error/exceptions.dart';
import 'package:fitsy/core/error/failures.dart';
import 'package:fitsy/features/outfit/data/datasources/outfit_remote_datasource.dart';
import 'package:fitsy/features/outfit/domain/entities/outfit.dart';
import 'package:fitsy/features/outfit/domain/repositories/outfit_repository.dart';

class OutfitRepositoryImpl implements OutfitRepository {
  final OutfitRemoteDataSource remoteDataSource;

  OutfitRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Outfit>>> getRecommendations({
    required String userId,
  }) async {
    try {
      final outfits =
          await remoteDataSource.getRecommendations(userId: userId);
      return Right(outfits);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Outfit>> generateOutfitImage({
    required String userId,
    required String outfitId,
  }) async {
    try {
      final outfit = await remoteDataSource.generateOutfitImage(
        userId: userId,
        outfitId: outfitId,
      );
      return Right(outfit);
    } on ServerException catch (e) {
      return Left(ImageGenerationFailure(e.message));
    }
  }
}
