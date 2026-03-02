# 🏗️ AI 오케스트레이션 프로젝트 설계 가이드

> **목적**: 어떤 프로젝트든 초기 설계 단계에서 이 문서를 참고하여, Teams(수평 협업)와 Subagent(수직 위임) 구조를 효과적으로 설계한다.
>
> **사용법**: 프로젝트 루트에 이 파일을 두고, AI 에이전트(Claude 등)에게 "이 가이드에 따라 프로젝트를 설계해줘"라고 요청하면 된다.

---

## 1. 프로젝트 초기 분석 프레임워크

새 프로젝트가 시작되면, 아래 질문에 답하면서 구조를 잡는다.

### 1-1. 프로젝트 정보 카드 (복사해서 채우기)

```yaml
project:
  name: ""                    # 프로젝트 이름
  description: ""             # 한 줄 설명
  type: ""                    # product | internal-tool | marketing | research | migration
  timeline: ""                # 예상 기간
  complexity: ""              # small | medium | large | epic

domains_involved:             # 관련된 분야 (해당하는 것 체크)
  - planning: false           # 기획/PM
  - backend: false            # 백엔드 개발
  - frontend: false           # 프론트엔드 개발
  - design: false             # UI/UX 디자인
  - marketing: false          # 마케팅/그로스
  - data: false               # 데이터 분석/엔지니어링
  - infra: false              # 인프라/DevOps
  - qa: false                 # QA/테스트
  - legal: false              # 법무/컴플라이언스
  - custom: ""                # 기타 도메인

constraints:                  # 제약 조건
  budget: ""
  tech_stack: ""              # 사용해야 하는 기술 스택
  integrations: ""            # 연동해야 하는 외부 시스템
  compliance: ""              # 규제/보안 요구사항
```

### 1-2. 복잡도 판단 기준

프로젝트 복잡도에 따라 오케스트레이션 전략이 달라진다.

**Small (단일 도메인)**: 관련 분야가 1~2개이고, 한 사람이 전체를 파악할 수 있는 규모이다. 이 경우 Teams 없이 Subagent만으로 충분하며, 메인 에이전트가 직접 작업을 분배하고 결과를 수집한다.

**Medium (크로스 도메인)**: 관련 분야가 3~4개이며, 분야 간 의존성이 존재하는 규모이다. Teams 1계층에 Subagent를 결합하는 구조가 적합하다. 리드 에이전트들이 합의하고, 각 리드 아래 Subagent가 실행한다.

**Large (멀티 도메인)**: 관련 분야가 5개 이상이고, 분야 간 복잡한 의존성과 트레이드오프가 있는 규모이다. Teams 다계층 구조가 필요하며, 도메인 그룹별 리드 → 세부 분야 리드 → Subagent의 3계층 구조를 고려한다.

**Epic (조직 전체)**: 여러 팀, 여러 제품에 걸친 대규모 프로젝트이다. 전략 Teams + 실행 Teams + Subagent의 3계층 이상 구조를 설계하며, 프로젝트를 하위 프로젝트로 분리하는 것을 우선 검토한다.

---

## 2. 오케스트레이션 아키텍처 설계

### 2-1. 핵심 원칙: "판단은 Teams, 실행은 Subagent"

이 원칙을 모든 설계의 출발점으로 삼는다.

**Teams에 배치하는 작업**은 다른 분야의 맥락이 필요한 의사결정이다. 예를 들어, "실시간 알림을 WebSocket으로 할지 Polling으로 할지"는 기술(성능), 비즈니스(사용자 기대), 인프라(비용) 관점이 모두 필요하므로 Teams에서 토론한다.

**Subagent에 배치하는 작업**은 단일 분야 지식으로 완결되는 실행 작업이다. 예를 들어, "WebSocket 서버 코드 구현", "랜딩페이지 카피 작성", "API 문서 생성" 등은 해당 분야 전문성만 있으면 되므로 Subagent가 처리한다.

### 2-2. 아키텍처 템플릿

아래 구조를 프로젝트에 맞게 커스터마이즈한다.

```
┌─────────────────────────────────────────────────┐
│              🎯 프로젝트 오케스트레이터           │
│         (전체 진행 상황 관리 & 사이클 조율)        │
└──────────────────────┬──────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
  ┌───────────┐  ┌───────────┐  ┌───────────┐
  │  🧠 리드A  │◄─►│  🧠 리드B  │◄─►│  🧠 리드C  │   ← Teams 계층
  │  (기획)    │  │  (개발)    │  │ (마케팅)   │      (수평 협업)
  └─────┬─────┘  └─────┬─────┘  └─────┬─────┘
        │              │              │
   ┌────┼────┐    ┌────┼────┐    ┌────┼────┐
   ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼
  [S1] [S2] [S3] [S4] [S5] [S6] [S7] [S8] [S9]   ← Subagent 계층
                                                      (수직 위임)
```

### 2-3. 에이전트 역할 정의 템플릿

각 에이전트의 역할을 아래 형식으로 명확히 정의한다.

```yaml
agents:
  teams_layer:                         # --- Teams 계층 (리드) ---
    - id: "lead-planning"
      role: "기획 리드"
      responsibility: "PRD 작성, 요구사항 정의, 우선순위 결정"
      communicates_with:               # 다른 리드와의 소통 채널
        - "lead-backend"
        - "lead-frontend"
        - "lead-marketing"
      decision_authority:              # 이 리드가 최종 결정권을 가지는 영역
        - "기능 범위(scope) 결정"
        - "MVP 기능 선정"
      escalation_to: "orchestrator"    # 합의 안 될 때 상위 에스컬레이션

    - id: "lead-backend"
      role: "백엔드 리드"
      responsibility: "시스템 아키텍처, API 설계, 기술 의사결정"
      communicates_with:
        - "lead-planning"
        - "lead-frontend"
        - "lead-data"
      decision_authority:
        - "기술 스택 선택"
        - "API 인터페이스 설계"
      escalation_to: "orchestrator"

    # ... 프로젝트에 필요한 리드를 추가 ...

  subagent_layer:                      # --- Subagent 계층 (실행) ---
    - id: "sub-api-impl"
      parent: "lead-backend"           # 소속 리드
      task: "API 엔드포인트 구현"
      input: "API 설계 문서"
      output: "구현된 API 코드 + 테스트"
      skills:                          # 이 Subagent가 참고할 Skills
        - "fastapi-conventions"
        - "error-handling-guide"

    - id: "sub-db-design"
      parent: "lead-backend"
      task: "데이터베이스 스키마 설계 및 마이그레이션"
      input: "ERD, 요구사항"
      output: "마이그레이션 파일, 스키마 문서"
      skills:
        - "db-naming-conventions"

    # ... 프로젝트에 필요한 Subagent를 추가 ...
```

---

## 3. 실행 사이클: "합의 → 병렬 실행 → 통합 검토"

프로젝트는 아래 3단계 사이클을 반복하며 진행된다.

### Phase 1: 합의 (Teams 활성화)

이 단계에서 리드 에이전트들이 수평적으로 토론하며 방향을 결정한다.

```yaml
phase_1_consensus:
  trigger: "새로운 기능/이터레이션 시작 시"
  participants: "모든 리드 에이전트"
  process:
    - step: "기획 리드가 초안(PRD/요구사항) 제시"
    - step: "각 리드가 자기 분야 관점에서 피드백"
      examples:
        - "백엔드: 이 기능은 기술적으로 N일 소요 예상"
        - "프론트: 이 UX 흐름은 사용자 테스트에서 혼란을 줄 수 있음"
        - "마케팅: 이 기능이 핵심 셀링 포인트이므로 MVP에 포함 필요"
        - "인프라: 예상 트래픽 대비 비용이 X원/월 증가"
    - step: "트레이드오프 토론 후 합의안 도출"
    - step: "합의 결과를 '실행 명세서'로 문서화"
  output: "실행 명세서 (각 리드별 구체적 작업 목록 포함)"
  max_rounds: 3                        # 최대 토론 라운드 (무한 토론 방지)
  deadlock_resolution: "오케스트레이터가 최종 결정"
```

### Phase 2: 병렬 실행 (Subagent 활성화)

합의된 실행 명세서를 기반으로, 각 리드가 Subagent에게 작업을 위임한다.

```yaml
phase_2_execution:
  trigger: "Phase 1의 실행 명세서 확정 시"
  process:
    - step: "각 리드가 자기 팀의 Subagent에게 작업 배분"
    - step: "Subagent들이 병렬로 독립 실행"
    - step: "완료된 결과물을 리드에게 보고"
  rules:
    - "Subagent 간 직접 통신 금지 (반드시 리드를 통해)"
    - "블로킹 이슈 발생 시 즉시 리드에게 에스컬레이션"
    - "각 Subagent는 할당된 Skills를 참고하여 품질 기준 준수"
  output: "각 분야별 결과물 (코드, 디자인, 문서 등)"
```

### Phase 3: 통합 검토 (Teams 재활성화)

각 팀의 결과물을 리드들이 모여서 크로스 체크한다.

```yaml
phase_3_review:
  trigger: "Phase 2의 모든 팀 결과물 제출 완료 시"
  participants: "모든 리드 에이전트"
  process:
    - step: "각 리드가 다른 팀의 결과물을 자기 분야 관점에서 검토"
      examples:
        - "프론트 리드 → 백엔드 결과물: API 응답 구조가 UI 컴포넌트와 맞는지"
        - "마케팅 리드 → 프론트 결과물: 랜딩페이지가 마케팅 메시지를 잘 전달하는지"
        - "QA 리드 → 전체: 엣지 케이스와 에러 시나리오 커버리지"
    - step: "이슈 발견 시 수정 사항 합의"
    - step: "수정 필요 시 Phase 2로 회귀, 통과 시 완료"
  output: "승인된 최종 결과물 또는 수정 요청"
  criteria:
    - "모든 리드의 승인 (또는 과반수 + 오케스트레이터 확인)"
    - "분야 간 인터페이스 정합성 확인"
    - "원래 합의된 요구사항 충족 여부"
```

### 사이클 흐름도

```
[Phase 1: 합의] ──→ [Phase 2: 병렬 실행] ──→ [Phase 3: 통합 검토]
      ▲                                              │
      │            이슈 발견 시                        │
      └──────────── Phase 2로 회귀 ◄──────────────────┘
                                                      │
                                              통과 시 완료 ✅
```

---

## 4. 분야별 리드 에이전트 프롬프트 템플릿

각 리드 에이전트에게 부여할 시스템 프롬프트의 기본 구조이다. 프로젝트에 맞게 커스터마이즈한다.

### 4-1. 기획 리드

```markdown
## 역할
당신은 이 프로젝트의 기획 리드입니다.

## 핵심 책임
- 사용자 관점에서 요구사항을 정의하고 우선순위를 매긴다.
- 다른 리드들의 피드백을 종합하여 현실적인 제품 요구사항을 도출한다.
- 기능 범위(scope)에 대한 최종 결정권을 가진다.

## 의사결정 원칙
- 항상 "사용자에게 가장 큰 가치를 주는 것"을 기준으로 판단한다.
- 기술적 제약이 있을 때는 기능을 축소하되, 핵심 가치는 보존한다.
- MVP와 후속 버전을 명확히 구분한다.

## 다른 리드와의 소통 규칙
- 기술적 의사결정은 개발 리드의 판단을 존중한다.
- 마케팅 관점의 피드백을 적극 반영한다.
- 합의가 안 되면 트레이드오프를 명시하고 오케스트레이터에 에스컬레이션한다.

## 출력 형식
요구사항은 항상 아래 형식으로 작성한다:
- 사용자 스토리: "~로서, ~하고 싶다, ~하기 위해"
- 수용 기준: 구체적이고 테스트 가능한 조건
- 우선순위: P0(필수) / P1(중요) / P2(있으면 좋음)
```

### 4-2. 백엔드 리드

```markdown
## 역할
당신은 이 프로젝트의 백엔드 리드입니다.

## 핵심 책임
- 시스템 아키텍처를 설계하고 기술 스택을 결정한다.
- API 인터페이스를 정의한다 (프론트 리드와 합의).
- 성능, 보안, 확장성에 대한 기술적 판단을 내린다.

## 의사결정 원칙
- 현재 기술 스택과의 호환성을 우선 고려한다.
- 오버엔지니어링을 피하고, 현재 규모에 적합한 솔루션을 선택한다.
- 기술 부채를 인식하고, 의도적으로 남기는 경우 문서화한다.

## 다른 리드와의 소통 규칙
- 프론트 리드와 API 스펙을 사전에 합의한다.
- 기획 리드에게 기술적 제약과 소요 시간을 명확히 전달한다.
- 인프라 비용 영향이 있는 결정은 반드시 공유한다.

## Subagent 관리
작업을 Subagent에게 위임할 때 아래를 명시한다:
- 구현할 기능의 명확한 스펙
- 참고할 Skills 문서
- 완료 기준과 테스트 요구사항
```

### 4-3. 프론트엔드 리드

```markdown
## 역할
당신은 이 프로젝트의 프론트엔드 리드입니다.

## 핵심 책임
- UI/UX 구현 전략을 결정한다.
- 컴포넌트 아키텍처를 설계한다.
- 사용자 경험의 품질을 보장한다.

## 의사결정 원칙
- 사용자 경험을 최우선으로 고려한다.
- 백엔드 API 응답 구조에 맞춰 효율적인 데이터 흐름을 설계한다.
- 접근성(a11y)과 반응형 디자인을 기본으로 포함한다.

## 다른 리드와의 소통 규칙
- 백엔드 리드와 API 스펙을 사전에 합의한다.
- 디자인 변경이 기획 의도와 다를 때 기획 리드와 확인한다.
- 성능에 영향을 주는 UI 결정은 백엔드 리드와 논의한다.
```

### 4-4. 마케팅 리드

```markdown
## 역할
당신은 이 프로젝트의 마케팅 리드입니다.

## 핵심 책임
- 제품의 시장 포지셔닝과 메시징을 결정한다.
- 마케팅 채널 전략을 수립한다.
- 사용자 획득 및 전환 최적화 전략을 제시한다.

## 의사결정 원칙
- 타겟 사용자의 관점에서 모든 커뮤니케이션을 검토한다.
- 경쟁사 대비 차별화 포인트를 명확히 한다.
- 데이터 기반의 마케팅 성과 측정 기준을 설정한다.

## 다른 리드와의 소통 규칙
- 마케팅에서 약속하는 기능이 실제 구현 범위에 포함되는지 확인한다.
- 제품의 핵심 셀링 포인트가 기획 우선순위에 반영되도록 피드백한다.
- 런칭 타이밍을 개발 일정과 조율한다.
```

---

## 5. Subagent 작업 위임 템플릿

리드가 Subagent에게 작업을 위임할 때 사용하는 표준 형식이다.

```yaml
task_delegation:
  task_id: "TASK-001"
  title: ""                            # 작업 제목
  assigned_to: ""                      # Subagent ID
  delegated_by: ""                     # 리드 ID

  context:                             # 작업의 배경 (왜 이 작업을 하는지)
    background: ""
    related_decisions: ""              # Teams에서 합의된 관련 결정사항

  specification:                       # 구체적인 작업 내용
    description: ""                    # 무엇을 해야 하는지
    acceptance_criteria: []            # 완료 기준 (테스트 가능한 조건)
    constraints: []                    # 제약 조건 (기술, 시간, 비용 등)

  resources:                           # 참고 자료
    skills: []                         # 참고할 Skills 파일 경로
    reference_docs: []                 # 관련 문서 링크
    examples: []                       # 참고할 예시

  interface:                           # 다른 작업과의 인터페이스
    depends_on: []                     # 선행 작업
    blocks: []                         # 이 작업을 기다리는 후행 작업
    api_contracts: []                  # 합의된 API/데이터 인터페이스

  delivery:                            # 산출물
    output_format: ""                  # 코드, 문서, 디자인 파일 등
    output_location: ""                # 결과물 저장 위치
    review_checklist: []               # 리드가 검토할 체크리스트
```

---

## 6. 커뮤니케이션 프로토콜

에이전트 간 소통 규칙을 명확히 하여 혼선을 방지한다.

### 6-1. Teams 계층 (리드 간 소통)

```yaml
teams_protocol:
  message_format:
    from: ""                           # 발신 리드
    to: ""                             # 수신 리드 (또는 "all")
    type: ""                           # proposal | feedback | question | decision | escalation
    priority: ""                       # critical | high | normal | low
    content: ""                        # 메시지 본문
    requires_response: true/false
    deadline: ""                       # 응답 기한

  rules:
    - "모든 의사결정은 명시적으로 '합의(agreed)' 또는 '이의(objection)' 표시"
    - "이의 제기 시 반드시 대안을 함께 제시"
    - "3라운드 토론 후 합의 안 되면 오케스트레이터에 에스컬레이션"
    - "기술 용어 사용 시 비기술 리드가 이해할 수 있도록 설명 포함"
```

### 6-2. Subagent 계층 (리드 ↔ Subagent 소통)

```yaml
subagent_protocol:
  report_format:
    status: ""                         # in_progress | blocked | completed | failed
    progress: ""                       # 진행률 (%)
    output: ""                         # 현재까지의 산출물
    issues: []                         # 발생한 이슈
    needs_decision: []                 # 리드의 판단이 필요한 사항

  escalation_triggers:                 # 즉시 리드에게 보고해야 하는 상황
    - "요구사항이 모호하여 두 가지 이상 해석이 가능한 경우"
    - "기술적으로 불가능하거나 예상보다 2배 이상 복잡한 경우"
    - "다른 Subagent의 결과물이 필요한데 아직 도착하지 않은 경우"
    - "보안 또는 성능에 심각한 영향을 미치는 이슈를 발견한 경우"
```

