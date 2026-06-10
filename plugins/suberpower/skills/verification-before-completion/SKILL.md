---
name: verification-before-completion
description: 작업이 완료되었거나, 수정되었거나, 통과되었다고 주장하기 직전에 사용하며, commit이나 PR을 생성하기 전에 사용합니다 - 어떤 성공 주장이라도 하기 전에 verification 명령을 실행하고 출력을 확인해야 합니다; 항상 주장보다 evidence가 먼저입니다
---

# Verification Before Completion

## Overview

verification 없이 작업이 완료되었다고 주장하는 것은 효율이 아니라 부정직함입니다.

**핵심 원칙:** 항상 주장보다 evidence가 먼저입니다.

**이 규칙의 문자를 위반하는 것은 이 규칙의 정신을 위반하는 것입니다.**

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

이번 메시지에서 verification 명령을 실행하지 않았다면, 통과한다고 주장할 수 없습니다.

## The Gate Function

```
어떤 상태를 주장하거나 만족을 표현하기 전에:

1. IDENTIFY: 어떤 명령이 이 주장을 증명하는가?
2. RUN: 전체 명령을 실행 (신선하게, 완전하게)
3. READ: 전체 출력 확인, exit code 확인, 실패 수 세기
4. VERIFY: 출력이 주장을 확증하는가?
   - NO인 경우: evidence와 함께 실제 상태를 진술
   - YES인 경우: evidence와 함께 주장을 진술
5. ONLY THEN: 주장을 합니다

어떤 단계든 건너뛰면 = verifying이 아니라 거짓말
```

## Common Failures

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| test 통과 | test 명령 출력: 0 failures | 이전 실행, "통과할 것" |
| Linter 깨끗함 | Linter 출력: 0 errors | 부분 확인, 추론 |
| Build 성공 | Build 명령: exit 0 | Linter 통과, 로그 양호 |
| 버그 수정됨 | 원래 증상 test: 통과 | 코드 변경, 수정되었다고 가정 |
| 회귀 test 동작 | Red-green cycle 검증됨 | test가 한 번 통과 |
| Agent 완료 | VCS diff가 변경 사항을 보여줌 | Agent가 "success" 보고 |
| 요구사항 충족 | 라인별 체크리스트 | test 통과 |

## Red Flags - STOP

- "should", "probably", "seems to" 사용
- verification 전에 만족 표현 ("Great!", "Perfect!", "Done!" 등)
- verification 없이 commit/push/PR 직전
- agent의 성공 보고를 신뢰함
- 부분 verification에 의존
- "이번 한 번만" 생각
- 피곤해서 작업을 끝내고 싶음
- **verification을 실행하지 않은 채로 성공을 암시하는 모든 표현**

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "이제 동작할 것" | verification을 RUN하세요 |
| "확신합니다" | 확신 ≠ evidence |
| "이번 한 번만" | 예외 없음 |
| "Linter가 통과했음" | Linter ≠ compiler |
| "Agent가 success라 말했음" | 독립적으로 verify |
| "피곤함" | 피로 ≠ 변명 |
| "부분 확인으로 충분" | 부분은 아무것도 증명하지 못함 |
| "다른 단어니까 규칙이 적용 안 됨" | 문자보다 정신 |

## Key Patterns

**Tests:**
```
✅ [test 명령 실행] [확인: 34/34 pass] "All tests pass"
❌ "이제 통과할 것" / "맞아 보임"
```

**Regression tests (TDD Red-Green):**
```
✅ 작성 → 실행 (pass) → 수정 되돌리기 → 실행 (MUST FAIL) → 복원 → 실행 (pass)
❌ "회귀 test를 작성했습니다" (red-green verification 없이)
```

**Build:**
```
✅ [build 실행] [확인: exit 0] "Build passes"
❌ "Linter가 통과했음" (linter는 컴파일을 확인하지 않음)
```

**Requirements:**
```
✅ plan 재독 → 체크리스트 작성 → 각 항목 verify → gap 또는 완료 보고
❌ "test 통과, phase 완료"
```

**Agent delegation:**
```
✅ Agent가 success 보고 → VCS diff 확인 → 변경 사항 verify → 실제 상태 보고
❌ agent 보고를 신뢰함
```

## Why This Matters

24개의 실패 메모리로부터:
- your human partner가 "I don't believe you"라고 말함 - 신뢰가 깨짐
- 정의되지 않은 함수가 배포됨 - 크래시 발생
- 누락된 요구사항이 배포됨 - 불완전한 기능
- 잘못된 완료에 시간 낭비 → 방향 수정 → 재작업
- 위반함: "Honesty is a core value. If you lie, you'll be replaced."

## When To Apply

**다음 모든 경우 전에 항상:**
- 성공/완료 주장의 모든 변형
- 모든 만족 표현
- 작업 상태에 대한 모든 긍정적 진술
- Committing, PR 생성, 작업 완료
- 다음 작업으로 이동
- agent에게 위임

**규칙이 적용되는 대상:**
- 정확한 표현
- 패러프레이즈와 동의어
- 성공의 함의
- 완료/정확성을 시사하는 모든 communication

## The Bottom Line

**verification에 지름길은 없습니다.**

명령을 실행하세요. 출력을 읽으세요. 그런 후에 결과를 주장하세요.

이것은 협상 불가입니다.
