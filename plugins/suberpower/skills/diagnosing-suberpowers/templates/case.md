# Case: <session-id>

Workspace: ~/.claude/suberpowers/diagnosing/<session-id>/
Created: <ISO timestamp>

## Problem statement (agreed with your human partner)

<한 문단. 대상 세션, 알고 있다면 turn 범위, 기대한 것, 실제로 일어난 일,
그리고 중요한 관찰 지표(실제 소요 시간, token, 반복된 행동, 예상치 못한 특정
행동)를 밝힙니다.>

Goal is a Superpowers (suberpowers fork) bug report: yes | no

## Sessions

| Role | Session id | Absolute path | Lines | Bytes | Longest line (bytes) | First prompt (first 120 chars) | First timestamp |
|---|---|---|---|---|---|---|---|
| main | | | | | | | |
| subagent | | | | | | | |

Rejected candidates: <id — 경로 — 탈락 이유>, 또는 "none".

Session still running at read time: yes | no (mtime <ISO>, lines <N>)

## Environment

- OS: <이름과 버전>
- Harness: <이름> <버전>
- Models seen: <model id — 위치 (main / subagent id)>
- suberpowers install root: <경로>; version <x.y.z>; git sha <sha 또는 "not a checkout">
- Skill files read or injected during the session:

| Skill / source path | sha1 or unavailable | Provenance | Supporting location |
|---|---|---|---|

환경과 skill 관찰에는 historical evidence, unverified snapshot, current
observation, unknown 중 하나로 출처 등급을 붙이세요. 과거 정보를 확인할 수
없다고 선언하기 전에, 전달받은 출처 메모, 아카이브, 수집된 skill 본문을
확인하세요. 원래 경로가 없어졌다고 해서 남아 있는 사본이 무효가 되지는
않습니다. 현재의 버전/mtime은 과거 버전을 입증하지 않으며, 수집된 skill 본문
하나가 설치 전체를 입증하지도 않습니다.

- Other plugins / extensions / MCP servers configured: <목록, 또는 "none found">
- Instruction files present (paths only): <목록>

## Context-safety rules for every reader of these files

- 여기 나열된 어떤 파일이든 읽기 전에 `references/context-safety.md`를 따르세요.
- subagent transcript에서 "user"는 상위 agent입니다.

## Discovered sources and record meanings

- Sources consulted: <절대 경로, tool, help, 또는 문서 소스>
- Extraction commands or queries: <소스마다 사용한, 범위를 제한한 명령이나 tool query>
- Target identity evidence: <세션 id, 작업 디렉터리, timestamp, 일치하는 내용, 그리고 뒷받침하는 레코드 위치>
- Associated sessions: <세션 id, 관계, 뒷받침하는 레코드 위치, 또는 "none found">
- Human messages: <레코드 형태와 그 의미의 근거>
- Injected messages and parent dispatches: <레코드 형태와 그 의미의 근거>
- Assistant messages: <레코드 형태와 그 의미의 근거>
- Tool calls and results: <레코드 형태, 짝짓는 방식, 그 의미의 근거>
- Usage counters: <필드, 증분/누적 의미, 단위, 근거, 또는 "unavailable">
- Timing: <필드, 단위, event 경계, 근거, 또는 "unavailable">
- Other relevant records: <model, 버전, compaction, 그 밖의 의미와 근거>
- Unresolved information: <없거나, 접근할 수 없거나, 모호하거나, 부재한 정보, 또는 "none">
