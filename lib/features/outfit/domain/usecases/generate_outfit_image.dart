import 'package:dartz/dartz.dart';
import 'package:fitsy/core/error/failures.dart';
import 'package:fitsy/core/usecase/usecase.dart';
import 'package:fitsy/features/outfit/domain/entities/outfit.dart';
import 'package:fitsy/features/outfit/domain/repositories/outfit_repository.dart';

class GenerateOutfitImage extends UseCase<Outfit, GenerateOutfitImageParams> {
  final OutfitRepository repository;
  GenerateOutfitImage(this.repository);

  @override
  Future<Either<Failure, Outfit>> call(GenerateOutfitImageParams params) {
    return repository.generateOutfitImage(userId: params.userId, outfitId: params.outfitId);
  }
}

class GenerateOutfitImageParams {
  final String userId;
  final String outfitId;
  const GenerateOutfitImageParams({required this.userId, required this.outfitId});
}
