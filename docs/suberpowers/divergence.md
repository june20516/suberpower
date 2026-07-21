# 이 포크의 의도적 Divergence

**upstream을 반영하기 전에 이 문서를 가장 먼저 읽으세요.**

여기 적힌 항목은 이 포크가 upstream([obra/superpowers](https://github.com/obra/superpowers))과 **의도적으로** 다른 지점입니다. 번역 규칙이 "어떻게 옮길까"라면, 이 문서는 **"이 포크가 왜 포크인가"**입니다. 동기화 과정에서 가장 조용히 파괴되는 것이기도 합니다.

각 항목은 기계적으로 검증 가능합니다:

```bash
./scripts/check-divergence.sh
```

동기화 작업을 마친 뒤 **반드시** 이 스크립트를 실행하세요. 실패하면 upstream 변경이 포크의 정체성을 덮어쓴 것입니다.

---

## 정책 종류

| 정책 | 의미 |
|---|---|
| `NEVER_OVERWRITE` | upstream이 어떻게 바뀌든 이 형태를 유지합니다 |
| `MANUAL_MERGE` | upstream 변경을 자동 적용하지 말고, 사람이 판단해 선별 반영합니다 |
| `TRANSLATE_ON_SYNC` | upstream 변경을 가져오되 이 포크의 규약으로 변환해 적용합니다 |

---

## D-001 · 네임스페이스 치환

**범위:** `plugins/` 전체
**정책:** `NEVER_OVERWRITE`

`superpowers` → `suberpower`(플러그인 이름) / `suberpowers`(경로·디렉터리).

**근거:** 원본 `superpowers`와 동시에 활성화하면 SessionStart 훅이 중복 주입됩니다. 이름이 겹치면 어느 쪽이 로드됐는지 구분할 수 없습니다.

**검증:**
- `plugins/`에 `superpowers:` (skill 호출 네임스페이스) → 0건
- `plugins/`에 `docs/superpowers/`, `.superpowers/`, `~/.config/superpowers/`, `~/.claude/superpowers/` → 0건
- upstream 저장소 URL(`github.com/obra/superpowers`)은 원작자 링크이므로 **검사에서 제외**
- 그 외 `superpowers` 문자열은 아래 3곳만 허용 (브랜드성 표현 + 출처 설명)

| 위치 | 내용 |
|---|---|
| `hooks/session-start:2` | 주석 `SessionStart hook for superpowers plugin (suberpower fork)` |
| `hooks/session-start:35` | 주입 문구 `You have superpowers. (이 포크: suberpowers)` |
| `.claude-plugin/plugin.json` | `superpowers 스킬 라이브러리의 한국어 포크: …` |

> 브랜드성 일반 표현은 원문을 살리되 **이 포크임을 괄호로 부연**합니다. 설계 근거는 [2026-06-10 spec](./specs/2026-06-10-worktree-skill-improvement-design.md)의 4-C 참조.

---

## D-002 · `using-git-worktrees` 전면 재작성

**범위:** `plugins/suberpower/skills/using-git-worktrees/SKILL.md`
**정책:** `MANUAL_MERGE`

upstream의 native 위임 방식을 걷어내고 **git 직접 조작**으로 재작성했습니다. worktree를 프로젝트 밖 전역 경로에 만들고, base 브랜치와 이름을 사용자에게 확인하는 단계를 신설했습니다.

**근거:** 프로젝트 내부에 worktree를 만들면 메인 repo의 `git status`/`diff`가 오염됩니다. 랜덤 브랜치명 생성과 base 브랜치 임의 선택도 개인 워크플로우와 맞지 않았습니다.

**검증:** 아래 마커가 모두 존재해야 합니다.
- `~/.claude/suberpowers/worktrees/` (전역 경로 고정)
- `Step 0: Detect Existing Isolation` (기존 isolation 감지)
- `git worktree add` (git 직접 조작)

**동기화 시:** upstream이 이 파일을 바꿔도 **자동 적용하지 마세요.** 변경 의도를 읽고, 이 포크의 재작성본에 반영할 가치가 있는 것만 손으로 옮깁니다.

---

## D-003 · description 규약

**범위:** 모든 `plugins/suberpower/skills/*/SKILL.md`
**정책:** `TRANSLATE_ON_SYNC`

upstream은 `"Use when..."`으로 **시작**합니다. 이 포크는 **한국어로 트리거 조건을 서술하고 `사용`을 포함**합니다. 트리거 절 뒤에 대시로 부연을 붙이는 형태도 사용합니다.

```yaml
# ✅ 현재 세션에서 독립적인 task로 구성된 implementation plan을 실행할 때 사용합니다
# ✅ 모든 대화를 시작할 때 사용합니다 - skill을 찾고 사용하는 방법을 확립하며, …
# ❌ Use when executing implementation plans with independent tasks
# ❌ plan 실행 시 사용 - task마다 subagent를 dispatch하고 code review 수행   (워크플로우 요약 금지)
```

**근거:** description은 skill 선택에 직접 쓰입니다. 포크 전체가 한국어인데 description만 영어면 트리거 판단이 어긋납니다.

**검증:** 모든 SKILL.md의 `description`이
- 한글을 포함하고
- `사용`을 포함하며
- `Use when`으로 시작하지 않음

---

## D-004 · 플러그인 식별자

**범위:** `plugins/suberpower/.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`
**정책:** `NEVER_OVERWRITE`

플러그인 이름은 `suberpower`, skill 호출 네임스페이스는 `suberpower:<skill-name>`, `using-superpowers` skill은 `using-suberpowers`로 rename되어 있습니다.

**근거:** D-001과 동일 — 원본과의 공존 및 식별.

**검증:**
- `plugin.json`의 `name` == `suberpower`
- `marketplace.json`의 플러그인 `name` == `suberpower`
- `skills/using-suberpowers/` 존재, `skills/using-superpowers/` 부재

---

## D-005 · 한국어 번역 유지

**범위:** 모든 `plugins/suberpower/skills/*/SKILL.md`
**정책:** `TRANSLATE_ON_SYNC`

이 포크의 존재 이유입니다. upstream 파일을 번역 없이 그대로 덮어쓰면 즉시 파손됩니다.

**근거:** 동기화 중 가장 흔한 사고가 "upstream 파일을 그대로 복사"입니다. 이 검사가 그것을 잡습니다.

**검증:** 각 SKILL.md의 한글 문자 수가 **400자 이상** (현재 최솟값 531자, `requesting-code-review`).

번역 규칙 전문은 [translation-glossary.md](./translation-glossary.md)를 참조하세요.

---

## 항목 추가 방법

새 divergence가 생기면:

1. 이 문서에 `D-00N` 항목 추가 — 범위 / 정책 / 근거 / 검증
2. `scripts/check-divergence.sh`에 검사 함수 추가
3. 스크립트를 실행해 통과 확인 후 commit

**근거를 반드시 적으세요.** 근거 없는 divergence는 나중에 "upstream과 다르네" 하며 되돌려집니다.
