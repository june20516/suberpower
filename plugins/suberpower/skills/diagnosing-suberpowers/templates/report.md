# Session diagnosis: <session-id>

Report path: ~/.claude/suberpowers/diagnosing/<session-id>/report.md
Written: <ISO timestamp>

## 1. Problem statement (REQUIRED)

<case 파일에서 그대로 옮깁니다.>

## 2. Triage verdict (REQUIRED)

<보고된 문제 주변에서 무슨 일이 있었는지 증거가 보여 주는 것. 산문으로 쓰고,
모든 주장 뒤에 `path:line`을 붙입니다. 확신도(high / medium / low)와 무엇이
있으면 확신도가 올라갈지를 밝힙니다. Superpowers(suberpowers 포크)가 무엇을
해야 하는지에 대한 진술은 넣지 않습니다.>

## 3. Environment (REQUIRED)

- OS:
- Harness and version:
- Models seen:
- suberpowers install root / version / git sha:
- Skill files read or injected (sha1 table from the case file):
- Other plugins, extensions, MCP servers:
- Instruction files present (paths only):

모든 환경 필드와 skill 관찰에 historical evidence, unverified snapshot,
current observation, unknown 중 하나로 출처 등급을 붙이고, 그것을 뒷받침하는
증거 위치를 기록하세요.

## 4. Sessions examined (REQUIRED)

| Role | Session id | Absolute path | Lines | Bytes |
|---|---|---|---|---|

Rejected candidates: <id — 경로 — 이유>, 또는 "none".

## 5. Timeline (REQUIRED)

사람이 입력한 prompt 하나당 한 행. Events 열에는 호출된 skill, dispatch된
subagent, compaction, 오류, resume, 중단을 나열합니다.

| Turn | Line | Time | Request (one line) | Events |
|---|---|---|---|---|

## 6. Findings (REQUIRED, one subsection per dimension)

각 finding:
```
- finding: <one sentence>
  evidence: <path:line> — "<short quote>"
  turns: <first>–<last>
  confidence: high | medium | low
```
보고할 것이 없는 차원은 `none found — checked: <what was checked>`라고 씁니다.

### 6.1 Skill timeline
### 6.2 Plan adherence
### 6.3 Repeated work
### 6.4 Stumbles
### 6.5 Quality evidence
### 6.6 Request conflicts
### 6.7 Cost and time
### 6.8 Other plugins and skills used

## 7. suberpowers involvement (REQUIRED)

not indicated | possible | likely

Evidence lines: <path:line 목록>. 이 섹션은 관여 여부만 밝힙니다. 결함을
지목하지 않고 변경을 제안하지 않습니다.

## 8. Coverage notes (REQUIRED)

- Not read: <범위, 파일, 그리고 이유>
- Harness features unavailable: <목록 또는 none>
- Session was in progress at read time: yes/no
- For your human partner to double-check: <목록 또는 none>

## 9. Similar sessions (only when requested)

| Session id | Path | Date | Harness | Matched | Did not match |
|---|---|---|---|---|---|
