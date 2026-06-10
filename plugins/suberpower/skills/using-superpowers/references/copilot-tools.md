# Copilot CLI Tool 매핑

skill은 Claude Code tool 이름을 사용합니다. skill에서 다음을 마주치면, 해당 플랫폼 대응 tool을 사용하세요:

| skill에서의 참조 | Copilot CLI 대응 |
|-----------------|----------------------|
| `Read` (파일 읽기) | `view` |
| `Write` (파일 생성) | `create` |
| `Edit` (파일 편집) | `edit` |
| `Bash` (명령 실행) | `bash` |
| `Grep` (파일 내용 검색) | `grep` |
| `Glob` (이름으로 파일 검색) | `glob` |
| `Skill` tool (skill 호출) | `skill` |
| `WebFetch` | `web_fetch` |
| `Task` tool (subagent dispatch) | `agent_type: "general-purpose"` 또는 `"explore"`와 함께 `task` |
| 여러 개의 `Task` 호출 (병렬) | 여러 개의 `task` 호출 |
| Task 상태/출력 | `read_agent`, `list_agents` |
| `TodoWrite` (작업 추적) | 내장 `todos` 테이블과 함께 `sql` |
| `WebSearch` | 대응 없음 — 검색 엔진 URL과 함께 `web_fetch` 사용 |
| `EnterPlanMode` / `ExitPlanMode` | 대응 없음 — main session에 머무르세요 |

## 비동기 shell session

Copilot CLI는 영속적인 비동기 shell session을 지원하며, 이는 Claude Code에 직접 대응되는 것이 없습니다:

| Tool | 용도 |
|------|---------|
| `async: true`와 함께 `bash` | 백그라운드에서 장기 실행 명령 시작 |
| `write_bash` | 실행 중인 비동기 session에 입력 전송 |
| `read_bash` | 비동기 session에서 출력 읽기 |
| `stop_bash` | 비동기 session 종료 |
| `list_bash` | 모든 활성 shell session 목록 표시 |

## 추가 Copilot CLI tool

| Tool | 용도 |
|------|---------|
| `store_memory` | 향후 session을 위해 codebase에 대한 사실 영속화 |
| `report_intent` | 현재 의도로 UI 상태 줄 업데이트 |
| `sql` | session의 SQLite 데이터베이스 쿼리 (todos, 메타데이터) |
| `fetch_copilot_cli_documentation` | Copilot CLI 문서 조회 |
| GitHub MCP tool (`github-mcp-server-*`) | 네이티브 GitHub API 액세스 (issues, PR, 코드 검색) |
