# Pi Tool 매핑

skill은 행동 단위로 말합니다("subagent를 dispatch하세요", "todo를 만드세요", "파일을 읽으세요"). Pi에서는 이 행동이 아래 tool에 대응합니다.

| skill이 요청하는 행동 | Pi 대응 |
| --- | --- |
| subagent dispatch (`Subagent (general-purpose):` template) | 사용 가능하면 `pi-subagents`의 `subagent`처럼 설치된 subagent tool을 사용하세요 |
| 작업 추적 ("todo 만들기", "완료 표시") | 사용 가능하면 설치된 todo/task tool을 사용하고, 없으면 plan이나 `TODO.md`에서 작업을 추적하세요 |

## Subagent

Pi core는 표준 subagent tool을 제공하지 않습니다. `pi-subagents` 패키지는 권장할 만한 선택적 동반 패키지로, 단일 agent, chain, 병렬, 비동기, fork된 context, 재개/상태 workflow를 갖춘 `subagent` tool을 제공합니다. subagent tool이 없으면 `Task` 호출을 지어내지 마세요. 현재 세션에서 순차적으로 실행하거나, 선택적 subagent 기능이 설치되어 있지 않다고 설명하세요.

## 작업 목록

Pi core는 표준 작업 목록 tool을 제공하지 않습니다. todo/task extension이 설치되어 있으면 그 extension의 문서에 나온 tool을 사용하세요. 없으면 Superpowers(suberpowers 포크) plan 파일, Markdown checklist, 또는 repo 로컬 `TODO.md`로 작업을 추적하세요. 이전 Superpowers 문서는 `TodoWrite`를 언급할 수 있습니다. 그것은 위의 작업 추적 행동으로 취급하세요.
