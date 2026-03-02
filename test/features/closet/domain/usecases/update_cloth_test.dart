import 'package:dartz/dartz.dart';
import 'package:fitsy/core/error/failures.dart';
import 'package:fitsy/features/closet/domain/entities/cloth.dart';
import 'package:fitsy/features/closet/domain/usecases/update_cloth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock_closet_repository.dart';

void main() {
  late UpdateCloth usecase;
  late MockClosetRepository mockRepository;

  final tUpdatedCloth = Cloth(
    id: 'cloth-1',
    imageUrl: 'https://example.com/image.jpg',
    category: 'bottom',
    subcategory: 'jeans',
    color: ['blue'],
    season: ['all'],
    tags: ['casual', 'denim'],
    createdAt: DateTime(2024, 1, 1),
    isActive: true,
  );

  setUp(() {
    mockRepository = MockClosetRepository();
    usecase = UpdateCloth(mockRepository);
  });

  group('UpdateCloth UseCase', () {
    test('should return updated Cloth on success', () async {
      // arrange
      mockRepository.updateClothResult = Right(tUpdatedCloth);
      const params = UpdateClothParams(
        userId: 'user-123',
        clothId: 'cloth-1',
        category: 'bottom',
        subcategory: 'jeans',
        color: ['blue'],
        season: ['all'],
        tags: ['casual', 'denim'],
        isActive: true,
      );

      // act
      final result = await usecase(params);

      // assert
      expect(result, Right(tUpdatedCloth));
    });

    test('should return ServerFailure on failure', () async {
      // arrange
      mockRepository.updateClothResult = const Left(ServerFailure('Update failed'));
      const params = UpdateClothParams(
        userId: 'user-123',
        clothId: 'cloth-1',
      );

      // act
      final result = await usecase(params);

      // assert
      expect(result, const Left(ServerFailure('Update failed')));
    });

    test('should forward userId and clothId to repository', () async {
      // arrange
      mockRepository.updateClothResult = Right(tUpdatedCloth);
      const params = UpdateClothParams(
        userId: 'user-123',
        clothId: 'cloth-1',
        category: 'top',
      );

      // act
      await usecase(params);

      // assert
      expect(mockRepository.capturedUserId, 'user-123');
      expect(mockRepository.capturedClothId, 'cloth-1');
      expect(mockRepository.capturedCategory, 'top');
    });

    test('should allow partial updates with only required params', () async {
      // arrange
      mockRepository.updateClothResult = Right(tUpdatedCloth);
      const params = UpdateClothParams(
        userId: 'user-123',
        clothId: 'cloth-1',
      );

      // act
      final result = await usecase(params);

      // assert
      expect(result, Right(tUpdatedCloth));
      expect(mockRepository.capturedUserId, 'user-123');
      expect(mockRepository.capturedClothId, 'cloth-1');
    });
  });
}
