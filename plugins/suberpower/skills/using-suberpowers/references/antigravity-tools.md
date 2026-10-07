# Antigravity CLI (`agy`) Tool 매핑

skill은 행동 단위로 말합니다("subagent를 dispatch하세요", "todo를 만드세요", "파일을 읽으세요"). Antigravity CLI(`agy`)에서는 이 행동이 아래 tool에 대응합니다.

| skill이 요청하는 행동 | Antigravity CLI 대응 |
|----------------------|----------------------|
| subagent dispatch (`Subagent (general-purpose):` template) | 내장 `TypeName`과 함께 `invoke_subagent` — 전체 기능 작업에는 `self`, 읽기 전용에는 `research` |
| 작업 추적 ("todo 만들기", "완료 표시") | **task artifact** — `IsArtifact: true`와 `ArtifactType: "task"`로 `write_to_file` ([작업 추적](#작업-추적) 참조). background process를 관리하는 `manage_task`는 **아닙니다**. |

## 작업 추적

Antigravity에는 **todo tool이 없습니다**(`manage_task`는 background process를
관리합니다 — `list`/`kill`/`status`/`send_input` — checklist가 *아닙니다*). skill이
todo 목록을 만들거나 작업을 추적하라고 하면 **task artifact**를 유지하세요:
`write_to_file`(`IsArtifact: true`, `ArtifactMetadata.ArtifactType: "task"`)로
저장한 markdown checklist이며, 진행하면서 `replace_file_content` /
`multi_replace_file_content`로 편집합니다.

여러 단계로 된 작업을 시작할 때는 plan의 모든 단계를 나열한 task artifact를
만드세요. 각 단계를 마칠 때마다 artifact를 편집해 완료로 표시하세요(`- [x]`).
plan이 바뀌면 checklist를 갱신하세요. 항상 최신으로 유지하세요 — 무엇이 남았는지에
대한 기준점입니다. 대화가 길어지면 각 단계를 시작하기 전에 다시 읽으세요.
