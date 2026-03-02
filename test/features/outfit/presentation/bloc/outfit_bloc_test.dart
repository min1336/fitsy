import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:fitsy/core/error/failures.dart';
import 'package:fitsy/features/outfit/domain/entities/outfit.dart';
import 'package:fitsy/features/outfit/domain/repositories/outfit_repository.dart';
import 'package:fitsy/features/outfit/domain/usecases/generate_outfit_image.dart';
import 'package:fitsy/features/outfit/domain/usecases/get_recommendations.dart';
import 'package:fitsy/features/outfit/presentation/bloc/outfit_bloc.dart';
import 'package:fitsy/features/outfit/presentation/bloc/outfit_event.dart';
import 'package:fitsy/features/outfit/presentation/bloc/outfit_state.dart';
import 'package:flutter_test/flutter_test.dart';

class MockOutfitRepo implements OutfitRepository {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class MockGetRecommendations extends GetRecommendations {
  Either<Failure, List<Outfit>>? result;
  MockGetRecommendations() : super(MockOutfitRepo());

  @override
  Future<Either<Failure, List<Outfit>>> call(
    GetRecommendationsParams params,
  ) async => result!;
}

class MockGenerateOutfitImage extends GenerateOutfitImage {
  Either<Failure, Outfit>? result;
  MockGenerateOutfitImage() : super(MockOutfitRepo());

  @override
  Future<Either<Failure, Outfit>> call(
    GenerateOutfitImageParams params,
  ) async => result!;
}

void main() {
  late MockGetRecommendations mockGetRecommendations;
  late MockGenerateOutfitImage mockGenerateOutfitImage;

  final tOutfit = Outfit(
    id: 'outfit-1',
    clothIds: ['cloth-1', 'cloth-2'],
    prompt: 'Casual summer look',
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockGetRecommendations = MockGetRecommendations();
    mockGenerateOutfitImage = MockGenerateOutfitImage();
  });

  OutfitBloc buildBloc() => OutfitBloc(
        getRecommendations: mockGetRecommendations,
        generateOutfitImage: mockGenerateOutfitImage,
      );

  group('LoadRecommendations', () {
    blocTest<OutfitBloc, OutfitState>(
      'emits [OutfitLoading, OutfitLoaded] on success',
      setUp: () {
        mockGetRecommendations.result = Right([tOutfit]);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadRecommendations(userId: 'user-1')),
      expect: () => [
        OutfitLoading(),
        OutfitLoaded([tOutfit]),
      ],
    );

    blocTest<OutfitBloc, OutfitState>(
      'emits [OutfitLoading, OutfitError] on failure',
      setUp: () {
        mockGetRecommendations.result =
            Left(ServerFailure('Server error occurred'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadRecommendations(userId: 'user-1')),
      expect: () => [
        OutfitLoading(),
        const OutfitError('Server error occurred'),
      ],
    );
  });

  group('GenerateImage', () {
    blocTest<OutfitBloc, OutfitState>(
      'emits [OutfitImageGenerating, OutfitImageGenerated] on success',
      setUp: () {
        mockGenerateOutfitImage.result = Right(tOutfit);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const GenerateImage(userId: 'user-1', outfitId: 'outfit-1'),
      ),
      expect: () => [
        const OutfitImageGenerating('outfit-1'),
        OutfitImageGenerated(tOutfit),
      ],
    );

    blocTest<OutfitBloc, OutfitState>(
      'emits [OutfitImageGenerating, OutfitError] on failure',
      setUp: () {
        mockGenerateOutfitImage.result =
            Left(ImageGenerationFailure('Image generation failed'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const GenerateImage(userId: 'user-1', outfitId: 'outfit-1'),
      ),
      expect: () => [
        const OutfitImageGenerating('outfit-1'),
        const OutfitError('Image generation failed'),
      ],
    );
  });
}
