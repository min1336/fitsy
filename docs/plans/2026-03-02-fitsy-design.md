# Fitsy - AI 옷장 앱 설계 문서

**작성일**: 2026-03-02
**상태**: 승인됨

## 1. 제품 개요

| 항목 | 내용 |
|------|------|
| 제품명 | Fitsy |
| 설명 | AI 기반 옷장 관리 및 코디 추천 앱 |
| 타깃 | 10-20대 MZ세대 |
| 플랫폼 | iOS / Android (Flutter) |
| 백엔드 | Firebase (Firestore, Storage, Auth, Cloud Functions) |
| AI | Google Gemini API (나노바나나) |

## 2. MVP 기능 범위

### 포함

- 옷 등록/관리 (사진 촬영 → AI 자동 분류 + 사용자 수정)
- AI 코디 추천 (선호 스타일 기반)
- AI 코디 이미지 생성 (나노바나나)

### 미포함 (후속 버전)

- 사용자 인증/프로필 (v2)
- 날씨/장소(TPO) 기반 추천 (v2)
- 누끼 + 오브젝트화 (v2)
- AI 아바타 착장 Virtual Try-On (v3)

## 3. 전체 아키텍처

```
┌─────────────────────────────────────────┐
│            Flutter App (UI)             │
│  ┌───────┐ ┌──────────┐ ┌───────────┐  │
│  │ 옷장  │ │ 코디추천  │ │ 코디이미지 │  │
│  │ 관리  │ │   화면   │ │   생성    │  │
│  └───┬───┘ └────┬─────┘ └─────┬─────┘  │
└──────┼──────────┼─────────────┼─────────┘
       │          │             │
┌──────┼──────────┼─────────────┼─────────┐
│      ▼          ▼             ▼         │
│           Firebase Layer                │
│  ┌───────────┐  ┌──────────────────┐    │
│  │ Firestore │  │ Cloud Functions  │    │
│  │ (옷 데이터,│  │  ┌────────────┐  │    │
│  │  코디기록) │  │  │ 옷 분류 AI │  │    │
│  └───────────┘  │  │ 코디 추천  │  │    │
│  ┌───────────┐  │  │ 이미지 생성│  │    │
│  │ Storage   │  │  └──────┬─────┘  │    │
│  │ (옷 사진) │  │         │        │    │
│  └───────────┘  │         ▼        │    │
│  ┌───────────┐  │   Gemini API     │    │
│  │ Auth      │  │  (나노바나나)     │    │
│  │ (소셜로그인)│  └──────────────────┘    │
│  └───────────┘                          │
└─────────────────────────────────────────┘
```

### 핵심 흐름

1. **옷 등록**: 사진 촬영 → Storage 업로드 → Cloud Function 트리거 → Gemini로 자동 분류 → Firestore 저장
2. **코디 추천**: 추천 요청 → Cloud Function이 옷 목록 + 선호 스타일 조회 → Gemini에 코디 조합 요청 → 결과 반환
3. **코디 이미지 생성**: 코디 선택 → Cloud Function이 Gemini(나노바나나)에 이미지 생성 요청 → Storage 저장 → URL 반환

## 4. 데이터 모델 (Firestore)

```
users/
  └── {userId}/
        ├── displayName: string
        ├── stylePreferences: string[]     # ["미니멀", "캐주얼"]
        ├── createdAt: timestamp
        │
        ├── clothes/ (subcollection)
        │     └── {clothId}/
        │           ├── imageUrl: string           # 원본 이미지
        │           ├── cutoutUrl: string?          # 누끼 이미지 (v2, nullable)
        │           ├── category: string            # 상의/하의/외투/신발/악세서리
        │           ├── subcategory: string         # 반팔티, 청바지 등 (AI 분류)
        │           ├── color: string[]             # AI 자동 추출
        │           ├── season: string[]            # AI 자동 추출
        │           ├── tags: string[]              # AI 자동 + 사용자 추가
        │           ├── createdAt: timestamp
        │           └── isActive: bool              # 소프트 삭제
        │
        └── outfits/ (subcollection)
              └── {outfitId}/
                    ├── clothIds: string[]
                    ├── generatedImageUrl: string?
                    ├── liked: bool?                # 향후 선호도 학습용
                    ├── prompt: string
                    └── createdAt: timestamp
```

