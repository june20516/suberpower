# Scoped Re-Review Prompt 템플릿

수정 라운드 후 re-review를 dispatch할 때 이 템플릿을 사용하세요. re-reviewer는
지적 사항이 해결되었는지 검증하고, 수정 diff에 새로 깨진 것이 없는지 확인합니다.
새로운 review가 아닙니다 — 전체 review는 이미 끝났습니다.

**목적:** 이전 review의 각 지적 사항이 해결되었는지, 그리고 수정 자체가 아무것도
깨뜨리지 않았는지 검증

```
Subagent (general-purpose):
  description: "Re-review Task N fix round R"
  model: [MODEL — REQUIRED: SKILL.md의 Model Selection에 따라 선택하세요. model을
         생략하면 세션에서 가장 비싼 model을 조용히 상속합니다]
  prompt: |
    당신은 한 task의 수정 라운드를 re-review합니다. 이전 review가 지적 사항을
    냈고, implementer가 그것을 수정하려고 시도했습니다. 당신의 일은 각 지적
    사항을 판정하고 수정 diff를 살펴보는 것입니다 — 그 외에는 아무것도 하지
    마세요.

    ## Task

    task brief를 읽으세요: [BRIEF_FILE]

    ## 검증 대상 지적 사항

    [FINDINGS]

    ## 수정 내용

    implementer의 보고서를 읽으세요 (수정 보고서는 끝에 덧붙여져 있습니다):
    [REPORT_FILE]

    **Fix base:** [FIX_BASE_SHA] (이전 review가 본 head)
    **Head:** [HEAD_SHA]
    **Diff file:** [DIFF_FILE]

    diff 파일을 한 번 읽으세요 — 수정 commit, stat 요약, 주변 context를 포함한
    수정 diff가 들어 있습니다. git 명령을 다시 실행하지 마세요.
    diff 파일이 없으면 직접 diff를 가져오세요:
    `git diff --stat [FIX_BASE_SHA]..[HEAD_SHA]`와
    `git diff [FIX_BASE_SHA]..[HEAD_SHA]`.

    이 review는 현재 checkout에 대해 읽기 전용입니다. working tree, index, HEAD,
    브랜치 상태를 어떤 방식으로든 변경하지 마세요.

    ## Subagent를 dispatch하지 마세요

    이 review는 모두 직접 하세요. diff의 일부를 review하려고 subagent를 **절대**
    띄우지 마세요. 두 번째 의견을 얻으려고 다른 reviewer를 띄우는 일도 **절대**
    하지 마세요. 이 프로세스는 이 작업이 받을 모든 review 자리를 이미 마련해
    두었습니다. 당신이 띄운 reviewer는 그중 하나를 전체 비용을 들여 중복할
    뿐이고, 그 판정은 아무 효력이 없습니다. diff가 한 번에 보기에 너무 크다고
    느껴지면 직접 여러 번에 나눠 review하고, 보고서에 그렇다고 밝히세요.

    ## 범위

    당신의 범위는 지적 사항 목록과 수정 diff입니다. 모든 지적 사항을
    판정하세요. 수정 자체가 새로 만든 문제가 없는지 수정 diff를 살펴보세요.
    수정이 건드리지 않은 코드는 다시 review하지 **마세요**: 수정 diff와 전혀
    무관한 곳에서 이슈를 발견하면 Out-of-Scope Observations 아래에 보고하세요 —
    그것은 이 task를 막지 않으며 루프를 늘리지도 않습니다. 브랜치 전체에 대한
    폭넓은 review는 모든 task가 끝난 뒤에 진행됩니다.

    ## 테스트

    implementer는 수정한 코드를 커버하는 테스트를 다시 실행했고 그 결과를 report
    파일에 덧붙였습니다. 보고서는 검증되지 않은 주장으로 취급하세요: 수정
    보고서가 커버링 테스트를 명시하고 그 출력을 보여 주는지 확인하고, 주장을
    diff와 대조해 검증하세요. 그 보고를 확인하려고 test suite를 다시 실행하지
    마세요. 코드를 읽다가 기존 실행 결과로는 답할 수 없는 구체적인 의문이 생길
    때만 테스트를 실행하세요 — 그때도 집중된 테스트 하나만 실행하고, 패키지 전체
    suite는 **절대** 실행하지 마세요.

    ## 출력 형식

    최종 메시지가 곧 보고서입니다: 첫 번째 지적 사항의 판정으로 바로 시작하세요.
    모든 줄은 판정, file:line이 달린 지적 사항, 실행한 확인 중 하나여야
    합니다 — 서두, 과정 서술은 쓰지 마세요.

    ### Finding Verdicts

    "검증 대상 지적 사항"의 각 지적 사항에 대해, 순서대로:
    - **[지적 사항 한 줄 요약]** — ADDRESSED | NOT ADDRESSED, file:line 증거와
      함께. "시도함"은 해결이 아닙니다: 그 구체적인 결함이 더 이상 존재하지
      않아야 합니다.

    ### New Breakage in the Fix Diff

    수정 자체가 깨뜨리거나 새로 들여온 모든 것을 심각도(Critical/Important/Minor)와
    file:line과 함께 적으세요. 깨끗하다면 "None".

    ### Out-of-Scope Observations

    수정 diff와 전혀 무관한 곳에서 발견한 이슈. 차단 사항이 아니며, controller가
    이를 기록해 두었다가 최종 review로 넘깁니다. 없다면 "None".

    ### Verdict

    **Fix round:** [All findings addressed, no new Critical/Important
    breakage | Findings remain open] — 열려 있는 항목을 나열하세요.
```

**Placeholders:**
- `[MODEL]` — REQUIRED: SKILL.md의 Model Selection에 따른 reviewer model. 작은
  수정 diff에 대한 scoped re-review에는 저가~중간 등급이면 충분합니다
- `[BRIEF_FILE]` — task brief 파일 (implementer가 작업한 것과 같은 파일)
- `[FINDINGS]` — 이전 review의 Critical/Important 지적 사항과 spec 공백을
  그대로 복사해 bullet 하나에 하나씩
- `[REPORT_FILE]` — implementer의 보고서 파일 (수정 보고서가 덧붙여진 것)
- `[FIX_BASE_SHA]` — 이전 review가 본 head
- `[HEAD_SHA]` — 현재 commit
- `[DIFF_FILE]` — `bash scripts/review-package PLAN_FILE FIX_BASE HEAD`가 출력한 경로

**Re-reviewer 반환:** 지적 사항별 판정 (ADDRESSED / NOT ADDRESSED), 수정 diff의
새로 깨진 부분, 범위 밖 관찰 사항, 라운드 판정
