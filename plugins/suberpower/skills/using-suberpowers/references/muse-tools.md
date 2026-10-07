# Muse Tool 매핑

skill은 행동 단위로 말합니다("subagent를 dispatch하세요", "todo를 만드세요", "파일을 읽으세요"). Muse에서는 이 행동이 아래 tool에 대응합니다.

| skill이 요청하는 행동 | Muse 대응 |
|----------------------|----------------|
| 파일 읽기 | `read_file` |
| 여러 파일 읽기 | `read_file`(여러 번 호출) 또는 `search` |
| 새 파일 생성 | `write_file` |
| 파일 편집 | `edit_file` |
| shell 명령 실행 | `bash` |
| 파일 내용 검색 | `search` |
| 이름으로 파일 찾기 | `glob`과 함께 `search` |
| URL 가져오기 | `web_fetch` |
| 웹 검색 | `web_search` |
| skill 호출 | `skills/<name>/SKILL.md`에 `read_file`, 또는 네이티브 skill tool |
| subagent dispatch (`Subagent (general-purpose):` template) | prompt를 채운 뒤 `subagent_spawn` |
| 작업 추적 ("todo 만들기", "완료 표시") | `write_todos` 또는 `bash`로 task 파일 관리 |
| 사용자에게 질문하기 | `request_user_input` |

## instruction 파일

skill이 "instruction 파일"을 언급하면, Muse에서는 프로젝트 루트의 **`CLAUDE.md`** 또는 **`AGENTS.md`**입니다. 설정된 경우 Muse는 이 파일들을 계층적으로 로드합니다.

## skill 호출

Muse는 `muse skills`로 skill을 네이티브 지원합니다. Superpowers(suberpowers 포크) skill을 호출하려면 해당 `SKILL.md`를 읽고 지시를 따르세요. bootstrap(`using-suberpowers`)은 plugin hook을 통해 `SessionStart`에 자동으로 주입됩니다 — 이미 따르고 있으니 다시 로드하지 마세요.

## Subagent dispatch

격리된 subagent에 작업을 위임하려면 `subagent_spawn`을 사용하세요. dispatch하기 전에 prompt template(예: `implementer-prompt.md`, `task-reviewer-prompt.md`)을 채우세요. subagent tool이 없으면 tool 호출을 지어내지 말고 inline으로 작업하세요.

## 작업 추적

checklist 추적에는 `write_todos`를 사용하세요. skill checklist 항목마다 todo를 하나씩 만들고, 진행하면서 in_progress/completed로 표시하세요. `write_todos`를 쓸 수 없으면 `write_file`/`edit_file`로 markdown task 파일을 유지하세요.
