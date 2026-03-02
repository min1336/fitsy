# Fitsy Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Flutter + Firebase 기반 AI 옷장 앱 MVP를 DDD + Clean Architecture + TDD로 구현한다.

**Architecture:** Flutter 앱은 features/ 단위로 도메인을 분리하고 domain → data → presentation 3계층 구조를 따른다. 백엔드는 Firebase(Firestore, Storage, Cloud Functions)를 사용하며, Cloud Functions에서 Gemini API를 호출하여 옷 분류, 코디 추천, 이미지 생성을 처리한다.

**Tech Stack:** Flutter, Dart, Firebase (Firestore, Storage, Auth, Cloud Functions), Gemini API, flutter_bloc, get_it, injectable, dartz

---

## Task 1: Flutter 프로젝트 초기화

**Files:**
- Create: `pubspec.yaml`
- Create: `lib/main.dart`
- Create: `analysis_options.yaml`

**Step 1: Flutter 프로젝트 생성**

Run:
```bash
flutter create --org com.fitsy --project-name fitsy .
```
Expected: Flutter 프로젝트 파일 생성

**Step 2: pubspec.yaml 의존성 추가**

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.6
  get_it: ^8.0.3
  injectable: ^2.5.0
  dartz: ^0.10.1
  equatable: ^2.0.7
  cloud_firestore: ^5.6.5
  firebase_core: ^3.12.1
  firebase_storage: ^12.4.4
  firebase_auth: ^5.5.4
  image_picker: ^1.1.2
  cached_network_image: ^3.4.1
  go_router: ^15.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.7
  mockito: ^5.4.5
  build_runner: ^2.4.14
  injectable_generator: ^2.7.0
  flutter_lints: ^5.0.0
```

**Step 3: 불필요한 기본 파일 정리**

- `lib/main.dart`의 기본 카운터 앱 코드 제거
- `test/widget_test.dart` 제거

**Step 4: 의존성 설치**

Run:
```bash
flutter pub get
```
Expected: 모든 패키지 설치 성공

**Step 5: 커밋**

```bash
git add -A
git commit -m "FEAT:(AI-003) Flutter 프로젝트 초기화 및 의존성 설정"
```

---

## Task 2: Core 레이어 구축

**Files:**
- Create: `lib/core/error/failures.dart`
- Create: `lib/core/error/exceptions.dart`
- Create: `lib/core/usecase/usecase.dart`
- Create: `lib/core/di/injection.dart`
- Create: `lib/core/di/injection.config.dart`
- Test: `test/core/usecase/usecase_test.dart`

**Step 1: Failure 클래스 정의**

```dart
// lib/core/error/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

class AIClassificationFailure extends Failure {
  const AIClassificationFailure([super.message = 'AI classification failed']);
}

class ImageGenerationFailure extends Failure {
  const ImageGenerationFailure([super.message = 'Image generation failed']);
}
```

**Step 2: Exception 클래스 정의**

```dart
// lib/core/error/exceptions.dart
class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error']);
}

class AIException implements Exception {
  final String message;
  const AIException([this.message = 'AI processing error']);
}
```

**Step 3: UseCase 추상 클래스 작성 (테스트 먼저)**

```dart
// test/core/usecase/usecase_test.dart
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

void main() {
  late TestUseCase useCase;

  setUp(() {
    useCase = TestUseCase();
  });

  test('should return Right with result', () async {
    final result = await useCase('input');
    expect(result, const Right('result: input'));
  });
}
```

**Step 4: UseCase 구현**

```dart
// lib/core/usecase/usecase.dart
import 'package:dartz/dartz.dart';
import 'package:fitsy/core/error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
```

**Step 5: 테스트 실행**

Run:
```bash
flutter test test/core/
```
Expected: PASS

**Step 6: DI 설정**

```dart
// lib/core/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final sl = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // injectable이 생성하는 $initGetIt 호출
  // build_runner 실행 후 injection.config.dart가 생성됨
}
```

**Step 7: 커밋**

```bash
git add lib/core/ test/core/
git commit -m "FEAT:(AI-003) Core 레이어 구축 (Failure, Exception, UseCase, DI)"
```

---

## Task 3: Closet Domain 레이어

**Files:**
- Create: `lib/features/closet/domain/entities/cloth.dart`
- Create: `lib/features/closet/domain/repositories/closet_repository.dart`
- Create: `lib/features/closet/domain/usecases/add_cloth.dart`
- Create: `lib/features/closet/domain/usecases/get_clothes.dart`
- Create: `lib/features/closet/domain/usecases/update_cloth.dart`
- Test: `test/features/closet/domain/usecases/add_cloth_test.dart`
- Test: `test/features/closet/domain/usecases/get_clothes_test.dart`
- Test: `test/features/closet/domain/usecases/update_cloth_test.dart`

**Step 1: Cloth 엔티티 작성**

```dart
// lib/features/closet/domain/entities/cloth.dart
import 'package:equatable/equatable.dart';

