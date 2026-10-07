---
name: requesting-code-review
description: 작업을 완료하거나 주요 기능을 구현했을 때, 또는 merge 전에 작업이 요구사항을 충족하는지 검증할 때 사용합니다
---

# Requesting Code Review

code reviewer subagent를 dispatch하여 문제가 연쇄적으로 확대되기 전에 잡아냅니다. reviewer는 평가를 위해 정밀하게 구성된 context를 받으며, 세션의 히스토리는 절대 받지 않습니다.

**핵심 원칙:** 일찍 review하고, 자주 review하세요.

## 언제 Review를 요청해야 하는가

**필수:**
- subagent-driven development에서 각 task 이후
- 주요 기능 완료 후
- main으로의 merge 전

**선택적이지만 가치 있음:**
- 막혔을 때 (새로운 관점)
- 리팩터링 전 (baseline 확인)
- 복잡한 bug fix 후

## 요청 방법

**1. git SHA 가져오기:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # 또는: git merge-base origin/main HEAD
HEAD_SHA=$(git rev-parse HEAD)
```

**2. code reviewer subagent dispatch:**

`general-purpose` subagent를 dispatch하고, [code-reviewer.md](code-reviewer.md)의 template를 채우세요

**Placeholders:**
- `{DESCRIPTION}` - 무엇을 만들었는지에 대한 간략한 요약
- `{PLAN_OR_REQUIREMENTS}` - 무엇을 해야 하는지
- `{BASE_SHA}` - 시작 commit
- `{HEAD_SHA}` - 종료 commit

**3. feedback에 따라 행동:**
- Critical 이슈는 즉시 fix
- Important 이슈는 진행 전에 fix
- Minor 이슈는 나중을 위해 기록
- reviewer가 틀렸다면 push back (근거와 함께)

## 예시

```
[Task 2 완료: 검증 함수 추가]

You: 진행하기 전에 code review를 요청합니다.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[code reviewer subagent dispatch]
  DESCRIPTION: 4가지 이슈 타입을 가진 verifyIndex()와 repairIndex() 추가
  PLAN_OR_REQUIREMENTS: docs/suberpowers/plans/deployment-plan.md의 Task 2
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

[Subagent 반환]:
  Strengths: 깔끔한 아키텍처, 실제 테스트
  Issues:
    Important: 진행 상황 표시기 누락
    Minor: 보고 간격을 위한 매직 넘버 (100)
  Assessment: 진행 가능

You: [진행 상황 표시기 fix]
[Task 3로 계속]
```

## 흔한 합리화

| 변명 | 현실 |
|--------|---------|
| "reviewer를 dispatch하는 대신 diff를 그냥 내가 review하겠다" | 당신은 조율자입니다 — diff를 inline으로 review하면 작업을 계속 이끌어 가는 데 필요한 context window를 소모합니다. reviewer subagent를 dispatch하세요: diff와 평가는 reviewer의 context에 머물고, 당신에게는 지적 사항만 돌아옵니다. |
| "reviewer가 변경을 이해하려면 내 세션 히스토리 전체가 필요하다" | 정밀하게 구성된 context를 넘기고, 세션 히스토리는 절대 넘기지 마세요. 그래야 reviewer가 당신의 사고 과정이 아니라 작업 결과물에 집중합니다. |

## 위험 신호

**절대 하지 말 것:**
- "간단하니까"라며 review 건너뛰기
- Critical 이슈 무시
- 해결되지 않은 Important 이슈를 두고 진행
- 유효한 기술적 feedback에 반박

**reviewer가 틀렸다면:**
- 기술적 근거와 함께 push back
- 작동을 증명하는 코드/테스트 제시
- 명확화 요청

template 참조: [code-reviewer.md](code-reviewer.md)
