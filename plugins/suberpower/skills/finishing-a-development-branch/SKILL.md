---
name: finishing-a-development-branch
description: 구현이 완료되고 모든 테스트가 통과되어 작업을 통합하는 방법을 결정해야 할 때 사용합니다
---

# Finishing a Development Branch

## 개요

**핵심 원칙:** 테스트 확인 → 환경 감지 → 옵션 제시 → 선택 실행 → 정리.

**시작 시 안내:** "finishing-a-development-branch skill을 사용하여 이 작업을 완료합니다."

## Step 1: 테스트 확인

프로젝트의 전체 테스트 스위트를 실행합니다 (`npm test` / `cargo test` / `pytest` / `go test ./...`).

**테스트가 실패하면**, 실패를 보고하고 중단합니다 — 메뉴는 스위트가 통과한 뒤에 나옵니다:

```
테스트 실패 (<N>건). 완료 전에 반드시 수정해야 합니다:

[실패 내역 표시]
```

**테스트가 통과하면:** Step 2로 진행합니다.

## Step 2: 환경 감지

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
# 아직 workspace 안에 있을 때 지금 기록합니다 — Step 5가 디렉터리를 옮긴 뒤에
# 정리(Step 6)가 이 값을 사용합니다
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

이를 통해 어떤 메뉴를 보여주고 정리를 어떻게 수행할지 결정합니다:

| 상태 | 메뉴 | 정리 |
|-------|------|---------|
| `GIT_DIR == GIT_COMMON` (일반 repo) | 표준 3개 옵션 | 정리할 worktree 없음 |
| `GIT_DIR != GIT_COMMON`, 명명된 branch | 표준 3개 옵션 | 출처 기반 (Step 6 참조) |
| `GIT_DIR != GIT_COMMON`, detached HEAD | 축소된 2개 옵션 (merge 없음) | 외부 관리 — 그대로 둠 |

## Step 3: 베이스 branch 결정

베이스 branch는 이 작업이 분기해 나온 branch입니다 — 보통 plan, 대화, 또는
branch의 upstream에 이름이 나와 있습니다. 아직 알려져 있지 않다면 질문합니다:
"이 branch는 <가장 유력한 추정>에서 분기되었습니다 - 맞나요?"
merge 전에 확인하세요: 잘못된 베이스로 merge하면 되돌리는 비용이 큽니다.

## Step 4: 옵션 제시

**일반 repo와 명명된 branch worktree — 다음 3개 옵션을 정확히 제시합니다:**

```
구현이 완료되었습니다. 무엇을 하시겠습니까?

1. <base-branch>로 로컬에서 merge
2. Push하고 Pull Request 생성
3. branch를 그대로 유지 (나중에 직접 처리)

어떤 옵션을 선택하시겠습니까?
```

**Detached HEAD — 다음 2개 옵션을 정확히 제시합니다:**

```
구현이 완료되었습니다. detached HEAD 상태입니다 (외부에서 관리되는 workspace).

1. 새 branch로 push하고 Pull Request 생성
2. 그대로 유지 (나중에 직접 처리)

어떤 옵션을 선택하시겠습니까?
```

메뉴는 적힌 그대로 제시하세요 — 간결하게, 모든 옵션은 위 목록에서만 가져옵니다.
작업 폐기는 your human partner가 명시적으로 요청했을 때에만 그에 대한 응답으로
이루어집니다 (아래 "your human partner가 작업 폐기를 요청하는 경우" 참조).
답을 기다리세요. 통합 결정은 your human partner의 몫입니다.

## Step 5: 선택 실행

### Option 1: 로컬 Merge

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
```

merge된 결과에서 테스트가 실패하면: 중단하고, worktree와 branch를 그대로 둔 채
조사하세요 — 아무것도 push되지 않았으므로 merge는 로컬에 머물러 있고 복구할 수
있습니다.

merge된 결과가 통과하면: worktree를 정리하고 (Step 6), 그 다음 branch를
삭제합니다:

```bash
git branch -d <feature-branch>
```

### Option 2: Push 및 PR 생성

```bash
git push -u origin <feature-branch>
# detached HEAD에서는 remote에 새 branch 이름을 지정합니다:
# git push origin HEAD:refs/heads/<new-branch>
```

그런 다음 forge의 도구로 <base-branch>를 대상으로 하는 pull/merge request를
생성하세요 — 사용할 수 있으면 forge의 CLI를, 아니면 대부분의 forge가 push 시
출력하는 생성 URL을 사용합니다. repo에 PR 템플릿과 관례가 있으면 따르고, URL을
your human partner에게 보고하세요.

worktree를 유지하세요 — your human partner는 그곳에서 PR 피드백을 반영합니다.

### Option 3: 그대로 유지

보고: "branch <name>를 유지합니다. Worktree는 <path>에 보존됩니다."

### your human partner가 작업 폐기를 요청하는 경우

이 경로는 작업을 버려 달라는 명시적 요청에 대한 응답으로만 존재합니다. 먼저
확인합니다:

```
다음 항목이 영구적으로 삭제됩니다:
- Branch <name>
- 모든 commit: <commit-list>
- <path>의 worktree

