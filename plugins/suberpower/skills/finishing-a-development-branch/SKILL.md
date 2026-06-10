---
name: finishing-a-development-branch
description: 구현이 완료되고 모든 테스트가 통과되어 작업을 통합하는 방법을 결정해야 할 때 사용합니다 - merge, PR, 정리에 대한 구조화된 옵션을 제시하여 개발 작업 완료를 안내합니다
---

# Finishing a Development Branch

## 개요

명확한 옵션을 제시하고 선택된 워크플로를 처리하여 개발 작업 완료를 안내합니다.

**핵심 원칙:** 테스트 확인 → 환경 감지 → 옵션 제시 → 선택 실행 → 정리.

**시작 시 안내:** "finishing-a-development-branch skill을 사용하여 이 작업을 완료합니다."

## 진행 절차

### Step 1: 테스트 확인

**옵션을 제시하기 전에 테스트 통과 여부를 확인합니다:**

```bash
# 프로젝트의 테스트 스위트 실행
npm test / cargo test / pytest / go test ./...
```

**테스트가 실패하면:**
```
테스트 실패 (<N>건). 완료 전에 반드시 수정해야 합니다:

[실패 내역 표시]

테스트가 통과될 때까지 merge/PR을 진행할 수 없습니다.
```

중단합니다. Step 2로 진행하지 않습니다.

**테스트가 통과하면:** Step 2로 진행합니다.

### Step 2: 환경 감지

**옵션을 제시하기 전에 workspace 상태를 판단합니다:**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
```

이를 통해 어떤 메뉴를 보여주고 정리를 어떻게 수행할지 결정합니다:

| 상태 | 메뉴 | 정리 |
|-------|------|---------|
| `GIT_DIR == GIT_COMMON` (일반 repo) | 표준 4개 옵션 | 정리할 worktree 없음 |
| `GIT_DIR != GIT_COMMON`, 명명된 branch | 표준 4개 옵션 | 출처 기반 (Step 6 참조) |
| `GIT_DIR != GIT_COMMON`, detached HEAD | 축소된 3개 옵션 (merge 없음) | 정리 없음 (외부 관리) |

### Step 3: 베이스 branch 결정

```bash
# 일반적인 베이스 branch 시도
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

또는 질문합니다: "이 branch는 main에서 분기되었습니다 - 맞나요?"

### Step 4: 옵션 제시

**일반 repo와 명명된 branch worktree — 다음 4개 옵션을 정확히 제시합니다:**

```
구현이 완료되었습니다. 무엇을 하시겠습니까?

1. <base-branch>로 로컬에서 merge
2. Push하고 Pull Request 생성
3. branch를 그대로 유지 (나중에 직접 처리)
4. 이 작업 폐기

어떤 옵션을 선택하시겠습니까?
```

**Detached HEAD — 다음 3개 옵션을 정확히 제시합니다:**

```
구현이 완료되었습니다. detached HEAD 상태입니다 (외부에서 관리되는 workspace).

1. 새 branch로 push하고 Pull Request 생성
2. 그대로 유지 (나중에 직접 처리)
3. 이 작업 폐기

어떤 옵션을 선택하시겠습니까?
```

**설명을 추가하지 마세요** - 옵션을 간결하게 유지합니다.

### Step 5: 선택 실행

#### Option 1: 로컬 Merge

```bash
# CWD 안전을 위해 메인 repo 루트 가져오기
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"

# 먼저 merge — 무엇이든 제거하기 전에 성공 여부 확인
git checkout <base-branch>
git pull
git merge <feature-branch>

# merge된 결과에서 테스트 확인
<test command>

# merge 성공 후에만: worktree 정리 (Step 6), 그 다음 branch 삭제
```

그런 다음: worktree 정리 (Step 6), 그 다음 branch 삭제:

```bash
git branch -d <feature-branch>
```

#### Option 2: Push 및 PR 생성

```bash
# branch push
git push -u origin <feature-branch>

# PR 생성
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<변경 사항 2-3개 bullet>

## Test Plan
- [ ] <검증 단계>
EOF
)"
```

**worktree를 정리하지 마세요** — 사용자가 PR 피드백에 따라 반복 작업을 하기 위해 살아있어야 합니다.

