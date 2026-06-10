# Worktree 스킬 개선 + superpowers 네임스페이스 치환 설계

- 작성일: 2026-06-10
- 대상: `suberpower` 플러그인 (obra/superpowers 한국어 포크)

## 1. 배경 / 목표

`using-git-worktrees` 스킬은 현재 native worktree 도구(`EnterWorktree`)가 있으면 그쪽에 위임한다. 그 결과 사용자가 경험한 동작은 전부 native 도구의 동작이었다:

- worktree가 `.claude/worktrees/`(프로젝트 내부)에 생성 → gitignore 상황에 따라 메인 repo에 untracked로 노출
- base가 `worktree.baseRef` 설정(fresh=origin 기본브랜치 / head=현재 HEAD)에 고정 → 사실상 main 고정처럼 보임
- worktree 이름 미지정 시 `worktree-xxxx` 랜덤 생성

본 작업은 worktree 생성 메커니즘을 **git 직접 조작**으로 전환하여 위 문제들을 스킬 레벨에서 통제하고, 동시에 포크 전반에 남은 `superpowers` 네임스페이스를 정리한다.

## 2. 요구사항

1. **base를 프로젝트 단위로 최초 1회 질문하여 지정** — main 고정 탈피.
2. **worktree가 프로젝트의 git diff/status에 절대 잡히지 않게** — gitignore를 임의 조작하지 않는다.
3. **포크에 남은 `superpowers` 네임스페이스 치환** — 고유명사(upstream 출처)는 유지, 그 외는 치환.
4. (추가) **worktree/브랜치 이름을 사용자에게 먼저 질문** — 랜덤 이름 생성 방지.

## 3. 확정된 설계 결정

| 항목 | 결정 |
|------|------|
| 생성 메커니즘 | native `EnterWorktree` 위임 제거, **git worktree 직접 조작** |
| worktree 위치 | **프로젝트 밖 전역 경로** `~/.claude/suberpowers/worktrees/<project>/<branch>` |
| diff 차단 방식 | 전역 경로 사용으로 **원천 차단**(프로젝트 디렉터리 미접촉), `.gitignore` 손대지 않음 |
| base 처리 | 프로젝트별 최초 1회 질문, **임의 브랜치 허용** |
| base 저장 위치 | 프로젝트 파일 아님. **메모리에 프로젝트별 기록**(영속), 미지원 시 세션 한정 |
| 브랜치/worktree 이름 | 생성 직전 **사용자에게 질문** |
| 종료 시 정리 | harness confirm은 native 전용이라 **재현 불가**. `finishing-a-development-branch` 스킬의 작업 완료 시점 정리로 대체 |
| 네임스페이스 규칙 | `super`→`suber` 글자만 치환, **복수/단수·경로 구조는 원본 그대로** |

### 종료 정리에 대한 트레이드오프 (기록)

native `EnterWorktree`는 세션 종료 시 keep/remove를 묻는다(harness가 자기 worktree만 추적하기 때문). `git worktree add`로 만든 worktree는 harness가 추적하지 않아 이 confirm을 받을 수 없고, `SessionEnd`/`Stop` hook은 비대화형이라 "물어보기"를 재현할 수 없다. base 자유·diff 원천 차단을 얻는 대가로 이 confirm을 포기한다.

## 4. 변경 상세

### A. `using-git-worktrees/SKILL.md` 재구성

- **Step 1a (Native Worktree Tools 우선) 삭제.** native 도구가 있어도 사용하지 않고 항상 git으로 직접 생성한다. Red Flags / Common Mistakes의 native 관련 항목도 함께 정리.
- **Step 0 (기존 isolation 감지) 유지.** 이미 worktree 안이면 중복 생성하지 않는다.
- **디렉터리 선택 로직 단순화:**
  - 기존의 프로젝트-로컬(`.worktrees/`, `worktrees/`) 옵션 및 Safety Verification(`git check-ignore` 후 `.gitignore` 추가/commit) 단계 **삭제**.
  - 전역 경로 `~/.claude/suberpowers/worktrees/<project>/<branch>` 로 고정.
- **base 질문 단계 신설 (요구 1):**
  - worktree 생성 전, 이 프로젝트의 base 선호를 확인한다.
    - 메모리에 기록돼 있으면 재질문 없이 사용("최초 1회" 충족).
    - 없으면 사용자에게 질문(예: 현재 브랜치 / 기본브랜치 / 임의 입력) 후, **메모리에 프로젝트별로 저장**. 메모리 미지원 환경이면 현재 세션 동안만 유지.
- **이름 질문 단계 신설 (요구 4):**
  - 생성 직전 worktree/브랜치 이름을 사용자에게 질문하고, 그 값을 경로와 `-b`에 사용한다.
- **생성 명령:**
  ```bash
  project=$(basename "$(git rev-parse --show-toplevel)")
  path="$HOME/.claude/suberpowers/worktrees/$project/$BRANCH_NAME"
  git worktree add "$path" -b "$BRANCH_NAME" "$BASE_REF"
  cd "$path"
  ```
- Sandbox fallback(권한 거부 시 현재 위치에서 작업), Step 3(setup 자동 감지), Step 4(baseline 테스트), Quick Reference 표는 새 흐름에 맞게 갱신.

### B. `finishing-a-development-branch/SKILL.md` 정리 경로

- worktree 소유 판별 경로를 새 생성 경로와 일치시킨다: `~/.config/superpowers/worktrees/` → `~/.claude/suberpowers/worktrees/`.
- legacy 인식(`.worktrees/`, `worktrees/`)은 과거 생성분 호환을 위해 유지한다.
- (정합성 핵심) 생성 경로와 정리 인식 경로가 반드시 동일해야 정리가 작동한다.

