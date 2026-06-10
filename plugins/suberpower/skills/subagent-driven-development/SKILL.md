---
name: subagent-driven-development
description: 현재 세션에서 독립적인 task로 구성된 implementation plan을 실행할 때 사용합니다
---

# Subagent-Driven Development

각 task마다 새로운 subagent를 dispatch하여 plan을 실행하고, 각 task 후에는 두 단계의 review를 수행합니다 — 먼저 spec 준수 review, 그다음 code quality review입니다.

**왜 subagent를 사용하는가:** 격리된 context를 가진 전문 agent에게 task를 위임합니다. 지시문과 context를 정밀하게 구성함으로써, 해당 agent가 집중력을 유지하고 task를 성공적으로 수행하도록 보장합니다. subagent는 절대 당신의 세션 context나 히스토리를 상속받아서는 안 됩니다 — 필요한 것을 정확히 구성해서 전달해야 합니다. 이를 통해 당신 자신의 context도 조율 작업을 위해 보존됩니다.

**핵심 원칙:** task마다 새로운 subagent + 두 단계 review(spec → quality) = 높은 품질과 빠른 반복

**지속적인 실행:** task 사이에 사람 파트너에게 확인받기 위해 멈추지 마세요. plan의 모든 task를 멈추지 않고 실행하세요. 멈춰야 할 유일한 이유는 다음과 같습니다: 해결할 수 없는 BLOCKED 상태, 진행을 실제로 막는 모호함, 모든 task 완료. "계속할까요?" 같은 질문이나 진행 요약은 사용자의 시간을 낭비합니다 — 그들은 plan을 실행해달라고 요청한 것이므로, 그냥 실행하세요.

## 언제 사용하는가

```dot
digraph when_to_use {
    "implementation plan이 있는가?" [shape=diamond];
    "task들이 대체로 독립적인가?" [shape=diamond];
    "이 세션에 머무르는가?" [shape=diamond];
    "subagent-driven-development" [shape=box];
    "executing-plans" [shape=box];
    "수동 실행 또는 먼저 brainstorming" [shape=box];

    "implementation plan이 있는가?" -> "task들이 대체로 독립적인가?" [label="예"];
    "implementation plan이 있는가?" -> "수동 실행 또는 먼저 brainstorming" [label="아니오"];
    "task들이 대체로 독립적인가?" -> "이 세션에 머무르는가?" [label="예"];
    "task들이 대체로 독립적인가?" -> "수동 실행 또는 먼저 brainstorming" [label="아니오 - 강하게 결합됨"];
    "이 세션에 머무르는가?" -> "subagent-driven-development" [label="예"];
    "이 세션에 머무르는가?" -> "executing-plans" [label="아니오 - 병렬 세션"];
}
```

**Executing Plans(병렬 세션)와의 비교:**
- 같은 세션 (context 전환 없음)
- task마다 새로운 subagent (context 오염 없음)
- 각 task 후 두 단계 review: spec 준수 먼저, 그다음 code quality
- 더 빠른 반복 (task 사이에 사람 개입 없음)

## 프로세스

```dot
digraph process {
    rankdir=TB;

    subgraph cluster_per_task {
        label="Task별";
        "implementer subagent dispatch (./implementer-prompt.md)" [shape=box];
        "implementer subagent가 질문하는가?" [shape=diamond];
        "질문에 답하고 맥락 제공" [shape=box];
        "implementer subagent가 구현, 테스트, commit, self-review" [shape=box];
        "spec reviewer subagent dispatch (./spec-reviewer-prompt.md)" [shape=box];
        "spec reviewer subagent가 코드와 spec 일치를 확인하는가?" [shape=diamond];
        "implementer subagent가 spec 격차 수정" [shape=box];
        "code quality reviewer subagent dispatch (./code-quality-reviewer-prompt.md)" [shape=box];
        "code quality reviewer subagent가 승인하는가?" [shape=diamond];
        "implementer subagent가 품질 이슈 수정" [shape=box];
        "TodoWrite에서 task 완료 표시" [shape=box];
    }

    "plan을 읽고, 모든 task를 전체 텍스트로 추출, 맥락 기록, TodoWrite 생성" [shape=box];
    "남은 task가 있는가?" [shape=diamond];
    "전체 구현에 대한 최종 code reviewer subagent dispatch" [shape=box];
    "suberpower:finishing-a-development-branch 사용" [shape=box style=filled fillcolor=lightgreen];

    "plan을 읽고, 모든 task를 전체 텍스트로 추출, 맥락 기록, TodoWrite 생성" -> "implementer subagent dispatch (./implementer-prompt.md)";
    "implementer subagent dispatch (./implementer-prompt.md)" -> "implementer subagent가 질문하는가?";
    "implementer subagent가 질문하는가?" -> "질문에 답하고 맥락 제공" [label="예"];
    "질문에 답하고 맥락 제공" -> "implementer subagent dispatch (./implementer-prompt.md)";
    "implementer subagent가 질문하는가?" -> "implementer subagent가 구현, 테스트, commit, self-review" [label="아니오"];
    "implementer subagent가 구현, 테스트, commit, self-review" -> "spec reviewer subagent dispatch (./spec-reviewer-prompt.md)";
    "spec reviewer subagent dispatch (./spec-reviewer-prompt.md)" -> "spec reviewer subagent가 코드와 spec 일치를 확인하는가?";
    "spec reviewer subagent가 코드와 spec 일치를 확인하는가?" -> "implementer subagent가 spec 격차 수정" [label="아니오"];
    "implementer subagent가 spec 격차 수정" -> "spec reviewer subagent dispatch (./spec-reviewer-prompt.md)" [label="재검토"];
    "spec reviewer subagent가 코드와 spec 일치를 확인하는가?" -> "code quality reviewer subagent dispatch (./code-quality-reviewer-prompt.md)" [label="예"];
    "code quality reviewer subagent dispatch (./code-quality-reviewer-prompt.md)" -> "code quality reviewer subagent가 승인하는가?";
    "code quality reviewer subagent가 승인하는가?" -> "implementer subagent가 품질 이슈 수정" [label="아니오"];
    "implementer subagent가 품질 이슈 수정" -> "code quality reviewer subagent dispatch (./code-quality-reviewer-prompt.md)" [label="재검토"];
    "code quality reviewer subagent가 승인하는가?" -> "TodoWrite에서 task 완료 표시" [label="예"];
    "TodoWrite에서 task 완료 표시" -> "남은 task가 있는가?";
    "남은 task가 있는가?" -> "implementer subagent dispatch (./implementer-prompt.md)" [label="예"];
    "남은 task가 있는가?" -> "전체 구현에 대한 최종 code reviewer subagent dispatch" [label="아니오"];
    "전체 구현에 대한 최종 code reviewer subagent dispatch" -> "suberpower:finishing-a-development-branch 사용";
}
```

