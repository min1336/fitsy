import 'package:dartz/dartz.dart';
import 'package:fitsy/core/error/failures.dart';
import 'package:fitsy/features/closet/domain/entities/cloth.dart';

abstract class ClosetRepository {
  Future<Either<Failure, Cloth>> addCloth({
    required String imagePath,
    required String userId,
  });

  Future<Either<Failure, List<Cloth>>> getClothes({
    required String userId,
    String? category,
  });

  Future<Either<Failure, Cloth>> updateCloth({
    required String userId,
    required String clothId,
    String? category,
    String? subcategory,
    List<String>? color,
    List<String>? season,
    List<String>? tags,
    bool? isActive,
  });
}