---

## 7. 프로젝트 유형별 빠른 시작 가이드

### 7-1. 신규 제품/서비스 개발

```yaml
quick_start_product:
  teams:
    - 기획 리드
    - 백엔드 리드
    - 프론트엔드 리드
    - 디자인 리드 (선택)
    - 마케팅 리드 (선택)
  cycle: "기획 합의 → 설계 합의 → 구현 병렬 실행 → 통합 검토 → 런칭 준비"
  key_artifacts:
    - "PRD (기획 리드)"
    - "시스템 아키텍처 문서 (백엔드 리드)"
    - "API 스펙 (백엔드 + 프론트 합의)"
    - "와이어프레임/UI 가이드 (디자인 리드)"
```

### 7-2. 기존 시스템 리팩토링/마이그레이션

```yaml
quick_start_refactor:
  teams:
    - 테크 리드 (아키텍처 결정)
    - 백엔드 리드 (구현)
    - QA 리드 (회귀 테스트)
    - 인프라 리드 (배포 전략)
  cycle: "현상 분석 → 리팩토링 전략 합의 → 점진적 구현 → 회귀 테스트 → 배포"
  key_artifacts:
    - "현재 아키텍처 문서"
    - "목표 아키텍처 문서"
    - "마이그레이션 계획서"
    - "롤백 플랜"
```

### 7-3. 마케팅/캠페인 프로젝트

```yaml
quick_start_marketing:
  teams:
    - 마케팅 리드 (전략)
    - 콘텐츠 리드 (카피/크리에이티브)
    - 데이터 리드 (성과 측정)
    - 프론트엔드 리드 (랜딩페이지)
  cycle: "타겟/메시지 합의 → 콘텐츠 병렬 제작 → 크로스 리뷰 → 런칭"
  key_artifacts:
    - "캠페인 브리프"
    - "타겟 오디언스 정의"
    - "채널별 콘텐츠 가이드"
    - "KPI 대시보드 설계"
```

### 7-4. 데이터 파이프라인/분석 프로젝트

```yaml
quick_start_data:
  teams:
    - 데이터 리드 (아키텍처)
    - 백엔드 리드 (API/연동)
    - 분석 리드 (인사이트 도출)
    - 기획 리드 (비즈니스 요구사항)
  cycle: "데이터 요구사항 합의 → 파이프라인 설계 → 구현 → 검증 → 시각화"
  key_artifacts:
    - "데이터 소스 명세"
    - "ETL/ELT 파이프라인 설계"
    - "데이터 모델/스키마"
    - "대시보드/리포트 명세"
```

---

## 8. 안티 패턴 (이렇게 하면 안 된다)

설계 시 흔히 빠지는 함정들이다.

**"모든 걸 Teams로" 안티 패턴**: 10명의 리드가 코드 한 줄까지 토론하는 상황이다. 토론이 끝나지 않고 실행이 늦어진다. 해결책은 실행 작업은 반드시 Subagent로 위임하는 것이다.

**"모든 걸 Subagent로" 안티 패턴**: 메인 에이전트 하나가 모든 분야의 판단을 혼자 내리는 상황이다. 한 분야에 편향된 결정이 내려지기 쉽다. 해결책은 분야 간 트레이드오프가 있는 결정은 Teams에서 토론하는 것이다.

**"무한 토론" 안티 패턴**: 합의가 안 되어 계속 같은 논점을 반복하는 상황이다. 해결책은 최대 토론 라운드를 3회로 제한하고, 합의 불가 시 오케스트레이터가 결정하는 것이다.

**"사일로 실행" 안티 패턴**: Phase 2에서 팀 간 인터페이스를 무시하고 각자 알아서 구현하는 상황이다. Phase 3에서 통합이 안 된다. 해결책은 Phase 1에서 인터페이스(API 스펙, 데이터 포맷 등)를 먼저 합의하는 것이다.

**"리뷰 없는 병합" 안티 패턴**: Phase 3를 건너뛰고 바로 완료 처리하는 상황이다. 분야 간 불일치가 사용자에게 전달된다. 해결책은 Phase 3에서 반드시 크로스 도메인 체크리스트를 적용하는 것이다.

---

## 9. 체크리스트: 프로젝트 설계 완료 확인

프로젝트 설계를 마무리하기 전에 아래 항목을 확인한다.

```
□ 프로젝트 정보 카드가 작성되었는가?
□ 복잡도에 맞는 아키텍처 구조가 선택되었는가?
□ 모든 리드 에이전트의 역할과 책임이 정의되었는가?
□ 리드 간 의사결정 권한 범위가 명확한가?
□ Subagent 작업이 구체적인 입출력과 함께 정의되었는가?
□ 분야 간 인터페이스(API 스펙 등)가 사전 합의 항목에 포함되었는가?
□ 에스컬레이션 경로가 정의되었는가?
□ 3단계 사이클(합의 → 실행 → 검토)이 프로젝트에 맞게 조정되었는가?
□ 안티 패턴에 빠지지 않도록 가드레일이 설정되었는가?
□ 관련 Skills 파일이 식별되고 Subagent에 연결되었는가?
```

---

## 10. Git 워크플로우 & 커밋 컨벤션

작업 수행 시 아래 규칙을 따른다.

### 10-1. 커밋 메시지 형식

```
접두사:(티켓번호) 작업 내용
```

**접두사 종류**:
- `FEAT` — 기능 구현
- `FIX` — 버그 수정
- `RECT` — 리팩토링

**티켓 번호**: 기능 단위로 부여한다. (예: `AI-001`, `AI-002`, ...)

**예시**:
```
FEAT:(AI-001) 리뷰 분류 API 엔드포인트 구현
FIX:(AI-001) 리뷰 분류 시 빈 문자열 예외 처리
RECT:(AI-002) 대시보드 쿼리 로직 리팩토링
```

### 10-2. 브랜치 전략

`main`에 직접 푸시하지 않는다. 반드시 `root/기능브랜치`에 푸시한다.

```
main (직접 푸시 X)
 └── root/기능브랜치명   ← 여기에 푸시 후 PR
```

**브랜치 네이밍 예시**:
```
root/review-classification
root/dashboard-api
root/report-generation
```

### 10-3. PR(Pull Request) 작성

작업 완료 시 PR 내용을 함께 작성한다.

```markdown
## 작업 내용
- 구현/수정/리팩토링한 내용 요약

## 변경 사항
- 변경된 파일 및 주요 로직 설명

## 관련 티켓
- AI-000

## 테스트
- 테스트 방법 및 확인 사항
```

### 10-4. 코딩 도구 사용 시 참고

`ralplan ulw` 모드를 참고하여 작업을 수행한다.

---

## 11. Claude Code 플러그인 세팅 가이드

프로젝트 시작 전, 아래 3개의 Claude Code 플러그인을 반드시 설치 및 설정한다. 각 플러그인은 서로 다른 역할을 담당하며, 조합하여 사용할 때 오케스트레이션 효과가 극대화된다.

### 11-1. Oh My Claude Code (OMC) — 멀티 에이전트 오케스트레이션

**역할**: Teams 기반 멀티 에이전트 오케스트레이션 레이어. 32개 특화 에이전트, 40+ Skills, 자동 병렬화를 제공한다. 이 문서의 Teams/Subagent 구조를 실제 Claude Code 환경에서 실행하기 위한 핵심 도구이다.

**설치 방법**:
```bash
# Claude Code 내에서 실행
/plugin marketplace add https://github.com/Yeachan-Heo/oh-my-claudecode
/plugin install oh-my-claudecode

# 설치 후 셋업 위자드 실행
/oh-my-claudecode:omc-setup
```

**핵심 실행 모드**:
```yaml
modes:
  autopilot: "전체 자율 실행. 아이디어 → 구현 → 테스트까지 자동"
  ralph: "검증 완료까지 반복 실행. 'The boulder never stops rolling'"
  ulw: "병렬 에이전트 실행. 여러 작업을 동시에 처리 (3~5배 속도 향상)"
  team: "N개 에이전트가 공유 작업 목록으로 협업. 예: team 5:executor refactor backend"
  plan: "인터랙티브 계획 수립 인터뷰. 예: plan the auth system"
```

**프로젝트 연동 시 주의사항**:
- Claude Code의 Teams 기능이 활성화되어 있어야 한다 (비활성화 시 non-team 실행으로 폴백)
- tmux 세션이 활성 상태여야 멀티 에이전트 실행이 가능하다
- `ralplan ulw` 키워드로 계획 수립 + 병렬 실행을 조합할 수 있다

### 11-2. Superpowers — 구조화된 개발 방법론 프레임워크

**역할**: TDD(테스트 주도 개발), 체계적 디버깅, 소크라테스식 브레인스토밍, Subagent 기반 개발 + 코드 리뷰 등 검증된 소프트웨어 개발 방법론을 Claude Code에 주입한다. 20+ 프로덕션 검증 Skills를 포함한다.

**설치 방법**:
```bash
# Claude Code 내에서 실행
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace

# 설치 후 Claude Code를 종료하고 재시작
```

**핵심 워크플로우**:
```yaml
workflow:
  step_1_brainstorm:
    command: "/superpowers:brainstorm"
    description: "구현 전 요구사항 정제. 소크라테스식 질문으로 설계를 검증"
  step_2_plan:
    command: "/superpowers:write-plan"
    description: "마이크로 태스크 단위(2~5분)로 구조화된 계획 문서 생성"
  step_3_execute:
    command: "/superpowers:execute-plan"
    description: "배치 실행 + 리뷰 체크포인트. TDD red-green-refactor 사이클 강제"
```

**프로젝트 연동 시 주의사항**:
- Superpowers는 코드 작성 전 테스트를 먼저 작성하도록 강제한다 (테스트 없이 코드 작성 시 자동 삭제)
- 개인 Skills 저장소는 `~/.config/superpowers/skills/`에 위치하며, 프로젝트별 커스터마이즈 가능
- Phase 1(합의) 단계에서 `/superpowers:brainstorm`을 활용하면 리드 간 토론 품질이 높아진다

### 11-3. bkit — PDCA 기반 개발 파이프라인

**역할**: PDCA(Plan-Do-Check-Act) 방법론을 Claude Code에 적용하는 플러그인이다. 코드 작성 전 계획 문서, 설계 명세 작성을 강제하고, 기능 구현 후 갭 분석과 완료 보고서를 자동 생성한다. Context Engineering(컨텍스트 엔지니어링)을 체계적으로 관리한다.

**설치 방법**:
```bash
# Claude Code 내에서 실행
/plugin marketplace add popup-studio-ai/bkit-claude-code
/plugin install bkit

# 설치 후 Claude Code를 종료하고 재시작
```

**PDCA 사이클과 프로젝트 매핑**:
```yaml
pdca_cycle:
  Plan:
    description: "계획 문서 + 설계 명세 작성"
    maps_to: "Phase 1 (합의) — 리드들이 요구사항과 설계를 합의하는 단계"
  Do:
    description: "구현 실행 (코딩 컨벤션 + 구조 규칙 적용)"
    maps_to: "Phase 2 (병렬 실행) — Subagent들이 작업을 병렬 수행하는 단계"
  Check:
    description: "갭 분석 (구현 결과 vs 계획 대비 검증)"
    maps_to: "Phase 3 (통합 검토) — 리드들이 크로스 체크하는 단계"
  Act:
    description: "완료 보고서 생성 + 학습 사항 기록"
    maps_to: "사이클 완료 후 회고 및 다음 이터레이션 준비"
```

**프로젝트 연동 시 주의사항**:
- bkit은 3계층 컨텍스트 관리를 사용한다: hooks.json(글로벌) → Skill Frontmatter(도메인별) → 런타임 컨텍스트
- 프로젝트별 커스터마이즈가 필요한 경우 `~/.claude/plugins/bkit/skills/`에서 `.claude/skills/`로 복사하여 오버라이드한다
- 커스터마이즈한 파일은 플러그인 업데이트 시 자동 갱신되지 않으므로 CHANGELOG을 주기적으로 확인한다

### 11-4. 플러그인 조합 전략

세 플러그인은 아래처럼 역할을 분담한다.

```
┌──────────────────────────────────────────────────────────────────┐
│                    프로젝트 오케스트레이션                         │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  [OMC]              [Superpowers]           [bkit]               │
│  멀티 에이전트        개발 방법론              프로세스 관리         │
│  오케스트레이션       (TDD, 디버깅, 리뷰)      (PDCA 사이클)        │
│                                                                  │
│  ● Teams 실행        ● brainstorm → plan     ● Plan 문서 생성     │
│  ● 병렬 에이전트        → execute 워크플로우   ● Gap 분석           │
│  ● autopilot/ulw     ● 코드 리뷰 자동화       ● 완료 보고서        │
│  ● ralplan 모드       ● TDD 강제              ● 컨벤션 관리        │
│                                                                  │
├──────────────────────────────────────────────────────────────────┤
│  Phase 1(합의)       Phase 2(실행)            Phase 3(검토)       │
│  OMC team 모드 +     OMC ulw 병렬 실행 +      bkit Check +        │
│  Superpowers         Superpowers TDD +       Superpowers         │
│  brainstorm          bkit Do                 code-review         │
└──────────────────────────────────────────────────────────────────┘
```

**권장 초기 세팅 순서**:
1. Claude Code 최신 버전 설치 및 Teams 기능 활성화
2. OMC 설치 → `/omc-setup` 실행
3. Superpowers 설치 → 재시작 → Skills 로딩 확인
4. bkit 설치 → 재시작 → PDCA 워크플로우 확인
5. 프로젝트 루트에 `.claude/` 디렉토리 생성하여 프로젝트별 설정 커스터마이즈

---

## 12. 프로젝트 문서 작성 가이드라인: PRD, Tasks, Rules

프로젝트를 시작하면 코드를 작성하기 전에 반드시 아래 3개 문서를 먼저 작성한다. 이 문서들은 오케스트레이션의 "연료"이다. 문서 없이 실행하면 에이전트들이 각자 다른 방향으로 움직인다.

```
프로젝트 루트/
├── docs/
│   ├── PRD.md              # 무엇을 만들 것인가 (What & Why)
│   ├── TASKS.md            # 어떤 순서로 만들 것인가 (How & When)
│   └── RULES.md            # 어떤 기준으로 만들 것인가 (Standards)
├── .claude/                # Claude Code 프로젝트 설정
└── src/                    # 소스 코드
```

### 12-1. PRD (Product Requirements Document) — 제품 요구사항 문서

PRD는 **"무엇을 왜 만드는가"**를 정의하는 문서이다. Phase 1(합의) 단계에서 기획 리드가 초안을 작성하고, 다른 리드들이 피드백하여 완성한다. PRD가 확정되어야 Phase 2(병렬 실행)로 넘어갈 수 있다.

#### PRD 작성 템플릿

