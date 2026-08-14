---
name: requesting-code-review
description: 작업을 완료하거나 주요 기능을 구현했을 때, 또는 merge 전에 작업이 요구사항을 충족하는지 검증할 때 사용합니다
---

# Requesting Code Review

code reviewer subagent를 dispatch하여 문제가 연쇄적으로 확대되기 전에 잡아냅니다. reviewer는 세션의 히스토리가 아니라 평가를 위해 정밀하게 구성된 context를 받습니다. 이렇게 하면 reviewer가 사고 과정이 아닌 작업 결과물에 집중하게 되고, 본인의 context는 계속 작업하기 위해 보존됩니다.

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
BASE_SHA=$(git rev-parse HEAD~1)  # 또는 origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. dispatch 전 준비 (M-1 체크포인트):**

```bash
mkdir -p ~/.claude/suberpowers/reviews
find ~/.claude/suberpowers/reviews -type f -name '*.md' -mtime +14 -delete  # 14일 지난 보고서 청소
REPORT_FILE=~/.claude/suberpowers/reviews/$(date +%Y-%m-%d)-<프로젝트>-<대상>-review.md
# 같은 대상 재review 시에는 -r2, -r3 접미사로 새 파일을 쓴다 (이전 라운드 보고서를 덮어쓰지 않는다)
```

**3. code reviewer subagent dispatch:**

`general-purpose` 타입으로 Task tool을 사용하고, `code-reviewer.md`의 template를 채우세요

**Placeholders:**
- `{DESCRIPTION}` - 무엇을 만들었는지에 대한 간략한 요약
- `{PLAN_OR_REQUIREMENTS}` - 무엇을 해야 하는지
- `{BASE_SHA}` - 시작 commit
- `{HEAD_SHA}` - 종료 commit
- `{REPORT_FILE}` — review 보고서를 기록할 파일 경로 (orchestrator가 dispatch 전에 경로를 정한다 — 파일 생성은 reviewer가 한다)

**4. feedback에 따라 행동:**

reviewer는 3줄 요약(REPORT_FILE 경로, 판정, 이슈 개수)만 반환합니다. **orchestrator는 통지를 받으면 반드시 REPORT_FILE을 Read로 읽으세요.**

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
  ~/.claude/suberpowers/reviews/2026-08-13-deployment-task-2-review.md
  판정: With fixes
  이슈: Critical 0 / Important 1 / Minor 1

You: [REPORT_FILE을 Read로 읽음 — 전체 보고서는 여기에만 있다]
  Important: 진행 상황 표시기 누락
  Minor: 보고 간격을 위한 매직 넘버 (100)

You: [진행 상황 표시기 fix]
[Task 3로 계속]
```

## 워크플로우와의 통합

**Subagent-Driven Development:**
- 각 task 이후 review
- 문제가 누적되기 전에 잡아내기
- 다음 task로 넘어가기 전에 fix

**Executing Plans:**
- 각 task 이후 또는 자연스러운 체크포인트에서 review
- feedback을 받아 적용하고 계속 진행

**Ad-Hoc Development:**
- merge 전 review
- 막혔을 때 review

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

template 참조: requesting-code-review/code-reviewer.md
