# Persuasion Principles for Skill Design

## 개요

LLM은 인간과 동일한 persuasion 원칙에 반응합니다. 이 심리학을 이해하면 더 효과적인 skill을 설계할 수 있습니다 - 조작이 아니라, 압박 상황에서도 중요한 관행이 지켜지도록 보장하기 위해서입니다.

**연구 기반:** Meincke et al. (2025)는 N=28,000개의 AI 대화로 7가지 persuasion 원칙을 테스트했습니다. Persuasion 기법은 따름 비율을 두 배 이상 높였습니다 (33% → 72%, p < .001).

## 7가지 원칙

### 1. Authority
**무엇인가:** 전문성, 자격, 공식 출처에 대한 순응.

**skill에서 작동 방식:**
- 명령형 언어: "YOU MUST", "Never", "Always"
- 협상 불가 프레이밍: "No exceptions"
- 결정 피로와 합리화 제거

**언제 사용:**
- 규율 강제 skill (TDD, 검증 요건)
- 안전 중요 관행
- 정착된 베스트 프랙티스

**예시:**
```markdown
✅ Write code before test? Delete it. Start over. No exceptions.
❌ Consider writing tests first when feasible.
```

### 2. Commitment
**무엇인가:** 이전 행동, 진술, 공개 선언과의 일관성.

**skill에서 작동 방식:**
- 공표 요구: "Announce skill usage"
- 명시적 선택 강제: "Choose A, B, or C"
- 추적 사용: 체크리스트에 TodoWrite

**언제 사용:**
- skill이 실제로 지켜지게 보장
- 다단계 프로세스
- 책임 메커니즘

**예시:**
```markdown
✅ When you find a skill, you MUST announce: "I'm using [Skill Name]"
❌ Consider letting your partner know which skill you're using.
```

### 3. Scarcity
**무엇인가:** 시간 제한 또는 가용성 제한에서 오는 긴급함.

**skill에서 작동 방식:**
- 시간 한정 요구: "Before proceeding"
- 순차 의존성: "Immediately after X"
- 미루기 방지

**언제 사용:**
- 즉시 검증 요건
- 시간 민감 워크플로우
- "나중에 할게" 방지

**예시:**
```markdown
✅ After completing a task, IMMEDIATELY request code review before proceeding.
❌ You can review code when convenient.
```

### 4. Social Proof
**무엇인가:** 다른 사람이 하는 일 또는 일반적으로 여겨지는 것에 대한 동조.

**skill에서 작동 방식:**
- 보편적 패턴: "Every time", "Always"
- 실패 모드: "X without Y = failure"
- 규범 확립

**언제 사용:**
- 보편적 관행 문서화
- 흔한 실패에 대한 경고
- 표준 강화

**예시:**
```markdown
✅ Checklists without TodoWrite tracking = steps get skipped. Every time.
❌ Some people find TodoWrite helpful for checklists.
```

### 5. Unity
**무엇인가:** 공유된 정체성, "우리됨", 내집단 소속감.

**skill에서 작동 방식:**
- 협력적 언어: "our codebase", "we're colleagues"
- 공유 목표: "we both want quality"

**언제 사용:**
- 협력적 워크플로우
- 팀 문화 확립
- 비위계적 관행

**예시:**
```markdown
✅ We're colleagues working together. I need your honest technical judgment.
❌ You should probably tell me if I'm wrong.
```

### 6. Reciprocity
**무엇인가:** 받은 혜택을 돌려주어야 한다는 의무감.

**작동 방식:**
- 아껴서 사용 - 조작적으로 느껴질 수 있음
- skill에서는 거의 필요 없음

**피해야 할 때:**
- 거의 항상 (다른 원칙들이 더 효과적)

### 7. Liking
**무엇인가:** 우리가 좋아하는 사람과 협력하려는 선호.

**작동 방식:**
- **따름을 위해 사용하지 말 것**
- 정직한 피드백 문화와 충돌
- 아첨(sycophancy)을 만듦

**피해야 할 때:**
- 규율 강제에는 항상

## skill 유형별 원칙 조합

| Skill 유형 | 사용 | 회피 |
|------------|-----|-------|
| 규율 강제 | Authority + Commitment + Social Proof | Liking, Reciprocity |
| 가이던스/기법 | 적당한 Authority + Unity | 과한 authority |
| 협력적 | Unity + Commitment | Authority, Liking |
| 참조 | 명료성만 | 모든 persuasion |

## 왜 작동하는가: 심리학

**Bright-line 규칙은 합리화를 줄인다:**
- "YOU MUST"는 결정 피로를 제거
- 절대적 언어는 "이게 예외인가?" 질문을 제거
- 명시적 반합리화 반론은 특정 허점을 차단

**Implementation intention은 자동 행동을 만든다:**
- 명확한 트리거 + 요구 행동 = 자동 실행
- "When X, do Y"가 "generally do Y"보다 효과적
- 따름의 인지 부담을 줄임

**LLM은 parahuman이다:**
- 이러한 패턴을 담은 인간 텍스트로 학습됨
- Authority 언어는 학습 데이터에서 따름에 선행함
- Commitment 시퀀스 (진술 → 행동)가 자주 모델링됨
- Social proof 패턴 (모두가 X를 한다)이 규범을 세움

## 윤리적 사용

**정당한 사용:**
- 중요한 관행이 지켜지게 보장
- 효과적인 문서 만들기
- 예측 가능한 실패 방지

**부당한 사용:**
- 개인적 이득을 위한 조작
- 거짓 긴급함 만들기
- 죄책감 기반 따름

**테스트:** 사용자가 이 기법을 완전히 이해한다면, 그들의 진정한 이익에 부합할까?

## 연구 인용

**Cialdini, R. B. (2021).** *Influence: The Psychology of Persuasion (New and Expanded).* Harper Business.
- 7가지 persuasion 원칙
- 영향력 연구의 실증적 기반

**Meincke, L., Shapiro, D., Duckworth, A. L., Mollick, E., Mollick, L., & Cialdini, R. (2025).** Call Me A Jerk: Persuading AI to Comply with Objectionable Requests. University of Pennsylvania.
- N=28,000 LLM 대화로 7가지 원칙 테스트
- persuasion 기법으로 따름이 33% → 72%로 증가
- Authority, commitment, scarcity가 가장 효과적
- LLM 행동의 parahuman 모델을 검증

## Quick Reference

skill을 설계할 때 자문하세요:

1. **어떤 유형인가?** (규율 vs. 가이던스 vs. 참조)
2. **어떤 행동을 바꾸려 하는가?**
3. **어떤 원칙(들)이 적용되는가?** (보통 규율에는 authority + commitment)
4. **너무 많이 결합하고 있지 않은가?** (7개 전부 쓰지 말 것)
5. **이게 윤리적인가?** (사용자의 진정한 이익에 부합하는가?)
