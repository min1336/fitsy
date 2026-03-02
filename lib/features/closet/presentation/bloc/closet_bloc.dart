import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitsy/features/closet/domain/usecases/get_clothes.dart';
import 'package:fitsy/features/closet/domain/usecases/add_cloth.dart';
import 'package:fitsy/features/closet/domain/usecases/update_cloth.dart';
import 'closet_event.dart';
import 'closet_state.dart';

class ClosetBloc extends Bloc<ClosetEvent, ClosetState> {
  final GetClothes getClothes;
  final AddCloth addCloth;
  final UpdateCloth updateCloth;

  ClosetBloc({
    required this.getClothes,
    required this.addCloth,
    required this.updateCloth,
  }) : super(ClosetInitial()) {
    on<LoadClothes>(_onLoadClothes);
    on<AddClothEvent>(_onAddCloth);
    on<UpdateClothEvent>(_onUpdateCloth);
  }

  Future<void> _onLoadClothes(
    LoadClothes event,
    Emitter<ClosetState> emit,
  ) async {
    emit(ClosetLoading());
    final result = await getClothes(
      GetClothesParams(userId: event.userId, category: event.category),
    );
    result.fold(
      (failure) => emit(ClosetError(failure.message)),
      (clothes) => emit(ClosetLoaded(clothes: clothes, selectedCategory: event.category)),
    );
  }

  Future<void> _onAddCloth(
    AddClothEvent event,
    Emitter<ClosetState> emit,
  ) async {
    emit(ClothAdding());
    final result = await addCloth(
      AddClothParams(userId: event.userId, imagePath: event.imagePath),
    );
    result.fold(
      (failure) => emit(ClosetError(failure.message)),
      (cloth) => emit(ClothAdded(cloth)),
    );
  }

  Future<void> _onUpdateCloth(
    UpdateClothEvent event,
    Emitter<ClosetState> emit,
  ) async {
    final result = await updateCloth(
      UpdateClothParams(
        userId: event.userId,
        clothId: event.clothId,
        category: event.category,
        tags: event.tags,
        isActive: event.isActive,
      ),
    );
    result.fold(
      (failure) => emit(ClosetError(failure.message)),
      (_) => add(LoadClothes(userId: event.userId)),
    );
  }
}
