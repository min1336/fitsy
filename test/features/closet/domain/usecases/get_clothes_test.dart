import 'package:dartz/dartz.dart';
import 'package:fitsy/core/error/failures.dart';
import 'package:fitsy/features/closet/domain/entities/cloth.dart';
import 'package:fitsy/features/closet/domain/usecases/get_clothes.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock_closet_repository.dart';

void main() {
  late GetClothes usecase;
  late MockClosetRepository mockRepository;

  final tClothList = [
    Cloth(
      id: 'cloth-1',
      imageUrl: 'https://example.com/image1.jpg',
      category: 'top',
      subcategory: 't-shirt',
      color: ['white'],
      season: ['spring'],
      tags: ['casual'],
      createdAt: DateTime(2024, 1, 1),
    ),
    Cloth(
      id: 'cloth-2',
      imageUrl: 'https://example.com/image2.jpg',
      category: 'bottom',
      subcategory: 'jeans',
      color: ['blue'],
      season: ['all'],
      tags: ['casual'],
      createdAt: DateTime(2024, 1, 2),
    ),
  ];

  setUp(() {
    mockRepository = MockClosetRepository();
    usecase = GetClothes(mockRepository);
  });

  group('GetClothes UseCase', () {
    test('should return list of Cloth on success', () async {
      // arrange
      mockRepository.getClothesResult = Right(tClothList);
      final params = const GetClothesParams(userId: 'user-123');

      // act
      final result = await usecase(params);

      // assert
      expect(result, Right(tClothList));
    });

    test('should return ServerFailure on failure', () async {
      // arrange
      mockRepository.getClothesResult = const Left(ServerFailure('Fetch failed'));
      final params = const GetClothesParams(userId: 'user-123');

      // act
      final result = await usecase(params);

      // assert
      expect(result, const Left(ServerFailure('Fetch failed')));
    });

    test('should forward userId and category to repository', () async {
      // arrange
      mockRepository.getClothesResult = Right(tClothList);
      const params = GetClothesParams(userId: 'user-123', category: 'top');

      // act
      await usecase(params);

      // assert
      expect(mockRepository.capturedUserId, 'user-123');
      expect(mockRepository.capturedCategory, 'top');
    });

    test('should forward null category when not provided', () async {
      // arrange
      mockRepository.getClothesResult = Right(tClothList);
      const params = GetClothesParams(userId: 'user-123');

      // act
      await usecase(params);

      // assert
      expect(mockRepository.capturedUserId, 'user-123');
      expect(mockRepository.capturedCategory, isNull);
    });
  });
}
