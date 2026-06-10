# Gemini CLI Tool 매핑

skill은 Claude Code tool 이름을 사용합니다. skill에서 다음을 마주치면, 해당 플랫폼 대응 tool을 사용하세요:

| skill에서의 참조 | Gemini CLI 대응 |
|-----------------|----------------------|
| `Read` (파일 읽기) | `read_file` |
| `Write` (파일 생성) | `write_file` |
| `Edit` (파일 편집) | `replace` |
| `Bash` (명령 실행) | `run_shell_command` |
| `Grep` (파일 내용 검색) | `grep_search` |
| `Glob` (이름으로 파일 검색) | `glob` |
| `TodoWrite` (작업 추적) | `write_todos` |
| `Skill` tool (skill 호출) | `activate_skill` |
| `WebSearch` | `google_web_search` |
| `WebFetch` | `web_fetch` |
| `Task` tool (subagent dispatch) | `@agent-name` ([Subagent 지원](#subagent-support) 참조) |

## Subagent 지원

Gemini CLI는 `@` 구문을 통해 subagent를 네이티브로 지원합니다. 내장된 `@generalist` agent를 사용하여 모든 작업을 dispatch하세요 — 모든 tool에 액세스할 수 있고 제공한 prompt를 따릅니다.

skill이 명명된 agent 유형을 dispatch하라고 할 때, skill의 prompt template에서 가져온 전체 prompt와 함께 `@generalist`를 사용하세요:

| skill 지시 | Gemini CLI 대응 |
|-------------------|----------------------|
| `Task tool (suberpower:implementer)` | 채워진 `implementer-prompt.md` template과 함께 `@generalist` |
| `Task tool (suberpower:spec-reviewer)` | 채워진 `spec-reviewer-prompt.md` template과 함께 `@generalist` |
| `Task tool (suberpower:code-reviewer)` | `@code-reviewer` (번들된 agent) 또는 채워진 리뷰 prompt와 함께 `@generalist` |
| `Task tool (suberpower:code-quality-reviewer)` | 채워진 `code-quality-reviewer-prompt.md` template과 함께 `@generalist` |
| 인라인 prompt와 함께 `Task tool (general-purpose)` | 인라인 prompt와 함께 `@generalist` |

### Prompt 채우기

skill은 `{WHAT_WAS_IMPLEMENTED}` 또는 `[FULL TEXT of task]`와 같은 placeholder가 있는 prompt template을 제공합니다. 모든 placeholder를 채우고 완전한 prompt를 `@generalist`에 메시지로 전달하세요. prompt template 자체에는 agent의 역할, 리뷰 기준, 예상 출력 형식이 포함되어 있습니다 — `@generalist`가 이를 따를 것입니다.

### 병렬 dispatch

Gemini CLI는 병렬 subagent dispatch를 지원합니다. skill이 여러 독립적인 subagent 작업을 병렬로 dispatch하라고 요청할 때, 모든 `@generalist` 또는 명명된 subagent 작업을 동일한 prompt에서 함께 요청하세요. 종속적인 작업은 순차적으로 유지하되, 단순한 히스토리를 보존하기 위해 독립적인 subagent 작업을 직렬화하지 마세요.

## 추가 Gemini CLI tool

이 tool들은 Gemini CLI에서 사용 가능하지만 Claude Code에 대응이 없습니다:

| Tool | 용도 |
|------|---------|
| `list_directory` | 파일과 하위 디렉터리 목록 표시 |
| `save_memory` | session 전반에 걸쳐 GEMINI.md에 사실 영속화 |
| `ask_user` | 사용자로부터 구조화된 입력 요청 |
| `tracker_create_task` | 풍부한 작업 관리 (생성, 업데이트, 목록, 시각화) |
| `enter_plan_mode` / `exit_plan_mode` | 변경하기 전에 읽기 전용 연구 모드로 전환 |
