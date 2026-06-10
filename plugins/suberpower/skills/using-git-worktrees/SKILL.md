---
name: using-git-worktrees
description: 현재 workspace로부터 isolation이 필요한 feature 작업을 시작하거나 implementation plan을 실행하기 전에 사용 - native 도구 또는 git worktree fallback을 통해 isolated workspace가 존재하도록 보장합니다
---

# Using Git Worktrees

## Overview

작업이 isolated workspace에서 이루어지도록 보장합니다. 플랫폼의 native worktree 도구를 우선적으로 사용하세요. native 도구가 없을 때만 수동 git worktree로 fallback 합니다.

**핵심 원칙:** 먼저 기존 isolation을 감지합니다. 그다음 native 도구를 사용합니다. 그다음 git으로 fallback 합니다. 절대 harness와 싸우지 마세요.

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

**`GIT_DIR != GIT_COMMON`이고 submodule이 아닌 경우:** 이미 linked worktree 안에 있습니다. Step 3 (Project Setup)으로 건너뛰세요. 또 다른 worktree를 생성하지 마세요.

branch 상태와 함께 보고하세요:
- branch 위에 있을 때: "이미 isolated workspace `<path>`에서 branch `<name>` 위에 있습니다."
- Detached HEAD: "이미 isolated workspace `<path>`에 있습니다 (detached HEAD, 외부에서 관리됨). 마무리 시점에 branch 생성이 필요합니다."

**`GIT_DIR == GIT_COMMON`인 경우 (또는 submodule 안인 경우):** 일반 repo checkout 안에 있습니다.

사용자가 instructions에서 worktree 선호를 이미 밝혔는지 확인하세요. 그렇지 않다면 worktree를 생성하기 전에 동의를 구하세요:

> "isolated worktree를 설정해 드릴까요? 현재 branch가 변경되지 않도록 보호해 줍니다."

이미 선언된 선호가 있다면 질문 없이 따르세요. 사용자가 동의하지 않으면 현재 위치에서 작업하고 Step 3으로 건너뛰세요.

## Step 1: Create Isolated Workspace

**두 가지 메커니즘이 있습니다. 다음 순서로 시도하세요.**

### 1a. Native Worktree Tools (preferred)

사용자가 isolated workspace를 요청했습니다 (Step 0 동의). worktree를 생성할 방법이 이미 있나요? `EnterWorktree`, `WorktreeCreate` 같은 이름의 tool, `/worktree` 명령, 또는 `--worktree` flag일 수 있습니다. 있다면 그것을 사용하고 Step 3으로 건너뛰세요.

Native 도구는 디렉터리 배치, branch 생성, cleanup을 자동으로 처리합니다. native 도구가 있는데 `git worktree add`를 사용하면 harness가 보지도 관리하지도 못하는 phantom state가 생깁니다.

native worktree 도구가 없을 때만 Step 1b로 진행하세요.

### 1b. Git Worktree Fallback

**Step 1a가 적용되지 않을 때만 사용하세요** — 즉, native worktree 도구가 없을 때만. git을 사용하여 수동으로 worktree를 생성합니다.

#### Directory Selection

다음 우선순위를 따르세요. 명시적인 사용자 선호가 관찰된 파일시스템 상태보다 항상 우선합니다.

1. **instructions에서 선언된 worktree 디렉터리 선호를 확인하세요.** 사용자가 이미 지정했다면 질문 없이 사용하세요.

2. **기존 project-local worktree 디렉터리를 확인하세요:**
   ```bash
   ls -d .worktrees 2>/dev/null     # 우선 (숨김)
   ls -d worktrees 2>/dev/null      # 대안
   ```
   찾으면 사용하세요. 둘 다 있으면 `.worktrees`가 우선입니다.

3. **기존 전역 디렉터리를 확인하세요:**
   ```bash
   project=$(basename "$(git rev-parse --show-toplevel)")
   ls -d ~/.config/superpowers/worktrees/$project 2>/dev/null
   ```
   찾으면 사용하세요 (legacy 전역 경로와의 backward compatibility).

4. **다른 지침이 없다면**, 프로젝트 루트의 `.worktrees/`를 기본값으로 사용하세요.

#### Safety Verification (project-local 디렉터리에만 해당)

**worktree를 생성하기 전에 디렉터리가 ignored 상태인지 반드시 확인해야 합니다:**

