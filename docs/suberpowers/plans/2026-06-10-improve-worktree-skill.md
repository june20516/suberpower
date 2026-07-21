# Worktree 스킬 개선 + superpowers 네임스페이스 치환 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use suberpower:subagent-driven-development (recommended) or suberpower:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** worktree 스킬을 native 위임에서 git 직접 조작으로 전환(전역 경로·base/이름 질문)하고, 포크 전반의 `superpowers` 네임스페이스를 규칙에 따라 정리한다.

**Architecture:** 스킬 마크다운과 SessionStart 셸 hook을 편집한다. 코드 로직이 아니라 텍스트/구조 변경이므로, 각 task는 정확한 old→new 치환과 grep/문법 검증으로 확인한다. 디렉터리 rename(스킬명 변경)과 그것을 참조하는 hook은 정합성을 위해 한 commit에 묶는다.

**Tech Stack:** Markdown 스킬, bash hook, git worktree, git mv.

**참고 spec:** `docs/suberpowers/specs/2026-06-10-worktree-skill-improvement-design.md`

**치환 규칙 요약:**
- 유지(upstream 출처): `obra/superpowers` 링크, issue 링크, "원본 superpowers" 표현, plugin.json/marketplace.json의 "superpowers 스킬 라이브러리의 한국어 포크".
- 유지+부연(브랜드성 일반 표현): 원문 유지 + `(이 포크: suberpowers)` 류 괄호 부연.
- 치환(기능적 네임스페이스): `super`→`suber`, 복수/단수 유지. worktree 전역 경로는 `~/.claude/suberpowers/worktrees/`.

---

### Task 1: `using-git-worktrees/SKILL.md` 전면 재구성

native 위임 제거 → git 직접 조작, 전역 경로 고정, base/이름 질문 단계 신설.

**Files:**
- Modify(전면 교체): `plugins/suberpower/skills/using-git-worktrees/SKILL.md`

- [ ] **Step 1: 새 SKILL.md 전체 내용으로 교체**

아래 내용으로 파일 전체를 덮어쓴다(Write):

````markdown
---
name: using-git-worktrees
description: 현재 workspace로부터 isolation이 필요한 feature 작업을 시작하거나 implementation plan을 실행하기 전에 사용 - git worktree를 전역 경로에 직접 생성하여 isolated workspace를 보장합니다
---

# Using Git Worktrees

## Overview

작업이 isolated workspace에서 이루어지도록 보장합니다. git worktree를 **프로젝트 밖 전역 경로**(`~/.claude/suberpowers/worktrees/`)에 직접 생성하므로, 프로젝트의 git status/diff를 절대 오염시키지 않습니다.

**핵심 원칙:** 먼저 기존 isolation을 감지합니다. 그다음 base 브랜치와 이름을 사용자에게 확인합니다. 그다음 전역 경로에 git worktree를 생성합니다.

**시작 시 안내:** "isolated workspace를 설정하기 위해 using-git-worktrees skill을 사용합니다."

## Step 0: Detect Existing Isolation

**무엇이든 생성하기 전에, 이미 isolated workspace 안에 있는지 확인하세요.**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

**Submodule 가드:** `GIT_DIR != GIT_COMMON`는 git submodule 안에서도 true입니다. "이미 worktree 안에 있다"고 결론짓기 전에, submodule 안이 아닌지 확인하세요:

```bash
# 경로가 반환되면 worktree가 아니라 submodule 안에 있는 것입니다 — 일반 repo로 취급하세요
git rev-parse --show-superproject-working-tree 2>/dev/null
```

**`GIT_DIR != GIT_COMMON`이고 submodule이 아닌 경우:** 이미 linked worktree 안에 있습니다. Step 4 (Project Setup)로 건너뛰세요. 또 다른 worktree를 생성하지 마세요.

branch 상태와 함께 보고하세요:
- branch 위에 있을 때: "이미 isolated workspace `<path>`에서 branch `<name>` 위에 있습니다."
- Detached HEAD: "이미 isolated workspace `<path>`에 있습니다 (detached HEAD, 외부에서 관리됨). 마무리 시점에 branch 생성이 필요합니다."

**`GIT_DIR == GIT_COMMON`인 경우 (또는 submodule 안인 경우):** 일반 repo checkout 안에 있습니다.

