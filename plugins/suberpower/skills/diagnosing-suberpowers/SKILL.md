---
name: diagnosing-suberpowers
description: suberpowers 세션이 잘못 진행되어 your human partner가 그 이유를 알고 싶어 할 때 사용합니다 - 반복 작업, 무시된 plan, 막힘, 기대에 못 미친 결과, 발동하지 않은 skill, "너무 오래 걸렸다", "왜 이렇게 비싸지", "지금 뭘 하고 있는 거지" 같은 경우, 또는 suberpowers maintainer에게 보낼 bug report를 만들고 싶을 때. 현재 세션이든 id나 경로로 지정한 과거 세션이든, harness와 관계없이 해당됩니다
---

# suberpowers 진단

## 개요

세션에서 무엇이 잘못됐는지 your human partner와 함께 특정하고, 디스크의
transcript를 읽어 무슨 일이 있었는지 증거와 함께 보고합니다. 당신은
보고합니다. Superpowers(suberpowers 포크)를 진단하지는 않습니다. suberpowers를
바꿀지는 bundle이나 issue를 triage하는 사람이 결정합니다.

**핵심 원칙:** 모든 finding은 `path:line`을 인용합니다. 인용이 없으면
finding도 없습니다. 모든 숫자는 transcript나 당신이 실행한 명령에서 나옵니다.
기억에서 나온 숫자는 절대 쓰지 않습니다.

## 워크플로우

단계마다 todo를 하나씩 만드세요. 5–7단계는 각 단계에 명시된 조건에서만 실행합니다.

1. **문제 파악.** 다음을 담은 문제 진술을 쓸 수 있을 때까지 한 번에 하나씩
   질문하세요: 대상 세션, 알고 있다면 turn 범위, your human partner가 기대한
   것, 실제로 일어난 일, 그리고 your human partner가 신경 쓰는 관찰 지표(실제
   소요 시간, token, 반복된 행동, 특정한 행동 하나). "너무 오래 걸렸다"는
   불만이지 문제 진술이 아닙니다. 목표가 suberpowers bug report인지도
   기록하세요.
2. **위치 확인.** `references/session-discovery.md`를 따라 각 세션을 검증된
   절대 파일시스템 경로로 확정하세요. 과거 세션이면 첫 prompt와 timestamp를
   인용해 확인하고, 탈락시킨 후보를 이유와 함께 모두 나열하세요(없으면
   "none"). subagent transcript를 빠짐없이 찾으세요.
   `~/.claude/suberpowers/diagnosing/<session-id>/`를 만들고 your human
   partner에게 그 경로를 알린 뒤, 그곳에 `templates/case.md`를 채우세요.
   환경과 skill 관찰은 이 템플릿의 출처 규칙을 따릅니다.
3. **Triage.** 보고된 문제 주변 구간은 직접 읽으세요. 그다음 차원마다 분석
   subagent를 하나씩 병렬로 dispatch하고, 각각에 case 파일 경로,
   `prompts/analyst-common.md`, 그리고 `prompts/`의 차원 파일 하나를 주세요:
   `skill-timeline.md`,
   `plan-adherence.md`, `repeated-work.md`, `stumbles.md`,
   `quality-evidence.md`, `request-conflicts.md`, `cost-and-time.md`.
   transcript가 길면 한 차원을 turn 범위로 나누세요. 돌아온 finding 중
   `path:line`이 없는 것은 버리세요.
4. **보고.** `templates/report.md`의 모든 섹션을 순서대로 채워 작업 공간에
   쓰고, 보여 주고, 경로를 알리세요. 인용한 내용이 실제로 무엇을 증명하는지
   확인하고, 뒷받침하는 case 파일을 보존하세요. symlink 별칭은 중복 사본이
   아닙니다.
<!-- DIVERGENCE:D-008 start -->
5. **GitHub issues** — report §7이 possible이나 likely라고 할 때, 또는 your
   human partner가 요청할 때. `references/github-issues.md`에 따라 증상으로
   열린 issue와 닫힌 issue를 upstream(`obra/superpowers`)에서 먼저, 그다음
   포크(`june20516/suberpower`)에서 검색하세요. 일치하는 것을 저장소별로 보여
   주고, 가장 가까운 issue에 report를 덧붙이자고 제안하세요. upstream issue에
   다는 comment는 영어로 씁니다. 일치하는 것이 없으면 포크에 먼저 만드세요:
   `templates/issue.md`를 채워(양식 heading은 영문 그대로, 내용은 한국어 가능)
   작업 공간에 쓰고, 정확한 문구를 보여 준 뒤, 승인을 받은 후에만 issue를
   만드세요. 그다음 포크 issue를 검토하고, 같은 내용을 upstream에도 영어로
   보고할지 선택 동작으로 제안하세요. upstream 보고는 영어 본문을 따로 보여 주고
   **별도로** 승인받은 후에만 합니다. `gh`는 파일을 첨부할 수 없습니다.
   bundle이 있으면 your human partner가 브라우저에서 첨부할 수 있도록 그 경로를 주세요.
