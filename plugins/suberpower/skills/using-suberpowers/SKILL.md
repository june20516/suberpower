---
name: using-suberpowers
description: 모든 대화를 시작할 때 사용합니다 - skill을 찾고 사용하는 방법을 확립하며, 명확화 질문을 포함한 어떤 응답이라도 하기 전에 skill 호출을 요구합니다
---

<SUBAGENT-STOP>
특정 작업을 수행하기 위해 subagent로 dispatch되었다면, 이 skill은 무시하세요.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
지금 하고 있는 일에 어떤 skill이 적용될 가능성이 1%라도 있다고 생각된다면, 반드시 그 skill을 호출해야 합니다.

skill이 작업에 적용된다면, 선택의 여지는 없습니다. 반드시 사용해야 합니다.

이것은 협상의 여지가 없습니다. 어떠한 합리화로도 빠져나갈 수 없습니다.
</EXTREMELY-IMPORTANT>

## 규칙

**응답이나 행동을 하기 전에 관련된 또는 요청된 skill을 호출하세요** — 명확화 질문, codebase 탐색, 파일 확인보다도 먼저입니다. 상황에 맞지 않는 것으로 판명되면, 사용하지 않아도 됩니다.

**plan mode에 들어가기 전:** 아직 brainstorming하지 않았다면, brainstorming skill을 먼저 호출하세요.

그런 다음 "[purpose]를 위해 [skill] 사용"이라고 알리고 skill을 정확히 따르세요. checklist가 있으면 항목마다 todo를 하나씩 만드세요.

## skill 우선순위

여러 skill이 적용될 때는 프로세스 skill이 먼저입니다 — 프로세스 skill이 접근 방식을 정하고, 구현 skill(frontend-design 등)이 그것을 실행합니다. brainstorming과 systematic-debugging은 Superpowers(suberpowers 포크)에서 가장 흔한 프로세스 skill이지만, 이 규칙은 어떤 프로세스 skill에도 똑같이 적용됩니다.

- "X를 만들자" → suberpower:brainstorming 먼저, 그 다음 구현 skill.
- "이 버그를 고쳐" → suberpower:systematic-debugging 먼저, 그 다음 도메인 skill.

## 위험 신호

이런 생각이 들면 멈추세요 — 합리화하고 있는 것입니다:

| 생각 | 실제 |
|---------|---------|
| "이건 그냥 간단한 질문이야" | 질문도 작업입니다. skill을 확인하세요. |
| "먼저 context가 더 필요해" | skill 확인이 명확화 질문보다 먼저입니다. |
| "먼저 codebase를 탐색해보자" | skill이 탐색 방법을 알려줍니다. 먼저 확인하세요. |
| "git/파일을 빠르게 확인할 수 있어" | 파일에는 대화 context가 없습니다. skill을 확인하세요. |
| "먼저 정보를 모아보자" | skill이 정보 수집 방법을 알려줍니다. |
| "이건 정식 skill이 필요 없어" | skill이 존재한다면, 사용하세요. |
| "이 skill 기억해" | skill은 진화합니다. 현재 버전을 읽으세요. |
| "이건 작업으로 치지 않아" | 행동 = 작업. skill을 확인하세요. |
| "이 skill은 과해" | 간단한 일이 복잡해집니다. 사용하세요. |
| "이거 하나만 먼저 할게" | 어떤 일이든 하기 전에 확인하세요. |
| "이게 생산적으로 느껴져" | 규율 없는 행동은 시간을 낭비합니다. skill이 이를 방지합니다. |
| "그게 무슨 뜻인지 알아" | 개념을 안다는 것 ≠ skill을 사용하는 것. 호출하세요. |

## 플랫폼 적응

사용 중인 harness가 여기 있으면, 특별 지침이 담긴 해당 reference 파일을 읽으세요:

- Claude Code: `references/claude-code-tools.md`
- Codex: `references/codex-tools.md`
- Pi: `references/pi-tools.md`
- Antigravity: `references/antigravity-tools.md`
- Hermes Agent: `references/hermes-tools.md`
- Muse: `references/muse-tools.md`

## 사용자 지시

사용자 지시(CLAUDE.md, AGENTS.md, GEMINI.md 등, 직접 요청)는 skill보다 우선하고, skill은 다시 기본 동작을 override합니다. skill workflow나 지시는 your human partner가 명시적으로 건너뛰라고 했을 때만 건너뛰세요.