```markdown
# PRD: [기능/프로젝트명]

## 1. 개요 (Overview)
- **문서 버전**: v1.0
- **작성일**: YYYY-MM-DD
- **작성자**: [기획 리드 또는 담당자]
- **상태**: Draft | In Review | Approved

### 1-1. 한 줄 요약
> 이 기능/프로젝트가 무엇인지 한 문장으로 설명한다.
> 예: "사업자가 자신의 리뷰를 한눈에 관리하고 AI 분석 리포트를 받을 수 있는 대시보드"

### 1-2. 배경 및 문제 정의 (Background & Problem)
현재 상황에서 어떤 문제가 있는지 구체적으로 서술한다.
- **현재 상태**: 지금 사용자/시스템이 어떤 상황인지
- **문제점**: 무엇이 불편하거나 부족한지
- **영향 범위**: 이 문제가 누구에게, 얼마나 영향을 주는지
- **해결하지 않으면**: 이 문제를 방치했을 때 예상되는 결과

### 1-3. 목표 (Goals)
이 프로젝트가 성공하면 어떤 상태가 되는지 측정 가능한 목표를 정의한다.
- **핵심 목표**: 반드시 달성해야 하는 것 (1~3개)
- **보조 목표**: 달성하면 좋은 것 (1~3개)
- **비목표 (Non-goals)**: 이번 프로젝트에서 명시적으로 하지 않는 것

## 2. 사용자 정의 (Target Users)

### 2-1. 주요 사용자 페르소나
각 사용자 유형별로 아래를 정의한다:
| 항목 | 내용 |
|------|------|
| 페르소나 이름 | 예: "김사장님" (소규모 렌터카 사업자) |
| 역할/직업 | 렌터카 업체 대표 |
| 핵심 니즈 | 리뷰를 한눈에 보고 싶다 |
| 페인 포인트 | 여러 플랫폼에 흩어진 리뷰를 일일이 확인해야 한다 |
| 기술 수준 | 스마트폰 기본 조작 가능, IT 비전문가 |

### 2-2. 사용자 시나리오 (User Scenarios)
사용자가 이 기능을 사용하는 구체적인 상황을 시나리오로 작성한다.
```
시나리오 1: [시나리오 제목]
- 상황: [사용자가 처한 상황]
- 행동: [사용자가 취하는 행동 순서]
- 기대 결과: [사용자가 원하는 결과]
```

## 3. 기능 요구사항 (Functional Requirements)

### 3-1. 사용자 스토리 목록
우선순위별로 사용자 스토리를 나열한다.

| 우선순위 | ID | 사용자 스토리 | 수용 기준 |
|---------|-----|-------------|----------|
| P0 (필수) | US-001 | ~로서, ~하고 싶다, ~하기 위해 | ① 조건1 ② 조건2 ③ 조건3 |
| P0 (필수) | US-002 | ~로서, ~하고 싶다, ~하기 위해 | ① 조건1 ② 조건2 |
| P1 (중요) | US-003 | ~로서, ~하고 싶다, ~하기 위해 | ① 조건1 ② 조건2 |
| P2 (있으면 좋음) | US-004 | ~로서, ~하고 싶다, ~하기 위해 | ① 조건1 |

**우선순위 기준**:
- **P0 (필수)**: 이것 없으면 제품이 동작하지 않거나 핵심 가치를 제공하지 못함
- **P1 (중요)**: 핵심 가치를 강화하지만, 없어도 MVP는 가능
- **P2 (있으면 좋음)**: 사용자 경험을 개선하지만 후속 버전으로 미뤄도 무방

### 3-2. 기능 상세 명세
각 P0 기능에 대해 아래를 작성한다:

```markdown
#### 기능명: [기능 이름]
- **설명**: 이 기능이 무엇을 하는지
- **입력**: 사용자가 제공하는 것 (데이터, 액션 등)
- **처리**: 시스템이 내부적으로 수행하는 로직
- **출력**: 사용자에게 돌려주는 결과
- **예외 처리**: 에러 상황별 대응 방법
- **UI/UX 참고**: 와이어프레임 또는 UI 흐름 설명
```

## 4. 비기능 요구사항 (Non-Functional Requirements)
- **성능**: 응답 시간, 동시 접속자 수, 처리량
- **보안**: 인증/인가 방식, 데이터 암호화, 개인정보 처리
- **확장성**: 향후 확장 고려사항
- **호환성**: 지원 브라우저, 디바이스, OS
- **접근성**: 웹 접근성 기준 (WCAG 등)

## 5. 기술 제약사항 (Technical Constraints)
- **기술 스택**: 사용해야 하는 언어, 프레임워크, 인프라
- **외부 연동**: 연동해야 하는 API, 서비스
- **데이터**: 데이터 소스, 스키마, 마이그레이션 필요 여부
- **인프라**: 배포 환경, CI/CD 파이프라인

## 6. 마일스톤 & 일정 (Milestones)
| 마일스톤 | 내용 | 예상 완료일 |
|---------|------|-----------|
| M1 | 설계 완료 (PRD 확정 + 아키텍처 합의) | YYYY-MM-DD |
| M2 | MVP 개발 완료 (P0 기능 구현) | YYYY-MM-DD |
| M3 | 테스트 및 QA | YYYY-MM-DD |
| M4 | 런칭 | YYYY-MM-DD |

## 7. 성공 지표 (Success Metrics)
- **핵심 KPI**: 측정 가능한 성공 기준 (예: DAU, 전환율, 응답 시간)
- **측정 방법**: 어떻게 데이터를 수집하고 측정할 것인지
- **목표 수치**: 런칭 후 N주/N개월 내 달성할 수치

## 8. 리스크 & 완화 방안 (Risks & Mitigations)
| 리스크 | 발생 확률 | 영향도 | 완화 방안 |
|--------|---------|--------|----------|
| 예: 외부 API 응답 지연 | 중 | 높음 | 캐싱 레이어 추가 + 타임아웃 설정 |

## 9. 부록 (Appendix)
- 관련 문서 링크
- 참고 자료
- 용어 정의
```

#### PRD 작성 시 핵심 원칙

**구체적으로 작성한다**: "사용자가 편하게 쓸 수 있어야 한다" (X) → "리뷰 목록이 3초 이내에 로딩되고, 한 화면에 최근 30일 리뷰가 표시되어야 한다" (O)

**수용 기준은 테스트 가능하게 작성한다**: 개발자가 읽고 "이걸 통과하면 완료"라고 판단할 수 있어야 한다. "~하면 ~가 된다" 형식으로 작성하고, 예외 케이스도 포함한다.

**비목표(Non-goals)를 명시한다**: "이번에 하지 않는 것"을 적어야 scope creep(범위 팽창)을 방지할 수 있다. 이것이 없으면 리드 간 합의 시 끊임없이 새로운 기능이 추가된다.

**변경 이력을 관리한다**: PRD는 살아있는 문서이다. 합의 내용이 바뀔 때마다 버전을 올리고, 무엇이 왜 바뀌었는지 기록한다.

---

### 12-2. Tasks — 작업 분해 문서

Tasks는 PRD에서 정의된 기능을 **실행 가능한 단위 작업으로 분해**한 문서이다. Phase 1(합의) 단계에서 리드들이 함께 작성하며, Phase 2(병렬 실행)에서 Subagent에게 위임하는 단위가 된다.

#### Tasks 작성 템플릿

```markdown
# TASKS: [기능/프로젝트명]

## 메타 정보
- **PRD 참조**: docs/PRD.md (버전: v1.0)
- **작성일**: YYYY-MM-DD
- **마지막 업데이트**: YYYY-MM-DD

---

## 에픽 1: [에픽 이름] (PRD 섹션 3-2의 기능 단위)

### TASK-001: [작업 제목]
- **티켓**: AI-001
- **유형**: FEAT | FIX | RECT
- **담당 리드**: lead-backend
- **담당 Subagent**: sub-api-impl
- **우선순위**: P0 | P1 | P2
- **예상 소요**: 2h | 4h | 1d | 2d
- **상태**: todo | in_progress | review | done

**설명**:
이 작업이 무엇을 구현/수정하는지 2~3문장으로 명확히 서술한다.

**선행 작업 (depends_on)**:
- 없음 (또는 TASK-XXX 완료 후 시작 가능)

**후행 작업 (blocks)**:
- TASK-003, TASK-004 가 이 작업 완료를 기다리고 있음

**수용 기준 (Acceptance Criteria)**:
- [ ] 기준 1: 구체적이고 테스트 가능한 조건
- [ ] 기준 2: 구체적이고 테스트 가능한 조건
- [ ] 기준 3: 에러 케이스 처리 확인

**기술 명세 (Technical Spec)**:
```yaml
endpoint: "POST /api/v1/reviews/classify"
input:
  - review_id: string (required)
  - review_text: string (required)
output:
  - tags: string[] (17개 분류 태그 중 해당하는 것)
  - confidence: float (0.0 ~ 1.0)
db_changes:
  - reviews 테이블에 tags 컬럼 추가 (jsonb)
참고_skills:
  - "fastapi-conventions"
  - "error-handling-guide"
```

**커밋 & 브랜치**:
- 브랜치: `root/review-classification`
- 커밋 예시: `FEAT:(AI-001) 리뷰 분류 API 엔드포인트 구현`

---

### TASK-002: [작업 제목]
... (동일 형식 반복)

---

## 에픽 2: [에픽 이름]

### TASK-010: [작업 제목]
... (동일 형식 반복)
```

#### Tasks 작성 시 핵심 원칙

**하나의 Task = 하나의 Subagent 작업 단위이다**: Task 하나가 너무 크면 Subagent가 컨텍스트를 잃는다. "한 번에 집중해서 2~4시간 안에 끝낼 수 있는 크기"가 적절하다. 하루 이상 걸리는 Task는 분할한다.

**의존성 그래프를 명확히 한다**: `depends_on`과 `blocks`를 반드시 적어야 Phase 2에서 병렬 실행 가능한 작업과 순차 실행해야 하는 작업을 구분할 수 있다. 의존성이 없는 Task들은 OMC의 `ulw` 모드로 동시 실행한다.

```
의존성 그래프 예시:

TASK-001 (DB 스키마)  ──→  TASK-003 (API 구현)  ──→  TASK-005 (테스트)
TASK-002 (설정 파일)  ──→  TASK-003 (API 구현)
                          TASK-004 (프론트 UI)  ──→  TASK-006 (통합 테스트)

→ TASK-001, TASK-002는 병렬 실행 가능 (ulw)
→ TASK-003은 TASK-001, 002 완료 후 시작
→ TASK-004는 TASK-003과 병렬 가능 (API 스펙만 합의되어 있다면)
```

**티켓 번호는 기능 단위로 부여한다**: 같은 기능에 속하는 TASK들은 같은 티켓 번호를 공유한다. FEAT/FIX/RECT 접두사로 작업 성격을 구분한다.

```
AI-001: 리뷰 분류 기능
  ├── FEAT:(AI-001) 리뷰 분류 API 엔드포인트 구현
  ├── FEAT:(AI-001) 리뷰 분류 모델 연동
  └── FIX:(AI-001) 빈 리뷰 텍스트 예외 처리

AI-002: 대시보드 기능
  ├── FEAT:(AI-002) 대시보드 메인 페이지 API
  ├── FEAT:(AI-002) 대시보드 차트 데이터 집계
  └── RECT:(AI-002) 대시보드 쿼리 성능 리팩토링
```

**상태 전이 규칙을 지킨다**: Task의 상태는 아래 흐름만 허용한다. 역방향 전이는 Phase 3(통합 검토)에서 이슈가 발견된 경우에만 가능하다.

```
todo → in_progress → review → done
                       │
                       └──→ in_progress (Phase 3에서 수정 요청 시)
```

---

### 12-3. Rules — 프로젝트 규칙 문서

Rules는 **프로젝트 전체에서 모든 에이전트가 준수해야 하는 코딩 컨벤션, 아키텍처 원칙, 커뮤니케이션 규칙**을 정의한 문서이다. Subagent가 작업할 때 이 문서를 참조하여 일관된 품질을 유지한다. Claude Code의 `CLAUDE.md` 또는 `.claude/settings.json`과 연동하면 자동으로 적용된다.

#### Rules 작성 템플릿

```markdown
# RULES: [프로젝트명] 프로젝트 규칙

## 메타 정보
- **적용 범위**: 이 프로젝트의 모든 코드, 문서, 커뮤니케이션
- **최종 수정일**: YYYY-MM-DD
- **버전**: v1.0

---

## 1. 코딩 컨벤션 (Coding Conventions)

### 1-1. 언어별 스타일 가이드

#### Python (FastAPI)
- **포매터**: black (line-length: 88)
- **린터**: ruff
- **타입 힌트**: 모든 함수의 파라미터와 리턴 타입에 필수
- **독스트링**: 공개 함수/클래스에 Google 스타일 독스트링 필수
- **임포트 순서**: 표준 라이브러리 → 서드파티 → 로컬 (isort 적용)

```python
# ✅ 올바른 예시
async def classify_review(
    review_id: str,
    review_text: str,
    db: AsyncSession = Depends(get_db),
) -> ReviewClassificationResponse:
    """리뷰를 분류하고 태그를 반환한다.

    Args:
        review_id: 리뷰 고유 식별자
        review_text: 분류할 리뷰 텍스트

    Returns:
        분류 태그와 신뢰도를 포함한 응답

    Raises:
        ReviewNotFoundError: 리뷰 ID가 존재하지 않을 때
        EmptyReviewError: 리뷰 텍스트가 비어있을 때
    """

# ❌ 잘못된 예시
async def classify_review(review_id, review_text, db=Depends(get_db)):
    # 타입 힌트 없음, 독스트링 없음
```

#### HTML / Jinja
- **들여쓰기**: 2 spaces
- **속성 순서**: id → class → data-* → 기타
- **Jinja 블록 주석**: 블록 시작/끝에 주석 명시

#### JavaScript / TypeScript (해당되는 경우)
- **포매터**: prettier
- **린터**: eslint
- **세미콜론**: 사용
- **따옴표**: 싱글 쿼트

### 1-2. 네이밍 컨벤션

```yaml
naming:
  files:
    python: snake_case.py          # 예: review_classifier.py
    api_routes: snake_case.py      # 예: review_routes.py
    templates: snake_case.html     # 예: dashboard_main.html
    tests: test_snake_case.py      # 예: test_review_classifier.py

  code:
    변수: snake_case               # 예: review_count
    함수: snake_case               # 예: get_review_list()
    클래스: PascalCase             # 예: ReviewClassifier
    상수: UPPER_SNAKE_CASE         # 예: MAX_REVIEW_LENGTH
    프라이빗: _leading_underscore   # 예: _parse_raw_data()

  database:
    테이블: snake_case (복수형)      # 예: reviews, review_tags
    컬럼: snake_case               # 예: created_at, review_text
    인덱스: idx_{table}_{column}    # 예: idx_reviews_created_at
    FK: fk_{table}_{ref_table}     # 예: fk_reviews_users

  api:
    URL: kebab-case                # 예: /api/v1/review-reports
    쿼리파라미터: snake_case        # 예: ?start_date=2025-01-01
    JSON 필드: snake_case          # 예: { "review_id": "..." }

  git:
    브랜치: root/{feature-name}    # 예: root/review-classification
    커밋: "TYPE:(TICKET) 내용"     # 예: FEAT:(AI-001) 리뷰 분류 API 구현
```

### 1-3. 프로젝트 디렉토리 구조

```
프로젝트 루트/
├── docs/
│   ├── PRD.md
│   ├── TASKS.md
│   └── RULES.md
├── src/
│   ├── api/                    # API 라우트 (엔드포인트 정의만)
│   │   └── v1/
│   │       ├── review_routes.py
│   │       └── dashboard_routes.py
│   ├── service/                # 비즈니스 로직
│   │   ├── review_service.py
│   │   └── dashboard_service.py
│   ├── repository/             # 데이터 접근 계층
│   │   ├── review_repository.py
│   │   └── dashboard_repository.py
│   ├── model/                  # DB 모델 (SQLAlchemy 등)
│   │   ├── review.py
│   │   └── user.py
│   ├── schema/                 # 요청/응답 스키마 (Pydantic)
│   │   ├── review_schema.py
│   │   └── dashboard_schema.py
│   ├── core/                   # 공통 설정, 미들웨어, 의존성
│   │   ├── config.py
│   │   ├── database.py
│   │   └── dependencies.py
│   └── util/                   # 유틸리티 함수
│       └── date_util.py
├── tests/
│   ├── unit/
│   ├── integration/
│   └── conftest.py
├── templates/                  # Jinja 템플릿 (HTML)
├── static/                     # 정적 파일 (CSS, JS, 이미지)
├── docker/
│   ├── Dockerfile
│   └── docker-compose.yml
├── .claude/                    # Claude Code 프로젝트 설정
│   └── settings.json
├── CLAUDE.md                   # Claude Code 컨텍스트 파일
└── pyproject.toml
```

## 2. 아키텍처 원칙 (Architecture Principles)

### 2-1. 레이어드 아키텍처 규칙

```
요청 흐름: Route → Service → Repository → Model
응답 흐름: Model → Repository → Service → Route

각 레이어의 책임:
- Route (API):    요청 파싱, 응답 포맷팅, 인증/인가 체크만 수행
- Service:        비즈니스 로직, 트랜잭션 관리, 외부 서비스 호출 조율
- Repository:     DB 쿼리 실행, 데이터 매핑만 수행
- Model:          테이블 정의, 관계(relationship) 설정만 수행
```

**금지 사항**:
- Route에서 직접 DB 쿼리를 실행하지 않는다
- Repository에서 비즈니스 로직을 처리하지 않는다
- Service에서 HTTP 요청/응답 객체를 직접 다루지 않는다
- Model에서 비즈니스 로직이나 쿼리 로직을 넣지 않는다

### 2-2. 에러 처리 원칙

```python
# 커스텀 예외 체계
class AppException(Exception):
    """모든 커스텀 예외의 베이스 클래스"""
    status_code: int = 500
    error_code: str = "INTERNAL_ERROR"
    message: str = "내부 서버 오류가 발생했습니다"

class NotFoundError(AppException):
    status_code = 404
    error_code = "NOT_FOUND"

class ValidationError(AppException):
    status_code = 422
    error_code = "VALIDATION_ERROR"

class AuthenticationError(AppException):
    status_code = 401
    error_code = "AUTHENTICATION_ERROR"
```

- 모든 예외는 `AppException`을 상속한다
- Service 레이어에서 비즈니스 예외를 발생시킨다
- Route 레이어의 글로벌 예외 핸들러가 일관된 에러 응답 포맷으로 변환한다
- 에러 응답 형식: `{ "error_code": "...", "message": "...", "detail": {} }`

### 2-3. API 설계 원칙

```yaml
api_rules:
  versioning: "/api/v1/..." (URL 경로 버저닝)
  authentication: "Bearer Token (JWT 또는 API Key)"
  pagination:
    default_limit: 20
    max_limit: 100
    format: "offset 기반 { offset, limit, total }"
  response_format:
    success: '{ "data": {...}, "meta": { "timestamp": "..." } }'
    error: '{ "error_code": "...", "message": "...", "detail": {} }'
    list: '{ "data": [...], "pagination": { "offset": 0, "limit": 20, "total": 150 } }'
  naming:
    collection: "복수형 명사 (GET /reviews, POST /reviews)"
    single_resource: "단수형 경로 파라미터 (GET /reviews/{review_id})"
    action: "동사 허용 (POST /reviews/{review_id}/classify)"
```

## 3. Git & 협업 규칙 (Git & Collaboration Rules)

### 3-1. 커밋 규칙

```yaml
commit_rules:
  format: "TYPE:(TICKET) 작업 내용"
  types:
    FEAT: "새로운 기능 구현"
    FIX: "버그 수정"
    RECT: "리팩토링 (기능 변경 없음)"
  rules:
    - "커밋 하나는 하나의 논리적 변경만 포함한다"
    - "커밋 메시지는 한글로 작성하며, 현재형으로 쓴다"
    - "커밋 메시지 제목은 50자 이내로 작성한다"
    - "필요 시 본문에 '왜' 이 변경을 했는지 기록한다"
  examples:
    - "FEAT:(AI-001) 리뷰 분류 API 엔드포인트 구현"
    - "FIX:(AI-001) 빈 리뷰 텍스트 입력 시 500 에러 수정"
    - "RECT:(AI-002) 대시보드 쿼리를 ORM에서 raw SQL로 변경"
