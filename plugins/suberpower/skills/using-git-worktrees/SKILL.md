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

1. **이 프로젝트의 base 선호가 이미 알려져 있는지 확인하세요.** 메모리(또는 현재 세션 context)에 이 프로젝트의 worktree base가 기록돼 있으면 그 값을 사용하고 질문을 건너뛰세요.
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
