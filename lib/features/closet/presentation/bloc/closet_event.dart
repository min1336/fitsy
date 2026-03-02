import 'package:equatable/equatable.dart';

abstract class ClosetEvent extends Equatable {
  const ClosetEvent();
  @override
  List<Object?> get props => [];
}

class LoadClothes extends ClosetEvent {
  final String userId;
  final String? category;
  const LoadClothes({required this.userId, this.category});
  @override
  List<Object?> get props => [userId, category];
}

class AddClothEvent extends ClosetEvent {
  final String userId;
  final String imagePath;
  const AddClothEvent({required this.userId, required this.imagePath});
  @override
  List<Object?> get props => [userId, imagePath];
}

class UpdateClothEvent extends ClosetEvent {
  final String userId;
  final String clothId;
  final String? category;
  final List<String>? tags;
  final bool? isActive;
  const UpdateClothEvent({
    required this.userId,
    required this.clothId,
    this.category,
    this.tags,
    this.isActive,
  });
  @override
  List<Object?> get props => [userId, clothId, category, tags, isActive];
}