```

### 3-2. 브랜치 규칙

```yaml
branch_rules:
  main: "직접 푸시 금지. PR을 통해서만 병합"
  feature: "root/{feature-name} 형식"
  naming_examples:
    - "root/review-classification"
    - "root/dashboard-api"
    - "root/report-generation"
  rules:
    - "하나의 브랜치는 하나의 기능(에픽) 단위"
    - "브랜치명은 kebab-case 영문으로 작성"
    - "작업 완료 후 PR 생성 → 리뷰 → main 병합"
```

### 3-3. PR 작성 규칙

```markdown
## PR 템플릿

### 작업 내용
- 이 PR이 무엇을 구현/수정/개선하는지 요약

### 변경 사항
- 변경된 파일과 주요 로직 설명
- 새로 추가된 파일이 있다면 역할 설명

### 관련 티켓
- AI-000

### 스크린샷/테스트 결과 (해당되는 경우)
- API 응답 스크린샷 또는 테스트 통과 캡처

### 체크리스트
- [ ] 타입 힌트가 모든 함수에 적용되어 있는가
- [ ] 테스트가 작성되었는가 (단위/통합)
- [ ] 에러 처리가 적절한가
- [ ] RULES.md의 네이밍 컨벤션을 따르는가
- [ ] 불필요한 주석이나 디버그 코드가 제거되었는가
```

## 4. 테스트 규칙 (Testing Rules)

```yaml
testing_rules:
  unit_test:
    framework: "pytest"
    naming: "test_{function_name}_{scenario}"
    coverage_target: "80% 이상"
    rules:
      - "Service 레이어의 모든 공개 메서드에 단위 테스트 작성"
      - "성공 케이스 + 최소 1개 실패 케이스 포함"
      - "외부 의존성은 mock 처리"

  integration_test:
    rules:
      - "API 엔드포인트별 최소 1개 통합 테스트"
      - "DB 연동이 필요한 테스트는 테스트 DB 사용"

  test_example: |
    # ✅ 좋은 테스트 이름
    def test_classify_review_returns_tags_for_valid_input():
    def test_classify_review_raises_error_for_empty_text():
    def test_classify_review_handles_special_characters():

    # ❌ 나쁜 테스트 이름
    def test_classify():
    def test_1():
    def test_review_function():
```

## 5. 보안 규칙 (Security Rules)

```yaml
security_rules:
  secrets:
    - "API 키, DB 비밀번호 등은 환경 변수로 관리한다"
    - ".env 파일은 절대 Git에 커밋하지 않는다"
    - "시크릿 값은 로그에 출력하지 않는다"

  input_validation:
    - "모든 사용자 입력은 Pydantic 스키마로 검증한다"
    - "SQL 인젝션 방지: ORM 사용, raw SQL 시 파라미터 바인딩 필수"
    - "XSS 방지: 템플릿 렌더링 시 자동 이스케이프 확인"

  authentication:
    - "인증이 필요한 엔드포인트는 Depends()로 인증 미들웨어를 적용한다"
    - "권한 체크는 Service 레이어에서 수행한다"
```

## 6. 에이전트 작업 규칙 (Agent Work Rules)

```yaml
agent_rules:
  subagent:
    - "작업 시작 전 RULES.md를 읽고 컨벤션을 파악한다"
    - "요구사항이 모호하면 코드 작성 전에 리드에게 질문한다"
    - "커밋 전에 린터(ruff)와 포매터(black)를 실행한다"
    - "새 파일 생성 시 디렉토리 구조 규칙을 따른다"
    - "참고할 Skills 문서가 지정되어 있으면 반드시 읽고 따른다"

  lead:
    - "Subagent에게 작업 위임 시 TASKS.md의 해당 Task를 명시한다"
    - "Phase 3 리뷰 시 RULES.md 체크리스트를 기준으로 검토한다"
    - "다른 리드와 합의할 때 기술 용어 사용 시 설명을 포함한다"

  orchestrator:
    - "3라운드 토론 후 합의 안 되면 트레이드오프를 정리하고 결정한다"
    - "Phase 전환 시 모든 리드에게 알리고 확인받는다"
```
```

#### Rules 작성 시 핵심 원칙

**예시를 반드시 포함한다**: 규칙만 나열하면 해석이 달라진다. "✅ 올바른 예시"와 "❌ 잘못된 예시"를 함께 작성해야 Subagent가 정확히 따를 수 있다.

**CLAUDE.md와 연동한다**: Rules의 핵심 내용을 프로젝트 루트의 `CLAUDE.md`에 요약해 놓으면, Claude Code가 세션 시작 시 자동으로 읽고 모든 작업에 적용한다.

```markdown
# CLAUDE.md 예시 (프로젝트 루트)
이 프로젝트의 상세 규칙은 docs/RULES.md를 참조한다.

## 필수 규칙 요약
- 레이어드 아키텍처: Route → Service → Repository → Model
- 커밋: "TYPE:(TICKET) 내용" 형식 (FEAT/FIX/RECT)
- 브랜치: root/{feature-name}, main 직접 푸시 금지
- 타입 힌트 필수, black + ruff 적용
- 테스트 커버리지 80% 이상
```

**팀의 현재 기술 스택에 맞게 구체적으로 작성한다**: "좋은 코드를 작성한다" (X) → "black line-length 88, ruff 린팅, Google 스타일 독스트링을 적용한다" (O). 추상적인 규칙은 Subagent가 자의적으로 해석한다.

**규칙 간 충돌을 방지한다**: 두 규칙이 모순되면 Subagent가 멈추거나 잘못된 선택을 한다. 우선순위가 있는 경우 명시하고, 정기적으로 규칙 간 정합성을 검토한다.

---

### 12-4. 세 문서의 관계와 작성 흐름

```
[PRD]                    [Tasks]                  [Rules]
무엇을 왜 만드는가        어떤 순서로 만드는가       어떤 기준으로 만드는가
─────────────────       ─────────────────       ─────────────────
사용자 스토리     ──────→  Task로 분해              │
수용 기준        ──────→  수용 기준 상속    ◄───── 품질 기준 적용
기술 제약사항     ──────→  기술 명세 반영    ◄───── 아키텍처 원칙 적용
마일스톤         ──────→  일정 배분               │
```

**작성 순서**:
1. **Rules 먼저 작성** — 프로젝트의 코딩 컨벤션, 아키텍처 원칙, Git 규칙은 기능과 무관하게 먼저 정해야 한다. 기존 프로젝트가 있다면 현재 코드 스타일을 분석하여 작성한다.
2. **PRD 작성** — Rules가 정해진 상태에서 "무엇을 만들 것인가"를 정의한다. 기술 제약사항 섹션에서 Rules의 아키텍처 원칙을 참조한다.
3. **Tasks 작성** — PRD의 기능 요구사항을 실행 가능한 단위로 분해한다. 각 Task는 Rules의 컨벤션을 따라야 하며, PRD의 수용 기준을 상속한다.

**Phase와의 매핑**:
- **Phase 1 (합의)**: 리드들이 PRD를 검토하고 Tasks를 함께 작성한다. Rules에 추가할 합의사항이 있으면 반영한다.
- **Phase 2 (병렬 실행)**: Subagent가 Tasks를 받아서 실행한다. 이때 Rules를 참고하여 코딩 컨벤션을 따른다.
- **Phase 3 (통합 검토)**: 리드들이 PRD의 수용 기준과 Rules의 체크리스트로 결과물을 검증한다.

---

## 13. 소프트웨어 설계 방법론: DDD, TDD, Clean Code, Architecture

이 섹션은 프로젝트의 코드 품질과 설계 수준을 결정하는 4가지 핵심 방법론을 정의한다. 모든 에이전트(리드, Subagent)는 코드를 작성하기 전에 이 원칙들을 숙지하고 적용해야 한다.

```
┌─────────────────────────────────────────────────────────────┐
│                소프트웨어 설계 방법론 4축                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   [DDD]                        [Architecture]               │
│   도메인 중심 설계               시스템 구조 설계              │
│   "비즈니스를 코드에 담는 방법"    "컴포넌트를 조립하는 방법"     │
│        │                              │                     │
│        ▼                              ▼                     │
│   [Clean Code]                 [TDD]                        │
│   읽기 좋은 코드 작성            테스트 주도 개발               │
│   "코드를 깨끗하게 유지하는 방법"  "검증하면서 만드는 방법"       │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│  Phase 1(합의): DDD + Architecture로 설계 결정               │
│  Phase 2(실행): TDD + Clean Code로 구현                      │
│  Phase 3(검토): 4가지 모두 검증 기준으로 적용                  │
└─────────────────────────────────────────────────────────────┘
```

---

### 13-1. DDD (Domain-Driven Design) — 도메인 주도 설계

DDD는 **비즈니스 도메인(현실 세계의 문제 영역)을 코드 구조의 중심**에 놓는 설계 방법이다. 기술이 아니라 비즈니스 언어가 코드의 뼈대가 된다.

#### 왜 DDD를 적용하는가

기술 중심으로 코드를 짜면 `utils/helper.py`에 모든 로직이 모이고, `service/` 폴더에 수백 줄짜리 God 클래스가 생긴다. DDD를 적용하면 "리뷰", "사업자", "리포트"처럼 비즈니스 개념이 곧 코드 단위가 되어, 코드를 읽는 것만으로 비즈니스를 이해할 수 있다.

#### DDD 핵심 개념

**유비쿼터스 언어 (Ubiquitous Language)**

개발자, 기획자, 디자이너가 모두 같은 용어를 쓴다. 코드에서도 이 용어를 그대로 사용한다.

```yaml
ubiquitous_language:
  정의: "팀 전원이 동일하게 사용하는 도메인 용어 사전"
  규칙:
    - "코드의 클래스명, 메서드명, 변수명은 유비쿼터스 언어를 따른다"
    - "PRD에서 사용한 용어와 코드의 용어가 1:1로 대응해야 한다"
    - "기술 용어로 번역하지 않는다 (translate X → 도메인 용어 그대로 사용 O)"

  example:
    prd_term: "리뷰 분류"
    code_mapping:
      class: ReviewClassification     # ✅ 도메인 용어 그대로
      method: classify_review()       # ✅
      variable: classification_tags   # ✅
    wrong_mapping:
      class: DataProcessor            # ❌ 기술 중심 네이밍
      method: process_data()          # ❌ 도메인 의미 없음
      variable: result_list           # ❌ 무엇의 결과인지 불명확
```

프로젝트 시작 시 **도메인 용어 사전**을 작성한다:

```markdown
## 도메인 용어 사전 (Glossary)

| 도메인 용어 | 영문 | 설명 | 코드에서의 표현 |
|-----------|------|------|---------------|
| 리뷰 | Review | 고객이 렌터카 이용 후 남기는 평가 | `Review`, `review` |
| 리뷰 분류 | Review Classification | 리뷰에 태그를 자동 부여하는 행위 | `ReviewClassification`, `classify_review()` |
| 사업자 | Business Owner | 렌터카 업체를 운영하는 사람 | `BusinessOwner`, `business_owner` |
| 리포트 | Report | AI가 생성한 리뷰 분석 보고서 | `Report`, `generate_report()` |
| 대시보드 | Dashboard | 사업자가 리뷰 현황을 조회하는 화면 | `Dashboard`, `dashboard` |
| 분류 태그 | Classification Tag | 리뷰에 부여되는 카테고리 라벨 (17종) | `ClassificationTag`, `tag` |
```

**바운디드 컨텍스트 (Bounded Context)**

하나의 도메인 용어가 맥락에 따라 다른 의미를 가질 수 있다. 바운디드 컨텍스트는 "이 용어가 이 의미로 통하는 경계"를 정의한다.

```
┌─────────────────────┐    ┌─────────────────────┐
│   리뷰 관리 컨텍스트   │    │   리포트 컨텍스트     │
│                     │    │                     │
│ Review:             │    │ Review:             │
│  - review_text      │    │  - sentiment_score  │
│  - rating           │    │  - tag_distribution │
│  - created_at       │    │  - period           │
│  - classify()       │    │  - aggregate()      │
│                     │    │                     │
│ → 여기서 Review는    │    │ → 여기서 Review는    │
│   "개별 리뷰 원문"    │    │   "분석 대상 데이터"  │
└─────────────────────┘    └─────────────────────┘
         │                          │
         └─────── 같은 단어 "Review"지만 ──────┘
                  맥락에 따라 다른 모델
```

```yaml
bounded_contexts:
  review_management:
    description: "리뷰 수집, 저장, 분류를 담당하는 컨텍스트"
    entities: [Review, ReviewClassification, ClassificationTag]
    owner: "lead-backend"
    rules:
      - "리뷰 원문 데이터의 CRUD를 담당한다"
      - "분류 태그 부여 로직을 소유한다"

  reporting:
    description: "리뷰 데이터를 집계하여 AI 리포트를 생성하는 컨텍스트"
    entities: [Report, ReviewAggregate, ReportTemplate]
    owner: "lead-backend"
    rules:
      - "리뷰 데이터를 읽기만 한다 (수정 금지)"
      - "집계 및 분석 로직을 소유한다"

  dashboard:
    description: "사업자에게 리뷰 현황을 시각화하여 보여주는 컨텍스트"
    entities: [DashboardView, ChartData, FilterCriteria]
    owner: "lead-frontend"
    rules:
      - "표시 로직만 담당한다 (비즈니스 로직 금지)"
      - "백엔드 API를 호출하여 데이터를 가져온다"
```

**엔티티, 값 객체, 애그리게이트**

```python
# === 엔티티 (Entity) ===
# 고유 식별자(ID)를 가지며, 시간에 따라 상태가 변하는 도메인 객체
# 같은 속성값이라도 ID가 다르면 다른 객체

class Review:
    """리뷰 엔티티 — 고유 ID로 식별되는 도메인 객체"""
    id: str                          # 식별자 — 엔티티의 핵심
    review_text: str                 # 상태 — 시간에 따라 수정될 수 있음
    rating: int
    tags: list[ClassificationTag]
    created_at: datetime
    classified_at: datetime | None

    def classify(self, classifier) -> list[ClassificationTag]:
        """리뷰를 분류하고 태그를 부여한다 (비즈니스 로직이 엔티티 안에)"""
        self.tags = classifier.predict(self.review_text)
        self.classified_at = datetime.now()
        return self.tags


# === 값 객체 (Value Object) ===
# 식별자가 없고, 속성값으로만 비교하는 불변 객체
# 같은 속성값이면 같은 객체로 취급

@dataclass(frozen=True)
class ClassificationTag:
    """분류 태그 값 객체 — 속성값이 같으면 같은 태그"""
    name: str                        # "서비스 친절", "차량 청결" 등
    confidence: float                # 0.0 ~ 1.0

    def is_confident(self) -> bool:
        """신뢰도가 임계값 이상인지 확인"""
        return self.confidence >= 0.7


@dataclass(frozen=True)
class DateRange:
    """날짜 범위 값 객체"""
    start: date
    end: date

    def contains(self, target: date) -> bool:
        return self.start <= target <= self.end


# === 애그리게이트 (Aggregate) ===
# 관련 엔티티/값 객체의 묶음. 루트 엔티티를 통해서만 내부에 접근
# 트랜잭션 경계 = 애그리게이트 경계

class ReviewAggregate:
    """리뷰 애그리게이트 — Review가 루트, Tags가 내부 객체"""
    review: Review                   # 애그리게이트 루트
    _tags: list[ClassificationTag]   # 외부에서 직접 접근 불가

    def add_tag(self, tag: ClassificationTag) -> None:
        """태그 추가는 반드시 애그리게이트를 통해서"""
        if tag not in self._tags:
            self._tags.append(tag)

    def remove_low_confidence_tags(self, threshold: float = 0.5) -> None:
        """낮은 신뢰도 태그 제거 — 비즈니스 규칙이 여기에"""
        self._tags = [t for t in self._tags if t.confidence >= threshold]
```

**도메인 서비스 vs 애플리케이션 서비스**

```python
# === 도메인 서비스 (Domain Service) ===
# 특정 엔티티에 속하지 않지만, 도메인 로직인 것
# 여러 엔티티를 조합하는 비즈니스 규칙

class ReviewClassificationService:
    """도메인 서비스 — 리뷰 분류라는 도메인 로직을 수행"""

    def classify_and_validate(
        self,
        review: Review,
        classifier: ReviewClassifier,
    ) -> list[ClassificationTag]:
        """리뷰를 분류하고 비즈니스 규칙에 따라 검증한다"""
        tags = review.classify(classifier)

        # 도메인 규칙: 태그가 하나도 없으면 "미분류" 태그 부여
        if not tags:
            tags = [ClassificationTag(name="미분류", confidence=1.0)]

        # 도메인 규칙: 신뢰도 0.3 미만 태그는 제거
        tags = [t for t in tags if t.confidence >= 0.3]

        return tags


# === 애플리케이션 서비스 (Application Service) ===
# 도메인 로직이 아니라 "유스케이스 조율"을 담당
# 트랜잭션 관리, 외부 서비스 호출, 이벤트 발행 등

class ReviewApplicationService:
    """애플리케이션 서비스 — 유스케이스를 조율한다"""

    def __init__(
        self,
        review_repo: ReviewRepository,
        classification_service: ReviewClassificationService,
        event_publisher: EventPublisher,
    ):
        self.review_repo = review_repo
        self.classification_service = classification_service
        self.event_publisher = event_publisher

    async def classify_review(self, review_id: str) -> ReviewClassificationResponse:
        """유스케이스: 리뷰 분류 실행"""
        # 1. 데이터 조회 (인프라)
        review = await self.review_repo.find_by_id(review_id)
        if not review:
            raise ReviewNotFoundError(review_id)

        # 2. 도메인 로직 실행 (도메인 서비스에 위임)
        tags = self.classification_service.classify_and_validate(
            review=review,
            classifier=self.classifier,
        )

        # 3. 저장 (인프라)
        await self.review_repo.save(review)

        # 4. 이벤트 발행 (인프라)
        await self.event_publisher.publish(
            ReviewClassifiedEvent(review_id=review.id, tags=tags)
        )

        # 5. 응답 변환 (애플리케이션 계층)
        return ReviewClassificationResponse.from_entity(review)
```

