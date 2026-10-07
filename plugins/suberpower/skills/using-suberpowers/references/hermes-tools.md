# Hermes Agent Tool 매핑

skill은 행동 단위로 말합니다("subagent를 dispatch하세요", "todo를 만드세요", "파일을 읽으세요"). Hermes Agent에서는 이 행동이 아래 tool에 대응합니다.

## Tool

| skill이 요청하는 행동 | Hermes tool |
|---|---|
| 파일 읽기 | `read_file` |
| 새 파일 생성 | `write_file` |
| 파일 편집 (대상을 지정한 patch) | `patch` |
| shell 명령 실행 | `terminal` |
| 파일 내용 검색 | `search_files` |
| 이름으로 파일 찾기 | `find`와 함께 `terminal` |
| URL 가져오기 / 웹페이지 읽기 | `web_extract(urls=[...])` |
| 웹 검색 | `web_search(query=...)` |
| subagent dispatch | `delegate_task(goal=..., context=..., toolsets=[...], role="leaf")` |
| 작업 추적 | `todo` tool |
| skill 호출 | `skill_view("skill-name")` |

## instruction 파일

skill이 "instruction 파일"을 언급하면, Hermes Agent에서는 프로젝트 디렉터리의 **`AGENTS.md`**, 또는 전역으로는 **`SOUL.md`**(`~/.hermes/SOUL.md`)입니다.

## skill 호출

Hermes Agent에는 `skill_view`와 `skills_list` tool이 든 `skills` toolset이 있습니다.
Superpowers(suberpowers 포크) skill을 호출하려면 다음을 사용하세요:

```
skill_view("brainstorming")
skill_view("test-driven-development")
```

`skill_view`가 suberpowers skill을 찾지 못하면(plugin이 완전히 등록하기 전에는
catalog에 나타나지 않을 수 있습니다), SKILL.md를 직접 읽는 방식으로 대체하세요:

```
read_file(path="~/.hermes/plugins/suberpower/skills/<skill-name>/SKILL.md")
```

이 대체 방식은 네이티브 skill 로딩이 없는 다른 harness가 쓰는 것과 같은 방식입니다.

## Subagent dispatch

병렬 또는 순차 작업 흐름에 격리된 subagent를 spawn하려면 `delegate_task`를 사용하세요:

```
delegate_task(goal="...", context="...", toolsets=[...], role="leaf")
```

`delegate_task`를 쓸 수 없으면 tool 호출을 지어내지 말고 inline으로 작업하세요.

## 작업 추적

세션 안의 작업 추적에는 `todo` tool을 사용하세요. multi-agent 작업 보드가 필요하면, 사용 가능한 경우 `hermes kanban` CLI를 사용하세요. 이전의 `TodoWrite` 참조는 작업 추적 행동으로 취급하세요.