#### Option 3: 그대로 유지

보고: "branch <name>를 유지합니다. Worktree는 <path>에 보존됩니다."

**worktree를 정리하지 마세요.**

#### Option 4: 폐기

**먼저 확인:**
```
다음 항목이 영구적으로 삭제됩니다:
- Branch <name>
- 모든 commit: <commit-list>
- <path>의 worktree

확인하려면 'discard'를 입력하세요.
```

정확한 확인을 기다립니다.

확인되면:
```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
```

그런 다음: worktree 정리 (Step 6), 그 다음 branch 강제 삭제:
```bash
git branch -D <feature-branch>
```

### Step 6: Workspace 정리

**Option 1과 4에만 적용됩니다.** Option 2와 3은 항상 worktree를 보존합니다.

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

**`GIT_DIR == GIT_COMMON`인 경우:** 일반 repo이며 정리할 worktree가 없습니다. 완료.

**worktree 경로가 `.worktrees/`, `worktrees/`, 또는 `~/.claude/suberpowers/worktrees/` 하위에 있는 경우:** Superpowers가 이 worktree를 생성했으므로 — 정리는 우리의 책임입니다.

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
git worktree remove "$WORKTREE_PATH"
git worktree prune  # 자가 치유: 오래된 등록 정보 정리
```

**그 외의 경우:** 호스트 환경(harness)이 이 workspace를 소유합니다. 제거하지 마세요. 플랫폼이 workspace 종료 도구를 제공하면 사용하세요. 그렇지 않으면 workspace를 그대로 둡니다.

## 빠른 참조

| 옵션 | Merge | Push | Worktree 유지 | Branch 정리 |
|--------|-------|------|---------------|----------------|
| 1. 로컬 merge | yes | - | - | yes |
| 2. PR 생성 | - | yes | yes | - |
| 3. 그대로 유지 | - | - | yes | - |
| 4. 폐기 | - | - | - | yes (강제) |

## 자주 발생하는 실수

**테스트 확인 건너뛰기**
- **문제:** 망가진 코드를 merge하거나 실패하는 PR 생성
- **해결:** 옵션을 제공하기 전에 항상 테스트를 확인합니다

**열린 질문**
- **문제:** "다음에 무엇을 할까요?"는 모호함
- **해결:** 정확히 4개의 구조화된 옵션 제시 (detached HEAD는 3개)

**Option 2에 대해 worktree 정리**
- **문제:** PR 반복 작업에 필요한 worktree 제거
- **해결:** Option 1과 4에만 정리 수행

**worktree 제거 전에 branch 삭제**
- **문제:** worktree가 여전히 branch를 참조하고 있어 `git branch -d` 실패
- **해결:** 먼저 merge, worktree 제거, 그 다음 branch 삭제

**worktree 내부에서 git worktree remove 실행**
- **문제:** CWD가 제거되는 worktree 내부에 있을 때 명령이 조용히 실패함
- **해결:** `git worktree remove` 전에 항상 메인 repo 루트로 `cd`

**harness가 소유한 worktree 정리**
- **문제:** harness가 생성한 worktree를 제거하면 phantom 상태 발생
- **해결:** `.worktrees/`, `worktrees/`, 또는 `~/.claude/suberpowers/worktrees/` 하위의 worktree만 정리

**폐기 시 확인 없음**
- **문제:** 실수로 작업 삭제
- **해결:** 입력된 "discard" 확인 요구

## 경고 신호

**절대 금지:**
- 실패하는 테스트로 진행
- 결과에서 테스트 확인 없이 merge
- 확인 없이 작업 삭제
- 명시적 요청 없이 force-push
- merge 성공 확인 전에 worktree 제거
- 만들지 않은 worktree 정리 (출처 확인)
- worktree 내부에서 `git worktree remove` 실행

**항상:**
- 옵션 제공 전에 테스트 확인
- 메뉴 제시 전에 환경 감지
- 정확히 4개 옵션 제시 (detached HEAD는 3개)
- Option 4에 대해 입력된 확인 받기
- Option 1 & 4에만 worktree 정리
- worktree 제거 전에 메인 repo 루트로 `cd`
- 제거 후 `git worktree prune` 실행
