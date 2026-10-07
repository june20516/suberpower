# Gemini CLI Tool 매핑

skill은 행동 단위로 말합니다("subagent를 dispatch하세요", "todo를 만드세요", "파일을 읽으세요"). Gemini CLI에서는 이 행동이 아래 tool에 대응합니다.

| skill이 요청하는 행동 | Gemini CLI 대응 |
|----------------------|----------------------|
| 파일 읽기 | `read_file` |
| 여러 파일 한 번에 읽기 | `read_many_files` |
| 새 파일 생성 | `write_file` |
| 파일 편집 | `replace` |
| shell 명령 실행 | `run_shell_command` |
| 파일 내용 검색 | `grep_search` |
| 이름으로 파일 찾기 | `glob` |
| 파일과 하위 디렉터리 목록 표시 | `list_directory` |
| URL 가져오기 | `web_fetch` |
| 웹 검색 | `google_web_search` |
| skill 호출 | `activate_skill` |
| subagent dispatch (`Subagent (general-purpose):` template) | `agent_name: "generalist"`로 `invoke_agent` (`@generalist` 채팅 구문으로도 호출 가능 — [Subagent 지원](#subagent-지원) 참조) |
| 여러 병렬 dispatch | 같은 응답에서 여러 `invoke_agent` 호출 |
| 작업 추적 ("todo 만들기", "완료 표시") | `write_todos` (상태: pending, in_progress, completed, cancelled, blocked) |

## instruction 파일

skill이 "instruction 파일"을 언급하면, Gemini CLI에서는 **`GEMINI.md`**입니다. Gemini CLI는 `GEMINI.md`를 계층적으로 로드합니다: 전역 파일은 `~/.gemini/GEMINI.md`, 프로젝트 수준 파일은 workspace 디렉터리와 그 상위 디렉터리에 있는 것을 로드하고, 하위 디렉터리의 `GEMINI.md`는 tool이 그 디렉터리의 파일에 접근할 때 로드합니다.

## 개인 skill 디렉터리

사용자 수준 skill은 **`~/.gemini/skills/`**에 있으며, **`~/.agents/skills/`**가 runtime 간 공용 alias입니다(Codex, Copilot CLI와 공유). 같은 범위에 두 디렉터리가 모두 있으면 `.agents/skills/`가 우선합니다. 각 skill은 `SKILL.md`(`name`과 `description` frontmatter 포함)가 든 하위 디렉터리입니다.

## Subagent 지원

Gemini CLI는 `agent_name`과 `prompt` 파라미터를 받는 `invoke_agent` tool로 subagent를 dispatch합니다. 같은 dispatch가 채팅 구문 단축키로도 제공됩니다: `@generalist <prompt>`를 입력하는 것은 `agent_name: "generalist"`로 `invoke_agent`를 호출하는 것과 같습니다. 내장 agent 이름에는 `generalist`, `cli_help`, `codebase_investigator`, 그리고 (browser tool이 활성화된 경우) `browser_agent`가 있습니다.

skill은 `Subagent (general-purpose):`로 dispatch하며, prompt template 파일(예: `suberpower:subagent-driven-development`의 `./implementer-prompt.md`)을 참조하거나 inline prompt를 제공합니다. Gemini CLI에서는:

| skill의 dispatch 형태 | Gemini CLI 대응 |
|---------------------|----------------------|
| `*-prompt.md` template 참조 (implementer, task-reviewer, code-reviewer 등) | template을 채운 뒤, `agent_name: "generalist"`와 채운 prompt로 `invoke_agent` |
| `suberpower:requesting-code-review`의 `./code-reviewer.md` 참조 | `agent_name: "generalist"`와 채운 review template으로 `invoke_agent` |
| inline prompt (참조하는 template 없음) | `agent_name: "generalist"`와 inline prompt로 `invoke_agent` |

### Prompt 채우기

skill은 `{WHAT_WAS_IMPLEMENTED}` 또는 `[FULL TEXT of task]`와 같은 placeholder가 있는 prompt template을 제공합니다. 완전한 prompt를 `invoke_agent`에 전달하기 전에 모든 placeholder를 채우세요. prompt template 자체에는 agent의 역할, review 기준, 예상 출력 형식이 포함되어 있습니다 — subagent가 이를 따를 것입니다.

### 병렬 dispatch

Gemini CLI는 병렬 subagent dispatch를 지원합니다. 독립적인 subagent 작업을 병렬로 실행하려면 같은 응답에서 여러 `invoke_agent` 호출을 내리세요(또는 한 prompt에서 여러 `@generalist` 호출). 종속적인 작업은 순차적으로 유지하되, 히스토리를 단순하게 유지하려는 이유만으로 독립적인 subagent 작업을 직렬화하지 마세요.

## 추가 Gemini CLI tool

이 tool들은 Gemini CLI에만 있습니다:

| Tool | 용도 |
|------|---------|
| `save_memory` (legacy) | `experimental.memoryV2 = false`일 때 세션 간에 사실을 영속화 |
| `get_internal_docs` | Gemini CLI 번들 문서 조회 |
| `ask_user` | 사용자에게 구조화된 질문 제시 (텍스트 / 단일 선택 / 다중 선택) |
| `enter_plan_mode` / `exit_plan_mode` | 읽기 전용 plan mode로 들어가고 나오기 |
| `update_topic` | 현재 대화의 주제 / 전략적 의도 메타데이터 업데이트 |
| `complete_task` | Gemini subagent가 완료되었음을 알리고 그 결과를 상위 agent에 반환 |
| `tracker_create_task`, `tracker_update_task`, `tracker_get_task`, `tracker_list_tasks`, `tracker_add_dependency`, `tracker_visualize` | 의존성과 시각화를 지원하는 풍부한 작업 tracker |
| `read_mcp_resource`, `list_mcp_resources` | MCP resource 접근 |