확인하려면 'discard'를 입력하세요.
```

정확히 그 확인이 올 때까지 기다립니다. 확인이 오면:

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
```

그런 다음 worktree를 정리하고 (Step 6) branch를 강제 삭제합니다:

```bash
git branch -D <feature-branch>
```

## Step 6: Workspace 정리

**Option 1과 확인된 폐기에서만 실행됩니다.** Option 2와 3은 항상 worktree를
보존합니다. 두 호출 경로 모두 이미 메인 repo 루트로 디렉터리를 옮긴 상태이며
— worktree 제거는 worktree 밖에서 실행해야 합니다 — 그 디렉터리 이동 전에
Step 2에서 기록한 `GIT_DIR`/`GIT_COMMON`/`WORKTREE_PATH` 값을 사용합니다.

**`GIT_DIR == GIT_COMMON`인 경우:** 일반 repo이며 정리할 worktree가 없습니다. 완료.

<!-- DIVERGENCE:D-002 start -->
**`WORKTREE_PATH`가 `~/.claude/suberpowers/worktrees/`(`$HOME/.claude/suberpowers/worktrees/`), `.worktrees/`, 또는 `worktrees/` 하위에 있는 경우:**
Superpowers(suberpowers 포크)가 이 worktree를 생성했으므로 — 정리는 우리의
책임입니다. `suberpower:using-git-worktrees`는 worktree를 항상 전역 경로
`~/.claude/suberpowers/worktrees/<project>/<branch>`에 생성합니다. 이 경로를
놓치면 이 포크가 만든 worktree가 정리되지 않고 남습니다.

```bash
git worktree remove "$WORKTREE_PATH"
git worktree prune  # 자가 치유: 오래된 등록 정보 정리
```
<!-- DIVERGENCE:D-002 end -->

**제거가 거부되면** (`contains modified or untracked files`): 그 worktree에는
다른 어디에도 없는 파일이 있습니다 — commit되지 않은 plan, 메모, 임시 작업물.
스스로 판단해 `--force`를 절대 쓰지 마세요. 무엇이 걸려 있는지
your human partner에게 보여주고 질문하세요:

```bash
git -C "$WORKTREE_PATH" status --porcelain -uall
```

```
worktree 제거가 거부되었습니다 — 다음 파일은 한 번도 commit되지 않았습니다:

<file list>

1. 정리 전에 <branch>에 commit
2. <main repo root>로 이동
3. 삭제 (복구 불가)

어떻게 하시겠습니까?
```

선택을 수행한 뒤 worktree를 제거합니다.

**그 외의 경우:** 호스트 환경이 이 workspace를 소유합니다 — 그대로 두세요.
플랫폼이 workspace 종료 도구를 제공하면 사용하세요.

## 빠른 참조

| 옵션 | Merge | Push | Worktree 유지 | Branch 정리 |
|--------|-------|------|---------------|----------------|
| 1. 로컬 merge | yes | - | - | yes |
| 2. PR 생성 | - | yes | yes | - |
| 3. 그대로 유지 | - | - | yes | - |
| 폐기 (명시적 요청 시에만) | - | - | - | yes (강제) |

## 흔한 합리화

| 핑계 | 현실 |
|--------|---------|
| "이번 세션 초반에 테스트가 통과했다" | 통합하려는 바로 그 트리에서 스위트를 실행하세요. 통과한 실행은 그 실행이 돌았던 트리만 증명합니다. |
| "merge를 원하는 게 뻔하다" | 통합은 your human partner의 결정입니다. 메뉴를 제시하고 기다리세요. |
| "이 기능은 끝난 것 같으니 폐기를 제안하자" | 메뉴는 적힌 그대로가 전부입니다. 폐기는 your human partner가 분명한 말로 요청할 때에만 일어납니다. |
| "'응, 없애 줘'도 확인으로 친다" | 입력된 단어 `discard`만이 삭제를 승인합니다. |
| "PR이 올라갔으니 이제 worktree는 잡동사니다" | PR 피드백은 그 worktree에서 고칩니다. 작업이 반영될 때까지 남겨 둡니다. |
| "이 다른 worktree는 오래된 것 같으니 같이 정리하자" | `~/.claude/suberpowers/worktrees/`, `.worktrees/`, `worktrees/` 하위의 worktree만 정리하세요. 그 외는 모두 호스트의 것입니다. |
| "제거가 거부됐다 — `--force`는 정리를 마무리할 뿐이다" | 거부는 그 worktree에만 있는 파일이 있다는 뜻입니다. `--force`는 그 파일을 영구히 파괴합니다. your human partner에게 보여주고 질문하세요. |
| "merge된 결과의 실패는 아마 flaky일 것이다" | merge된 결과가 실패하면 모든 것이 멈춥니다. 조사하는 동안 branch와 worktree는 그대로 둡니다. |
| "베이스 branch는 당연히 main이다" | 분기 지점을 확인하거나 질문하세요. 잘못된 베이스로 merge하면 되돌리는 비용이 큽니다. |
| "push가 거부됐다 — force-push하면 해결된다" | push 거부는 remote가 바뀌었다는 뜻입니다. 조사하세요. force-push는 your human partner가 명시적으로 요청할 때에만 합니다. |
