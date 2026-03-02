import 'package:dartz/dartz.dart';
import 'package:fitsy/core/error/exceptions.dart';
import 'package:fitsy/core/error/failures.dart';
import 'package:fitsy/features/outfit/data/datasources/outfit_remote_datasource.dart';
import 'package:fitsy/features/outfit/data/models/outfit_model.dart';
import 'package:fitsy/features/outfit/data/repositories/outfit_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class MockOutfitRemoteDataSource implements OutfitRemoteDataSource {
  // Control values set per test
  List<OutfitModel>? recommendationsResult;
  OutfitModel? generateResult;
  Exception? throwOnGetRecommendations;
  Exception? throwOnGenerateOutfitImage;

  @override
  Future<List<OutfitModel>> getRecommendations({required String userId}) async {
    if (throwOnGetRecommendations != null) throw throwOnGetRecommendations!;
    return recommendationsResult!;
  }

  @override
  Future<OutfitModel> generateOutfitImage({
    required String userId,
    required String outfitId,
  }) async {
    if (throwOnGenerateOutfitImage != null) throw throwOnGenerateOutfitImage!;
    return generateResult!;
  }
}

void main() {
  late MockOutfitRemoteDataSource mockDataSource;
  late OutfitRepositoryImpl repository;

  final tCreatedAt = DateTime(2024, 1, 15, 10, 0, 0);

  final tOutfitModel = OutfitModel(
    id: 'outfit-1',
    clothIds: ['cloth-1', 'cloth-2'],
    generatedImageUrl: 'https://example.com/image.png',
    prompt: 'casual summer look',
    createdAt: tCreatedAt,
  );

  setUp(() {
    mockDataSource = MockOutfitRemoteDataSource();
    repository = OutfitRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('getRecommendations', () {
    test('returns Right(outfits) on success', () async {
      mockDataSource.recommendationsResult = [tOutfitModel];

      final result = await repository.getRecommendations(userId: 'user-1');

      expect(result, isA<Right>());
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (outfits) {
          expect(outfits.length, 1);
          expect(outfits.first, tOutfitModel);
        },
      );
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      mockDataSource.throwOnGetRecommendations =
          const ServerException('network error');

      final result = await repository.getRecommendations(userId: 'user-1');

      expect(result, isA<Left>());
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'network error');
        },
        (r) => fail('Expected Left but got Right'),
      );
    });

    test('returns empty Right([]) when datasource returns empty list', () async {
      mockDataSource.recommendationsResult = [];

      final result = await repository.getRecommendations(userId: 'user-1');

      expect(result, isA<Right>());
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (outfits) => expect(outfits, isEmpty),
      );
    });
  });

  group('generateOutfitImage', () {
    test('returns Right(outfit) on success', () async {
      mockDataSource.generateResult = tOutfitModel;

      final result = await repository.generateOutfitImage(
        userId: 'user-1',
        outfitId: 'outfit-1',
      );

      expect(result, isA<Right>());
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (outfit) => expect(outfit, tOutfitModel),
      );
    });

    test('returns Left(ImageGenerationFailure) on ServerException', () async {
      mockDataSource.throwOnGenerateOutfitImage =
          const ServerException('generation failed');

      final result = await repository.generateOutfitImage(
        userId: 'user-1',
        outfitId: 'outfit-1',
      );

      expect(result, isA<Left>());
      result.fold(
        (failure) {
          expect(failure, isA<ImageGenerationFailure>());
          expect(failure.message, 'generation failed');
        },
        (r) => fail('Expected Left but got Right'),
      );
    });

    test('ImageGenerationFailure is not a ServerFailure', () async {
      mockDataSource.throwOnGenerateOutfitImage =
          const ServerException('image error');

      final result = await repository.generateOutfitImage(
        userId: 'user-1',
        outfitId: 'outfit-1',
      );

      result.fold(
        (failure) => expect(failure, isNot(isA<ServerFailure>())),
        (r) => fail('Expected Left but got Right'),
      );
    });
  });
}
