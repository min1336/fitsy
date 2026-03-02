import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

import 'package:fitsy/features/closet/data/datasources/closet_remote_datasource.dart';
import 'package:fitsy/features/closet/data/repositories/closet_repository_impl.dart';
import 'package:fitsy/features/closet/domain/repositories/closet_repository.dart';
import 'package:fitsy/features/closet/domain/usecases/add_cloth.dart';
import 'package:fitsy/features/closet/domain/usecases/get_clothes.dart';
import 'package:fitsy/features/closet/domain/usecases/update_cloth.dart';
import 'package:fitsy/features/closet/presentation/bloc/closet_bloc.dart';

import 'package:fitsy/features/outfit/data/datasources/outfit_remote_datasource.dart';
import 'package:fitsy/features/outfit/data/repositories/outfit_repository_impl.dart';
import 'package:fitsy/features/outfit/domain/repositories/outfit_repository.dart';
import 'package:fitsy/features/outfit/domain/usecases/get_recommendations.dart';
import 'package:fitsy/features/outfit/domain/usecases/generate_outfit_image.dart';
import 'package:fitsy/features/outfit/presentation/bloc/outfit_bloc.dart';

final sl = GetIt.instance;

void configureDependencies() {
  // Firebase
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => FirebaseFunctions.instanceFor(region: 'asia-northeast3'));

  // Closet
  sl.registerLazySingleton<ClosetRemoteDataSource>(
    () => ClosetRemoteDataSourceImpl(
      firestore: sl(),
      storage: sl(),
    ),
  );
  sl.registerLazySingleton<ClosetRepository>(
    () => ClosetRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetClothes(sl()));
  sl.registerLazySingleton(() => AddCloth(sl()));
  sl.registerLazySingleton(() => UpdateCloth(sl()));
  sl.registerFactory(
    () => ClosetBloc(
      getClothes: sl(),
      addCloth: sl(),
      updateCloth: sl(),
    ),
  );

  // Outfit
  sl.registerLazySingleton<OutfitRemoteDataSource>(
    () => OutfitRemoteDataSourceImpl(
      firestore: sl(),
      functions: sl(),
    ),
  );
  sl.registerLazySingleton<OutfitRepository>(
    () => OutfitRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetRecommendations(sl()));
  sl.registerLazySingleton(() => GenerateOutfitImage(sl()));
  sl.registerFactory(
    () => OutfitBloc(
      getRecommendations: sl(),
      generateOutfitImage: sl(),
    ),
  );
}
