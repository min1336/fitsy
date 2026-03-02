import 'package:equatable/equatable.dart';
import 'package:fitsy/features/outfit/domain/entities/outfit.dart';

abstract class OutfitState extends Equatable {
  const OutfitState();
  @override
  List<Object?> get props => [];
}

class OutfitInitial extends OutfitState {}

class OutfitLoading extends OutfitState {}

class OutfitLoaded extends OutfitState {
  final List<Outfit> outfits;
  const OutfitLoaded(this.outfits);
  @override
  List<Object?> get props => [outfits];
}

class OutfitError extends OutfitState {
  final String message;
  const OutfitError(this.message);
  @override
  List<Object?> get props => [message];
}

class OutfitImageGenerating extends OutfitState {
  final String outfitId;
  const OutfitImageGenerating(this.outfitId);
  @override
  List<Object?> get props => [outfitId];
}

class OutfitImageGenerated extends OutfitState {
  final Outfit outfit;
  const OutfitImageGenerated(this.outfit);
  @override
  List<Object?> get props => [outfit];
}
