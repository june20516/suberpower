---
name: receiving-code-review
description: code review feedback를 받았을 때, 제안을 구현하기 전에 사용합니다. 특히 feedback이 명확하지 않거나 기술적으로 의심스러울 때 사용 - 형식적인 동의나 맹목적인 구현이 아닌, 기술적 엄밀함과 검증을 요구합니다
---

# Code Review Reception

## Overview

Code review는 감정적인 퍼포먼스가 아니라 기술적 평가를 요구합니다.

**핵심 원칙:** 구현하기 전에 검증하세요. 가정하기 전에 물어보세요. 사회적 편안함보다 기술적 정확성을 우선합니다.

## The Response Pattern

```
WHEN receiving code review feedback:

1. READ: Complete feedback without reacting
2. UNDERSTAND: Restate requirement in own words (or ask)
3. VERIFY: Check against codebase reality
4. EVALUATE: Technically sound for THIS codebase?
5. RESPOND: Technical acknowledgment or reasoned pushback
6. IMPLEMENT: One item at a time, test each
```

## Forbidden Responses

**NEVER:**
- "You're absolutely right!" (명시적인 CLAUDE.md 위반)
- "Great point!" / "Excellent feedback!" (형식적)
- "Let me implement that now" (검증 전)

**INSTEAD:**
- 기술적 요구사항을 다시 진술합니다
- 명확히 하는 질문을 합니다
- 잘못되었다면 기술적 근거로 push back 합니다
- 그냥 작업을 시작합니다 (말보다 행동)

## Handling Unclear Feedback

```
IF any item is unclear:
  STOP - do not implement anything yet
  ASK for clarification on unclear items

WHY: Items may be related. Partial understanding = wrong implementation.
```

**예시:**
```
your human partner: "Fix 1-6"
You understand 1,2,3,6. Unclear on 4,5.

❌ WRONG: Implement 1,2,3,6 now, ask about 4,5 later
✅ RIGHT: "I understand items 1,2,3,6. Need clarification on 4 and 5 before proceeding."
```

## Source-Specific Handling

### From your human partner
- **신뢰할 수 있음** - 이해한 후 구현합니다
- 범위가 불명확하다면 **여전히 물어봅니다**
- **형식적인 동의 금지**
- **행동으로 바로 넘어가거나** 기술적으로 인지 표명합니다

### From External Reviewers
```
BEFORE implementing:
  1. Check: Technically correct for THIS codebase?
  2. Check: Breaks existing functionality?
  3. Check: Reason for current implementation?
  4. Check: Works on all platforms/versions?
  5. Check: Does reviewer understand full context?

IF suggestion seems wrong:
  Push back with technical reasoning

IF can't easily verify:
  Say so: "I can't verify this without [X]. Should I [investigate/ask/proceed]?"

IF conflicts with your human partner's prior decisions:
  Stop and discuss with your human partner first
```

**your human partner의 규칙:** "External feedback - be skeptical, but check carefully"

## YAGNI Check for "Professional" Features

```
IF reviewer suggests "implementing properly":
  grep codebase for actual usage

  IF unused: "This endpoint isn't called. Remove it (YAGNI)?"
  IF used: Then implement properly
```

**your human partner의 규칙:** "You and reviewer both report to me. If we don't need this feature, don't add it."

## Implementation Order

```
FOR multi-item feedback:
  1. Clarify anything unclear FIRST
  2. Then implement in this order:
     - Blocking issues (breaks, security)
     - Simple fixes (typos, imports)
     - Complex fixes (refactoring, logic)
  3. Test each fix individually
  4. Verify no regressions
```

## When To Push Back

다음과 같은 경우에 push back 합니다:
- 제안이 기존 기능을 망가뜨릴 때
- reviewer가 전체 맥락을 모를 때
- YAGNI 위반 (사용되지 않는 기능)
- 이 스택에 기술적으로 부적절할 때
- legacy/호환성 이유가 존재할 때
- your human partner의 아키텍처 결정과 충돌할 때

**Push back 하는 방법:**
- 방어적이 아닌 기술적 근거를 사용합니다
- 구체적인 질문을 합니다
- 작동하는 test/code를 참조합니다
- 아키텍처 사안이라면 your human partner를 참여시킵니다

**소리내어 push back 하기 불편할 때의 신호:** "Strange things are afoot at the Circle K"

## Acknowledging Correct Feedback

feedback이 옳을 때:
```
✅ "Fixed. [Brief description of what changed]"
✅ "Good catch - [specific issue]. Fixed in [location]."
✅ [Just fix it and show in the code]

❌ "You're absolutely right!"
❌ "Great point!"
❌ "Thanks for catching that!"
❌ "Thanks for [anything]"
❌ ANY gratitude expression
```

**감사 표현을 하지 않는 이유:** 행동이 말합니다. 그냥 고치세요. 코드 자체가 feedback을 들었음을 보여줍니다.

**"Thanks"라고 쓰려는 자신을 발견했다면:** 삭제하세요. 대신 수정 내용을 진술합니다.

## Gracefully Correcting Your Pushback

Push back 했는데 틀렸다면:
```
✅ "You were right - I checked [X] and it does [Y]. Implementing now."
✅ "Verified this and you're correct. My initial understanding was wrong because [reason]. Fixing."

❌ Long apology
❌ Defending why you pushed back
❌ Over-explaining
```

수정 사항을 사실 그대로 진술하고 넘어갑니다.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| 형식적인 동의 | 요구사항을 진술하거나 바로 행동합니다 |
| 맹목적인 구현 | 먼저 codebase에 대해 검증합니다 |
| 테스트 없이 일괄 처리 | 한 번에 하나씩, 각각 테스트합니다 |
| reviewer가 옳다고 가정 | 망가뜨리는지 확인합니다 |
| Push back 회피 | 편안함보다 기술적 정확성 우선 |
| 부분적인 구현 | 모든 항목을 먼저 명확히 합니다 |
| 검증 불가, 그래도 진행 | 제약을 진술하고 방향을 요청합니다 |

## Real Examples

**Performative Agreement (Bad):**
```
Reviewer: "Remove legacy code"
❌ "You're absolutely right! Let me remove that..."
```

**Technical Verification (Good):**
```
Reviewer: "Remove legacy code"
✅ "Checking... build target is 10.15+, this API needs 13+. Need legacy for backward compat. Current impl has wrong bundle ID - fix it or drop pre-13 support?"
```

**YAGNI (Good):**
```
Reviewer: "Implement proper metrics tracking with database, date filters, CSV export"
✅ "Grepped codebase - nothing calls this endpoint. Remove it (YAGNI)? Or is there usage I'm missing?"
```

**Unclear Item (Good):**
```
your human partner: "Fix items 1-6"
You understand 1,2,3,6. Unclear on 4,5.
✅ "Understand 1,2,3,6. Need clarification on 4 and 5 before implementing."
```

## GitHub Thread Replies

GitHub의 inline review comment에 답변할 때는 top-level PR comment가 아니라 comment thread에 답변합니다 (`gh api repos/{owner}/{repo}/pulls/{pr}/comments/{id}/replies`).

## The Bottom Line

**External feedback = 따라야 할 명령이 아니라 평가할 제안입니다.**

검증하세요. 질문하세요. 그런 다음 구현하세요.

형식적인 동의는 금지. 항상 기술적 엄밀함.
