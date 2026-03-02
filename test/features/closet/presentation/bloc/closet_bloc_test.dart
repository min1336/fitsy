import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitsy/core/error/failures.dart';
import 'package:fitsy/features/closet/domain/entities/cloth.dart';
import 'package:fitsy/features/closet/domain/repositories/closet_repository.dart';
import 'package:fitsy/features/closet/domain/usecases/get_clothes.dart';
import 'package:fitsy/features/closet/domain/usecases/add_cloth.dart';
import 'package:fitsy/features/closet/domain/usecases/update_cloth.dart';
import 'package:fitsy/features/closet/presentation/bloc/closet_bloc.dart';
import 'package:fitsy/features/closet/presentation/bloc/closet_event.dart';
import 'package:fitsy/features/closet/presentation/bloc/closet_state.dart';

// Dummy repository that throws for any unimplemented call
class MockClosetRepo implements ClosetRepository {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

// Manual mock use cases
class MockGetClothes extends GetClothes {
  Either<Failure, List<Cloth>>? result;
  MockGetClothes() : super(MockClosetRepo());

  @override
  Future<Either<Failure, List<Cloth>>> call(GetClothesParams params) async =>
      result!;
}

class MockAddCloth extends AddCloth {
  Either<Failure, Cloth>? result;
  MockAddCloth() : super(MockClosetRepo());

  @override
  Future<Either<Failure, Cloth>> call(AddClothParams params) async => result!;
}

class MockUpdateCloth extends UpdateCloth {
  Either<Failure, Cloth>? result;
  MockUpdateCloth() : super(MockClosetRepo());

  @override
  Future<Either<Failure, Cloth>> call(UpdateClothParams params) async =>
      result!;
}

// Helper fixture
Cloth _makeCloth({String id = 'c1'}) => Cloth(
      id: id,
      imageUrl: 'https://example.com/image.jpg',
      category: '상의',
      subcategory: '티셔츠',
      color: const ['white'],
      season: const ['spring'],
      tags: const [],
      createdAt: DateTime(2024),
    );

void main() {
  late MockGetClothes mockGetClothes;
  late MockAddCloth mockAddCloth;
  late MockUpdateCloth mockUpdateCloth;

  setUp(() {
    mockGetClothes = MockGetClothes();
    mockAddCloth = MockAddCloth();
    mockUpdateCloth = MockUpdateCloth();
  });

  ClosetBloc buildBloc() => ClosetBloc(
        getClothes: mockGetClothes,
        addCloth: mockAddCloth,
        updateCloth: mockUpdateCloth,
      );

  group('LoadClothes', () {
    blocTest<ClosetBloc, ClosetState>(
      'emits [ClosetLoading, ClosetLoaded] on success',
      setUp: () {
        mockGetClothes.result = Right([_makeCloth()]);
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadClothes(userId: 'u1')),
      expect: () => [
        isA<ClosetLoading>(),
        isA<ClosetLoaded>().having(
          (s) => s.clothes.length,
          'clothes count',
          1,
        ),
      ],
    );

    blocTest<ClosetBloc, ClosetState>(
      'emits [ClosetLoading, ClosetError] on failure',
      setUp: () {
        mockGetClothes.result = const Left(ServerFailure('load error'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadClothes(userId: 'u1')),
      expect: () => [
        isA<ClosetLoading>(),
        isA<ClosetError>().having((s) => s.message, 'message', 'load error'),
      ],
    );
  });

  group('AddClothEvent', () {
    blocTest<ClosetBloc, ClosetState>(
      'emits [ClothAdding, ClothAdded] on success',
      setUp: () {
        mockAddCloth.result = Right(_makeCloth());
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const AddClothEvent(userId: 'u1', imagePath: '/tmp/img.jpg'),
      ),
      expect: () => [
        isA<ClothAdding>(),
        isA<ClothAdded>().having((s) => s.cloth.id, 'cloth.id', 'c1'),
      ],
    );

    blocTest<ClosetBloc, ClosetState>(
      'emits [ClothAdding, ClosetError] on failure',
      setUp: () {
        mockAddCloth.result = const Left(ServerFailure('add error'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const AddClothEvent(userId: 'u1', imagePath: '/tmp/img.jpg'),
      ),
      expect: () => [
        isA<ClothAdding>(),
        isA<ClosetError>().having((s) => s.message, 'message', 'add error'),
      ],
    );
  });
}