class Cloth extends Equatable {
  final String id;
  final String imageUrl;
  final String? cutoutUrl;
  final String category;
  final String subcategory;
  final List<String> color;
  final List<String> season;
  final List<String> tags;
  final DateTime createdAt;
  final bool isActive;

  const Cloth({
    required this.id,
    required this.imageUrl,
    this.cutoutUrl,
    required this.category,
    required this.subcategory,
    required this.color,
    required this.season,
    required this.tags,
    required this.createdAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, imageUrl, cutoutUrl, category, subcategory, color, season, tags, createdAt, isActive];
}
```

**Step 2: Repository 추상 클래스 작성**

```dart
// lib/features/closet/domain/repositories/closet_repository.dart
import 'package:dartz/dartz.dart';
import 'package:fitsy/core/error/failures.dart';
import 'package:fitsy/features/closet/domain/entities/cloth.dart';

abstract class ClosetRepository {
  Future<Either<Failure, Cloth>> addCloth({
    required String imagePath,
    required String userId,
  });

  Future<Either<Failure, List<Cloth>>> getClothes({
    required String userId,
    String? category,
  });

  Future<Either<Failure, Cloth>> updateCloth({
    required String userId,
    required String clothId,
    String? category,
    String? subcategory,
    List<String>? color,
    List<String>? season,
    List<String>? tags,
    bool? isActive,
  });
}
```

**Step 3: GetClothes UseCase 테스트 작성**

```dart
// test/features/closet/domain/usecases/get_clothes_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fitsy/features/closet/domain/entities/cloth.dart';
import 'package:fitsy/features/closet/domain/repositories/closet_repository.dart';
import 'package:fitsy/features/closet/domain/usecases/get_clothes.dart';

@GenerateMocks([ClosetRepository])
import 'get_clothes_test.mocks.dart';

void main() {
  late GetClothes useCase;
  late MockClosetRepository repository;

  setUp(() {
    repository = MockClosetRepository();
    useCase = GetClothes(repository);
  });

  final tClothes = [
    Cloth(
      id: '1',
      imageUrl: 'https://example.com/shirt.jpg',
      category: '상의',
      subcategory: '반팔티',
      color: ['흰색'],
      season: ['여름'],
      tags: ['캐주얼'],
      createdAt: DateTime(2026, 3, 1),
    ),
  ];

  test('should get list of clothes from repository', () async {
    when(repository.getClothes(userId: 'user1'))
        .thenAnswer((_) async => Right(tClothes));

    final result = await useCase(const GetClothesParams(userId: 'user1'));

    expect(result, Right(tClothes));
    verify(repository.getClothes(userId: 'user1'));
    verifyNoMoreInteractions(repository);
  });
}
```

**Step 4: GetClothes UseCase 구현**

```dart
// lib/features/closet/domain/usecases/get_clothes.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fitsy/core/error/failures.dart';
import 'package:fitsy/core/usecase/usecase.dart';
import 'package:fitsy/features/closet/domain/entities/cloth.dart';
import 'package:fitsy/features/closet/domain/repositories/closet_repository.dart';

class GetClothes extends UseCase<List<Cloth>, GetClothesParams> {
  final ClosetRepository repository;

  GetClothes(this.repository);

  @override
  Future<Either<Failure, List<Cloth>>> call(GetClothesParams params) {
    return repository.getClothes(
      userId: params.userId,
      category: params.category,
    );
  }
}

class GetClothesParams extends Equatable {
  final String userId;
  final String? category;

  const GetClothesParams({required this.userId, this.category});

