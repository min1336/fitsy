# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

Fitsy는 현재 초기 설계 단계의 프로젝트이다. 소스 코드 구현 전이며, 기획 및 아키텍처 결정이 진행 중이다.

## 프로젝트 상태

- **현재 단계**: Pre-development (기획/설계)
- **계획된 백엔드**: Firebase (CLI 인증 완료, 계정: aldursjrnf123@gmail.com)
- **기술 스택**: 미확정 — 개발 시작 전 Phase 1 합의에서 결정 예정

## 핵심 문서

- `PROJECT_DESIGN_ORCHESTRATION.md` — AI 에이전트 오케스트레이션 설계 가이드. Teams(수평 협업)와 Subagent(수직 위임) 구조의 3단계 사이클을 정의한다:
  1. **Phase 1 (합의)**: 리드 에이전트들이 수평 토론으로 방향 결정 (최대 3라운드, 교착 시 오케스트레이터 결정)
  2. **Phase 2 (병렬 실행)**: 합의된 명세를 기반으로 Subagent가 독립 병렬 실행
  3. **Phase 3 (통합 검토)**: 크로스 도메인 검토 후 승인 또는 Phase 2 회귀

## 오케스트레이션 원칙

- **"판단은 Teams, 실행은 Subagent"** — 분야 간 트레이드오프가 필요한 의사결정은 Teams에서 토론, 단일 분야 실행 작업은 Subagent에 위임
- Phase 1에서 분야 간 인터페이스(API 스펙, 데이터 포맷 등)를 반드시 사전 합의
- Subagent 간 직접 통신 금지 — 반드시 리드를 통해 소통
- 블로킹 이슈 발생 시 즉시 리드에게 에스컬레이션

## Git 워크플로우

### 커밋 메시지 규칙

형식: `TYPE:(AI-XXX) 작업 내용`

- `FEAT:(AI-XXX)` — 기능 구현
- `FIX:(AI-XXX)` — 버그 수정
- `RECT:(AI-XXX)` — 리팩토링

티켓 번호(AI-XXX)는 기능 단위로 부여한다. 같은 기능에 속하는 커밋은 동일한 티켓 번호를 사용한다.

### 브랜치 전략

- `main`에 직접 푸시하지 않는다
- 기능 브랜치: `root/기능명` 형식으로 생성 (예: `root/auth`, `root/landing-page`)
- 기능 브랜치에서 작업 후 PR을 생성하여 `main`에 병합한다

### PR 규칙

- PR 제목은 커밋 메시지 규칙과 동일한 형식을 따른다
- PR 본문에 변경 사항 요약, 테스트 계획을 포함한다

## 주의사항

- 기술 스택이 확정되지 않았으므로, 개발 시작 전 반드시 Phase 1 합의를 거쳐야 한다
- 이 CLAUDE.md는 기술 스택 확정 후 빌드/테스트/린트 명령어 등으로 업데이트해야 한다
