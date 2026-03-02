import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitsy/core/error/exceptions.dart';
import 'package:fitsy/core/error/failures.dart';
import 'package:fitsy/features/closet/data/datasources/closet_remote_datasource.dart';
import 'package:fitsy/features/closet/data/models/cloth_model.dart';
import 'package:fitsy/features/closet/data/repositories/closet_repository_impl.dart';

class MockClosetRemoteDataSource implements ClosetRemoteDataSource {
  ClothModel? addClothResult;
  Exception? addClothError;

  List<ClothModel>? getClothesResult;
  Exception? getClothesError;

  ClothModel? updateClothResult;
  Exception? updateClothError;

  @override
  Future<ClothModel> addCloth({required String imagePath, required String userId}) async {
    if (addClothError != null) throw addClothError!;
    return addClothResult!;
  }

  @override
  Future<List<ClothModel>> getClothes({required String userId, String? category}) async {
    if (getClothesError != null) throw getClothesError!;
    return getClothesResult!;
  }

  @override
  Future<ClothModel> updateCloth({
    required String userId,
    required String clothId,
    String? category,
    String? subcategory,
    List<String>? color,
    List<String>? season,
    List<String>? tags,
    bool? isActive,
  }) async {
    if (updateClothError != null) throw updateClothError!;
    return updateClothResult!;
  }
}

void main() {
  late ClosetRepositoryImpl repository;
  late MockClosetRemoteDataSource mockDataSource;

  final tClothModel = ClothModel(
    id: 'test-id',
    imageUrl: 'https://example.com/image.jpg',
    category: '상의',
    subcategory: '티셔츠',
    color: ['흰색'],
    season: ['여름'],
    tags: ['캐주얼'],
    createdAt: DateTime(2026, 3, 2),
  );

  setUp(() {
    mockDataSource = MockClosetRemoteDataSource();
    repository = ClosetRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('addCloth', () {
    test('should return Right(Cloth) on success', () async {
      mockDataSource.addClothResult = tClothModel;

      final result = await repository.addCloth(
        imagePath: '/path/to/image.jpg',
        userId: 'user-1',
      );

      expect(result, Right(tClothModel));
    });

    test('should return Left(ServerFailure) on ServerException', () async {
      mockDataSource.addClothError = const ServerException('upload failed');

      final result = await repository.addCloth(
        imagePath: '/path/to/image.jpg',
        userId: 'user-1',
      );

      expect(result, const Left(ServerFailure('upload failed')));
    });
  });

  group('getClothes', () {
    test('should return Right(List<Cloth>) on success', () async {
      mockDataSource.getClothesResult = [tClothModel];

      final result = await repository.getClothes(userId: 'user-1');

      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (clothes) => expect(clothes, [tClothModel]),
      );
    });

    test('should return Left(ServerFailure) on ServerException', () async {
      mockDataSource.getClothesError = const ServerException('fetch failed');

      final result = await repository.getClothes(userId: 'user-1');

      expect(result, const Left(ServerFailure('fetch failed')));
    });
  });

  group('updateCloth', () {
    test('should return Right(Cloth) on success', () async {
      mockDataSource.updateClothResult = tClothModel;

      final result = await repository.updateCloth(
        userId: 'user-1',
        clothId: 'test-id',
        category: '하의',
      );

      expect(result, Right(tClothModel));
    });

    test('should return Left(ServerFailure) on ServerException', () async {
      mockDataSource.updateClothError = const ServerException('update failed');

      final result = await repository.updateCloth(
        userId: 'user-1',
        clothId: 'test-id',
      );

      expect(result, const Left(ServerFailure('update failed')));
    });
  });
}