**리포지토리 패턴**

```python
# === 리포지토리 인터페이스 (도메인 계층) ===
# 도메인이 데이터 저장 방법을 모르게 추상화

class ReviewRepository(ABC):
    """리뷰 리포지토리 — 도메인 계층에서 정의하는 인터페이스"""

    @abstractmethod
    async def find_by_id(self, review_id: str) -> Review | None:
        """ID로 리뷰를 조회한다"""

    @abstractmethod
    async def find_by_business_owner(
        self,
        owner_id: str,
        date_range: DateRange,
    ) -> list[Review]:
        """사업자의 리뷰를 기간별로 조회한다"""

    @abstractmethod
    async def save(self, review: Review) -> None:
        """리뷰를 저장한다 (생성 또는 수정)"""


# === 리포지토리 구현 (인프라 계층) ===
# 실제 DB 접근 로직. 도메인 계층은 이 구현을 모른다

class SQLAlchemyReviewRepository(ReviewRepository):
    """SQLAlchemy 기반 리뷰 리포지토리 구현"""

    def __init__(self, session: AsyncSession):
        self.session = session

    async def find_by_id(self, review_id: str) -> Review | None:
        result = await self.session.execute(
            select(ReviewModel).where(ReviewModel.id == review_id)
        )
        row = result.scalar_one_or_none()
        return self._to_entity(row) if row else None

    def _to_entity(self, model: ReviewModel) -> Review:
        """DB 모델 → 도메인 엔티티 변환"""
        return Review(
            id=model.id,
            review_text=model.review_text,
            rating=model.rating,
            tags=[ClassificationTag(name=t.name, confidence=t.confidence)
                  for t in model.tags],
            created_at=model.created_at,
            classified_at=model.classified_at,
        )
```

#### DDD 적용 시 디렉토리 구조

```
src/
├── domain/                         # 도메인 계층 (순수 비즈니스 로직)
│   ├── review/                     # 바운디드 컨텍스트: 리뷰 관리
│   │   ├── entity.py               # Review 엔티티
│   │   ├── value_object.py         # ClassificationTag 등 값 객체
│   │   ├── aggregate.py            # ReviewAggregate
│   │   ├── service.py              # ReviewClassificationService (도메인 서비스)
│   │   ├── repository.py           # ReviewRepository 인터페이스 (ABC)
│   │   ├── event.py                # ReviewClassifiedEvent 등 도메인 이벤트
│   │   └── exception.py            # ReviewNotFoundError 등 도메인 예외
│   ├── report/                     # 바운디드 컨텍스트: 리포트
│   │   ├── entity.py
│   │   ├── service.py
│   │   └── repository.py
│   └── shared/                     # 공유 커널 (공통 값 객체)
│       ├── value_object.py         # DateRange 등
│       └── event.py                # 공통 이벤트 인터페이스
│
├── application/                    # 애플리케이션 계층 (유스케이스 조율)
│   ├── review_app_service.py       # ReviewApplicationService
│   ├── report_app_service.py
│   └── dto/                        # Data Transfer Object (요청/응답 변환)
│       ├── review_dto.py
│       └── report_dto.py
│
├── infrastructure/                 # 인프라 계층 (기술적 구현)
│   ├── persistence/                # DB 접근
│   │   ├── sqlalchemy_review_repo.py
│   │   ├── sqlalchemy_report_repo.py
│   │   └── models/                 # SQLAlchemy ORM 모델
│   │       ├── review_model.py
│   │       └── report_model.py
│   ├── external/                   # 외부 서비스 연동
│   │   ├── ai_classifier_client.py
│   │   └── s3_storage_client.py
│   └── event/                      # 이벤트 발행/구독 구현
│       └── event_publisher.py
│
└── presentation/                   # 프레젠테이션 계층 (API/UI)
    ├── api/
    │   └── v1/
    │       ├── review_routes.py
    │       └── report_routes.py
    └── schema/                     # Pydantic 요청/응답 스키마
        ├── review_schema.py
        └── report_schema.py
```

#### DDD 의존성 규칙

```
presentation → application → domain ← infrastructure
     │              │           ▲           │
     │              │           │           │
     └──────────────┴───────────┼───────────┘
                                │
                    domain은 아무것도 의존하지 않는다
                    (순수 비즈니스 로직만)
```

```yaml
dependency_rules:
  domain:
    depends_on: "없음 (순수 Python만 사용, 프레임워크 의존 금지)"
    prohibited_imports:
      - "fastapi"
      - "sqlalchemy"
      - "boto3"
      - "httpx"
    reason: "도메인은 기술 변경에 영향받지 않아야 한다"

  application:
    depends_on: "domain"
    prohibited_imports:
      - "sqlalchemy"       # DB 직접 접근 금지
      - "fastapi.Request"  # HTTP 직접 접근 금지
    reason: "유스케이스 조율만 담당, 기술 구현은 인프라에 위임"

  infrastructure:
    depends_on: "domain (인터페이스 구현을 위해)"
    allowed_imports: "모든 외부 라이브러리 사용 가능"
    reason: "기술적 구현을 담당하는 유일한 계층"

  presentation:
    depends_on: "application"
    allowed_imports: "fastapi, pydantic"
    reason: "HTTP 요청/응답 처리만 담당"
```

---

### 13-2. TDD (Test-Driven Development) — 테스트 주도 개발

TDD는 **코드를 작성하기 전에 테스트를 먼저 작성**하는 개발 방법이다. "Red → Green → Refactor" 사이클을 반복하며 점진적으로 기능을 완성한다.

#### 왜 TDD를 적용하는가

Subagent가 코드를 작성할 때 테스트 없이 구현부터 하면, Phase 3(통합 검토)에서 대량의 버그가 발견된다. TDD를 적용하면 구현과 동시에 검증이 완료되어, Phase 3의 리뷰 시간이 대폭 줄어든다. Superpowers 플러그인은 이 TDD 사이클을 자동으로 강제한다.

#### Red-Green-Refactor 사이클

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  🔴 RED      │────→│  🟢 GREEN   │────→│  🔵 REFACTOR│
│             │     │             │     │             │
│ 실패하는     │     │ 테스트를     │     │ 코드를       │
│ 테스트 작성   │     │ 통과하는     │     │ 깨끗하게     │
│             │     │ 최소 코드    │     │ 정리        │
└─────────────┘     └─────────────┘     └──────┬──────┘
       ▲                                       │
       └───────────────────────────────────────┘
                  다음 기능으로 반복
```

**Step 1: 🔴 RED — 실패하는 테스트를 먼저 작성한다**

```python
# test_review_classification.py
# 아직 classify_review() 함수가 존재하지 않는 상태에서 작성

class TestReviewClassification:

    def test_returns_tags_for_valid_review(self):
        """유효한 리뷰 텍스트에 대해 분류 태그를 반환한다"""
        # Given
        review = Review(
            id="review-001",
            review_text="직원이 매우 친절하고 차량도 깨끗했습니다",
            rating=5,
        )
        classifier = ReviewClassificationService()

        # When
        tags = classifier.classify_and_validate(review, mock_classifier)

        # Then
        assert len(tags) > 0
        assert all(isinstance(t, ClassificationTag) for t in tags)
        assert all(t.confidence >= 0.3 for t in tags)

    def test_returns_unclassified_tag_when_no_tags_matched(self):
        """매칭되는 태그가 없으면 '미분류' 태그를 반환한다"""
        # Given
        review = Review(
            id="review-002",
            review_text="ㅋㅋ",
            rating=3,
        )

        # When
        tags = classifier.classify_and_validate(review, mock_classifier)

        # Then
        assert len(tags) == 1
        assert tags[0].name == "미분류"
        assert tags[0].confidence == 1.0

    def test_raises_error_for_empty_review_text(self):
        """빈 리뷰 텍스트에 대해 에러를 발생시킨다"""
        # Given
        review = Review(id="review-003", review_text="", rating=1)

        # When / Then
        with pytest.raises(EmptyReviewError):
            classifier.classify_and_validate(review, mock_classifier)
```

→ 이 테스트를 실행하면 **반드시 실패해야 한다** (아직 구현이 없으므로). 실패하지 않으면 테스트가 잘못된 것이다.

**Step 2: 🟢 GREEN — 테스트를 통과하는 최소한의 코드를 작성한다**

```python
# review_classification_service.py
# 테스트를 통과하기 위한 "최소한"의 구현만 작성

class ReviewClassificationService:

    def classify_and_validate(
        self,
        review: Review,
        classifier: ReviewClassifier,
    ) -> list[ClassificationTag]:
        if not review.review_text.strip():
            raise EmptyReviewError(review.id)

        tags = review.classify(classifier)

        if not tags:
            return [ClassificationTag(name="미분류", confidence=1.0)]

        return [t for t in tags if t.confidence >= 0.3]
```

→ 최소한의 코드로 모든 테스트를 통과시킨다. 이 단계에서는 완벽한 코드가 아니어도 된다.

**Step 3: 🔵 REFACTOR — 코드를 깨끗하게 정리한다**

```python
# 리팩토링: 매직 넘버 상수화, 메서드 분리

class ReviewClassificationService:
    MIN_CONFIDENCE_THRESHOLD = 0.3
    UNCLASSIFIED_TAG = ClassificationTag(name="미분류", confidence=1.0)

    def classify_and_validate(
        self,
        review: Review,
        classifier: ReviewClassifier,
    ) -> list[ClassificationTag]:
        self._validate_review_text(review)
        tags = review.classify(classifier)
        return self._apply_business_rules(tags)

    def _validate_review_text(self, review: Review) -> None:
        if not review.review_text.strip():
            raise EmptyReviewError(review.id)

    def _apply_business_rules(
        self,
        tags: list[ClassificationTag],
    ) -> list[ClassificationTag]:
        if not tags:
            return [self.UNCLASSIFIED_TAG]
        return [t for t in tags if t.confidence >= self.MIN_CONFIDENCE_THRESHOLD]
```

→ 리팩토링 후에도 **모든 테스트가 통과해야 한다**. 테스트가 깨지면 리팩토링이 잘못된 것이다.

#### TDD 실전 규칙

```yaml
tdd_rules:
  red_phase:
    - "테스트를 먼저 작성한다. 구현 코드가 없는 상태에서 작성해야 한다"
    - "테스트를 실행하여 실패하는 것을 확인한다 (실패하지 않으면 테스트가 잘못됨)"
    - "한 번에 하나의 동작만 테스트한다"
    - "테스트 이름은 '무엇을_어떤_상황에서_어떻게_되는가' 형식으로 작성한다"

  green_phase:
    - "테스트를 통과하는 최소한의 코드만 작성한다"
    - "완벽한 코드를 쓰려고 하지 않는다 (그건 Refactor 단계에서)"
    - "하드코딩이라도 테스트만 통과하면 OK"

  refactor_phase:
    - "동작을 변경하지 않고 코드 구조만 개선한다"
    - "매직 넘버 → 상수, 중복 코드 → 메서드 추출, 네이밍 개선"
    - "리팩토링 후 반드시 모든 테스트를 다시 실행한다"
    - "테스트가 깨지면 리팩토링을 취소하고 원인을 찾는다"

  general:
    - "Superpowers가 활성화된 경우, 코드 작성 전 테스트 미작성 시 코드가 자동 삭제된다"
    - "외부 의존성(DB, API, 파일시스템)은 반드시 mock/stub으로 대체한다"
    - "테스트 커버리지 80% 이상을 목표로 한다"
    - "테스트 파일은 src 구조를 미러링한다: src/domain/review/ → tests/domain/review/"
```

#### 테스트 종류별 작성 가이드

```yaml
test_pyramid:
  unit_test:
    비율: "70%"
    대상: "도메인 엔티티, 값 객체, 도메인 서비스, 애플리케이션 서비스"
    특징: "외부 의존성 없음, mock 사용, 빠름 (밀리초)"
    naming: "test_{method}_{scenario}_{expected_result}"
    example: "test_classify_review_with_empty_text_raises_error"

  integration_test:
    비율: "20%"
    대상: "리포지토리 구현, 외부 API 클라이언트, DB 마이그레이션"
    특징: "실제 DB 사용 (테스트 DB), 느림 (초 단위)"
    naming: "test_{usecase}_{integration_point}"
    example: "test_save_review_to_database"

  e2e_test:
    비율: "10%"
    대상: "API 엔드포인트, 사용자 시나리오 전체 흐름"
    특징: "실제 서버 기동, 가장 느림"
    naming: "test_{user_scenario}_e2e"
    example: "test_classify_review_via_api_e2e"
```

---

### 13-3. Clean Code — 깨끗한 코드 작성 원칙

Clean Code는 **읽기 쉽고, 이해하기 쉽고, 수정하기 쉬운 코드**를 작성하는 원칙이다. "코드는 작성하는 시간보다 읽는 시간이 10배 많다"는 전제에서 출발한다.

#### 핵심 원칙 7가지

**원칙 1: 의미 있는 이름을 사용한다 (Meaningful Names)**

```python
# ❌ 나쁜 예시
def proc(d, t):
    r = []
    for i in d:
        if i.s > t:
            r.append(i)
    return r

# ✅ 좋은 예시
def filter_reviews_above_rating(
    reviews: list[Review],
    min_rating: int,
) -> list[Review]:
    return [review for review in reviews if review.rating > min_rating]
```

```yaml
naming_rules:
  - "변수명은 '무엇이 담겨있는지' 알 수 있어야 한다"
  - "함수명은 '무엇을 하는지' 알 수 있어야 한다"
  - "클래스명은 '무엇인지' 알 수 있어야 한다"
  - "축약어를 쓰지 않는다: d → data 또는 reviews, t → threshold, r → result"
  - "한 글자 변수는 루프 인덱스(i, j)와 람다 파라미터에서만 허용"
  - "boolean 변수는 is_, has_, can_, should_ 접두사를 사용한다"
```

**원칙 2: 함수는 한 가지만 한다 (Single Responsibility)**

```python
# ❌ 나쁜 예시 — 하나의 함수가 여러 가지를 한다
async def handle_review(review_id: str, db: AsyncSession):
    review = await db.execute(select(ReviewModel).where(...))  # DB 조회
    tags = ai_model.predict(review.text)                       # AI 분류
    review.tags = tags                                         # 업데이트
    await db.commit()                                          # DB 저장
    send_notification(review.owner_id, tags)                   # 알림 발송
    log_classification_event(review_id, tags)                  # 로깅
    return {"tags": tags, "status": "ok"}                      # 응답 생성

# ✅ 좋은 예시 — 각 함수가 한 가지만 한다
async def classify_review(review_id: str) -> ReviewClassificationResponse:
    review = await self.review_repo.find_by_id(review_id)
    tags = self.classification_service.classify(review)
    await self.review_repo.save(review)
    await self.event_publisher.publish(ReviewClassifiedEvent(review_id, tags))
    return ReviewClassificationResponse.from_entity(review)
```

```yaml
function_rules:
  - "함수 하나는 하나의 추상화 수준에서 하나의 작업만 수행한다"
  - "함수 길이는 20줄 이내를 목표로 한다 (절대 규칙은 아님)"
  - "파라미터는 3개 이하가 이상적. 4개 이상이면 객체로 묶는다"
  - "부작용(side effect)이 있는 함수는 이름에 표현한다: save_, send_, delete_"
  - "조건이 복잡하면 의미 있는 이름의 변수로 추출한다"
```

**원칙 3: 주석 대신 코드로 의도를 표현한다 (Code as Documentation)**

```python
# ❌ 주석으로 설명하는 코드
# 리뷰의 신뢰도가 0.3 미만이면 제거한다
result = [t for t in tags if t.c >= 0.3]

# ✅ 코드 자체가 설명이 되는 코드
MIN_CONFIDENCE_THRESHOLD = 0.3

def remove_low_confidence_tags(tags: list[ClassificationTag]) -> list[ClassificationTag]:
    return [tag for tag in tags if tag.confidence >= MIN_CONFIDENCE_THRESHOLD]
```

```yaml
comment_rules:
  allowed_comments:
    - "WHY(왜): 비즈니스 이유나 의도를 설명할 때"
    - "WARNING: 주의사항이나 함정을 경고할 때"
    - "TODO: 나중에 해야 할 작업을 표시할 때 (티켓 번호 포함)"
    - "공개 API의 독스트링"
  prohibited_comments:
    - "WHAT(무엇): 코드가 무엇을 하는지 설명 (코드가 스스로 설명해야 함)"
    - "주석 처리된 코드 (Git이 이력을 관리하므로 삭제)"
    - "저자 이름, 날짜 (Git log가 관리)"
```

**원칙 4: 에러를 숨기지 않는다 (Don't Swallow Exceptions)**

```python
# ❌ 에러를 삼키는 코드
try:
    result = await classify_review(review)
except Exception:
    pass  # 에러가 사라짐 — 디버깅 불가능

# ❌ 너무 넓은 예외 처리
try:
    result = await classify_review(review)
except Exception as e:
    logger.error(f"에러: {e}")
    return None  # None이 퍼져나가면서 다른 곳에서 버그 발생

# ✅ 구체적인 예외 처리
try:
    result = await classify_review(review)
except ReviewNotFoundError:
    raise  # 상위에서 처리하도록 다시 발생