사용자가 instructions에서 worktree 선호를 이미 밝혔는지 확인하세요. 그렇지 않다면 worktree를 생성하기 전에 동의를 구하세요:

> "isolated worktree를 설정해 드릴까요? 현재 branch가 변경되지 않도록 보호해 줍니다."

이미 선언된 선호가 있다면 질문 없이 따르세요. 사용자가 동의하지 않으면 worktree 생성(Step 1~3)을 건너뛰고 현재 위치에서 작업하며 Step 4 (Project Setup)로 이동하세요.

## Step 1: Determine Base Branch (프로젝트별 최초 1회)

worktree는 사용자가 지정한 base 브랜치에서 분기합니다. base는 **프로젝트마다 한 번만** 정하고 이후 재사용합니다.

1. **이 프로젝트의 base 선호가 이미 알려져 있는지 확인하세요.** 메모리(또는 현재 세션 컨텍스트)에 이 프로젝트의 worktree base가 기록돼 있으면 그 값을 사용하고 질문을 건너뛰세요.
2. **알려져 있지 않으면 사용자에게 질문하세요:**
   > "이 프로젝트에서 worktree를 만들 base 브랜치를 지정해 주세요. (예: 현재 브랜치, main, develop)"
3. **답을 메모리에 프로젝트별로 저장하세요** — 다음부터 재질문하지 않도록. 메모리를 쓸 수 없는 환경이면 현재 세션 동안만 유지합니다.

선택된 base 브랜치를 `BASE_REF`로 둡니다.

## Step 2: Determine Worktree Name

worktree(=브랜치) 이름을 **사용자에게 질문**합니다 — 랜덤 이름 생성을 막기 위함입니다.

> "worktree(브랜치) 이름을 지정해 주세요. (예: fix-login, feature-x)"

답을 `BRANCH_NAME`으로 둡니다.

## Step 3: Create Isolated Workspace

worktree를 전역 경로에 직접 생성합니다. 프로젝트 디렉터리에는 아무것도 만들지 않으므로 git status/diff에 절대 잡히지 않습니다 — `.gitignore`를 건드릴 필요가 없습니다.

```bash
project=$(basename "$(git rev-parse --show-toplevel)")
path="$HOME/.claude/suberpowers/worktrees/$project/$BRANCH_NAME"
git worktree add "$path" -b "$BRANCH_NAME" "$BASE_REF"
cd "$path"
```

**Sandbox fallback:** `git worktree add`가 permission error(sandbox 거부)로 실패하면, sandbox가 worktree 생성을 차단했으며 대신 현재 디렉터리에서 작업한다고 사용자에게 알리세요. 그런 다음 현재 위치에서 setup과 baseline 테스트를 실행하세요.

## Step 4: Project Setup

자동으로 감지하고 적절한 setup을 실행하세요:

```bash
# Node.js
if [ -f package.json ]; then npm install; fi

# Rust
if [ -f Cargo.toml ]; then cargo build; fi

# Python
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then poetry install; fi

# Go
if [ -f go.mod ]; then go mod download; fi
```

## Step 5: Verify Clean Baseline

workspace가 깨끗한 상태로 시작하는지 테스트를 실행하세요:

```bash
# 프로젝트에 맞는 명령 사용
npm test / cargo test / pytest / go test ./...
```

**테스트가 실패하면:** 실패를 보고하고, 진행할지 조사할지 물어보세요.

**테스트가 통과하면:** 준비 완료를 보고하세요.

### Report

```
Worktree 준비 완료: <full-path>
Base: <BASE_REF>
테스트 통과 (<N>개 테스트, 실패 0)
<feature-name> 구현 준비 완료
```

## Quick Reference

| 상황 | 조치 |
|-----------|--------|
| 이미 linked worktree 안에 있음 | 생성 건너뛰기 (Step 0) |
| submodule 안에 있음 | 일반 repo로 취급 (Step 0 가드) |
| base 선호가 메모리에 있음 | 재질문 없이 사용 (Step 1) |
| base 선호가 없음 | 사용자에게 질문 후 메모리에 저장 (Step 1) |
| worktree 이름 미정 | 사용자에게 질문 (Step 2) |
| 생성 위치 | 항상 전역 `~/.claude/suberpowers/worktrees/<project>/<branch>` (Step 3) |
| 생성 시 permission error | Sandbox fallback, 현재 위치에서 작업 |
| baseline 중 테스트 실패 | 실패 보고 + 질문 |
| package.json/Cargo.toml 없음 | 의존성 설치 건너뛰기 |

