# Spec Compliance Reviewer Prompt 템플릿

spec 준수 reviewer subagent를 dispatch할 때 이 템플릿을 사용하세요.

**목적:** implementer가 요청된 것을 만들었는지 검증 (더도 말고 덜도 말고)

**dispatch 전 준비 (M-1 체크포인트):** report 파일 경로를 먼저 만드세요.

```bash
mkdir -p ~/.claude/suberpowers/reviews
find ~/.claude/suberpowers/reviews -name '*.md' -mtime +14 -delete  # 14일 지난 보고서 청소
REPORT_FILE=~/.claude/suberpowers/reviews/$(date +%Y-%m-%d)-<프로젝트>-task-<N>-spec.md
```

```
Task tool (general-purpose):
  description: "Review spec compliance for Task N"
  prompt: |
    당신은 구현이 해당 spec과 일치하는지 review합니다.

    ## 무엇이 요청되었는가

    [task 요구사항의 전체 원문]

    ## Implementer가 만들었다고 주장하는 것

    [implementer의 보고서에서 발췌]

    ## 보고서 체크포인트 (필수)

    review 결과를 다음 파일에 기록하면서 진행하세요: [REPORT_FILE 경로]

    - review를 시작하면 즉시 위 파일을 생성하고 아래 "보고 형식"의 뼈대를 쓰세요.
    - 검증 항목 하나를 확정할 때마다(누락 1건 확인, 추가 기능 1건 발견 등) 그 즉시
      파일에 반영하세요. 마지막에 한꺼번에 쓰지 마세요.
    - 점진 기록의 분할 단위는 입력이 아니라 출력입니다 — "diff 파일 하나를 읽을
      때마다"가 아니라 "보고서 항목 하나가 확정될 때마다" 기록하세요.
    - 점진 기록은 출력 버퍼일 뿐, 분석 순서를 강제하지 않습니다. 판정을 기록하기 전에
      전체 diff를 먼저 훑어 큰 그림을 파악하세요. 나중에 본 코드가 앞의 판단을
      뒤집으면 이미 기록한 항목을 수정하세요 — 이 파일은 append-only 로그가 아닙니다.
    - 개별 파일 검증을 마친 뒤, 여러 파일을 함께 봐야만 드러나는 문제(파일 간
      상호작용, 일관성 위반)를 점검하는 패스를 한 번 더 돌고 결과를 기록하세요.
    - 최종 응답 메시지는 3줄 이내: REPORT_FILE 경로, 판정(✅/❌), 이슈 개수.
      긴 최종 메시지는 금지합니다 — 긴 단일 응답 스트림은 연결 절단으로 유실될 수
      있습니다 (anthropics/claude-code#75318).

    ## CRITICAL: 보고서를 신뢰하지 마세요

    implementer는 의심스러울 만큼 빠르게 끝냈습니다. 그 보고서는 불완전하거나,
    부정확하거나, 낙관적일 수 있습니다. 당신은 반드시 모든 것을 독립적으로 검증해야 합니다.

    **DO NOT:**
    - implementer가 무엇을 구현했다고 말하든 그대로 받아들이지 마세요
    - 완전성에 대한 implementer의 주장을 신뢰하지 마세요
    - 요구사항에 대한 implementer의 해석을 수용하지 마세요

    **DO:**
    - implementer가 작성한 실제 코드를 읽으세요
    - 실제 구현과 요구사항을 한 줄씩 대조하세요
    - 구현했다고 주장했지만 누락된 부분을 확인하세요
    - 언급하지 않은 추가 기능을 찾으세요

    ## 당신이 할 일

    구현 코드를 읽고 다음을 검증하세요:

    **누락된 요구사항:**
    - 요청된 모든 것을 구현했는가?
    - 건너뛰거나 놓친 요구사항이 있는가?
    - 동작한다고 주장했지만 실제로는 구현하지 않은 것이 있는가?

    **불필요한/추가된 작업:**
    - 요청되지 않은 것을 만들었는가?
    - 과도하게 엔지니어링하거나 불필요한 기능을 추가했는가?
    - spec에 없는 "있으면 좋은 것"을 추가했는가?

    **오해:**
    - 요구사항을 의도와 다르게 해석했는가?
    - 잘못된 문제를 풀었는가?
    - 올바른 기능을 잘못된 방식으로 구현했는가?

    **보고서를 신뢰하지 말고, 코드를 읽어서 검증하세요.**

    보고 형식 (REPORT_FILE에 기록):
    - ✅ Spec 준수 (코드 검사 후 모든 것이 일치하는 경우)
    - ❌ 이슈 발견: [무엇이 누락되었거나 추가되었는지 file:line 참조와 함께 구체적으로 나열]
```

**Spec reviewer가 반환하는 것:** 3줄 요약 (REPORT_FILE 경로, ✅/❌, 이슈 개수). **orchestrator는 통지를 받으면 반드시 REPORT_FILE을 Read로 읽으세요.**

**reviewer가 응답 없이 종료된 경우:** REPORT_FILE에 부분 보고서가 남아 있을 수 있습니다. SKILL.md의 "Subagent 실패 처리" 섹션을 따르세요.