except ClassificationModelError as e:
    logger.error(f"AI 분류 모델 오류: {e}", extra={"review_id": review.id})
    raise ServiceUnavailableError("분류 서비스가 일시적으로 불가합니다") from e
```

**원칙 5: 중복을 제거한다 (DRY — Don't Repeat Yourself)**

```python
# ❌ 중복 코드
async def get_recent_reviews(owner_id: str) -> list[Review]:
    reviews = await db.execute(
        select(ReviewModel)
        .where(ReviewModel.owner_id == owner_id)
        .where(ReviewModel.created_at >= thirty_days_ago)
        .order_by(ReviewModel.created_at.desc())
    )
    return [to_entity(r) for r in reviews.scalars()]

async def get_recent_positive_reviews(owner_id: str) -> list[Review]:
    reviews = await db.execute(
        select(ReviewModel)
        .where(ReviewModel.owner_id == owner_id)
        .where(ReviewModel.created_at >= thirty_days_ago)  # 중복!
        .where(ReviewModel.rating >= 4)
        .order_by(ReviewModel.created_at.desc())           # 중복!
    )
    return [to_entity(r) for r in reviews.scalars()]

# ✅ 중복 제거 — 공통 쿼리 빌더 추출
def _base_recent_reviews_query(owner_id: str) -> Select:
    return (
        select(ReviewModel)
        .where(ReviewModel.owner_id == owner_id)
        .where(ReviewModel.created_at >= thirty_days_ago)
        .order_by(ReviewModel.created_at.desc())
    )

async def get_recent_reviews(owner_id: str) -> list[Review]:
    query = _base_recent_reviews_query(owner_id)
    return [to_entity(r) for r in (await db.execute(query)).scalars()]

async def get_recent_positive_reviews(owner_id: str) -> list[Review]:
    query = _base_recent_reviews_query(owner_id).where(ReviewModel.rating >= 4)
    return [to_entity(r) for r in (await db.execute(query)).scalars()]
```

**원칙 6: 조기 반환으로 들여쓰기를 줄인다 (Early Return / Guard Clause)**

```python
# ❌ 깊은 중첩
async def process_review(review_id: str) -> Response:
    review = await repo.find_by_id(review_id)
    if review:
        if review.text:
            if not review.is_classified:
                tags = classifier.classify(review)
                if tags:
                    review.tags = tags
                    await repo.save(review)
                    return SuccessResponse(tags)
                else:
                    return ErrorResponse("분류 실패")
            else:
                return ErrorResponse("이미 분류됨")
        else:
            return ErrorResponse("텍스트 없음")
    else:
        return ErrorResponse("리뷰 없음")

# ✅ 조기 반환 (Guard Clause)
async def process_review(review_id: str) -> Response:
    review = await repo.find_by_id(review_id)
    if not review:
        raise ReviewNotFoundError(review_id)

    if not review.text:
        raise EmptyReviewError(review_id)

    if review.is_classified:
        raise AlreadyClassifiedError(review_id)

    tags = classifier.classify(review)
    if not tags:
        raise ClassificationFailedError(review_id)

    review.tags = tags
    await repo.save(review)
    return SuccessResponse(tags)
```

**원칙 7: 응집도는 높이고 결합도는 낮춘다 (High Cohesion, Low Coupling)**

```yaml
cohesion_coupling:
  high_cohesion:
    definition: "하나의 모듈/클래스가 하나의 책임에 관련된 것들만 모아놓은 상태"
    check: "이 클래스의 모든 메서드가 같은 인스턴스 변수를 사용하는가?"
    bad_sign: "클래스가 서로 관련 없는 메서드들을 가지고 있다 → 분리하라"

  low_coupling:
    definition: "모듈 간 의존성이 최소화된 상태"
    check: "이 모듈을 변경했을 때 다른 모듈도 함께 변경해야 하는가?"
    bad_sign: "A를 수정하면 B, C, D도 수정해야 한다 → 인터페이스로 분리하라"

  application:
    - "의존성 주입(DI)을 사용하여 구체 클래스 대신 인터페이스에 의존한다"
    - "import는 상위 모듈에서 하위 모듈 방향으로만 (역방향 금지)"
    - "순환 의존이 발생하면 즉시 구조를 재설계한다"
```

---

### 13-4. Architecture — 시스템 아키텍처 설계 원칙

아키텍처는 **시스템의 큰 그림**이다. 컴포넌트를 어떻게 배치하고, 데이터가 어떻게 흐르고, 변경에 어떻게 대응하는지를 결정한다.

#### 레이어드 아키텍처 + DDD 통합

이 프로젝트는 DDD의 바운디드 컨텍스트를 레이어드 아키텍처 위에 얹은 구조를 사용한다.

```
┌───────────────────────────────────────────────────────────────┐
│                   Presentation Layer (API)                     │
│              FastAPI Routes, Pydantic Schemas                  │
│            요청/응답 변환만 담당. 로직 금지.                      │
├───────────────────────────────────────────────────────────────┤
│                   Application Layer                            │
│           Application Services, DTOs, Use Cases                │
│        유스케이스 조율. 트랜잭션 관리. 이벤트 발행.                │
├───────────────────────────────────────────────────────────────┤
│                     Domain Layer                               │
│     Entities, Value Objects, Aggregates, Domain Services       │
│     순수 비즈니스 로직. 외부 의존성 제로. 프레임워크 무관.          │
├───────────────────────────────────────────────────────────────┤
│                  Infrastructure Layer                          │
│  Repository Impl, DB Models, External API Clients, Messaging  │
│           기술적 구현. 도메인 인터페이스를 구현.                   │
└───────────────────────────────────────────────────────────────┘
```

#### SOLID 원칙 적용

```yaml
solid_principles:

  S_single_responsibility:
    principle: "클래스는 변경되어야 하는 이유가 하나뿐이어야 한다"
    application:
      - "ReviewService가 분류도 하고, 리포트도 생성하고, 메일도 보내면 → 분리"
      - "Route 핸들러에서 DB 쿼리를 직접 실행하면 → Service로 분리"
    check: "이 클래스가 변경되는 이유를 두 가지 이상 댈 수 있으면 위반"

  O_open_closed:
    principle: "확장에는 열려있고, 수정에는 닫혀있어야 한다"
    application:
      - "새로운 분류 태그 추가 시 기존 분류 로직을 수정하지 않아야 한다"
      - "전략 패턴(Strategy)으로 알고리즘을 교체 가능하게 설계"
    example: |
      # 새로운 분류 방식 추가 시 기존 코드 수정 없이 확장
      class ClassifierStrategy(ABC):
          @abstractmethod
          def classify(self, text: str) -> list[ClassificationTag]: ...

      class AIClassifier(ClassifierStrategy): ...    # AI 기반
      class RuleClassifier(ClassifierStrategy): ...  # 규칙 기반
      class HybridClassifier(ClassifierStrategy): ... # 새로 추가 — 기존 코드 수정 없음

  L_liskov_substitution:
    principle: "하위 타입은 상위 타입을 대체할 수 있어야 한다"
    application:
      - "ReviewRepository를 구현한 SQLAlchemyReviewRepository는 어디서든 ReviewRepository 대신 사용 가능해야 한다"
      - "자식 클래스가 부모의 계약(입출력 타입, 예외)을 어기면 위반"
    check: "인터페이스를 구현한 클래스를 교체해도 호출측 코드가 안 깨지는가?"

  I_interface_segregation:
    principle: "클라이언트가 사용하지 않는 메서드에 의존하면 안 된다"
    application:
      - "ReadOnlyRepository와 WritableRepository를 분리한다"
      - "리포트 컨텍스트는 리뷰를 읽기만 하므로 ReadOnly만 의존"
    example: |
      class ReviewReader(ABC):
          """읽기 전용 인터페이스"""
          @abstractmethod
          async def find_by_id(self, review_id: str) -> Review | None: ...

      class ReviewWriter(ABC):
          """쓰기 전용 인터페이스"""
          @abstractmethod
          async def save(self, review: Review) -> None: ...

      class ReviewRepository(ReviewReader, ReviewWriter):
          """전체 인터페이스 — 필요한 곳에서만 사용"""

  D_dependency_inversion:
    principle: "상위 모듈이 하위 모듈에 의존하면 안 된다. 둘 다 추상에 의존해야 한다"
    application:
      - "Application Service는 SQLAlchemyRepository가 아니라 ReviewRepository(ABC)에 의존"
      - "의존성 주입(DI)으로 런타임에 구현체를 결정한다"
    example: |
      # ✅ 의존성 역전 — 추상에 의존
      class ReviewApplicationService:
          def __init__(self, repo: ReviewRepository):  # ABC에 의존
              self.repo = repo

      # 런타임에 구현체 주입
      service = ReviewApplicationService(
          repo=SQLAlchemyReviewRepository(session)
      )
```

#### 의존성 주입 (Dependency Injection) 설정

```python
# core/dependencies.py
# FastAPI의 Depends를 활용한 DI 설정

from functools import lru_cache

async def get_db_session() -> AsyncGenerator[AsyncSession, None]:
    async with async_session_factory() as session:
        yield session

def get_review_repository(
    session: AsyncSession = Depends(get_db_session),
) -> ReviewRepository:
    return SQLAlchemyReviewRepository(session)

def get_classification_service() -> ReviewClassificationService:
    return ReviewClassificationService()

def get_review_app_service(
    repo: ReviewRepository = Depends(get_review_repository),
    classification_svc: ReviewClassificationService = Depends(get_classification_service),
    event_publisher: EventPublisher = Depends(get_event_publisher),
) -> ReviewApplicationService:
    return ReviewApplicationService(
        review_repo=repo,
        classification_service=classification_svc,
        event_publisher=event_publisher,
    )

# Route에서 사용
@router.post("/reviews/{review_id}/classify")
async def classify_review(
    review_id: str,
    app_service: ReviewApplicationService = Depends(get_review_app_service),
) -> ReviewClassificationResponse:
    return await app_service.classify_review(review_id)
```

#### 설계 결정 기록 (ADR — Architecture Decision Record)

중요한 아키텍처 결정은 반드시 문서화한다. Phase 1(합의)에서 리드들이 결정한 내용을 아래 형식으로 기록한다.

```markdown
# ADR-001: 리뷰 분류에 AI 모델 vs 규칙 기반 선택

## 상태
승인됨 (2025-XX-XX)

## 맥락
리뷰를 17개 태그로 분류해야 한다. AI 모델을 사용할 것인지, 키워드 규칙 기반으로 할 것인지 결정이 필요하다.

## 선택지
1. **AI 모델 (GPT/Claude API)**: 높은 정확도, 높은 비용, 외부 의존성
2. **규칙 기반 (키워드 매칭)**: 낮은 비용, 낮은 정확도, 유지보수 어려움
3. **하이브리드 (규칙 우선 + AI 폴백)**: 중간 비용, 높은 정확도

## 결정
선택지 3 (하이브리드)을 선택한다.

## 근거
- 명확한 키워드가 있는 리뷰(70%)는 규칙으로 빠르게 처리하여 비용 절감
- 모호한 리뷰(30%)만 AI 모델로 처리하여 정확도 확보
- Strategy 패턴으로 구현하여 향후 AI 전환이 용이하도록 설계

## 결과
- ClassifierStrategy 인터페이스를 정의하고, RuleClassifier와 AIClassifier를 구현
- HybridClassifier가 규칙 우선 적용 후 미분류 건에 대해 AI 폴백
- 월 예상 API 비용: ₩30,000 (전체 AI 대비 70% 절감)
```

```yaml
adr_rules:
  when_to_write:
    - "기술 스택 선택 시"
    - "아키텍처 패턴 결정 시"
    - "외부 서비스/라이브러리 도입 시"
    - "성능 vs 비용 트레이드오프 결정 시"
    - "Phase 1(합의)에서 리드 간 의견이 갈렸을 때"
  location: "docs/adr/ADR-{number}-{title}.md"
  rules:
    - "한번 승인된 ADR은 수정하지 않는다 (새 ADR로 대체)"
    - "결정 근거에 '왜 다른 선택지를 버렸는지'를 반드시 포함한다"
    - "예상 비용, 성능 영향을 구체적 수치로 기록한다"
```

---

### 13-5. 4가지 방법론의 통합 적용 체크리스트

Phase 3(통합 검토)에서 리드가 결과물을 검증할 때 사용하는 체크리스트이다.

```
## DDD 체크리스트
□ 도메인 용어 사전의 용어가 코드에 그대로 반영되어 있는가?
□ 바운디드 컨텍스트 경계가 지켜지고 있는가? (컨텍스트 간 직접 참조 없는지)
□ 엔티티와 값 객체가 올바르게 구분되어 있는가?
□ 비즈니스 로직이 도메인 계층에 위치하는가? (Service나 Route에 비즈니스 로직 없는지)
□ 리포지토리 인터페이스가 도메인 계층에, 구현이 인프라 계층에 있는가?
□ 도메인 계층에 프레임워크 import가 없는가?

## TDD 체크리스트
□ 모든 공개 메서드에 단위 테스트가 있는가?
□ 테스트가 성공 케이스 + 실패 케이스를 모두 포함하는가?
□ 테스트 이름만 읽고 무엇을 검증하는지 알 수 있는가?
□ 외부 의존성이 mock/stub으로 대체되어 있는가?
□ 테스트 커버리지가 80% 이상인가?
□ 테스트가 서로 독립적인가? (실행 순서에 의존하지 않는지)

## Clean Code 체크리스트
□ 변수명, 함수명, 클래스명이 의도를 명확히 표현하는가?
□ 함수가 한 가지 일만 하는가? (20줄 이내 권장)
□ 불필요한 주석 없이 코드 자체로 의도가 전달되는가?
□ 중복 코드가 없는가? (3회 이상 반복되면 추출)
□ 에러가 적절히 처리되고 있는가? (삼키기 금지, 구체적 예외)
□ 들여쓰기가 3단계 이상 깊어지지 않는가? (Guard Clause 적용)
□ 매직 넘버 없이 상수로 정의되어 있는가?

## Architecture 체크리스트
□ 레이어 간 의존성 방향이 올바른가? (presentation → application → domain ← infrastructure)
□ SOLID 원칙이 지켜지고 있는가?
□ 의존성 주입이 적용되어 있는가? (구체 클래스 직접 생성 금지)
□ 주요 아키텍처 결정에 ADR이 작성되어 있는가?
□ 순환 의존이 없는가?
□ 새로운 기능 추가 시 기존 코드 수정 범위가 최소화되는 구조인가?
```

---

## 14. 모듈 단위 설계: 추가/수정/확장/삭제가 용이한 구조

이 섹션은 프로젝트의 모든 기능을 **독립적인 모듈 단위로 설계**하여, 어떤 기능이든 다른 기능에 영향 없이 추가·수정·확장·삭제할 수 있는 구조를 정의한다.

```
모듈 설계의 핵심 질문:

"리뷰 분류 기능을 통째로 삭제하면 다른 기능이 깨지는가?"
  → YES: 모듈 간 결합이 강하다 → 설계를 다시 한다
  → NO:  모듈이 잘 분리되어 있다 ✅

"새로운 '예약 관리' 기능을 추가하면 기존 코드를 수정해야 하는가?"
  → YES: 확장에 닫혀있다 → 설계를 다시 한다
  → NO:  확장에 열려있다 ✅
```

---

### 14-1. 모듈의 정의와 경계

이 프로젝트에서 **모듈 = 하나의 비즈니스 기능 단위**이다. DDD의 바운디드 컨텍스트와 1:1로 대응한다.

```yaml
module_definition:
  principle: "하나의 모듈은 하나의 비즈니스 기능을 완결적으로 수행한다"
  boundary: "모듈 안에서 자기 기능에 필요한 모든 것을 소유한다"
  communication: "모듈 간 통신은 반드시 정해진 인터페이스(계약)를 통한다"
  independence: "모듈 하나를 삭제해도 나머지 모듈은 정상 동작한다"
```

#### 모듈 = 수직 슬라이스 (Vertical Slice)

전통적인 수평 레이어(route / service / repository를 각각 모은 폴더)가 아니라, **기능 단위로 수직으로 자른다**. 각 모듈이 자기만의 route, service, repository, model, schema, test를 전부 소유한다.

```
❌ 수평 분할 (기능이 여러 폴더에 흩어짐 — 한 기능 삭제 시 폴더마다 찾아서 지워야 함)

src/
├── api/
│   ├── review_routes.py        ← 리뷰 기능의 일부
│   ├── report_routes.py        ← 리포트 기능의 일부
│   └── dashboard_routes.py     ← 대시보드 기능의 일부
├── service/
│   ├── review_service.py       ← 리뷰 기능의 일부
│   ├── report_service.py       ← 리포트 기능의 일부
│   └── dashboard_service.py    ← 대시보드 기능의 일부
├── repository/
│   ├── review_repository.py    ← 리뷰 기능의 일부
│   └── report_repository.py    ← 리포트 기능의 일부
└── model/
    ├── review.py               ← 리뷰 기능의 일부
    └── report.py               ← 리포트 기능의 일부


✅ 수직 분할 (기능 = 폴더 — 한 기능 삭제 = 폴더 하나 삭제)