## Common Mistakes

### 감지 건너뛰기

- **문제:** 기존 worktree 안에 중첩된 worktree를 생성
- **해결:** 무엇이든 생성하기 전에 항상 Step 0을 실행

### base를 묻지 않고 가정하기

- **문제:** 항상 main(또는 현재 HEAD)에서 분기하여 사용자 의도와 어긋남
- **해결:** Step 1에서 프로젝트별 base를 확인 (메모리에 없으면 질문)

### 이름을 묻지 않고 랜덤 생성하기

- **문제:** `worktree-xxxx` 같은 의미 없는 브랜치명 양산
- **해결:** Step 2에서 사용자에게 이름을 질문

### 프로젝트 내부에 worktree 생성하기

- **문제:** worktree 내용이 메인 repo의 git status/diff를 오염시킴
- **해결:** 항상 전역 경로(`~/.claude/suberpowers/worktrees/`)에 생성

### 실패하는 테스트와 함께 진행하기

- **문제:** 새로운 버그와 기존 이슈를 구별할 수 없음
- **해결:** 실패를 보고하고, 진행에 대한 명시적 허가를 받으세요

## Red Flags

**절대 하지 마세요:**
- Step 0이 기존 isolation을 감지했을 때 worktree를 생성
- base를 확인하지 않고 worktree를 생성
- 이름을 묻지 않고 랜덤 worktree를 생성
- 프로젝트 내부 경로에 worktree를 생성
- baseline 테스트 검증을 건너뛰기
- 질문 없이 실패하는 테스트와 함께 진행

**항상 하세요:**
- 먼저 Step 0 감지를 실행
- Step 1에서 프로젝트별 base를 확인(메모리 우선, 없으면 질문)
- Step 2에서 worktree 이름을 질문
- 전역 경로 `~/.claude/suberpowers/worktrees/<project>/<branch>`에 생성
- 프로젝트 setup을 자동 감지하여 실행
- 깨끗한 테스트 baseline을 검증
````

- [ ] **Step 2: 검증 — native 위임 잔재가 없고 새 경로가 들어갔는지 확인**

Run:
```bash
grep -nE "EnterWorktree|Native Worktree|1a\.|\.config/superpowers|check-ignore" plugins/suberpower/skills/using-git-worktrees/SKILL.md || echo "OK: 잔재 없음"
grep -n "~/.claude/suberpowers/worktrees/" plugins/suberpower/skills/using-git-worktrees/SKILL.md
```
Expected: 첫 명령은 "OK: 잔재 없음", 둘째 명령은 전역 경로 라인이 출력됨.

- [ ] **Step 3: Commit**

```bash
git add plugins/suberpower/skills/using-git-worktrees/SKILL.md
git commit -m "worktree 스킬: native 위임 제거, 전역경로·base·이름 질문 방식으로 재구성"
```

---

### Task 2: `finishing-a-development-branch/SKILL.md` worktree 정리 경로 갱신

생성 경로(전역)와 정리 인식 경로를 일치시킨다.

**Files:**
- Modify: `plugins/suberpower/skills/finishing-a-development-branch/SKILL.md:183,227`

- [ ] **Step 1: 두 경로 치환**

`~/.config/superpowers/worktrees/` → `~/.claude/suberpowers/worktrees/` (line 183, 227 두 곳). 두 라인 모두 `또는 ~/.config/superpowers/worktrees/ 하위` 형태이므로, `~/.config/superpowers/worktrees/`를 `~/.claude/suberpowers/worktrees/`로 replace_all 한다.

- [ ] **Step 2: 검증**

Run:
```bash
grep -n "config/superpowers" plugins/suberpower/skills/finishing-a-development-branch/SKILL.md || echo "OK: 잔재 없음"
grep -n "claude/suberpowers/worktrees" plugins/suberpower/skills/finishing-a-development-branch/SKILL.md
```
Expected: 첫 명령 "OK: 잔재 없음", 둘째 명령 2개 라인 출력.

- [ ] **Step 3: Commit**

