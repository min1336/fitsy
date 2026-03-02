import 'package:dartz/dartz.dart';
import 'package:fitsy/core/error/failures.dart';
import 'package:fitsy/core/usecase/usecase.dart';
import 'package:fitsy/features/closet/domain/entities/cloth.dart';
import 'package:fitsy/features/closet/domain/repositories/closet_repository.dart';

class GetClothes extends UseCase<List<Cloth>, GetClothesParams> {
  final ClosetRepository repository;
  GetClothes(this.repository);

  @override
  Future<Either<Failure, List<Cloth>>> call(GetClothesParams params) {
    return repository.getClothes(userId: params.userId, category: params.category);
  }
}

class GetClothesParams {
  final String userId;
  final String? category;
  const GetClothesParams({required this.userId, this.category});
}