## 5. Flutter 앱 아키텍처 (DDD + Clean Architecture)

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── routes.dart
│
├── core/
│   ├── error/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   ├── usecase/
│   │   └── usecase.dart
│   └── di/
│       └── injection.dart
│
├── features/
│   ├── closet/                        # 옷장 관리 모듈
│   │   ├── domain/
│   │   │   ├── entities/cloth.dart
│   │   │   ├── repositories/closet_repository.dart
│   │   │   └── usecases/
│   │   │       ├── add_cloth.dart
│   │   │       ├── get_clothes.dart
│   │   │       └── update_cloth.dart
│   │   ├── data/
│   │   │   ├── models/cloth_model.dart
│   │   │   ├── datasources/closet_remote_datasource.dart
│   │   │   └── repositories/closet_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   │
│   ├── outfit/                        # AI 코디 추천 모듈
│   │   ├── domain/
│   │   │   ├── entities/outfit.dart
│   │   │   ├── repositories/outfit_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_recommendations.dart
│   │   │       └── generate_outfit_image.dart
│   │   ├── data/
│   │   │   ├── models/outfit_model.dart
│   │   │   ├── datasources/outfit_remote_datasource.dart
│   │   │   └── repositories/outfit_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   │
│   └── auth/                          # 인증 모듈 (후속)
│       ├── domain/
│       ├── data/
│       └── presentation/
```

### 아키텍처 원칙

| 원칙 | 적용 |
|------|------|
| DDD | `features/` 단위로 도메인 분리. 각 모듈은 domain → data → presentation 3계층 |
| Clean Architecture | 의존성 방향: presentation → domain ← data. Domain은 외부 의존 없음 |
| TDD | test/가 lib/features/ 구조를 미러링. UseCase/Repository/BLoC 모두 테스트 |
| 일관성 | 모든 모듈이 동일한 폴더 구조. BLoC 패턴으로 상태관리 통일 |
| 모듈 독립성 | closet과 outfit 모듈은 서로 직접 참조하지 않음. core만 공유 |

### 핵심 패키지

- 상태관리: `flutter_bloc`
- DI: `get_it` + `injectable`
- 함수형 에러처리: `dartz` (Either<Failure, Success>)
- Firebase: `cloud_firestore`, `firebase_storage`, `firebase_auth`

## 6. Cloud Functions (AI 처리)

```
functions/
├── src/
│   ├── index.ts
│   ├── closet/
│   │   └── onClothUploaded.ts         # Storage 트리거: AI 자동 분류
│   ├── outfit/
│   │   ├── getRecommendations.ts      # Callable: 코디 추천
│   │   └── generateOutfitImage.ts     # Callable: 코디 이미지 생성
│   └── shared/
│       ├── gemini.ts                  # Gemini API 클라이언트
│       └── prompts.ts                 # 프롬프트 템플릿
```

### 에러 처리

- Gemini API 실패: 재시도 1회 후 사용자에게 안내
- 이미지 분류 실패: `category: "미분류"`로 저장, 사용자 수동 분류 유도
- 타임아웃: Cloud Functions 최대 60초, 이미지 생성은 비동기 처리 고려

## 7. 화면 구성

| 화면 | 기능 | BLoC |
|------|------|------|
| 온보딩 | 선호 스타일 3~5개 선택 | OnboardingBloc |
| 옷장 (옷 목록) | 그리드 뷰, 카테고리 필터, FAB으로 옷 추가 | ClosetBloc |
| 옷 등록 | 카메라/갤러리 → AI 분류 → 수정 → 저장 | AddClothBloc |
| 코디 추천 | 코디 조합 카드 3~5개 표시 | OutfitBloc |
| 코디 상세 | 이미지 생성, 좋아요/싫어요 | OutfitDetailBloc |
| 설정 | 선호 스타일 수정 | SettingsBloc |

### 디자인 방향

- 다크모드 기본, 미니멀 UI
- 카드 기반 레이아웃, 부드러운 애니메이션
- 옷장은 Pinterest 스타일 그리드

## 8. 확장 로드맵

| 버전 | 기능 |
|------|------|
| MVP | 옷 등록(AI 분류), 코디 추천(선호 스타일), 코디 이미지 생성 |
| v2 | 사용자 인증, 누끼/오브젝트화, 날씨/TPO 기반 추천 |
| v3 | AI 아바타 착장 (Virtual Try-On), 선호도 학습 고도화 |
