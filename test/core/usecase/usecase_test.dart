import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitsy/core/error/failures.dart';
import 'package:fitsy/core/usecase/usecase.dart';

class TestUseCase extends UseCase<String, String> {
  @override
  Future<Either<Failure, String>> call(String params) async {
    return Right('result: $params');
  }
}

class FailingUseCase extends UseCase<String, String> {
  @override
  Future<Either<Failure, String>> call(String params) async {
    return const Left(ServerFailure());
  }
}

class NoParamsUseCase extends UseCase<String, NoParams> {
  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return const Right('no params result');
  }
}

void main() {
  group('UseCase', () {
    test('should return Right with result when successful', () async {
      final useCase = TestUseCase();
      final result = await useCase('input');
      expect(result, const Right('result: input'));
    });

    test('should return Left with Failure when failed', () async {
      final useCase = FailingUseCase();
      final result = await useCase('input');
      expect(result, const Left(ServerFailure()));
    });

    test('should work with NoParams', () async {
      final useCase = NoParamsUseCase();
      final result = await useCase(const NoParams());
      expect(result, const Right('no params result'));
    });
  });

  group('Failure', () {
    test('ServerFailure should have default message', () {
      const failure = ServerFailure();
      expect(failure.message, 'Server error occurred');
    });

    test('ServerFailure should support custom message', () {
      const failure = ServerFailure('custom error');
      expect(failure.message, 'custom error');
    });

    test('different Failures with same message should be equal', () {
      const f1 = ServerFailure('error');
      const f2 = ServerFailure('error');
      expect(f1, equals(f2));
    });

    test('AIClassificationFailure should have default message', () {
      const failure = AIClassificationFailure();
      expect(failure.message, 'AI classification failed');
    });

    test('ImageGenerationFailure should have default message', () {
      const failure = ImageGenerationFailure();
      expect(failure.message, 'Image generation failed');
    });
  });
}