  @override
  List<Object?> get props => [userId, category];
}
```

**Step 5: AddCloth, UpdateCloth UseCase도 동일한 TDD 패턴으로 작성**

각 UseCase마다: 테스트 작성 → mock 생성 → 구현 → 테스트 통과 확인

**Step 6: mock 생성 및 테스트 실행**

Run:
```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/closet/
```
Expected: 모든 테스트 PASS

**Step 7: 커밋**

```bash
git add lib/features/closet/domain/ test/features/closet/domain/
git commit -m "FEAT:(AI-003) Closet 도메인 레이어 (Entity, Repository, UseCases)"
```

---

## Task 4: Closet Data 레이어

**Files:**
- Create: `lib/features/closet/data/models/cloth_model.dart`
- Create: `lib/features/closet/data/datasources/closet_remote_datasource.dart`
- Create: `lib/features/closet/data/repositories/closet_repository_impl.dart`
- Test: `test/features/closet/data/models/cloth_model_test.dart`
- Test: `test/features/closet/data/repositories/closet_repository_impl_test.dart`

**Step 1: ClothModel 테스트 작성**

Firestore 문서 ↔ Cloth 엔티티 변환 테스트:
- `fromFirestore()` 테스트: Map → ClothModel
- `toFirestore()` 테스트: ClothModel → Map
- `toEntity()` 테스트: ClothModel → Cloth

**Step 2: ClothModel 구현**

```dart
// lib/features/closet/data/models/cloth_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsy/features/closet/domain/entities/cloth.dart';

class ClothModel {
  final String id;
  final String imageUrl;
  final String? cutoutUrl;
  final String category;
  final String subcategory;
  final List<String> color;
  final List<String> season;
  final List<String> tags;
  final DateTime createdAt;
  final bool isActive;

  const ClothModel({
    required this.id,
    required this.imageUrl,
    this.cutoutUrl,
    required this.category,
    required this.subcategory,
    required this.color,
    required this.season,
    required this.tags,
    required this.createdAt,
    this.isActive = true,
  });

