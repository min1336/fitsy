import 'package:dartz/dartz.dart';
import 'package:fitsy/core/error/failures.dart';
import 'package:fitsy/features/outfit/domain/entities/outfit.dart';
import 'package:fitsy/features/outfit/domain/usecases/get_recommendations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock_outfit_repository.dart';

void main() {
  late GetRecommendations usecase;
  late MockOutfitRepository mockRepository;

  final tOutfit = Outfit(
    id: 'outfit-1',
    clothIds: ['cloth-1', 'cloth-2'],
    generatedImageUrl: 'https://example.com/outfit.jpg',
    liked: null,
    prompt: 'casual summer look',
    createdAt: DateTime(2024, 1, 1),
  );

  final tOutfits = [tOutfit];
  const tParams = GetRecommendationsParams(userId: 'user-123');

  setUp(() {
    mockRepository = MockOutfitRepository();
    usecase = GetRecommendations(mockRepository);
  });

  test('should return list of outfits on success', () async {
    // arrange
    mockRepository.getRecommendationsResult = Right(tOutfits);

    // act
    final result = await usecase(tParams);

    // assert
    expect(result, Right(tOutfits));
  });

  test('should return ServerFailure on failure', () async {
    // arrange
    mockRepository.getRecommendationsResult = const Left(ServerFailure());

    // act
    final result = await usecase(tParams);

    // assert
    expect(result, const Left(ServerFailure()));
  });
}
