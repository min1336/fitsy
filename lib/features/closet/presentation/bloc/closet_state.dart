import 'package:equatable/equatable.dart';
import 'package:fitsy/features/closet/domain/entities/cloth.dart';

abstract class ClosetState extends Equatable {
  const ClosetState();
  @override
  List<Object?> get props => [];
}

class ClosetInitial extends ClosetState {}

class ClosetLoading extends ClosetState {}

class ClosetLoaded extends ClosetState {
  final List<Cloth> clothes;
  final String? selectedCategory;
  const ClosetLoaded({required this.clothes, this.selectedCategory});
  @override
  List<Object?> get props => [clothes, selectedCategory];
}

class ClosetError extends ClosetState {
  final String message;
  const ClosetError(this.message);
  @override
  List<Object?> get props => [message];
}

class ClothAdding extends ClosetState {}

class ClothAdded extends ClosetState {
  final Cloth cloth;
  const ClothAdded(this.cloth);
  @override
  List<Object?> get props => [cloth];
}