```bash
git add plugins/suberpower/skills/finishing-a-development-branch/SKILL.md
git commit -m "finishing 스킬: worktree 정리 인식 경로를 전역 suberpowers 경로로 갱신"
```

---

### Task 3: 스킬명 `using-superpowers` → `using-suberpowers` + hook 전체 갱신

디렉터리 rename과 그것을 참조하는 hook, README를 한 commit으로 묶어 정합성을 유지한다. hook의 네임스페이스/브랜드 부연도 여기서 함께 처리한다.

**Files:**
- Rename: `plugins/suberpower/skills/using-superpowers/` → `plugins/suberpower/skills/using-suberpowers/`
- Modify: `plugins/suberpower/skills/using-suberpowers/SKILL.md` (frontmatter name + 브랜드 부연 20,23)
- Modify: `plugins/suberpower/hooks/session-start` (2,12,14,17,18,33,35)
- Modify: `README.md:19`

- [ ] **Step 1: 디렉터리 rename (git mv)**

```bash
git mv plugins/suberpower/skills/using-superpowers plugins/suberpower/skills/using-suberpowers
```

- [ ] **Step 2: SKILL.md frontmatter name 변경**

`plugins/suberpower/skills/using-suberpowers/SKILL.md:2`:
- old: `name: using-superpowers`
- new: `name: using-suberpowers`

- [ ] **Step 3: SKILL.md 브랜드 표현 부연 (line 20, 23)**

line 20:
- old: `Superpowers skill은 기본 시스템 prompt 동작을 override하지만, **사용자 지시가 항상 우선합니다**:`
- new: `Superpowers skill(이 포크 suberpowers)은 기본 시스템 prompt 동작을 override하지만, **사용자 지시가 항상 우선합니다**:`

line 23:
- old: `2. **Superpowers skill** — 충돌하는 경우 기본 시스템 동작을 override`
- new: `2. **Superpowers skill(suberpowers)** — 충돌하는 경우 기본 시스템 동작을 override`

- [ ] **Step 4: hook의 스킬 경로/변수/식별자/네임스페이스/브랜드 갱신**

`plugins/suberpower/hooks/session-start`에서 다음을 치환한다:

line 2:
- old: `# SessionStart hook for superpowers plugin`
- new: `# SessionStart hook for superpowers plugin (suberpower fork)`

line 12:
- old: `legacy_skills_dir="${HOME}/.config/superpowers/skills"`
- new: `legacy_skills_dir="${HOME}/.config/suberpowers/skills"`

line 14 (경고 메시지) — `~/.config/superpowers/skills` 2곳을 `~/.config/suberpowers/skills`로:
- old: `Custom skills in ~/.config/superpowers/skills will not be read. Move custom skills to ~/.claude/skills instead. To make this message go away, remove ~/.config/superpowers/skills`
- new: `Custom skills in ~/.config/suberpowers/skills will not be read. Move custom skills to ~/.claude/skills instead. To make this message go away, remove ~/.config/suberpowers/skills`

line 17:
- old: `# Read using-superpowers content`
- new: `# Read using-suberpowers content`

line 18:
- old: `using_superpowers_content=$(cat "${PLUGIN_ROOT}/skills/using-superpowers/SKILL.md" 2>&1 || echo "Error reading using-superpowers skill")`
- new: `using_suberpowers_content=$(cat "${PLUGIN_ROOT}/skills/using-suberpowers/SKILL.md" 2>&1 || echo "Error reading using-suberpowers skill")`

line 33:
- old: `using_superpowers_escaped=$(escape_for_json "$using_superpowers_content")`
- new: `using_suberpowers_escaped=$(escape_for_json "$using_suberpowers_content")`

line 35 (브랜드 부연 + 변수명 `using_superpowers_escaped`→`using_suberpowers_escaped` + 스킬 식별자 `suberpower:using-superpowers`→`suberpower:using-suberpowers`). 여는/닫는 태그는 둘 다 `EXTREMELY_IMPORTANT` 그대로 유지:
- old: `session_context="<EXTREMELY_IMPORTANT>\nYou have superpowers.\n\n**Below is the full content of your 'suberpower:using-superpowers' skill - your introduction to using skills. For all other skills, use the 'Skill' tool:**\n\n${using_superpowers_escaped}\n\n${warning_escaped}\n</EXTREMELY_IMPORTANT>"`
- new: `session_context="<EXTREMELY_IMPORTANT>\nYou have superpowers. (이 포크: suberpowers)\n\n**Below is the full content of your 'suberpower:using-suberpowers' skill - your introduction to using skills. For all other skills, use the 'Skill' tool:**\n\n${using_suberpowers_escaped}\n\n${warning_escaped}\n</EXTREMELY_IMPORTANT>"`