```bash
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

**ignored 상태가 아닌 경우:** .gitignore에 추가하고, 변경 사항을 commit한 다음 진행하세요.

**중요한 이유:** worktree 내용이 실수로 repository에 commit되는 것을 방지합니다.

전역 디렉터리(`~/.config/superpowers/worktrees/`)는 확인이 필요 없습니다.

#### Create the Worktree

```bash
project=$(basename "$(git rev-parse --show-toplevel)")

# 선택된 위치에 따라 경로 결정
# project-local의 경우: path="$LOCATION/$BRANCH_NAME"
# 전역의 경우: path="~/.config/superpowers/worktrees/$project/$BRANCH_NAME"

git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

**Sandbox fallback:** `git worktree add`가 permission error(sandbox 거부)로 실패하면, sandbox가 worktree 생성을 차단했으며 대신 현재 디렉터리에서 작업한다고 사용자에게 알리세요. 그런 다음 현재 위치에서 setup과 baseline 테스트를 실행하세요.

## Step 3: Project Setup

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

## Step 4: Verify Clean Baseline

workspace가 깨끗한 상태로 시작하는지 테스트를 실행하세요:

```bash
# 프로젝트에 맞는 명령 사용
npm test / cargo test / pytest / go test ./...
```

**테스트가 실패하면:** 실패를 보고하고, 진행할지 조사할지 물어보세요.

**테스트가 통과하면:** 준비 완료를 보고하세요.

### Report

```
Worktree ready at <full-path>
Tests passing (<N> tests, 0 failures)
Ready to implement <feature-name>
```

## Quick Reference

| 상황 | 조치 |
|-----------|--------|
| 이미 linked worktree 안에 있음 | 생성 건너뛰기 (Step 0) |
| submodule 안에 있음 | 일반 repo로 취급 (Step 0 가드) |
| Native worktree 도구 사용 가능 | 그것을 사용 (Step 1a) |
| native 도구 없음 | Git worktree fallback (Step 1b) |
| `.worktrees/` 존재 | 사용 (ignored 확인) |
| `worktrees/` 존재 | 사용 (ignored 확인) |
| 둘 다 존재 | `.worktrees/` 사용 |
| 둘 다 없음 | instruction 파일 확인 후, 기본값 `.worktrees/` |
| 전역 경로 존재 | 사용 (backward compat) |
| 디렉터리가 ignored 아님 | .gitignore에 추가 + commit |
| 생성 시 permission error | Sandbox fallback, 현재 위치에서 작업 |
| baseline 중 테스트 실패 | 실패 보고 + 질문 |
| package.json/Cargo.toml 없음 | 의존성 설치 건너뛰기 |

## Common Mistakes

### Harness와 싸우기

- **문제:** 플랫폼이 이미 isolation을 제공하는데 `git worktree add`를 사용
- **해결:** Step 0이 기존 isolation을 감지합니다. Step 1a가 native 도구에 위임합니다.

### 감지 건너뛰기

- **문제:** 기존 worktree 안에 중첩된 worktree를 생성
- **해결:** 무엇이든 생성하기 전에 항상 Step 0을 실행

### Ignore 확인 건너뛰기

- **문제:** worktree 내용이 추적되어 git status를 오염시킴
- **해결:** project-local worktree를 생성하기 전에 항상 `git check-ignore` 사용

### 디렉터리 위치 가정하기

- **문제:** 비일관성을 만들고, 프로젝트 관례를 위반
- **해결:** 우선순위를 따르세요: 기존 > 전역 legacy > instruction 파일 > 기본값

### 실패하는 테스트와 함께 진행하기

- **문제:** 새로운 버그와 기존 이슈를 구별할 수 없음
- **해결:** 실패를 보고하고, 진행에 대한 명시적 허가를 받으세요

## Red Flags

**절대 하지 마세요:**
- Step 0이 기존 isolation을 감지했을 때 worktree를 생성
- native worktree 도구(예: `EnterWorktree`)가 있을 때 `git worktree add`를 사용. 이것이 가장 흔한 실수입니다 — 있다면 사용하세요.
- Step 1a를 건너뛰고 Step 1b의 git 명령으로 바로 뛰어들기
- 프로젝트 로컬에서 ignored 인지 확인하지 않고 worktree를 생성
- baseline 테스트 검증을 건너뛰기
- 질문 없이 실패하는 테스트와 함께 진행

**항상 하세요:**
- 먼저 Step 0 감지를 실행
- git fallback보다 native 도구를 우선
- 디렉터리 우선순위를 따르세요: 기존 > 전역 legacy > instruction 파일 > 기본값
- project-local의 경우 디렉터리가 ignored 인지 확인
- 프로젝트 setup을 자동 감지하여 실행
- 깨끗한 테스트 baseline을 검증