## 모델 선택

비용을 절감하고 속도를 높이기 위해 각 역할을 처리할 수 있는 가장 약한 모델을 사용하세요.

**기계적인 implementation task** (격리된 함수, 명확한 spec, 1-2개 파일): 빠르고 저렴한 모델을 사용하세요. plan이 잘 명세되어 있으면 대부분의 implementation task는 기계적입니다.

**통합 및 판단 task** (다중 파일 조율, 패턴 매칭, 디버깅): 표준 모델을 사용하세요.

**아키텍처, 설계, review task**: 사용 가능한 가장 강력한 모델을 사용하세요.

**Task 복잡도 신호:**
- 완전한 spec과 함께 1-2개 파일에 영향 → 저렴한 모델
- 통합 관심사가 있는 여러 파일에 영향 → 표준 모델
- 설계 판단이나 광범위한 코드베이스 이해 필요 → 가장 강력한 모델

## Implementer 상태 처리

Implementer subagent는 네 가지 상태 중 하나를 보고합니다. 각각을 적절히 처리하세요.

**DONE:** spec 준수 review로 진행합니다.

**DONE_WITH_CONCERNS:** implementer가 작업을 완료했지만 의심을 표시했습니다. 진행하기 전에 그 우려 사항을 읽어보세요. 우려가 정확성이나 범위에 관한 것이라면 review 전에 해결하세요. 단순한 관찰(예: "이 파일이 커지고 있다")이라면 메모해두고 review로 진행하세요.

**NEEDS_CONTEXT:** implementer가 제공받지 못한 정보가 필요합니다. 누락된 context를 제공하고 다시 dispatch하세요.

**BLOCKED:** implementer가 task를 완료할 수 없습니다. blocker를 평가하세요:
1. context 문제라면 더 많은 context를 제공하고 같은 모델로 다시 dispatch합니다
2. task에 더 많은 추론이 필요하다면 더 강력한 모델로 다시 dispatch합니다
3. task가 너무 크다면 더 작은 조각으로 나눕니다
4. plan 자체가 잘못되었다면 사람에게 에스컬레이션합니다

에스컬레이션을 **절대** 무시하거나 변경 없이 같은 모델에게 재시도를 강요하지 마세요. implementer가 막혔다고 말했다면 무언가가 바뀌어야 합니다.

## Prompt 템플릿

- `./implementer-prompt.md` - implementer subagent dispatch
- `./spec-reviewer-prompt.md` - spec 준수 reviewer subagent dispatch
- `./code-quality-reviewer-prompt.md` - code quality reviewer subagent dispatch

## 예시 워크플로우