- [ ] **Step 5: README.md:19 스킬명 갱신**

- old: `- \`plugins/suberpower/hooks/\` — SessionStart 훅 (매 세션 시작 시 \`using-superpowers\` 주입)`
- new: `- \`plugins/suberpower/hooks/\` — SessionStart 훅 (매 세션 시작 시 \`using-suberpowers\` 주입)`

- [ ] **Step 6: 검증 — hook 문법 + 잔재 + 디렉터리**

Run:
```bash
bash -n plugins/suberpower/hooks/session-start && echo "OK: bash 문법 정상"
test -f plugins/suberpower/skills/using-suberpowers/SKILL.md && echo "OK: 새 디렉터리 존재"
test ! -d plugins/suberpower/skills/using-superpowers && echo "OK: 옛 디렉터리 없음"
grep -n "using-superpowers\|using_superpowers" plugins/suberpower/hooks/session-start || echo "OK: hook 잔재 없음"
grep -c "EXTREMELY_IMPORTANT" plugins/suberpower/hooks/session-start
```
Expected: bash 문법 정상, 새 디렉터리 존재, 옛 디렉터리 없음, hook 잔재 없음, `EXTREMELY_IMPORTANT` 카운트 2(여는/닫는 태그).

- [ ] **Step 7: Commit**

```bash
git add -A plugins/suberpower/skills/using-suberpowers plugins/suberpower/hooks/session-start README.md
git commit -m "스킬명 using-superpowers→using-suberpowers rename 및 hook 네임스페이스 정리"
```

---

### Task 4: 프로젝트 산출물/전역 경로 네임스페이스 일괄 치환

`docs/superpowers/` → `docs/suberpowers/`, `.superpowers/` → `.suberpowers/`, `~/.config/superpowers/hooks/` → `~/.config/suberpowers/hooks/`.

**Files:**
- Modify: `plugins/suberpower/skills/brainstorming/SKILL.md:29,111`
- Modify: `plugins/suberpower/skills/brainstorming/spec-document-reviewer-prompt.md:7`
- Modify: `plugins/suberpower/skills/writing-plans/SKILL.md:18,138`
- Modify: `plugins/suberpower/skills/requesting-code-review/SKILL.md:60`
- Modify: `plugins/suberpower/skills/subagent-driven-development/SKILL.md:133,144`
- Modify: `plugins/suberpower/skills/brainstorming/visual-companion.md:40,41,46,48,281`
- Modify: `plugins/suberpower/skills/brainstorming/scripts/stop-server.sh:6`
- Modify: `plugins/suberpower/skills/brainstorming/scripts/start-server.sh:9,81`

- [ ] **Step 1: `docs/superpowers/` → `docs/suberpowers/` 일괄 치환**

```bash
grep -rl "docs/superpowers/" plugins/suberpower/skills | xargs sed -i '' 's|docs/superpowers/|docs/suberpowers/|g'
```

- [ ] **Step 2: `.superpowers/` → `.suberpowers/` 일괄 치환**

```bash
grep -rl "\.superpowers/" plugins/suberpower/skills | xargs sed -i '' 's|\.superpowers/|.suberpowers/|g'
```

- [ ] **Step 3: `~/.config/superpowers/hooks/` → `~/.config/suberpowers/hooks/` 치환**

`plugins/suberpower/skills/subagent-driven-development/SKILL.md:144`:
- old: `You: "User level (~/.config/superpowers/hooks/)"`
- new: `You: "User level (~/.config/suberpowers/hooks/)"`

- [ ] **Step 4: 검증**

Run:
```bash
grep -rn "docs/superpowers/\|\.superpowers/\|config/superpowers" plugins/suberpower/skills || echo "OK: 잔재 없음"
```
Expected: "OK: 잔재 없음" (이 디렉터리 트리에 더 이상 해당 경로 없음).

- [ ] **Step 5: Commit**

