import 'package:dartz/dartz.dart';
import 'package:fitsy/core/error/failures.dart';
import 'package:fitsy/core/usecase/usecase.dart';
import 'package:fitsy/features/closet/domain/entities/cloth.dart';
import 'package:fitsy/features/closet/domain/repositories/closet_repository.dart';

class AddCloth extends UseCase<Cloth, AddClothParams> {
  final ClosetRepository repository;
  AddCloth(this.repository);

  @override
  Future<Either<Failure, Cloth>> call(AddClothParams params) {
    return repository.addCloth(imagePath: params.imagePath, userId: params.userId);
  }
}

class AddClothParams {
  final String imagePath;
  final String userId;
  const AddClothParams({required this.imagePath, required this.userId});
}
