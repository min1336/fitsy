import 'package:dartz/dartz.dart';
import 'package:fitsy/core/error/failures.dart';
import 'package:fitsy/features/outfit/domain/entities/outfit.dart';

abstract class OutfitRepository {
  Future<Either<Failure, List<Outfit>>> getRecommendations({
    required String userId,
  });

  Future<Either<Failure, Outfit>> generateOutfitImage({
    required String userId,
    required String outfitId,
  });
}
