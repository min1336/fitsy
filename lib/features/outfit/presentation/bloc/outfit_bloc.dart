import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitsy/features/outfit/domain/usecases/get_recommendations.dart';
import 'package:fitsy/features/outfit/domain/usecases/generate_outfit_image.dart';
import 'outfit_event.dart';
import 'outfit_state.dart';

class OutfitBloc extends Bloc<OutfitEvent, OutfitState> {
  final GetRecommendations getRecommendations;
  final GenerateOutfitImage generateOutfitImage;

  OutfitBloc({
    required this.getRecommendations,
    required this.generateOutfitImage,
  }) : super(OutfitInitial()) {
    on<LoadRecommendations>(_onLoadRecommendations);
    on<GenerateImage>(_onGenerateImage);
  }

  Future<void> _onLoadRecommendations(
    LoadRecommendations event,
    Emitter<OutfitState> emit,
  ) async {
    emit(OutfitLoading());
    final result = await getRecommendations(
      GetRecommendationsParams(userId: event.userId),
    );
    result.fold(
      (failure) => emit(OutfitError(failure.message)),
      (outfits) => emit(OutfitLoaded(outfits)),
    );
  }

  Future<void> _onGenerateImage(
    GenerateImage event,
    Emitter<OutfitState> emit,
  ) async {
    emit(OutfitImageGenerating(event.outfitId));
    final result = await generateOutfitImage(
      GenerateOutfitImageParams(userId: event.userId, outfitId: event.outfitId),
    );
    result.fold(
      (failure) => emit(OutfitError(failure.message)),
      (outfit) => emit(OutfitImageGenerated(outfit)),
    );
  }
}