```
You: I'm using Subagent-Driven Development to execute this plan.

[Read plan file once: docs/superpowers/plans/feature-plan.md]
[Extract all 5 tasks with full text and context]
[Create TodoWrite with all tasks]

Task 1: Hook installation script

[Get Task 1 text and context (already extracted)]
[Dispatch implementation subagent with full task text + context]

Implementer: "Before I begin - should the hook be installed at user or system level?"

You: "User level (~/.config/superpowers/hooks/)"

Implementer: "Got it. Implementing now..."
[Later] Implementer:
  - Implemented install-hook command
  - Added tests, 5/5 passing
  - Self-review: Found I missed --force flag, added it
  - Committed

[Dispatch spec compliance reviewer]
Spec reviewer: ✅ Spec compliant - all requirements met, nothing extra

[Get git SHAs, dispatch code quality reviewer]
Code reviewer: Strengths: Good test coverage, clean. Issues: None. Approved.

[Mark Task 1 complete]

Task 2: Recovery modes

[Get Task 2 text and context (already extracted)]
[Dispatch implementation subagent with full task text + context]

Implementer: [No questions, proceeds]
Implementer:
  - Added verify/repair modes
  - 8/8 tests passing
  - Self-review: All good
  - Committed

[Dispatch spec compliance reviewer]
Spec reviewer: ❌ Issues:
  - Missing: Progress reporting (spec says "report every 100 items")
  - Extra: Added --json flag (not requested)

[Implementer fixes issues]
Implementer: Removed --json flag, added progress reporting

[Spec reviewer reviews again]
Spec reviewer: ✅ Spec compliant now

[Dispatch code quality reviewer]
Code reviewer: Strengths: Solid. Issues (Important): Magic number (100)

[Implementer fixes]
Implementer: Extracted PROGRESS_INTERVAL constant

[Code reviewer reviews again]
Code reviewer: ✅ Approved

[Mark Task 2 complete]

...

[After all tasks]
[Dispatch final code-reviewer]
Final reviewer: All requirements met, ready to merge

Done!
```

## 장점

**수동 실행과의 비교:**
- subagent가 자연스럽게 TDD를 따름
- task마다 fresh context (혼동 없음)
- 병렬 안전 (subagent끼리 간섭하지 않음)
- subagent가 질문 가능 (작업 시작 전 그리고 작업 중에도)

**Executing Plans와의 비교:**
- 같은 세션 (핸드오프 없음)
- 지속적인 진행 (대기 없음)
- 자동 review 체크포인트

**효율성 이득:**
- 파일 읽기 오버헤드 없음 (controller가 전체 텍스트 제공)
- controller가 필요한 context만 정확히 큐레이션
- subagent가 완전한 정보를 미리 받음
- 작업 시작 전 질문이 드러남 (작업 후가 아님)

**품질 게이트:**
- 자체 review로 핸드오프 전에 이슈 발견
- 두 단계 review: spec 준수, 그다음 code quality
- review 루프로 수정이 실제로 작동하는지 확인
- spec 준수로 과/소 구축 방지
- code quality로 구현이 잘 만들어지도록 보장

**비용:**
- 더 많은 subagent 호출 (task당 implementer + 2명의 reviewer)
- controller가 더 많은 준비 작업 수행 (모든 task를 미리 추출)
- review 루프로 반복 추가
- 하지만 이슈를 일찍 잡음 (나중에 디버깅하는 것보다 저렴)

## 위험 신호

**절대 하지 말 것:**
- 사용자의 명시적 동의 없이 main/master branch에서 implementation 시작
- review 건너뛰기 (spec 준수 또는 code quality)
- 수정되지 않은 이슈로 진행
- 여러 implementation subagent를 병렬로 dispatch (충돌 발생)
- subagent에게 plan 파일을 읽게 하기 (대신 전체 텍스트 제공)
- 장면 설정 context 건너뛰기 (subagent는 task가 어디에 맞는지 이해해야 함)
- subagent 질문 무시 (진행시키기 전에 답변)
- spec 준수에서 "충분히 가까움"을 받아들이기 (spec reviewer가 이슈를 발견 = 완료 아님)
- review 루프 건너뛰기 (reviewer가 이슈 발견 = implementer 수정 = 다시 review)
- implementer의 자체 review가 실제 review를 대체하게 하기 (둘 다 필요함)
- **spec 준수가 ✅ 되기 전에 code quality review 시작** (잘못된 순서)
- 어느 review라도 미해결 이슈가 있는데 다음 task로 이동

**subagent가 질문할 때:**
- 명확하고 완전하게 답변
- 필요하면 추가 context 제공
- implementation으로 서두르지 말 것

**reviewer가 이슈를 발견하면:**
- implementer(같은 subagent)가 수정
- reviewer가 다시 review
- 승인될 때까지 반복
- 재review를 건너뛰지 말 것

**subagent가 task에 실패하면:**
- 구체적인 지시와 함께 fix subagent를 dispatch
- 수동으로 수정하려 하지 말 것 (context 오염)

## 통합

**필수 워크플로우 skill:**
- **suberpower:using-git-worktrees** - 격리된 작업 공간 보장 (새로 만들거나 기존 것 확인)
- **suberpower:writing-plans** - 이 skill이 실행할 plan을 생성
- **suberpower:requesting-code-review** - reviewer subagent를 위한 code review 템플릿
- **suberpower:finishing-a-development-branch** - 모든 task 후 개발 완료

**subagent가 사용해야 할 것:**
- **suberpower:test-driven-development** - subagent는 각 task마다 TDD를 따름

**대안 워크플로우:**
- **suberpower:executing-plans** - 같은 세션 실행 대신 병렬 세션에 사용
