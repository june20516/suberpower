# Codex Tool 매핑

skill은 Claude Code tool 이름을 사용합니다. skill에서 다음을 마주치면, 해당 플랫폼 대응 tool을 사용하세요:

| skill에서의 참조 | Codex 대응 |
|-----------------|------------------|
| `Task` tool (subagent dispatch) | `spawn_agent` ([Subagent dispatch는 multi-agent 지원이 필요합니다](#subagent-dispatch-requires-multi-agent-support) 참조) |
| 여러 개의 `Task` 호출 (병렬) | 여러 개의 `spawn_agent` 호출 |
| Task가 결과를 반환 | `wait_agent` |
| Task가 자동으로 완료 | `close_agent`로 슬롯 해제 |
| `TodoWrite` (작업 추적) | `update_plan` |
| `Skill` tool (skill 호출) | skill은 네이티브로 로드됩니다 — 지시를 따르기만 하면 됩니다 |
| `Read`, `Write`, `Edit` (파일) | 네이티브 파일 tool을 사용하세요 |
| `Bash` (명령 실행) | 네이티브 shell tool을 사용하세요 |

## Subagent dispatch는 multi-agent 지원이 필요합니다

Codex config (`~/.codex/config.toml`)에 추가하세요:

```toml
[features]
multi_agent = true
```

이렇게 하면 `dispatching-parallel-agents` 및 `subagent-driven-development`와 같은 skill에서 `spawn_agent`, `wait_agent`, `close_agent`를 사용할 수 있습니다.

레거시 참고사항: `rust-v0.115.0` 이전의 Codex 빌드는 spawn된 agent를 기다리는 것을 `wait`로 노출했습니다. 현재 Codex는 spawn된 agent에 대해 `wait_agent`를 사용합니다. `wait`라는 이름은 이제 code-mode `exec/wait`에 속하며, 이는 `cell_id`로 yield된 exec cell을 재개합니다; spawn된 agent의 결과 tool이 아닙니다.

## 환경 감지

worktree를 만들거나 branch를 마무리하는 skill은 진행하기 전에 읽기 전용 git 명령으로 환경을 감지해야 합니다:

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

- `GIT_DIR != GIT_COMMON` → 이미 linked worktree에 있음 (생성 건너뛰기)
- `BRANCH`가 비어있음 → detached HEAD (sandbox에서 branch/push/PR 불가)

각 skill이 이 신호를 어떻게 사용하는지는 `using-git-worktrees` Step 0과 `finishing-a-development-branch` Step 1을 참조하세요.

## Codex App 마무리

sandbox가 branch/push 작업을 차단할 때 (외부에서 관리되는 worktree의 detached HEAD), agent는 모든 작업을 commit하고 사용자에게 App의 네이티브 컨트롤을 사용하도록 알립니다:

- **"Create branch"** — branch 이름을 지정한 다음, App UI를 통해 commit/push/PR
- **"Hand off to local"** — 작업을 사용자의 로컬 checkout으로 이전

agent는 여전히 테스트를 실행하고, 파일을 stage하고, 사용자가 복사할 수 있도록 제안된 branch 이름, commit 메시지, PR 설명을 출력할 수 있습니다.
