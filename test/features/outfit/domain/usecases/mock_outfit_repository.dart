import 'package:dartz/dartz.dart';
import 'package:fitsy/core/error/failures.dart';
import 'package:fitsy/features/outfit/domain/entities/outfit.dart';
import 'package:fitsy/features/outfit/domain/repositories/outfit_repository.dart';

class MockOutfitRepository implements OutfitRepository {
  Either<Failure, List<Outfit>>? getRecommendationsResult;
  Either<Failure, Outfit>? generateOutfitImageResult;

  @override
  Future<Either<Failure, List<Outfit>>> getRecommendations({required String userId}) async {
    return getRecommendationsResult!;
  }

  @override
  Future<Either<Failure, Outfit>> generateOutfitImage({required String userId, required String outfitId}) async {
    return generateOutfitImageResult!;
  }
}