  factory ClothModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClothModel(
      id: doc.id,
      imageUrl: data['imageUrl'] as String,
      cutoutUrl: data['cutoutUrl'] as String?,
      category: data['category'] as String? ?? '미분류',
      subcategory: data['subcategory'] as String? ?? '',
      color: List<String>.from(data['color'] ?? []),
      season: List<String>.from(data['season'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'imageUrl': imageUrl,
      'cutoutUrl': cutoutUrl,
      'category': category,
      'subcategory': subcategory,
      'color': color,
      'season': season,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  Cloth toEntity() {
    return Cloth(
      id: id,
      imageUrl: imageUrl,
      cutoutUrl: cutoutUrl,
      category: category,
      subcategory: subcategory,
      color: color,
      season: season,
      tags: tags,
      createdAt: createdAt,
      isActive: isActive,
    );
  }
}
```

**Step 3: RemoteDataSource 작성**

Firestore와 Storage 호출을 담당하는 datasource 구현

**Step 4: RepositoryImpl 테스트 및 구현 (TDD)**

Repository가 datasource를 호출하고, 예외를 Failure로 변환하는지 테스트

**Step 5: 테스트 실행**

Run:
```bash
flutter test test/features/closet/data/
```
Expected: 모든 테스트 PASS

**Step 6: 커밋**

```bash
git add lib/features/closet/data/ test/features/closet/data/
git commit -m "FEAT:(AI-003) Closet 데이터 레이어 (Model, DataSource, Repository)"
```

---

## Task 5: Closet Presentation 레이어

**Files:**
- Create: `lib/features/closet/presentation/bloc/closet_bloc.dart`
- Create: `lib/features/closet/presentation/bloc/closet_event.dart`
- Create: `lib/features/closet/presentation/bloc/closet_state.dart`
- Create: `lib/features/closet/presentation/pages/closet_page.dart`
- Create: `lib/features/closet/presentation/widgets/cloth_card.dart`
- Create: `lib/features/closet/presentation/bloc/add_cloth_bloc.dart`
- Create: `lib/features/closet/presentation/pages/add_cloth_page.dart`
- Test: `test/features/closet/presentation/bloc/closet_bloc_test.dart`

**Step 1: ClosetBloc 이벤트/상태 정의**

- Events: `LoadClothes`, `FilterByCategory`, `DeleteCloth`
- States: `ClosetInitial`, `ClosetLoading`, `ClosetLoaded`, `ClosetError`

**Step 2: ClosetBloc 테스트 작성 (bloc_test)**

```dart
blocTest<ClosetBloc, ClosetState>(
  'emits [Loading, Loaded] when LoadClothes is added',
  build: () {
    when(mockGetClothes(any)).thenAnswer((_) async => Right(tClothes));
    return ClosetBloc(getClothes: mockGetClothes);
  },
  act: (bloc) => bloc.add(const LoadClothes(userId: 'user1')),
  expect: () => [ClosetLoading(), ClosetLoaded(clothes: tClothes)],
);
```

**Step 3: ClosetBloc 구현**

**Step 4: UI 페이지 작성**

- `closet_page.dart`: 그리드 뷰 + 카테고리 필터 + FAB
- `cloth_card.dart`: 옷 카드 위젯
- `add_cloth_page.dart`: 카메라/갤러리 선택 → AI 분류 결과 → 수정 → 저장

**Step 5: 테스트 실행**

Run:
```bash
flutter test test/features/closet/
```
Expected: 모든 테스트 PASS

**Step 6: 커밋**

```bash
git add lib/features/closet/presentation/ test/features/closet/presentation/
git commit -m "FEAT:(AI-003) Closet 프레젠테이션 레이어 (BLoC, Pages, Widgets)"
```

---

## Task 6: Outfit Domain + Data 레이어

**Files:**
- Create: `lib/features/outfit/domain/entities/outfit.dart`
- Create: `lib/features/outfit/domain/repositories/outfit_repository.dart`
- Create: `lib/features/outfit/domain/usecases/get_recommendations.dart`
- Create: `lib/features/outfit/domain/usecases/generate_outfit_image.dart`
- Create: `lib/features/outfit/data/models/outfit_model.dart`
- Create: `lib/features/outfit/data/datasources/outfit_remote_datasource.dart`
- Create: `lib/features/outfit/data/repositories/outfit_repository_impl.dart`
- Test: `test/features/outfit/domain/usecases/get_recommendations_test.dart`
- Test: `test/features/outfit/domain/usecases/generate_outfit_image_test.dart`
- Test: `test/features/outfit/data/repositories/outfit_repository_impl_test.dart`

**Step 1-4: Task 3-4와 동일한 TDD 패턴**

Outfit 엔티티, Repository 추상화, UseCase 테스트/구현, Model/DataSource/RepositoryImpl

**Step 5: 커밋**

```bash
git add lib/features/outfit/ test/features/outfit/
git commit -m "FEAT:(AI-004) Outfit 도메인 및 데이터 레이어"
```

---

## Task 7: Outfit Presentation 레이어

**Files:**
- Create: `lib/features/outfit/presentation/bloc/outfit_bloc.dart`
- Create: `lib/features/outfit/presentation/bloc/outfit_event.dart`
- Create: `lib/features/outfit/presentation/bloc/outfit_state.dart`
- Create: `lib/features/outfit/presentation/pages/outfit_page.dart`
- Create: `lib/features/outfit/presentation/pages/outfit_detail_page.dart`
- Create: `lib/features/outfit/presentation/widgets/outfit_card.dart`
- Test: `test/features/outfit/presentation/bloc/outfit_bloc_test.dart`

**Step 1-4: Task 5와 동일한 패턴**

OutfitBloc (추천 요청, 이미지 생성), 추천 결과 카드 UI, 코디 상세 페이지

**Step 5: 커밋**

```bash
git add lib/features/outfit/presentation/ test/features/outfit/presentation/
git commit -m "FEAT:(AI-004) Outfit 프레젠테이션 레이어 (BLoC, Pages, Widgets)"
```

---

## Task 8: 앱 셸 (라우팅, 네비게이션, 온보딩)

**Files:**
- Create: `lib/app/app.dart`
- Create: `lib/app/routes.dart`
- Create: `lib/app/theme.dart`
- Create: `lib/features/onboarding/presentation/pages/onboarding_page.dart`
- Create: `lib/features/onboarding/presentation/pages/style_selection_page.dart`
- Modify: `lib/main.dart`

**Step 1: 테마 정의 (다크모드 기본, MZ세대 타깃)**

**Step 2: GoRouter 라우팅 설정**

```
/ → 스플래시
/onboarding → 온보딩 (스타일 선택)
/home → 메인 (BottomNavBar: 옷장, 코디, 설정)
/closet/add → 옷 등록
/outfit/:id → 코디 상세
```

**Step 3: BottomNavigationBar 메인 셸 구성**

**Step 4: 온보딩 페이지 (선호 스타일 선택)**

**Step 5: main.dart에 Firebase 초기화 + DI + App 연결**

**Step 6: 테스트 실행**

Run:
```bash
flutter test
```
Expected: 모든 테스트 PASS

**Step 7: 커밋**

```bash
git add lib/app/ lib/features/onboarding/ lib/main.dart
git commit -m "FEAT:(AI-005) 앱 셸 구성 (라우팅, 테마, 온보딩, 네비게이션)"
```

---

## Task 9: Firebase 프로젝트 설정

**Files:**
- Create: `firebase.json`
- Create: `firestore.rules`
- Create: `firestore.indexes.json`
- Create: `storage.rules`

**Step 1: Firebase 프로젝트 초기화**

Run:
```bash
firebase init firestore storage functions
```

**Step 2: Firestore 보안 규칙 작성**

사용자 자신의 clothes/outfits만 읽기/쓰기 가능하도록 설정

**Step 3: Storage 보안 규칙 작성**

사용자 자신의 이미지만 업로드/읽기 가능하도록 설정

**Step 4: Flutter에 Firebase 연결**

Run:
```bash
flutterfire configure
```

**Step 5: 커밋**

```bash
git add firebase.json firestore.rules firestore.indexes.json storage.rules
git commit -m "FEAT:(AI-005) Firebase 프로젝트 설정 (Firestore, Storage 규칙)"
```

---

## Task 10: Cloud Functions (AI 처리)

**Files:**
- Create: `functions/src/index.ts`
- Create: `functions/src/closet/onClothUploaded.ts`
- Create: `functions/src/outfit/getRecommendations.ts`
- Create: `functions/src/outfit/generateOutfitImage.ts`
- Create: `functions/src/shared/gemini.ts`
- Create: `functions/src/shared/prompts.ts`

**Step 1: Cloud Functions 프로젝트 초기화 (TypeScript)**

**Step 2: Gemini API 클라이언트 래퍼 작성**

```typescript
// functions/src/shared/gemini.ts
import { GoogleGenerativeAI } from '@google/generative-ai';

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY!);

export const geminiModel = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });
```

**Step 3: 프롬프트 템플릿 작성**

```typescript
// functions/src/shared/prompts.ts
export const CLASSIFY_CLOTH_PROMPT = `이 옷 이미지를 분석하여 다음을 JSON으로 반환해줘:
{
  "category": "상의|하의|외투|신발|악세서리",
  "subcategory": "구체적 종류 (예: 반팔티, 청바지)",
  "color": ["주요 색상"],
  "season": ["적합한 계절"],
  "tags": ["스타일 태그"]
}`;

export const RECOMMEND_OUTFIT_PROMPT = (clothes: string, styles: string[]) =>
  `다음 옷들 중에서 ${styles.join(', ')} 스타일에 맞는 코디 조합 3개를 추천해줘.
각 조합은 상의, 하의, (선택)외투, (선택)신발로 구성.
옷 목록: ${clothes}
JSON 배열로 반환: [{"top": "id", "bottom": "id", "outer": "id?", "shoes": "id?"}]`;

export const GENERATE_OUTFIT_IMAGE_PROMPT = (items: string) =>
  `다음 옷 조합으로 스타일리시한 코디 이미지를 생성해줘: ${items}`;
```

**Step 4: onClothUploaded 트리거 구현**

Storage에 옷 사진 업로드 시 → Gemini로 분류 → Firestore 업데이트

**Step 5: getRecommendations Callable 구현**

사용자 옷 목록 + 선호 스타일 → Gemini에 코디 조합 요청 → 결과 반환

**Step 6: generateOutfitImage Callable 구현**

선택된 코디 조합 → Gemini(나노바나나)에 이미지 생성 → Storage 저장 → URL 반환

**Step 7: Functions 배포**

Run:
```bash
firebase deploy --only functions
```

**Step 8: 커밋**

```bash
git add functions/
git commit -m "FEAT:(AI-006) Cloud Functions AI 파이프라인 (분류, 추천, 이미지생성)"
```

---

## Task 11: 통합 테스트 및 최종 점검

**Step 1: 전체 테스트 실행**

Run:
```bash
flutter test --coverage
```
Expected: 모든 테스트 PASS, 커버리지 확인

**Step 2: 앱 빌드 확인**

Run:
```bash
flutter build apk --debug
```
Expected: 빌드 성공

**Step 3: 에뮬레이터에서 수동 테스트**

- 옷 등록 → AI 분류 확인
- 코디 추천 → 결과 표시 확인
- 코디 이미지 생성 확인

**Step 4: 최종 커밋**

```bash
git add -A
git commit -m "FEAT:(AI-007) 통합 테스트 및 최종 점검"
```