<!-- DIVERGENCE:D-008 end -->
6. **Export** — your human partner가 bundle을 요청할 때만. 요청 없이
   절대 만들지 마세요. 문제 파악 단계의 목표가 bug report였다면, scrub한
   bundle을 요청 시 만들 수 있다고 한 번만 말하고 기다리세요. redaction 수준을
   물어보되, 각 수준에 무엇이 들어가는지 함께 말하세요: skeleton(tool 결과
   본문 없음), evidence(인용된 event의 본문만), full.
   `templates/bundle-README.md`에 따라 bundle을 만들고, `prompts/scrub.md`를
   dispatch한 뒤 `prompts/scrub-audit.md`를 dispatch하세요. audit가 CLEAN을
   반환할 때까지 둘을 반복합니다. 최종 scrub log, 파일 목록, 개인정보와 증거
   결과를 보여 주기 전에 bundle 템플릿의 증거 점검과 대조 작업을 마치세요.
   압축(`zip -r` 또는 `tar -czf`)은 승인 후에만 하세요. 압축 파일 경로를 줄 때
   무엇이 들어 있는지 말하고, 치환 내역은 scrub log를 보라고 안내하고,
   scrub이 놓치는 것이 있을 수 있다고 말하세요: 공유하기 전에 your human
   partner가 모든 파일을 반드시 검토해야 합니다.
7. **유사 세션** — 요청받았을 때. 확정된 finding을 signature로 바꾸고,
   후보를 mtime과 크기로 나열하고, marker의 줄 번호를 찾은 뒤, 후보마다
   `prompts/similar-session.md`를 병렬로 dispatch하고, report §9를 덧붙이세요.

## 빠른 참조

일곱 분석가는 항상 모두 실행됩니다. 이 표는 3단계에서 어느 구간을 직접
읽을지, 판정에서 어떤 finding을 앞세울지를 알려 줍니다.

| 불만 | 먼저 읽고 앞세울 것 |
|---|---|
| "너무 오래 걸렸다" | cost-and-time, stumbles |
| "왜 이런 추가 작업을 했지?" | repeated-work, plan-adherence |
| "왜 이렇게 비싸지?" | cost-and-time |
| "대체 지금 뭘 하고 있는 거야?" (아직 실행 중) | skill-timeline; coverage에 진행 중임을 기록 |
| "plan을 무시했다" | plan-adherence, compaction 줄부터 |
| "skill X가 한 번도 발동하지 않았다" | skill-timeline |

## 엄격한 규칙

- **Context 안전.** transcript 한 줄이 1MB일 수 있습니다. 모든 세션 파일에,
  매번, `references/context-safety.md`를 따르세요.
- **읽기 전용.** 세션 파일을 절대 수정하거나 옮기거나 삭제하지 마세요.
- **subagent에는 정확한 경로를.** subagent에게 "현재 세션"은 그 subagent
  자신의 세션입니다. 절대 경로와 id를 넘기세요.
- **사람의 prompt만.** hook 출력, system reminder, tool 결과는 your human
  partner의 말이 아닙니다. subagent transcript에서 "user"는 상위 agent입니다.
- **suberpowers 진단 금지.** report §7은 관여 여부만 밝히고 멈춥니다. skill의
  결함을 지목하거나 변경을 제안하는 일은 절대 하지 마세요. your human
  partner가 수정을 재촉해도 이 규칙은 면제되지 않습니다. issue 단계를 가리키고
  bundle을 요청 시 만들 수 있다고 언급하세요. your human partner에게 조언하는
  것도 금지입니다.
- **승인 관문.** your human partner가 scrub log와 파일 목록을 보기 전에는
  압축하지 마세요. 정확한 문구를 승인받기 전에는 어느 저장소에도 issue나
  comment를 올리지 마세요. 포크 issue 승인은 upstream 보고 승인이 아닙니다.
  upstream에 올릴 영어 본문은 따로 승인받으세요.
- **분석 전에 문제 파악.** your human partner가 답하기 전에는 2–7단계 중
  어느 것도 시작하지 마세요. 자리에 없다면 질문을 적어 두고 멈추세요. 당신이
  대신 재구성한 진술은 답이 아닙니다. 이미 범위가 정해진 요청 — 특정 event
  하나, 지금 실행 중인 것, 또는 실행할 분석 — 은 그 자체가 진술입니다: 먼저
  답하고, 그다음 물어보세요. 세션 전체에 대한 "왜"는 불만입니다.

## 위험 신호

| 생각 | 현실 |
|---------|---------|
| "문제가 뻔하니 문제 파악은 건너뛰자" | 문제 진술이 모든 범위를 정합니다. 물어보세요. |
| "자리에 없으니 내가 진술을 재구성하자" | 상대가 원한 것을 당신이 재구성할 수는 없습니다. 질문을 적어 두고 멈추세요. |
| "지금 전부 훑고 마지막에 물어보자" | 범위 없는 전수 조사는 엉뚱한 질문에 상대의 예산을 씁니다. 먼저 물어보세요. |
| "bug report를 원하니 지금 bundle을 만들자" | bundle은 상대의 세션 데이터를 묶은 것입니다. 요청할 때만 만드세요. |
| "작고 국소적인 수정이니 구조 변경은 필요 없다" | 아무리 작아도 당신이 정할 일이 아닙니다. 증거를 보고하세요. triage하는 사람이 결정합니다. |
| "원작 문제 같으니 upstream에 바로 올리자" | 포크에서 생긴 문제는 번역이나 포크 수정이 원인일 수 있습니다. 포크에 먼저 올리고, upstream 보고는 선택으로 제안해 영어 본문을 따로 승인받으세요. |
| "token당 가격은 잘 알려져 있다" | transcript에서 계산하지 않은 숫자는 지어낸 것입니다. 인용하거나 빼세요. |
