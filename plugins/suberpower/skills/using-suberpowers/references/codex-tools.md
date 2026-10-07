## Subagent dispatch는 multi-agent 지원이 필요합니다

Codex config (`~/.codex/config.toml`)에 추가하세요:

```toml
[features]
multi_agent = true
```

이렇게 하면 `dispatching-parallel-agents`, `subagent-driven-development` 같은
skill이 쓰는 multi-agent tool이 활성화됩니다. 어떤 tool을 쓸 수 있는지는 model
preset이 선택하는 multi-agent 버전에 따라 다릅니다(현재 preset은 V2, 이전
preset은 V1로 동작합니다). 어떤 표든 — 이 문서를 포함해 — 실제 tool 목록과
다르면 실제 tool 목록을 믿으세요.

- **Spawn:** 하위 agent에게 깨끗한 context를 주려면
  `spawn_agent {fork_turns: "none"}`을 쓰세요. 기본값 `"all"`은 당신의
  transcript 전체를 하위 agent에 복사합니다. Codex 0.145+에서는
  `~/.codex/agents/` 아래의 role 파일이 `agent_type`으로 격리된 fork에 붙습니다.
  전체 히스토리 fork도 `model`과 `reasoning_effort` override를 받습니다(거기서
  거부되는 것은 `agent_type`뿐입니다) — 격리된 fork가 SDD 기본값인 것은 context
  위생 때문이지, override에 격리된 fork가 필요해서가 아닙니다.
- **수정 라운드:** `followup_task`로 implementer를 재개하세요 — 메시지를
  전달하고, turn을 일으키며, harness가 evict한 하위 agent를 투명하게 다시
  로드합니다. spawn된 agent에는 다시 메시지를 보낼 수 없다는 가정으로 새
  implementer를 절대 dispatch하지 마세요. V2에서는 언제나 보낼 수 있습니다.
- **수명 주기:** V2에는 `close_agent`가 없습니다. 끝난 하위 agent는 슬롯이
  필요할 때 자동으로 evict되므로, 닫지 않고 두어도 비용이 들지 않습니다.
  `close_agent`는 V1 session에만 있습니다 — 그곳에서는 reviewer는 review가
  돌아오면 닫고, 각 implementer는 해당 task의 review가 통과한 뒤 닫으세요.
- **모델 이름:** skill, 표, 이전 session에서 본 모델 이름을 현재 spawn
  allowlist와 대조하지 않고 `spawn_agent`에 절대 그대로 옮기지 마세요 — V2는
  V2를 지원하는 preset만 받고, 나머지에는 hard error를 냅니다.

## 하위 agent 기다리기

`wait_agent`는 polling이 아니라 이벤트 구독입니다: 긴 대기도 하위 agent에서
mailbox 활동이 생기는 즉시 깨어나며, 지연은 짧은 대기와 같습니다. 짧은
timeout으로 polling해도 얻는 것은 없고, poll마다 tool 호출 한 번 — 그리고
context 재과금 — 의 비용이 듭니다. 측정한 session에서는 전체 wait 호출의 약
3분의 2가 timeout으로 끝난 짧은 poll이었습니다.

- 아직 로컬 작업이 남아 있으면 아예 기다리지 마세요. 완료된 하위 agent의 최종
  답변은 mailbox로 push되어 다음 turn에 함께 도착합니다.
- 하위 agent가 남아 있는데 정말로 할 일이 없을 때는, 제한된 구간 단위로
  기다리세요: `wait_agent`에 `timeout_ms` 300000-600000(5-10분). 각 구간이
  끝나면 — 깨어났든 timeout이든 — 상태 줄을 하나 남기고, `list_agents`를
  실행하고, 보고 없이 끝난 하위 agent를 찾아 확인하세요. 5분보다 짧은 poll을
  절대 연달아 걸지 마세요. 이벤트 구독은 제한된 구간도 짧은 대기만큼 빠르게
  깨웁니다.
- 완료 메일은 idle 상태의 controller를 깨우지 못합니다(turn을 일으키지 않고
  전달됩니다). 그 idle 구간을 메우는 것이 `wait_agent`의 유일한 역할입니다.
  아무 활동 없이 timeout된 구간은 상태를 맞춰 보라는 신호이지, 다음 구간을
  줄이라는 신호가 아닙니다.

## spawn 시 모델 라우팅

당신이 내리는 모든 `spawn_agent`는 — 당신 자신이 fan-out을 실행하는 spawn된
하위 agent일 때도 — 실행 중인 skill의 '모델 선택' 규칙에 따라 `model`과
`reasoning_effort`를 **둘 다** 명시해야 합니다. `model`만 설정하는 것은
함정입니다: 하위 agent의 effort가 당신의 것이 아니라 그 모델의 기본값으로
조용히 초기화됩니다.

your human partner에게 `~/.codex/config.toml`에 머신 수준의 안전장치를 추가해
달라고 요청하세요. 그러면 놓친 spawn도 session의 가장 비싼 모델을 조용히
상속하는 대신 의도한 등급으로 라우팅됩니다:

```toml
[agents]
default_subagent_model = "<a mid-tier model from your spawn allowlist>"
default_subagent_reasoning_effort = "medium"
```

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
