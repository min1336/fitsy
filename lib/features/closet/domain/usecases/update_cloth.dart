import 'package:dartz/dartz.dart';
import 'package:fitsy/core/error/failures.dart';
import 'package:fitsy/core/usecase/usecase.dart';
import 'package:fitsy/features/closet/domain/entities/cloth.dart';
import 'package:fitsy/features/closet/domain/repositories/closet_repository.dart';

class UpdateCloth extends UseCase<Cloth, UpdateClothParams> {
  final ClosetRepository repository;
  UpdateCloth(this.repository);

  @override
  Future<Either<Failure, Cloth>> call(UpdateClothParams params) {
    return repository.updateCloth(
      userId: params.userId,
      clothId: params.clothId,
      category: params.category,
      subcategory: params.subcategory,
      color: params.color,
      season: params.season,
      tags: params.tags,
      isActive: params.isActive,
    );
  }
}

class UpdateClothParams {
  final String userId;
  final String clothId;
  final String? category;
  final String? subcategory;
  final List<String>? color;
  final List<String>? season;
  final List<String>? tags;
  final bool? isActive;
  const UpdateClothParams({
    required this.userId,
    required this.clothId,
    this.category,
    this.subcategory,
    this.color,
    this.season,
    this.tags,
    this.isActive,
  });
}