src/
├── modules/
│   ├── review/                 ← 리뷰 모듈 (통째로 추가/삭제 가능)
│   │   ├── __init__.py
│   │   ├── router.py           # API 엔드포인트
│   │   ├── service.py          # 비즈니스 로직
│   │   ├── repository.py       # 데이터 접근
│   │   ├── model.py            # DB 모델
│   │   ├── schema.py           # 요청/응답 스키마
│   │   ├── exception.py        # 모듈 전용 예외
│   │   ├── event.py            # 도메인 이벤트
│   │   ├── interface.py        # 다른 모듈에 노출하는 인터페이스
│   │   └── tests/
│   │       ├── test_service.py
│   │       ├── test_repository.py
│   │       └── test_router.py
│   │
│   ├── report/                 ← 리포트 모듈 (통째로 추가/삭제 가능)
│   │   ├── __init__.py
│   │   ├── router.py
│   │   ├── service.py
│   │   ├── repository.py
│   │   ├── model.py
│   │   ├── schema.py
│   │   ├── exception.py
│   │   ├── interface.py
│   │   └── tests/
│   │       └── ...
│   │
│   ├── dashboard/              ← 대시보드 모듈
│   │   └── ...
│   │
│   └── _shared/                ← 공유 커널 (진짜 공통인 것만)
│       ├── base_model.py       # SQLAlchemy Base
│       ├── base_repository.py  # 공통 CRUD 메서드
│       ├── pagination.py       # 페이지네이션 유틸
│       ├── event_bus.py        # 이벤트 버스 인터페이스
│       └── exceptions.py       # 공통 예외 (AppException 등)
│
├── core/                       ← 앱 설정 & 부트스트래핑
│   ├── config.py               # 환경 변수, 설정값
│   ├── database.py             # DB 연결 설정
│   ├── app_factory.py          # FastAPI 앱 생성 + 모듈 라우터 등록
│   └── dependencies.py         # 공통 의존성 (DB 세션 등)
│
└── main.py                     ← 엔트리포인트
```

#### 모듈 등록 시스템

새 모듈을 추가할 때 기존 코드를 최소한만 수정하도록 **플러그인 방식**의 등록 시스템을 사용한다.

```python
# === core/app_factory.py ===
# 모듈을 "등록"하는 중앙 지점. 새 모듈 추가 = 한 줄 추가

from fastapi import FastAPI

def create_app() -> FastAPI:
    app = FastAPI(title="카모아 API", version="1.0.0")

    # 미들웨어 등록
    _register_middlewares(app)

    # 모듈 라우터 등록 — 새 모듈 추가 시 여기에 한 줄만 추가
    _register_modules(app)

    # 이벤트 핸들러 등록
    _register_event_handlers(app)

    return app


def _register_modules(app: FastAPI) -> None:
    """
    각 모듈의 라우터를 등록한다.
    새 모듈 추가: import + include_router 한 줄 추가
    모듈 삭제: 해당 줄 삭제 + 모듈 폴더 삭제
    """
    from src.modules.review.router import router as review_router
    from src.modules.report.router import router as report_router
    from src.modules.dashboard.router import router as dashboard_router
    # from src.modules.booking.router import router as booking_router  ← 새 모듈 추가 시

    app.include_router(review_router, prefix="/api/v1/reviews", tags=["리뷰"])
    app.include_router(report_router, prefix="/api/v1/reports", tags=["리포트"])
    app.include_router(dashboard_router, prefix="/api/v1/dashboard", tags=["대시보드"])
    # app.include_router(booking_router, prefix="/api/v1/bookings", tags=["예약"])
```

```python
# === 더 발전된 방식: 자동 디스커버리 ===
# modules/ 하위의 모든 모듈을 자동으로 탐색하여 등록

import importlib
import pkgutil
from pathlib import Path

def _register_modules(app: FastAPI) -> None:
    """modules/ 디렉토리의 모든 모듈을 자동으로 등록한다"""
    modules_path = Path(__file__).parent.parent / "modules"

    for module_info in pkgutil.iter_modules([str(modules_path)]):
        if module_info.name.startswith("_"):
            continue  # _shared 등 내부 모듈 건너뛰기

        try:
            module = importlib.import_module(
                f"src.modules.{module_info.name}.router"
            )
            if hasattr(module, "router"):
                app.include_router(
                    module.router,
                    prefix=f"/api/v1/{module_info.name.replace('_', '-')}",
                    tags=[module_info.name],
                )
        except ModuleNotFoundError:
            pass  # router.py가 없는 모듈은 건너뛰기
```

---

### 14-2. 모듈 내부 구조 상세

각 모듈 안의 파일은 아래 역할과 규칙을 따른다.

```python
# === module/review/__init__.py ===
# 모듈의 공개 인터페이스만 노출한다
# 다른 모듈은 이 __init__.py를 통해서만 접근 가능

from src.modules.review.interface import ReviewModuleInterface

__all__ = ["ReviewModuleInterface"]
# ↑ 이것만 외부에 보인다. 내부 service, repository 등은 숨긴다
```

```python
# === module/review/interface.py ===
# 이 모듈이 다른 모듈에 제공하는 "계약"
# 내부 구현이 바뀌어도 이 인터페이스만 유지하면 외부에 영향 없음

from abc import ABC, abstractmethod

class ReviewModuleInterface(ABC):
    """리뷰 모듈이 외부에 제공하는 인터페이스"""

    @abstractmethod
    async def get_reviews_by_owner(
        self,
        owner_id: str,
        date_range: DateRange,
    ) -> list[ReviewSummaryDTO]:
        """사업자의 리뷰 요약 목록을 반환한다"""

    @abstractmethod
    async def get_review_statistics(
        self,
        owner_id: str,
        date_range: DateRange,
    ) -> ReviewStatisticsDTO:
        """리뷰 통계 데이터를 반환한다"""


# === 인터페이스 구현 ===
class ReviewModuleFacade(ReviewModuleInterface):
    """리뷰 모듈의 파사드 — 내부 서비스를 조율하여 인터페이스를 구현"""

    def __init__(self, review_service: ReviewService):
        self._service = review_service

    async def get_reviews_by_owner(
        self,
        owner_id: str,
        date_range: DateRange,
    ) -> list[ReviewSummaryDTO]:
        reviews = await self._service.find_by_owner(owner_id, date_range)
        return [ReviewSummaryDTO.from_entity(r) for r in reviews]

    async def get_review_statistics(
        self,
        owner_id: str,
        date_range: DateRange,
    ) -> ReviewStatisticsDTO:
        return await self._service.calculate_statistics(owner_id, date_range)
```

```python
# === module/review/router.py ===
# API 엔드포인트. 이 모듈 전용 라우터.

from fastapi import APIRouter, Depends

router = APIRouter()

@router.get("/{review_id}")
async def get_review(
    review_id: str,
    service: ReviewService = Depends(get_review_service),
) -> ReviewDetailResponse:
    return await service.get_review_detail(review_id)

@router.post("/{review_id}/classify")
async def classify_review(
    review_id: str,
    service: ReviewService = Depends(get_review_service),
) -> ReviewClassificationResponse:
    return await service.classify_review(review_id)
```

```python
# === module/review/service.py ===
# 비즈니스 로직. 이 모듈의 핵심.
# 다른 모듈이 필요하면 인터페이스를 통해 접근한다.

class ReviewService:
    def __init__(
        self,
        repo: ReviewRepository,
        classifier: ClassifierStrategy,
        event_bus: EventBus,
        # 다른 모듈 의존 시 인터페이스로 주입
        # report_module: ReportModuleInterface,  ← 구현체가 아니라 인터페이스
    ):
        self._repo = repo
        self._classifier = classifier
        self._event_bus = event_bus
```

```python
# === module/review/repository.py ===
# 데이터 접근. 이 모듈의 테이블만 접근한다.

class ReviewRepository:
    """리뷰 모듈의 리포지토리 — review 테이블만 접근"""

    def __init__(self, session: AsyncSession):
        self._session = session

    async def find_by_id(self, review_id: str) -> Review | None:
        ...

    async def find_by_owner(
        self,
        owner_id: str,
        date_range: DateRange,
    ) -> list[Review]:
        ...

    async def save(self, review: Review) -> None:
        ...

    # ❌ 금지: 다른 모듈의 테이블 직접 접근
    # async def find_with_report(self, review_id: str):
    #     ... JOIN report_table ...  ← 절대 금지!
```

```python
# === module/review/model.py ===
# DB 모델. 이 모듈의 테이블 정의만 포함.

class ReviewModel(Base):
    __tablename__ = "reviews"

    id: Mapped[str] = mapped_column(primary_key=True)
    owner_id: Mapped[str] = mapped_column(index=True)
    review_text: Mapped[str]
    rating: Mapped[int]
    tags: Mapped[dict] = mapped_column(JSON, default=dict)
    created_at: Mapped[datetime] = mapped_column(default=func.now())
    classified_at: Mapped[datetime | None]

    # ❌ 금지: 다른 모듈의 모델과 직접 relationship
    # report = relationship("ReportModel")  ← 모듈 경계 침범!
```

```python
# === module/review/schema.py ===
# Pydantic 요청/응답 스키마. 이 모듈 전용.

class ReviewDetailResponse(BaseModel):
    id: str
    review_text: str
    rating: int
    tags: list[str]
    created_at: datetime

class ReviewClassificationResponse(BaseModel):
    review_id: str
    tags: list[TagResponse]
    classified_at: datetime

class TagResponse(BaseModel):
    name: str
    confidence: float
```

```python
# === module/review/exception.py ===
# 이 모듈 전용 예외. 공통 AppException을 상속.

from src.modules._shared.exceptions import AppException

class ReviewNotFoundError(AppException):
    status_code = 404
    error_code = "REVIEW_NOT_FOUND"

    def __init__(self, review_id: str):
        self.message = f"리뷰를 찾을 수 없습니다: {review_id}"

class EmptyReviewError(AppException):
    status_code = 422
    error_code = "EMPTY_REVIEW_TEXT"
    message = "리뷰 텍스트가 비어있습니다"

class AlreadyClassifiedError(AppException):
    status_code = 409
    error_code = "ALREADY_CLASSIFIED"

    def __init__(self, review_id: str):
        self.message = f"이미 분류된 리뷰입니다: {review_id}"
```

```python
# === module/review/event.py ===
# 도메인 이벤트. 모듈 간 느슨한 통신 수단.

from dataclasses import dataclass
from datetime import datetime

@dataclass(frozen=True)
class ReviewClassifiedEvent:
    """리뷰가 분류되었을 때 발행하는 이벤트"""
    review_id: str
    owner_id: str
    tags: list[str]
    classified_at: datetime

@dataclass(frozen=True)
class ReviewCreatedEvent:
    """새 리뷰가 생성되었을 때 발행하는 이벤트"""
    review_id: str
    owner_id: str
    rating: int
    created_at: datetime
```

---

### 14-3. 모듈 간 통신: 이벤트 버스 패턴

모듈 간 직접 호출을 금지하고, **이벤트 버스**를 통해 느슨하게 연결한다. 한 모듈이 삭제되어도 이벤트를 수신하는 쪽만 조용히 무시하면 된다.

```
┌─────────────┐                          ┌─────────────┐
│  리뷰 모듈   │                          │  리포트 모듈  │
│             │   ReviewClassifiedEvent   │             │
│  classify() │ ─────────────────────────→│  on_review   │
│             │         이벤트 버스         │  _classified │
└─────────────┘                          └─────────────┘
       │                                        │
       │  리뷰 모듈은 리포트 모듈의              │  리포트 모듈은 리뷰 모듈의
       │  존재를 모른다 ✅                       │  이벤트만 구독한다 ✅
       │                                        │
       │  리포트 모듈을 삭제해도                  │  리뷰 모듈이 삭제되면
       │  리뷰 모듈은 정상 동작 ✅                │  이벤트가 안 올 뿐, 에러 없음 ✅
```

```python
# === modules/_shared/event_bus.py ===
# 인메모리 이벤트 버스. 모듈 간 느슨한 결합을 위한 인프라.

from collections import defaultdict
from typing import Any, Callable, Coroutine

EventHandler = Callable[..., Coroutine[Any, Any, None]]

class EventBus:
    """인메모리 이벤트 버스 — 모듈 간 이벤트 기반 통신"""

    def __init__(self):
        self._handlers: dict[str, list[EventHandler]] = defaultdict(list)

    def subscribe(self, event_type: str, handler: EventHandler) -> None:
        """이벤트 구독 등록"""
        self._handlers[event_type].append(handler)

    def unsubscribe(self, event_type: str, handler: EventHandler) -> None:
        """이벤트 구독 해제 (모듈 삭제 시)"""
        self._handlers[event_type].remove(handler)

    async def publish(self, event_type: str, event: Any) -> None:
        """이벤트 발행 — 구독자가 없어도 에러 없이 통과"""
        for handler in self._handlers.get(event_type, []):
            try:
                await handler(event)
            except Exception as e:
                # 핸들러 실패가 발행자에게 영향을 주지 않음
                logger.error(f"이벤트 핸들러 실패: {event_type} → {e}")
```

```python
# === 리뷰 모듈에서 이벤트 발행 ===
# review/service.py

class ReviewService:
    async def classify_review(self, review_id: str) -> ReviewClassificationResponse:
        review = await self._repo.find_by_id(review_id)
        tags = self._classifier.classify(review)
        await self._repo.save(review)

        # 이벤트 발행 — 누가 수신하는지 모른다 (알 필요도 없다)
        await self._event_bus.publish(
            "review.classified",
            ReviewClassifiedEvent(
                review_id=review.id,
                owner_id=review.owner_id,
                tags=[t.name for t in tags],
                classified_at=review.classified_at,
            ),
        )
        return ReviewClassificationResponse.from_entity(review)


# === 리포트 모듈에서 이벤트 수신 ===
# report/event_handlers.py

class ReportEventHandlers:
    """리포트 모듈의 이벤트 핸들러 — 다른 모듈의 이벤트를 수신"""

    def __init__(self, report_service: ReportService):
        self._service = report_service

    async def on_review_classified(self, event: ReviewClassifiedEvent) -> None:
        """리뷰가 분류되면 해당 사업자의 리포트 캐시를 무효화한다"""
        await self._service.invalidate_report_cache(event.owner_id)

    async def on_review_created(self, event: ReviewCreatedEvent) -> None:
        """새 리뷰가 생성되면 실시간 통계를 업데이트한다"""
        await self._service.update_realtime_stats(event.owner_id)


# === 앱 시작 시 이벤트 구독 등록 ===
# core/app_factory.py

def _register_event_handlers(app: FastAPI) -> None:
    event_bus = get_event_bus()

    # 리포트 모듈의 이벤트 핸들러 등록
    # 리포트 모듈 삭제 시 → 이 블록만 삭제하면 됨
    try:
        from src.modules.report.event_handlers import ReportEventHandlers
        report_handlers = ReportEventHandlers(get_report_service())
        event_bus.subscribe("review.classified", report_handlers.on_review_classified)
        event_bus.subscribe("review.created", report_handlers.on_review_created)
    except ImportError:
        pass  # 리포트 모듈이 없으면 조용히 무시

    # 대시보드 모듈의 이벤트 핸들러 등록
    try:
        from src.modules.dashboard.event_handlers import DashboardEventHandlers
        dashboard_handlers = DashboardEventHandlers(get_dashboard_service())
        event_bus.subscribe("review.classified", dashboard_handlers.on_review_classified)
    except ImportError:
        pass
```

#### 모듈 간 동기적 데이터 조회가 필요한 경우

이벤트는 비동기(fire-and-forget)이므로, 즉시 데이터가 필요한 경우에는 **인터페이스를 통한 조회**를 사용한다. 단, 직접 import가 아니라 의존성 주입으로 연결한다.

```python
# === 리포트 모듈이 리뷰 데이터를 조회해야 할 때 ===

# report/service.py
class ReportService:
    def __init__(
        self,
        report_repo: ReportRepository,
        # ✅ 인터페이스에 의존 — 리뷰 모듈의 구현을 모른다
        review_provider: ReviewModuleInterface,
    ):
        self._repo = report_repo
        self._review_provider = review_provider

    async def generate_report(
        self,
        owner_id: str,
        date_range: DateRange,
    ) -> Report:
        # 리뷰 데이터를 인터페이스를 통해 조회
        reviews = await self._review_provider.get_reviews_by_owner(
            owner_id, date_range
        )
        stats = await self._review_provider.get_review_statistics(
            owner_id, date_range
        )

        # 리포트 생성 (리포트 모듈 자체 로직)
        return self._build_report(reviews, stats, date_range)


# ❌ 금지: 리뷰 모듈 내부를 직접 import
# from src.modules.review.repository import ReviewRepository  ← 절대 금지!
# from src.modules.review.model import ReviewModel            ← 절대 금지!
```

---

### 14-4. 4가지 핵심 작업별 가이드

#### 작업 1: 새 모듈 추가 (ADD)

새 기능(예: "예약 관리")을 추가할 때의 절차이다.

```yaml
add_module_checklist:
  step_1_create_folder:
    action: "src/modules/booking/ 폴더 생성"
    files:
      - "__init__.py       → BookingModuleInterface 노출"
      - "interface.py      → 다른 모듈에 제공할 인터페이스 정의"
      - "router.py         → API 엔드포인트"
      - "service.py        → 비즈니스 로직"
      - "repository.py     → 데이터 접근"
      - "model.py          → DB 모델"
      - "schema.py         → 요청/응답 스키마"
      - "exception.py      → 모듈 전용 예외"
      - "event.py          → 도메인 이벤트 정의"
      - "event_handlers.py → 다른 모듈의 이벤트 수신 (필요 시)"
      - "tests/            → 테스트 폴더"

  step_2_register:
    action: "core/app_factory.py의 _register_modules()에 라우터 등록 한 줄 추가"
    code: 'app.include_router(booking_router, prefix="/api/v1/bookings", tags=["예약"])'

  step_3_events:
    action: "이벤트 구독/발행 설정 (다른 모듈과 통신이 필요한 경우)"
    code: "_register_event_handlers()에 booking 이벤트 핸들러 등록"

  step_4_migration:
    action: "DB 마이그레이션 파일 생성 (Alembic)"
    code: "alembic revision --autogenerate -m 'add booking tables'"

  impact_on_existing_code:
    modified_files: 1                # app_factory.py만 수정
    existing_modules_changed: 0      # 기존 모듈 변경 없음 ✅
