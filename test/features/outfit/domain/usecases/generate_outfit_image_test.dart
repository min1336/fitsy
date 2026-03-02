import 'package:dartz/dartz.dart';
import 'package:fitsy/core/error/failures.dart';
import 'package:fitsy/features/outfit/domain/entities/outfit.dart';
import 'package:fitsy/features/outfit/domain/usecases/generate_outfit_image.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock_outfit_repository.dart';

void main() {
  late GenerateOutfitImage usecase;
  late MockOutfitRepository mockRepository;

  final tOutfit = Outfit(
    id: 'outfit-1',
    clothIds: ['cloth-1', 'cloth-2'],
    generatedImageUrl: 'https://example.com/generated.jpg',
    liked: null,
    prompt: 'casual summer look',
    createdAt: DateTime(2024, 1, 1),
  );

  const tParams = GenerateOutfitImageParams(
    userId: 'user-123',
    outfitId: 'outfit-1',
  );

  setUp(() {
    mockRepository = MockOutfitRepository();
    usecase = GenerateOutfitImage(mockRepository);
  });

  test('should return outfit with generated image on success', () async {
    // arrange
    mockRepository.generateOutfitImageResult = Right(tOutfit);

    // act
    final result = await usecase(tParams);

    // assert
    expect(result, Right(tOutfit));
  });

  test('should return ServerFailure on failure', () async {
    // arrange
    mockRepository.generateOutfitImageResult = const Left(ServerFailure());

    // act
    final result = await usecase(tParams);

    // assert
    expect(result, const Left(ServerFailure()));
  });
}