```bash
git add -A plugins/suberpower/skills
git commit -m "프로젝트 산출물/전역 경로 네임스페이스 suberpowers로 치환"
```

---

### Task 5: UI 텍스트 + 잔여 브랜드 표현 부연

frame-template.html 제목과 executing-plans 브랜드 표현.

**Files:**
- Modify: `plugins/suberpower/skills/brainstorming/scripts/frame-template.html:5,199`
- Modify: `plugins/suberpower/skills/executing-plans/SKILL.md:14`

- [ ] **Step 1: frame-template.html title (line 5)**

- old: `  <title>Superpowers Brainstorming</title>`
- new: `  <title>Suberpowers Brainstorming</title>`

- [ ] **Step 2: frame-template.html h1 (line 199) — 링크 텍스트만 변경, obra 링크 URL은 유지**

- old: `    <h1><a href="https://github.com/obra/superpowers" style="color: inherit; text-decoration: none;">Superpowers Brainstorming</a></h1>`
- new: `    <h1><a href="https://github.com/obra/superpowers" style="color: inherit; text-decoration: none;">Suberpowers Brainstorming</a></h1>`

- [ ] **Step 3: executing-plans 브랜드 표현 부연 (line 14)**

- old: `**참고:** Superpowers는 subagent에 access할 수 있을 때 훨씬 잘 동작한다고 human partner에게 알려주세요.`
- new: `**참고:** Superpowers(suberpowers 포크)는 subagent에 access할 수 있을 때 훨씬 잘 동작한다고 human partner에게 알려주세요.`

- [ ] **Step 4: 검증**

Run:
```bash
grep -n "Suberpowers Brainstorming" plugins/suberpower/skills/brainstorming/scripts/frame-template.html
grep -n "Superpowers(suberpowers 포크)" plugins/suberpower/skills/executing-plans/SKILL.md
grep -c "obra/superpowers" plugins/suberpower/skills/brainstorming/scripts/frame-template.html
```
Expected: title·h1 2개 라인, executing-plans 1개 라인, obra 링크 유지(카운트 1).

- [ ] **Step 5: Commit**

```bash
git add plugins/suberpower/skills/brainstorming/scripts/frame-template.html plugins/suberpower/skills/executing-plans/SKILL.md
git commit -m "UI 제목 Suberpowers로 변경 및 잔여 브랜드 표현 부연 추가"
```

---

### Task 6: 최종 전수 검증

유지 대상(upstream 출처)만 남았는지 확인하고, 치환되면 안 되는 것이 바뀌지 않았는지 확인한다.

- [ ] **Step 1: 전체 superpowers 출현 재집계**

Run:
```bash
grep -rn "superpowers\|Superpowers" --include="*.md" --include="*.sh" --include="*.html" --include="*.json" plugins README.md
```
Expected — 다음 "유지 대상"만 남아야 한다(그 외 출현이 있으면 누락):
- `obra/superpowers` 링크들 (README:3,23, frame-template.html:199의 href)
- README:14 "원본 \`superpowers\`"
- session-start hook의 issue 링크 `obra/superpowers/issues/571`, line 2 주석의 "superpowers plugin (suberpower fork)", line 35 "You have superpowers. (이 포크: suberpowers)"
- plugin.json:3 / marketplace.json의 "superpowers 스킬 라이브러리의 한국어 포크"
- using-suberpowers/SKILL.md:20,23 "Superpowers skill(... suberpowers)"
- executing-plans:14 "Superpowers(suberpowers 포크)"
- frame-template.html:5,199 "Suberpowers Brainstorming"(이미 suber)

- [ ] **Step 2: 기능 경로 잔재 0 확인**

Run:
```bash
grep -rn "config/superpowers\|docs/superpowers\|\.superpowers/\|using-superpowers\|claude/worktrees" plugins README.md || echo "OK: 기능 경로 잔재 없음"
```
Expected: "OK: 기능 경로 잔재 없음".

- [ ] **Step 3: hook 최종 문법 검증**

Run:
```bash
bash -n plugins/suberpower/hooks/session-start && echo "OK"
```
Expected: OK.

- [ ] **Step 4: 전체 변경 요약 확인 후 마무리**

Run:
```bash
git log --oneline -7
git status
```
작업 완료. finishing-a-development-branch 스킬로 통합 방식(merge/PR/유지)을 결정한다.