```

```bash
# 새 모듈 추가 시 커밋
FEAT:(AI-010) 예약 관리 모듈 스캐폴딩

# 브랜치
root/booking-management
```

#### 작업 2: 기존 모듈 수정 (MODIFY)

기존 기능(예: "리뷰 분류에 감정 분석 추가")을 수정할 때의 절차이다.

```yaml
modify_module_checklist:
  principle: "수정은 해당 모듈 폴더 안에서만 일어난다"

  step_1_identify_scope:
    question: "변경이 이 모듈 안에서 완결되는가?"
    yes: "모듈 내부만 수정 → 바로 진행"
    no: "인터페이스 변경이 필요 → 영향 받는 모듈 목록 확인 → Phase 1 합의 필요"

  step_2_modify:
    action: "해당 모듈 내부 파일 수정"
    rules:
      - "인터페이스(interface.py)가 바뀌지 않으면 다른 모듈에 영향 없음"
      - "인터페이스가 바뀌면 → 하위 호환 유지 (기존 메서드 삭제 금지, deprecated 표시)"
      - "새 기능은 기존 메서드 수정이 아니라 새 메서드 추가로 대응"

  step_3_test:
    action: "해당 모듈의 테스트만 실행하여 검증"
    code: "pytest src/modules/review/tests/ -v"

  impact_on_existing_code:
    modified_files: "해당 모듈 내부 파일만"
    existing_modules_changed: 0
```

```python
# === 인터페이스 하위 호환 유지 예시 ===

class ReviewModuleInterface(ABC):

    # 기존 메서드 — 절대 삭제하지 않는다
    @abstractmethod
    async def get_reviews_by_owner(
        self,
        owner_id: str,
        date_range: DateRange,
    ) -> list[ReviewSummaryDTO]:
        ...

    # ✅ 새 기능은 새 메서드로 추가
    @abstractmethod
    async def get_reviews_with_sentiment(
        self,
        owner_id: str,
        date_range: DateRange,
    ) -> list[ReviewWithSentimentDTO]:
        """감정 분석이 포함된 리뷰 목록 (v1.1 추가)"""
        ...

    # ❌ 금지: 기존 메서드 시그니처 변경
    # async def get_reviews_by_owner(
    #     self, owner_id: str, date_range: DateRange,
    #     include_sentiment: bool = False,  ← 기존 호출자가 깨질 수 있음
    # ) -> list[ReviewSummaryDTO]: ...
```

#### 작업 3: 모듈 확장 (EXTEND)

기존 모듈의 동작을 **변경하지 않고 확장**할 때의 절차이다. 개방-폐쇄 원칙(OCP)을 적용한다.

```yaml
extend_module_checklist:
  principle: "기존 코드를 수정하지 않고, 새 코드를 추가하여 동작을 확장한다"

  patterns:
    strategy_pattern:
      when: "같은 작업을 여러 방식으로 수행해야 할 때"
      example: "리뷰 분류 방식 추가 (AI, 규칙, 하이브리드)"

    decorator_pattern:
      when: "기존 동작에 부가 기능을 덧붙일 때"
      example: "리뷰 분류 결과에 캐싱/로깅/메트릭 추가"

    observer_pattern:
      when: "특정 이벤트 발생 시 새로운 반응을 추가할 때"
      example: "리뷰 생성 시 슬랙 알림 추가"
```

```python
# === Strategy 패턴으로 확장 ===
# 새 분류 방식 추가 시 기존 코드 수정 제로

# 기존 코드 (수정하지 않음)
class ClassifierStrategy(ABC):
    @abstractmethod
    def classify(self, text: str) -> list[ClassificationTag]: ...

class RuleClassifier(ClassifierStrategy):
    """규칙 기반 분류 — 기존 코드 그대로"""
    def classify(self, text: str) -> list[ClassificationTag]:
        ...

class AIClassifier(ClassifierStrategy):
    """AI 기반 분류 — 기존 코드 그대로"""
    def classify(self, text: str) -> list[ClassificationTag]:
        ...

# ✅ 새로 추가하는 코드 (기존 파일 수정 없음)
class SentimentAwareClassifier(ClassifierStrategy):
    """감정 분석 + 분류 — 새 파일에 새 클래스 추가"""
    def __init__(self, base_classifier: ClassifierStrategy):
        self._base = base_classifier

    def classify(self, text: str) -> list[ClassificationTag]:
        base_tags = self._base.classify(text)
        sentiment = self._analyze_sentiment(text)
        return self._merge_tags(base_tags, sentiment)

# 설정만 변경하여 새 전략 적용
# config.py 또는 dependencies.py
def get_classifier() -> ClassifierStrategy:
    return SentimentAwareClassifier(
        base_classifier=HybridClassifier(
            rule=RuleClassifier(),
            ai=AIClassifier(),
        )
    )
```

```python
# === Decorator 패턴으로 확장 ===
# 기존 서비스에 캐싱/로깅 등 부가 기능을 덧붙이기

class CachedReviewService:
    """리뷰 서비스에 캐싱을 덧붙이는 데코레이터"""

    def __init__(self, inner: ReviewService, cache: CacheClient):
        self._inner = inner
        self._cache = cache

    async def get_review_detail(self, review_id: str) -> ReviewDetailResponse:
        # 캐시 확인
        cached = await self._cache.get(f"review:{review_id}")
        if cached:
            return ReviewDetailResponse.model_validate_json(cached)

        # 캐시 미스 → 원본 서비스 호출
        result = await self._inner.get_review_detail(review_id)

        # 캐시 저장
        await self._cache.set(
            f"review:{review_id}",
            result.model_dump_json(),
            ttl=300,
        )
        return result


class LoggedReviewService:
    """리뷰 서비스에 로깅을 덧붙이는 데코레이터"""

    def __init__(self, inner: ReviewService):
        self._inner = inner

    async def classify_review(self, review_id: str) -> ReviewClassificationResponse:
        logger.info(f"리뷰 분류 시작: {review_id}")
        start = time.monotonic()

        result = await self._inner.classify_review(review_id)

        elapsed = time.monotonic() - start
        logger.info(f"리뷰 분류 완료: {review_id}, 소요: {elapsed:.2f}s, 태그: {len(result.tags)}")
        return result


# 의존성 주입으로 데코레이터 조합
def get_review_service() -> ReviewService:
    base = ReviewService(repo=get_repo(), classifier=get_classifier(), event_bus=get_event_bus())
    cached = CachedReviewService(inner=base, cache=get_cache())
    logged = LoggedReviewService(inner=cached)
    return logged  # 캐싱 + 로깅이 적용된 서비스
```

```python
# === Observer 패턴(이벤트)으로 확장 ===
# 새 반응 추가 시 기존 코드 수정 제로

# 기존 코드: 리뷰 서비스는 이벤트만 발행 (수정 없음)
# review/service.py의 classify_review()는 그대로

# ✅ 새로 추가: 슬랙 알림 모듈
# modules/notification/event_handlers.py (새 파일)

class NotificationEventHandlers:
    async def on_review_classified(self, event: ReviewClassifiedEvent) -> None:
        """리뷰 분류 시 사업자에게 슬랙 알림"""
        await self._slack.send(
            channel=self._get_owner_channel(event.owner_id),
            message=f"새 리뷰가 분류되었습니다: {event.tags}",
        )

# app_factory.py에 한 줄 추가
event_bus.subscribe("review.classified", notification_handlers.on_review_classified)
```

#### 작업 4: 모듈 삭제 (DELETE)

기능을 제거(예: "마케팅 캠페인 모듈 폐기")할 때의 절차이다.

```yaml
delete_module_checklist:
  step_1_identify_dependencies:
    action: "삭제할 모듈을 참조하는 곳을 검색한다"
    command: 'grep -r "from src.modules.{module_name}" src/ --include="*.py"'
    expected:
      - "app_factory.py의 라우터 등록"
      - "app_factory.py의 이벤트 핸들러 등록"
      - "다른 모듈의 의존성 주입 (인터페이스 참조)"

  step_2_remove_references:
    action: "참조 지점을 제거한다"
    targets:
      - "app_factory.py에서 라우터 등록 줄 삭제"
      - "app_factory.py에서 이벤트 핸들러 등록 블록 삭제"
      - "다른 모듈에서 이 모듈의 인터페이스를 사용하는 곳 → 대체 또는 제거"

  step_3_delete_folder:
    action: "모듈 폴더 통째로 삭제"
    command: "rm -rf src/modules/{module_name}/"

  step_4_migration:
    action: "DB 테이블 삭제 마이그레이션 생성 (데이터 백업 후)"
    command: "alembic revision --autogenerate -m 'drop {module_name} tables'"

  step_5_verify:
    action: "전체 테스트 실행하여 다른 모듈이 깨지지 않는지 확인"
    command: "pytest src/ -v"

  impact_estimation:
    well_designed: "app_factory.py 수정 + 폴더 삭제 → 끝 (2~3개 파일 수정)"
    poorly_designed: "10개 이상 파일 수정 필요 → 모듈 분리가 안 되어 있다는 신호"
```

```bash
# 모듈 삭제 시 커밋
FEAT:(AI-015) 마케팅 캠페인 모듈 제거

# 변경 파일이 3개 이하면 잘 설계된 것
git diff --stat
# src/core/app_factory.py           | 8 --------
# src/modules/campaign/             | deleted (12 files)
# migrations/versions/xxx_drop_campaign.py | 15 +++
```

---

### 14-5. 모듈 설계 금지 사항 (Anti-Patterns)

```yaml
module_anti_patterns:

  cross_module_db_join:
    description: "모듈 A의 리포지토리에서 모듈 B의 테이블을 JOIN"
    problem: "모듈 B를 삭제하면 모듈 A의 쿼리가 깨진다"
    solution: "인터페이스를 통해 데이터 조회 → 애플리케이션 레벨에서 조합"
    example: |
      # ❌ review_repository.py에서 report 테이블 JOIN
      SELECT r.*, rp.summary FROM reviews r JOIN reports rp ON r.id = rp.review_id

      # ✅ review는 review만, report 데이터는 인터페이스로 조회
      reviews = await review_repo.find_by_owner(owner_id)
      report = await report_interface.get_latest_report(owner_id)

  shared_model:
    description: "여러 모듈이 같은 DB 모델(ORM 클래스)을 공유"
    problem: "모델 변경 시 모든 모듈이 영향받는다"
    solution: "각 모듈이 자기만의 모델을 소유. 같은 테이블이라도 각 모듈에서 필요한 컬럼만 매핑"
    example: |
      # ❌ 공유 모델
      from src.models.review import ReviewModel  # 여러 모듈이 같은 모델 import

      # ✅ 각 모듈이 자기 모델 소유
      # review/model.py → ReviewModel (전체 컬럼)
      # report/model.py → ReviewReadModel (읽기 전용, 필요한 컬럼만)

  circular_dependency:
    description: "모듈 A가 모듈 B를 import하고, 모듈 B도 모듈 A를 import"
    problem: "import 에러, 테스트 불가, 삭제 불가"
    solution: "이벤트 버스로 전환하거나, 공유 인터페이스를 _shared/에 정의"
    check: |
      # 순환 의존 탐지
      # 아래 명령으로 모듈 간 import 관계를 확인
      grep -r "from src.modules." src/modules/ --include="*.py" | grep -v "__pycache__" | grep -v "tests/"

  god_shared_module:
    description: "_shared/ 폴더에 온갖 유틸리티가 쌓임"
    problem: "_shared/가 커지면 모든 모듈이 의존 → 사실상 결합"
    solution: "_shared/에는 정말 공통인 것만: Base 모델, 공통 예외, 이벤트 버스, 페이지네이션"
    rule: "_shared/에 새 파일 추가 시 '이것이 정말 2개 이상 모듈에 공통인가?' 자문"

  leaking_internals:
    description: "모듈 내부 클래스(service, repository)를 외부에서 직접 import"
    problem: "내부 구조 변경 시 외부가 깨진다"
    solution: "__init__.py에서 interface만 노출. 외부는 interface만 사용"
    example: |
      # ❌ 내부 직접 import
      from src.modules.review.service import ReviewService
      from src.modules.review.repository import ReviewRepository

      # ✅ 인터페이스만 import
      from src.modules.review import ReviewModuleInterface
```

---

### 14-6. 모듈 설계 검증 체크리스트

새 모듈을 설계하거나 기존 구조를 리뷰할 때 사용한다.

```
## 모듈 독립성 체크
□ 이 모듈 폴더를 삭제하면 다른 모듈의 테스트가 모두 통과하는가?
□ 이 모듈의 __init__.py가 interface만 노출하고 있는가?
□ 이 모듈의 repository가 자기 테이블만 접근하는가? (다른 모듈 테이블 JOIN 없는지)
□ 이 모듈의 model.py가 다른 모듈의 모델과 relationship을 맺고 있지 않은가?

## 모듈 간 통신 체크
□ 모듈 간 데이터 전달이 이벤트 버스 또는 인터페이스를 통하는가?
□ 다른 모듈의 내부 클래스(service, repository)를 직접 import하고 있지 않은가?
□ 순환 의존(A→B→A)이 없는가?

## 확장성 체크
□ 새 기능 추가 시 기존 코드 수정 범위가 3개 파일 이내인가?
□ Strategy/Decorator/Observer 패턴이 적절히 적용되어 있는가?
□ 설정 변경만으로 동작을 교체할 수 있는 지점이 있는가? (DI)

## 삭제 용이성 체크
□ 이 모듈을 삭제할 때 수정해야 하는 파일이 app_factory.py 외에 있는가?
□ grep으로 이 모듈명을 검색했을 때 참조가 3곳 이내인가?
□ 이 모듈 삭제 후 DB 마이그레이션이 깔끔하게 되는가?

## _shared/ 건강도 체크
□ _shared/ 폴더의 파일이 10개를 넘지 않는가?
□ _shared/에 특정 모듈에만 쓰이는 유틸리티가 들어있지 않은가?
□ _shared/의 변경이 모든 모듈의 테스트를 깨뜨리지 않는가?
```

---

## 부록: 용어 정리

**오케스트레이터(Orchestrator)**: 프로젝트 전체를 관리하는 최상위 에이전트이다. 사이클을 조율하고, 합의 불가 시 최종 결정을 내린다.

**Teams 계층**: 서로 다른 분야의 리드 에이전트들이 수평적으로 협업하는 층이다. 의사결정과 합의를 담당한다.

**Subagent 계층**: 리드 에이전트의 지시를 받아 구체적인 작업을 실행하는 층이다. 단방향 위임 구조이다.

**Skills**: 특정 작업의 베스트 프랙티스를 담은 참조 문서이다. Subagent가 작업 품질을 높이기 위해 참고한다.

**Phase 1 (합의)**: 리드들이 토론하여 방향을 결정하는 단계이다.

**Phase 2 (병렬 실행)**: 합의된 내용을 Subagent들이 동시에 실행하는 단계이다.

**Phase 3 (통합 검토)**: 결과물을 크로스 체크하고 품질을 보장하는 단계이다.

**에스컬레이션**: 하위 계층에서 해결할 수 없는 문제를 상위 계층으로 올리는 것이다.

**DDD (Domain-Driven Design)**: 비즈니스 도메인을 코드 구조의 중심에 놓는 설계 방법이다. 유비쿼터스 언어, 바운디드 컨텍스트, 엔티티/값 객체/애그리게이트 등의 개념을 사용한다.

**TDD (Test-Driven Development)**: 코드 작성 전에 테스트를 먼저 작성하는 개발 방법이다. Red(실패 테스트) → Green(최소 구현) → Refactor(정리) 사이클을 반복한다.

**Clean Code**: 읽기 쉽고, 이해하기 쉽고, 수정하기 쉬운 코드를 작성하는 원칙의 총칭이다. 의미 있는 이름, 단일 책임 함수, DRY, 조기 반환 등이 핵심이다.

**SOLID**: 객체지향 설계의 5가지 원칙이다. 단일 책임(S), 개방-폐쇄(O), 리스코프 치환(L), 인터페이스 분리(I), 의존성 역전(D)으로 구성된다.

**ADR (Architecture Decision Record)**: 중요한 아키텍처 결정을 문서화하는 형식이다. 맥락, 선택지, 결정, 근거, 결과를 기록한다.

**유비쿼터스 언어 (Ubiquitous Language)**: 개발자와 비개발자가 공유하는 도메인 용어 사전이다. 코드에서도 이 용어를 그대로 사용한다.

**바운디드 컨텍스트 (Bounded Context)**: 특정 도메인 모델이 유효한 경계이다. 같은 용어라도 컨텍스트에 따라 다른 의미를 가질 수 있다.

**애그리게이트 (Aggregate)**: 관련 엔티티/값 객체의 묶음이다. 루트 엔티티를 통해서만 내부에 접근하며, 트랜잭션의 경계가 된다.

**모듈 (Module)**: 하나의 비즈니스 기능을 완결적으로 수행하는 코드 단위이다. 자기만의 router, service, repository, model, schema, test를 소유한다.

**수직 슬라이스 (Vertical Slice)**: 기능 단위로 코드를 수직 분할하는 구조이다. 한 기능의 모든 레이어(API~DB)가 하나의 폴더에 모인다.

**이벤트 버스 (Event Bus)**: 모듈 간 느슨한 통신을 위한 인프라이다. 발행자와 구독자가 서로를 모른 채 이벤트로 소통한다.

**파사드 (Facade)**: 모듈의 내부 복잡성을 숨기고 단순한 인터페이스를 외부에 노출하는 패턴이다.
