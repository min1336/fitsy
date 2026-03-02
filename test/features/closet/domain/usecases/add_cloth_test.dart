import 'package:dartz/dartz.dart';
import 'package:fitsy/core/error/failures.dart';
import 'package:fitsy/features/closet/domain/entities/cloth.dart';
import 'package:fitsy/features/closet/domain/usecases/add_cloth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock_closet_repository.dart';

void main() {
  late AddCloth usecase;
  late MockClosetRepository mockRepository;

  final tCloth = Cloth(
    id: 'cloth-1',
    imageUrl: 'https://example.com/image.jpg',
    cutoutUrl: 'https://example.com/cutout.jpg',
    category: 'top',
    subcategory: 't-shirt',
    color: ['white'],
    season: ['spring', 'summer'],
    tags: ['casual'],
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockRepository = MockClosetRepository();
    usecase = AddCloth(mockRepository);
  });

  group('AddCloth UseCase', () {
    test('should return Cloth on success', () async {
      // arrange
      mockRepository.addClothResult = Right(tCloth);
      final params = const AddClothParams(
        imagePath: '/path/to/image.jpg',
        userId: 'user-123',
      );

      // act
      final result = await usecase(params);

      // assert
      expect(result, Right(tCloth));
    });

    test('should return ServerFailure on failure', () async {
      // arrange
      mockRepository.addClothResult = const Left(ServerFailure('Upload failed'));
      final params = const AddClothParams(
        imagePath: '/path/to/image.jpg',
        userId: 'user-123',
      );

      // act
      final result = await usecase(params);

      // assert
      expect(result, const Left(ServerFailure('Upload failed')));
    });

    test('should forward imagePath and userId to repository', () async {
      // arrange
      mockRepository.addClothResult = Right(tCloth);
      const params = AddClothParams(
        imagePath: '/path/to/image.jpg',
        userId: 'user-123',
      );

      // act
      await usecase(params);

      // assert
      expect(mockRepository.capturedImagePath, '/path/to/image.jpg');
      expect(mockRepository.capturedUserId, 'user-123');
    });
  });
}
