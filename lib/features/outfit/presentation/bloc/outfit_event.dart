import 'package:equatable/equatable.dart';

abstract class OutfitEvent extends Equatable {
  const OutfitEvent();
  @override
  List<Object?> get props => [];
}

class LoadRecommendations extends OutfitEvent {
  final String userId;
  const LoadRecommendations({required this.userId});
  @override
  List<Object?> get props => [userId];
}

class GenerateImage extends OutfitEvent {
  final String userId;
  final String outfitId;
  const GenerateImage({required this.userId, required this.outfitId});
  @override
  List<Object?> get props => [userId, outfitId];
}
