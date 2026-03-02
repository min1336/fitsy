import 'package:dartz/dartz.dart';
import 'package:fitsy/core/error/failures.dart';
import 'package:fitsy/core/usecase/usecase.dart';
import 'package:fitsy/features/outfit/domain/entities/outfit.dart';
import 'package:fitsy/features/outfit/domain/repositories/outfit_repository.dart';

class GetRecommendations extends UseCase<List<Outfit>, GetRecommendationsParams> {
  final OutfitRepository repository;
  GetRecommendations(this.repository);

  @override
  Future<Either<Failure, List<Outfit>>> call(GetRecommendationsParams params) {
    return repository.getRecommendations(userId: params.userId);
  }
}

class GetRecommendationsParams {
  final String userId;
  const GetRecommendationsParams({required this.userId});
}
