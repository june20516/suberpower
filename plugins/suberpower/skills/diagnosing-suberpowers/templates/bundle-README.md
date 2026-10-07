# Superpowers (suberpowers fork) session diagnosis bundle

Session: <session-id>
Harness: <name> <version> (<provenance label>)    suberpowers: <version> (<sha or "not a checkout">; <provenance label>)
Redaction level: skeleton | evidence | full
Built: <ISO timestamp>

header의 버전 필드에는 historical evidence, unverified snapshot, current
observation, unknown 중 하나로 출처 등급을 붙이세요. `environment.json`은
모든 환경 필드와 그 뒷받침 위치에 대해 같은 출처 구분을 담습니다.

## What this is

suberpowers가 설치된 상태에서 잘못 진행된 coding agent 세션을 scrub한
기록입니다. 그 자리에 없었던 agent나 사람이 suberpowers가 원인에 기여했는지,
그렇다면 무엇을 바꿔야 하는지 판단할 수 있게 해 줍니다. 안에 든 report는 무슨
일이 있었는지 `path:line` 증거와 함께 기술합니다. 설계상 suberpowers에 대한
진단이나 수정 제안은 담지 않습니다. 그것은 읽는 쪽의 몫입니다.

## Files

- `report.md` — 진단 report(문제 진술, 판정, 환경, 세션, timeline,
  finding, 관여 여부, coverage 메모).
- `case.md` — 분석가들이 작업 기준으로 삼은 case 파일.
- `environment.json` — 환경 섹션의 기계 판독용 사본.
- `timeline.md` — turn별 timeline.
- `findings/<dimension>.md` — 차원별 분석가 finding 원본.
- `transcripts/<session-id>.md` — 조사한 각 세션을 turn별로 압축해 옮긴 것
  (원본 JSONL은 절대 넣지 않음). 수준별 tool 결과 본문:

  | Level | Tool-result bodies |
  |---|---|
  | skeleton | 의도적으로 제한됨. `[tool result: <tool>, <bytes> bytes, exit <code>]`로 대체 |
  | evidence | 인용된 event의 본문만 유지. finding을 뒷받침하는 데 필요한 명령과 결과 포함 |
  | full | 모두 유지 |
- `scrub-log.md` — 사용한 모든 placeholder와 그 범주(원래 값은 절대 넣지
  않음).

## How to read it

`report.md` §1–2부터 읽고, 그다음 §7(관여 여부)과 거기서 인용한 증거 줄,
그다음 `transcripts/`의 해당 turn을 읽으세요. `path:line` 참조는 보고자
머신의 원본 파일을 가리킵니다. 압축된 transcript에도 같은 줄 번호가 `[L<n>]`
marker로 보존되어 있습니다.

## Redaction

placeholder는 `<EMAIL-1>`, `<PERSON-2>`, `<SECRET-3>`, `<HOST-4>`,
`<REPO-5>`, `<ORG-6>`, `<PROPRIETARY-7>` 같은 형태입니다. 홈 경로는 `~/…`로 바뀝니다. 같은 placeholder는
이 bundle 안에서 항상 같은 원래 값을 가리킵니다.

## Producer instructions

완성된 bundle에서는 이 지침을 실제 결과로 바꿔 넣습니다.

scrub한 뒤, 이 bundle만 사용해 export된 중요한 finding을 모두 점검하세요:
인용을 bundle에 포함된 transcript/소스 marker로 찾아가고, 인용된 명령/결과나
인용문을 읽고, 그것이 주장을 뒷받침하는지 검증하세요. 경로와 줄이 존재한다는
것만으로는 부족합니다. redaction 수준이나 불가피한 비공개 처리 때문에 근거가
사라지면 구체적인 한계를 기록하세요.

report, case, environment, findings, README, 그리고 로컬 issue 초안이 있다면
그것까지 서로 대조해 맞추세요. scrub-log의 횟수를 log 자신을 제외한 최종
파일 기준으로 갱신하세요. 낡은 export 진술은 지우고, bundle 준비와 압축 파일
전달을 구분하세요. 원래 위치 기준점(historical anchor)에서 bundle에 포함된
증거로 가는 대응표를 유지하세요.

독립적인 개인정보 audit 결과를 증거 유용성과 분리해 기록하세요:
- Privacy audit: CLEAN 또는 해결되지 않은 누락.
- Evidence support: supported 또는 limited. 영향받은 finding과 이유 포함.

점검 후 내용이 바뀌면 영향받은 점검을 다시 하세요. 기존 압축 승인 단계에 최종
log, 파일 목록, 두 결과를 제시하세요. 검토된 파일을 압축하고, 전달된 압축
파일이 그 파일들과 일치하는지 검증하세요. 압축 파일 전달 기록은 승인 후에
검토된 bundle의 내용을 바꾸는 대신 bundle 밖에 남기세요. scrub은 완전한
개인정보 보증이 아닙니다.