### C. `superpowers` → `suberpowers` 네임스페이스 치환

**치환 규칙:** `super`→`suber` 글자만 바꾸고 복수/단수 및 경로 구조는 원본 그대로 둔다(`superpowers`→`suberpowers`).

**분류 기준:**
- **유지 (upstream 출처를 가리키는 고유명사):**
  - `obra/superpowers` GitHub 링크 (README, frame-template.html), issue 링크(session-start)
  - "원본 superpowers" 표현 (README)
  - `plugin.json` / `marketplace.json`의 "superpowers 스킬 라이브러리의 한국어 포크" — 원본을 포크했다는 출처 설명
- **유지 + 부연 (브랜드성 일반 표현):** 원문 `Superpowers`/`superpowers`를 **그대로 살리되**, 모델이 원본과 혼동하지 않도록 이 포크(suberpowers) 맥락을 괄호 등으로 덧붙인다. 4-C-2 참조.
- **치환 (경로·식별자 등 기능적 네임스페이스):**

| 분류 | 위치 | 변경 |
|------|------|------|
| 전역 경로 | session-start(legacy_skills_dir, 경고), subagent-driven-development:144 | `~/.config/superpowers/` → `~/.config/suberpowers/` |
| worktree 전역 경로 | using-git-worktrees, finishing-a-development-branch | → `~/.claude/suberpowers/worktrees/` (4-A·B 참조) |
| 프로젝트 산출물 | brainstorming, writing-plans, requesting-code-review, subagent-driven, spec-document-reviewer-prompt | `docs/superpowers/` → `docs/suberpowers/` |
| 프로젝트 산출물 | brainstorming/visual-companion, scripts(start/stop-server) | `.superpowers/` → `.suberpowers/` |
| 스킬명 | `skills/using-superpowers/` 디렉터리 rename + SKILL.md frontmatter `name` + hook 경로 참조 + README:19 + 시스템 주입 식별자 | `using-superpowers` → `using-suberpowers` |
| UI 텍스트 | brainstorming/scripts/frame-template.html:199 제목 | `Superpowers Brainstorming` → `Suberpowers Brainstorming` |

### C-1. 스킬명 변경(`using-superpowers` → `using-suberpowers`) 연쇄 영향

- `plugins/suberpower/skills/using-superpowers/` 디렉터리 → `using-suberpowers/`로 rename (하위 `references/` 포함).
- `SKILL.md` frontmatter `name: using-superpowers` → `name: using-suberpowers`.
- `hooks/session-start`이 읽는 경로 `skills/using-superpowers/SKILL.md` → `skills/using-suberpowers/SKILL.md`, 관련 변수/식별자(`suberpower:using-superpowers`) 갱신.
- `README.md:19` 언급 갱신.
- 시스템이 인식하는 스킬 식별자가 `suberpower:using-suberpowers`로 바뀐다.

### C-2. 브랜드성 일반 표현 처리 (유지 + 부연)

원문을 그대로 살리되 이 포크 맥락을 괄호로 덧붙여 모델 혼동을 막는다. 글자 치환(`super`→`suber`)을 하지 않는다.

| 위치 | 원문 | 처리 예 |
|------|------|---------|
| session-start hook 주석 | `# SessionStart hook for superpowers plugin` | `... for superpowers plugin (suberpower fork)` |
| session-start 주입 텍스트 | `You have superpowers.` | `You have superpowers. (이 포크: suberpowers)` |
| using-superpowers/SKILL.md:20,23 | "Superpowers skill은 …" | "Superpowers skill(이 포크 suberpowers)은 …" |
| executing-plans/SKILL.md:14 | "Superpowers는 subagent에 …" | "Superpowers(suberpowers 포크)는 subagent에 …" |

부연 문구의 정확한 표현은 각 위치의 문맥에 맞춰 자연스럽게 조정한다(괄호가 어색하면 문장으로 풀어도 무방).

## 5. 영향 / 주의

- **플러그인 캐시 동기화:** 실제 활성화된 플러그인은 `~/.claude/plugins/cache/suberpower/...`에서 로드된다. 소스만 수정하면 캐시 재설치/동기화 전까지는 반영되지 않는다. 변경 후 재설치 또는 다음 세션에서 반영 확인이 필요하다.
- **메모리 의존:** base 영속 저장은 Claude 메모리에 의존한다. 메모리를 쓰지 않는 환경에서는 세션마다 base를 다시 질문하게 된다(동작 자체는 정상).

## 6. 검증 방법

- 깨끗한 테스트 repo에서 worktree 스킬 실행 → (1) 이름 질문, (2) base 질문(최초)·재실행 시 무질문, (3) `~/.claude/suberpowers/worktrees/<project>/<branch>` 생성, (4) 메인 repo `git status` 무변화 확인.
- finishing 스킬로 위 worktree 정리 → 전역 경로 인식·제거 확인.
- `grep -rn "superpowers\|Superpowers" plugins README.md`로 유지 대상(upstream 출처)만 남는지 확인.
- 스킬명 변경 후 hook이 `using-suberpowers` 주입에 성공하는지(session-start 로그) 확인.

## 7. 확인 필요 (user review)

- (정합성 판단) worktree 경로를 앞서 단수 `~/.claude/suberpower/`로 지시했으나, 이후 "기존 superpowers와 동일 규칙(복수 보존)" 지시에 따라 **복수** `~/.claude/suberpowers/worktrees/`로 정리했다. 단수를 원하면 알려줄 것.

(브랜드성 일반 표현 처리는 4-C-2로 확정 — 원문 유지 + 괄호 부연.)
