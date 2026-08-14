# Subagent 실패 완화 + 업스트림 수정 추적 Implementation Plan

> **agentic worker에게:** REQUIRED SUB-SKILL: 이 plan을 task 단위로 구현하려면 suberpower:subagent-driven-development(권장) 또는 suberpower:executing-plans를 사용하세요. Step은 추적을 위해 checkbox(`- [ ]`) 문법을 사용합니다.

**Goal:** reviewer subagent가 응답 없이 죽는 harness 버그의 피해를 플러그인 수준에서 완화하고, 업스트림 수정 여부를 자동 추적해 완화 제거 시점을 알 수 있게 한다.

**Architecture:** 완화는 3개(M-1 보고서 체크포인트, M-2 실패 처리 프로토콜, M-3 리뷰 범위 분할), 추적은 1개(M-4 GitHub Actions 주간 크론)로 구성한다. 각 완화는 커밋 메시지에 `[M-n]` 태그를 달아 독립 커밋으로 남기고, `docs/suberpowers/MITIGATIONS.md` 등록부가 완화 ↔ 업스트림 이슈 ↔ 제거 기준을 연결한다. 업스트림 이슈가 닫히면 워크플로우가 이 레포에 "제거 검토" 이슈를 자동 생성한다.

**Tech Stack:** Markdown skill 템플릿, Bash, GitHub Actions, gh CLI

---

## 배경: 왜 이 작업인가

세션 로그 전수 조사로 확인된 사실 (2026-08-13 진단):

- reviewer subagent 실패는 suberpower의 문제가 아니라 **Claude Code harness의 알려진 미해결 버그**다.
  - [anthropics/claude-code#75318](https://github.com/anthropics/claude-code/issues/75318) (원본), [#75367](https://github.com/anthropics/claude-code/issues/75367) (상세 리포트: 4.5시간 세션에서 subagent 사망 10건 중 9건이 이 에러로 종료)
- 실패 모드는 두 가지:
  1. `API Error: Connection closed mid-response` → "Agent terminated early due to an API error" failed 통지. 리뷰 결과물 전체 유실.
  2. 무통지 사망: 에러 기록 없이 transcript가 끊기고, orchestrator는 완료 통지를 영영 받지 못한 채 대기.
- **main 세션은 같은 에러에서 자동 복구되지만 subagent는 복구되지 않는다.** 트리거는 "긴 무발화 추론 후 큰 단일 메시지 출력" — diff를 읽고 오래 추론한 뒤 긴 보고서를 한 번에 출력하는 reviewer의 프로필과 정확히 일치한다. implementer가 상대적으로 안전한 이유는 짧은 툴콜을 자주 내보내기 때문.

완화 전략은 이 트리거를 직접 겨냥한다: **보고서를 파일에 조각조각 기록**하게 해서 (a) 긴 단일 출력 자체를 없애고, (b) 죽더라도 결과물이 보존되게 한다.

## 자동화 추적 방식에 대한 의견 (요청사항)

세 가지 옵션을 검토했고 **옵션 1(GitHub Actions)을 추천**한다. Task 4~5가 이를 구현한다.

1. **GitHub Actions 주간 크론 (추천)** — 무료이고, 완화 코드와 같은 레포에 버전 관리되며, 로컬 머신 상태와 무관하게 돌고, 이슈 생성 시 GitHub 알림으로 도달한다. 단점: 무료 플랜에서 60일간 레포에 활동이 없으면 스케줄이 자동 비활성화된다(fork를 계속 쓰는 한 문제 없음). 알림을 받으려면 fork 레포를 Watch(Issues) 설정할 것.
2. **Claude Code `/schedule` 클라우드 루틴** — 상태 확인을 넘어 "닫혔으면 MITIGATIONS.md 기준으로 제거 PR 초안까지 작성" 같은 판단+작업 자동화가 가능하다. 단, 단순 상태 체크에는 토큰 비용이 과하다. 제거 작업까지 자동화하고 싶어지면 그때 업그레이드하면 된다.
3. **로컬 cron/launchd** — 머신이 켜져 있어야 하고 알림 경로가 약하다. 비추천.

추천 운영: 옵션 1을 기본으로 두고, "제거 검토" 이슈가 생성되면 그때 Claude Code 세션에서 아래 "완화 제거 절차"를 실행한다.

## File Structure

- Modify: `plugins/suberpower/skills/subagent-driven-development/code-quality-reviewer-prompt.md` — REPORT_FILE 파라미터 추가 (M-1)
- Modify: `plugins/suberpower/skills/subagent-driven-development/spec-reviewer-prompt.md` — 체크포인트 지시 추가 (M-1)
- Modify: `plugins/suberpower/skills/requesting-code-review/code-reviewer.md` — 체크포인트 지시 + 짧은 최종 메시지 규칙 (M-1)
- Modify: `plugins/suberpower/skills/requesting-code-review/SKILL.md` — standalone 진입 경로에 REPORT_FILE 계약 반영 (M-1, Task 1-R에서 추가)
- Modify: `plugins/suberpower/skills/subagent-driven-development/SKILL.md` — 실패 처리 프로토콜(M-2) + 범위 분할(M-3)
- Create: `docs/suberpowers/MITIGATIONS.md` — 완화 등록부, 추적의 단일 소스 (M-4)
- Create: `scripts/check-upstream-fixes.sh` — 이슈 상태 확인 스크립트, 로컬/CI 겸용 (M-4)
- Create: `.github/workflows/upstream-fix-tracker.yml` — 주간 크론 (M-4)
- Modify: `plugins/suberpower/.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` — 버전 1.2.0 → 1.3.0

체크포인트 파일 위치는 프로젝트 레포 **밖**인 `~/.claude/suberpowers/reviews/`를 사용한다. 레포 안에 쓰면 `git status`가 오염되어 spec reviewer가 "요청되지 않은 추가 파일"로 오인한다. worktree 경로(`~/.claude/suberpowers/worktrees/`)와 같은 컨벤션이다.

---

### Task 1: reviewer 체크포인트 패턴 (M-1)

**Files:**
- Modify: `plugins/suberpower/skills/subagent-driven-development/code-quality-reviewer-prompt.md` (전체 교체, 현재 25줄)
- Modify: `plugins/suberpower/skills/subagent-driven-development/spec-reviewer-prompt.md` (전체 교체, 현재 61줄)
- Modify: `plugins/suberpower/skills/requesting-code-review/code-reviewer.md` (부분 수정)

- [ ] **Step 1: code-quality-reviewer-prompt.md 전체 교체**

파일 전체를 다음 내용으로 교체:

````markdown
# Code Quality Reviewer Prompt 템플릿

code quality reviewer subagent를 dispatch할 때 이 템플릿을 사용하세요.

**목적:** 구현이 잘 만들어졌는지 검증 (깔끔하고, 테스트되고, 유지보수 가능한지)

**spec 준수 review가 통과한 후에만 dispatch하세요.**

**dispatch 전 준비 (M-1 체크포인트):** report 파일 경로를 먼저 만드세요.

```bash
mkdir -p ~/.claude/suberpowers/reviews
find ~/.claude/suberpowers/reviews -name '*.md' -mtime +14 -delete  # 14일 지난 보고서 청소
# 예: ~/.claude/suberpowers/reviews/2026-08-13-myproject-task-3-quality.md
REPORT_FILE=~/.claude/suberpowers/reviews/$(date +%Y-%m-%d)-<프로젝트>-task-<N>-quality.md
```

```
Task tool (general-purpose):
  requesting-code-review/code-reviewer.md의 템플릿을 사용

  DESCRIPTION: [implementer 보고서에서 가져온 task 요약]
  PLAN_OR_REQUIREMENTS: [plan-file]의 Task N
  BASE_SHA: [task 이전 commit]
  HEAD_SHA: [현재 commit]
  REPORT_FILE: [위에서 만든 경로]
```

**표준 code quality 관심사 외에, reviewer는 다음을 확인해야 합니다:**
- 각 파일이 잘 정의된 인터페이스로 하나의 명확한 책임을 가지는가?
- 단위가 독립적으로 이해되고 테스트될 수 있도록 분해되어 있는가?
- 구현이 plan의 파일 구조를 따르고 있는가?
- 이 구현이 이미 큰 새 파일을 만들었거나, 기존 파일을 크게 키웠는가? (기존에 존재하던 파일 크기를 표시하지 말 것 — 이 변경이 기여한 부분에 집중할 것.)

**Code reviewer가 반환하는 것:** 3줄 요약 (REPORT_FILE 경로, 판정, 이슈 개수). 전체 보고서는 REPORT_FILE에 있으므로 **orchestrator는 통지를 받으면 반드시 REPORT_FILE을 Read로 읽으세요.**

**reviewer가 응답 없이 종료된 경우:** REPORT_FILE에 부분 보고서가 남아 있을 수 있습니다. SKILL.md의 "Subagent 실패 처리" 섹션을 따르세요.
````

- [ ] **Step 2: spec-reviewer-prompt.md 전체 교체**

파일 전체를 다음 내용으로 교체:

````markdown
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
````

- [ ] **Step 3: requesting-code-review/code-reviewer.md에 체크포인트 섹션 삽입**

`## Review 대상 Git Range` 블록 뒤, `    ## 무엇을 확인해야 하는가` 줄 **바로 앞**에 다음을 삽입 (템플릿 내부이므로 4칸 들여쓰기 유지):

```
    ## 보고서 체크포인트 (필수)

    review 결과를 다음 파일에 기록하면서 진행하세요: {REPORT_FILE}

    - review를 시작하면 즉시 위 파일을 생성하고 아래 "출력 형식"의 헤더 뼈대를 쓰세요.
    - 섹션 하나를 완성할 때마다(Strengths 파악 완료, 이슈 1건 확정 등) 그 즉시 파일에
      반영하세요. 마지막에 한꺼번에 쓰지 마세요.
    - 점진 기록의 분할 단위는 입력이 아니라 출력입니다 — "diff 파일 하나를 읽을
      때마다"가 아니라 "보고서 항목 하나가 확정될 때마다" 기록하세요.
    - 점진 기록은 출력 버퍼일 뿐, 분석 순서를 강제하지 않습니다. 판정을 기록하기 전에
      전체 diff를 먼저 훑어 큰 그림을 파악하세요. 나중에 본 코드가 앞의 판단을
      뒤집으면 이미 기록한 항목을 수정하세요 — 이 파일은 append-only 로그가 아닙니다.
    - 개별 파일 검증을 마친 뒤, 여러 파일을 함께 봐야만 드러나는 문제(파일 간
      상호작용, 일관성 위반)를 점검하는 패스를 한 번 더 돌고 결과를 기록하세요.
    - 파일 기록이 끝난 뒤, 최종 응답 메시지는 3줄 이내로:
      1. REPORT_FILE 경로
      2. 판정 (Yes | No | With fixes)
      3. 이슈 개수 (Critical n / Important n / Minor n)
    - 긴 최종 메시지는 금지합니다. 전체 내용은 파일로만 전달하세요.
      (이유: 긴 단일 응답 스트림은 연결 절단으로 유실될 수 있습니다 —
      anthropics/claude-code#75318)

```

- [ ] **Step 4: code-reviewer.md의 출력 형식/Placeholders/반환 규칙 갱신**

`    ## 출력 형식` 줄 바로 아래에 한 줄 추가:

```
    (아래 형식은 {REPORT_FILE}에 기록할 보고서의 형식입니다. 응답 메시지 형식이 아닙니다.)
```

`**Placeholders:**` 목록의 `- `{HEAD_SHA}` — 종료 commit` 줄 아래에 추가:

```
- `{REPORT_FILE}` — review 보고서를 기록할 파일 경로 (orchestrator가 dispatch 전에 생성)
```

`**Reviewer 반환:** Strengths, Issues (Critical / Important / Minor), Recommendations, Assessment` 줄을 다음으로 교체:

```
**Reviewer 반환:** 3줄 요약 (REPORT_FILE 경로, Assessment 판정, 이슈 개수). 전체 보고서는 REPORT_FILE에 있다.
```

- [ ] **Step 5: 검증**

실행:
```bash
cd ~/personal/suberpower
grep -c "REPORT_FILE" plugins/suberpower/skills/subagent-driven-development/code-quality-reviewer-prompt.md plugins/suberpower/skills/subagent-driven-development/spec-reviewer-prompt.md plugins/suberpower/skills/requesting-code-review/code-reviewer.md
```
기대: 세 파일 모두 1 이상 (대략 4~6, 4~5, 4~5)

```bash
grep -n "75318" plugins/suberpower/skills/*/*.md | wc -l
```
기대: 2 이상 (code-quality-reviewer-prompt.md는 SKILL.md의 실패 처리 섹션을 참조할 뿐 이슈 번호를 직접 담지 않는다. Task 2에서 SKILL.md에 참조가 추가되면 3 이상)

- [ ] **Step 6: Commit**

```bash
git add plugins/suberpower/skills/subagent-driven-development/code-quality-reviewer-prompt.md \
        plugins/suberpower/skills/subagent-driven-development/spec-reviewer-prompt.md \
        plugins/suberpower/skills/requesting-code-review/code-reviewer.md
git commit -m "[M-1] reviewer 보고서 체크포인트: 파일에 점진 기록 + 짧은 최종 메시지

upstream anthropics/claude-code#75318 완화: 긴 단일 응답 스트림이
연결 절단으로 유실되는 것을 방지하고, subagent가 죽어도 부분 보고서가
~/.claude/suberpowers/reviews/ 에 보존되게 한다."
```

### Task 1-R: quality 리뷰 반영 (M-1) — 실행 중 추가됨

Task 1 quality 리뷰(2026-08-14, 판정 With fixes)의 이슈를 반영하는 후속 커밋.
상세 근거: `~/.claude/suberpowers/reviews/2026-08-14-suberpower-task-1-quality.md`

- [ ] I-1: `requesting-code-review/SKILL.md`에 REPORT_FILE 계약 추가 (준비 bash,
  placeholder 목록, 3줄 반환 + "orchestrator는 REPORT_FILE을 Read" 지시) —
  plan File Structure가 standalone 진입 경로를 누락했던 것의 보완
- [ ] I-2: `code-reviewer.md`의 예시를 "예시 보고서(REPORT_FILE에 기록되는 내용)"로
  개칭하고 3줄 응답 메시지 예시를 별도 추가. `subagent-driven-development/SKILL.md`의
  워크플로우 예시 갱신은 Task 2에서 함께 수행
- [ ] I-3: 같은 날 재review 시 REPORT_FILE 경로 충돌 방지 — `-r2`, `-r3` 접미사 규칙을
  두 dispatch 가이드와 requesting-code-review 준비 bash에 추가
- [ ] m-1/m-3/m-4: placeholder 설명의 파일 생성 주체 정정("경로는 orchestrator,
  생성은 reviewer"), spec 보고서 뼈대(`## 검증 항목`/`## 판정`) 정의, find에 `-type f`
- 보류: m-2(`~` 경로 확장 안내)는 실전에서 마찰이 관측되면 반영

---

### Task 2: SKILL.md 실패 처리 프로토콜 + 리뷰 범위 분할 (M-2, M-3)

**Files:**
- Modify: `plugins/suberpower/skills/subagent-driven-development/SKILL.md`

- [ ] **Step 1: 실패 처리 섹션 삽입**

`## Prompt 템플릿` 줄 **바로 앞**에 다음을 삽입:

````markdown
## Subagent 실패 처리 (완화 M-2 — upstream anthropics/claude-code#75318)

subagent(특히 reviewer)는 harness의 알려진 버그로 응답 없이 죽을 수 있습니다.
긴 추론 후 긴 단일 응답을 출력하는 turn에서 API 스트림이 끊기면 subagent는 복구 없이
종료됩니다. main 세션은 같은 에러에서 자동 복구되지만 subagent는 아닙니다.

**실패 감지:**
- failed 통지: "Agent terminated early due to an API error: ..." → 즉시 복구 절차 진행
- 무통지: dispatch 후 완료 통지 없이 turn이 재개되었는데 해당 agent가 실행 목록에
  없거나 멈춰 있으면 실패로 간주 (agent 상태는 TaskList 또는 ListAgents로 확인)

**복구 절차 (순서대로):**
1. REPORT_FILE(체크포인트)을 orchestrator가 Read
   - 보고서가 사실상 완성돼 있으면(최종 판정 섹션까지 기록됨): 재dispatch 없이 그대로 사용
   - 미완성이면: 어디까지 진행되다 죽었는지 파악하고 2번으로
2. 재dispatch (최대 2회): 같은 프롬프트에 다음을 덧붙여 **같은 REPORT_FILE을 이어서
   완성**하게 한다. 목표는 남은 범위만큼의 비용으로 복구하는 것이다.
   "이전 reviewer가 도중에 종료되었습니다. [REPORT_FILE]에 지금까지 확정된 항목이
   기록되어 있습니다. 기록된 항목의 재검증은 건너뛰고, 남은 범위를 이어서 검증해
   같은 파일을 완성하세요. 단, 남은 범위를 검증하다 기존 기록과 모순되는 근거를
   발견하면 해당 항목을 수정하세요. 마지막의 파일 간 종합 패스는 전체 범위를
   대상으로 수행하세요."
   (기록된 항목은 확정 시점에 검증을 마친 출력이므로 이어쓰기의 기준점으로 신뢰할 수
   있다 — "출력 단위로만 기록"하는 M-1 원칙이 이 신뢰의 전제다.)
3. 2회 재dispatch에도 실패하면: 리뷰 범위를 절반으로 분할해 각각 dispatch (아래 M-3)
4. 그래도 실패하면 사람에게 escalate — 다른 원인(usage limit, 네트워크)일 수 있습니다

**하지 말 것:**
- 실패를 무시하고 review 없이 다음 task로 진행 ("review 건너뛰기 금지"는 여전히 유효)
- 무한 재dispatch (2회 초과 금지)
- REPORT_FILE 확인 없이 재dispatch (이미 완성됐거나 절반 진행된 리뷰를 처음부터
  다시 시키는 낭비)

## 리뷰 범위 분할 (완화 M-3)

diff가 크면 reviewer turn이 길어져 실패 확률이 올라갑니다. reviewer를 dispatch하기 전에
diff 크기를 확인하세요:

```bash
git diff --stat [BASE_SHA]..[HEAD_SHA] | tail -1
```

- 변경 500줄 이하이고 파일 8개 이하: 단일 reviewer로 진행
- 그 이상: 연관된 파일끼리 그룹으로 나눠 reviewer를 순차 dispatch하고, 각 reviewer에
  별도 REPORT_FILE을 주세요. orchestrator가 보고서들을 읽고 종합해 판정합니다.
- 분할 리뷰는 그룹 경계를 넘는 상호작용을 보지 못합니다. 그룹은 호출 관계가 밀접한
  파일끼리 묶으세요. 각 reviewer는 자기 그룹만 봅니다 — reviewer에게 다른 그룹의
  범위, 컨텍스트, 결과를 알려주지 마세요. 그룹 간 접점(공유 인터페이스, 호출 관계)에서
  생길 수 있는 문제는 orchestrator가 종합 시 직접 확인합니다.

````

- [ ] **Step 1b: 예시 워크플로우의 reviewer 반환 형식 갱신 (Task 1-R I-2 잔여분)**

같은 파일의 "예시 워크플로우" 섹션에서 spec reviewer / code reviewer가 결과를 인라인으로
반환하는 부분을 새 계약(3줄 요약: REPORT_FILE 경로, 판정, 이슈 개수 — orchestrator가
REPORT_FILE을 Read로 확인)에 맞게 갱신한다.

- [ ] **Step 2: 검증**

실행:
```bash
grep -n "Subagent 실패 처리\|리뷰 범위 분할" plugins/suberpower/skills/subagent-driven-development/SKILL.md
```
기대: 두 섹션 헤더가 각 1회, `## Prompt 템플릿`보다 앞 줄 번호에 위치

- [ ] **Step 3: Commit**

```bash
git add plugins/suberpower/skills/subagent-driven-development/SKILL.md
git commit -m "[M-2][M-3] subagent 실패 감지·복구 프로토콜과 대형 diff 리뷰 분할 추가

upstream anthropics/claude-code#75318 완화: failed 통지/무통지 사망 시
체크포인트 기반 재dispatch 절차를 정의하고, 긴 reviewer turn 자체를
줄이기 위해 500줄/8파일 초과 diff는 분할 리뷰하게 한다."
```

### Task 2-R: quality 리뷰 반영 (M-2, M-3) — 실행 중 추가됨

Task 2 quality 리뷰(2026-08-14, 판정 With fixes)의 이슈를 반영하는 후속 커밋.
Step 1 마커 블록의 원문은 역사적 기록으로 두고, 최종 문구는 SKILL.md가 기준이다.
상세 근거: `~/.claude/suberpowers/reviews/2026-08-14-suberpower-task-2-quality.md`

- [ ] I-1(부분 수용): 무통지 감지의 툴 이름(TaskList/ListAgents)을 harness 중립
  표현으로 보완. 리뷰어는 "실재하지 않는 툴"이라 했으나 orchestrator가 이 세션에서
  두 툴의 실재를 직접 확인 — 다만 비-Claude Code 플랫폼 지원을 위해 예시로 강등
- [ ] I-2: M-3 그룹 격리의 구현 수단 명시 — reviewer별 파일 목록 +
  `git diff BASE..HEAD -- <그룹 파일들>` 경로 제한, read-only이므로 병렬 dispatch 허용
- [ ] I-3: 복구 절차가 reviewer(REPORT_FILE 계약) 기준임을 명시하고 implementer
  실패 경로(커밋·작업 트리 = implementer의 체크포인트) 추가
- [ ] m-1b/m-2/m-3/m-4: 순수 hang의 감지 한계 명시, 3단계 분할 기준을 M-3 그룹
  기준으로 통일, 이어쓰기 시 커버리지 불확실성 처리, 분할 전환 시 부분 보고서 재사용
- 보류: {FILE_SCOPE} placeholder를 code-reviewer.md에 추가하는 근본 해결은 후속
  확장 후보 (M-3의 diff 경로 제한 지시로 당장은 충분)

---

### Task 3: 완화 등록부 MITIGATIONS.md (M-4)

**Files:**
- Create: `docs/suberpowers/MITIGATIONS.md`

- [ ] **Step 1: 등록부 파일 생성**

````markdown
# 완화 조치 등록부 (Mitigations Registry)

Claude Code harness 버그를 우회하기 위해 이 fork에 추가된 완화 조치들의 등록부입니다.

`.github/workflows/upstream-fix-tracker.yml`이 **이 파일에서 `anthropics/claude-code#NNN`
패턴을 읽어** 업스트림 이슈 상태를 매주 확인하고, 이슈가 닫히면 이 레포에 제거 검토
이슈를 자동 생성합니다. 즉, 이 파일이 추적 대상의 단일 소스입니다 — 새 완화를 추가하면
반드시 여기에 행을 추가하세요.

| ID | 완화 내용 | 적용 위치 | 업스트림 이슈 | 제거 기준 |
|----|----------|----------|--------------|----------|
| M-1 | reviewer 보고서 체크포인트 (파일에 점진 기록 + 3줄 최종 메시지) | subagent-driven-development/*-prompt.md, requesting-code-review/code-reviewer.md, requesting-code-review/SKILL.md | anthropics/claude-code#75318 | 아래 공통 기준 |
| M-2 | subagent 실패 감지·재dispatch 프로토콜 | subagent-driven-development/SKILL.md | anthropics/claude-code#75318 | 아래 공통 기준 |
| M-3 | 대형 diff 리뷰 범위 분할 (500줄/8파일 초과 시) | subagent-driven-development/SKILL.md | anthropics/claude-code#75318 | 공통 기준. 단 분할 자체는 리뷰 품질에도 이로우므로 유지 여부 별도 판단 |

증상 상세 리포트(같은 버그의 duplicate, 함께 추적): anthropics/claude-code#75367

## 공통 제거 기준

1. 추적 중인 업스트림 이슈가 모두 closed
2. Claude Code를 수정 버전으로 업데이트한 뒤, subagent-driven-development 실전 사용
   2주(또는 reviewer dispatch 20회) 동안 "응답 없이 종료" 재발 없음

## 제거 방법

각 완화는 커밋 메시지 앞에 `[M-n]` 태그를 달고 독립 커밋으로 존재합니다.

```bash
git log --oneline --grep='\[M-1\]'   # 해당 완화의 커밋 찾기
git revert <hash>                    # 제거 (충돌 시 해당 섹션 수동 삭제)
```

제거 후: 이 파일에서 해당 행을 삭제하고, 남은 행이 없으면 워크플로우
(`.github/workflows/upstream-fix-tracker.yml`)와 `scripts/check-upstream-fixes.sh`도
함께 제거한 뒤 plugin 버전을 bump하세요.
````

- [ ] **Step 2: 검증**

실행:
```bash
grep -oE 'anthropics/claude-code#[0-9]+' docs/suberpowers/MITIGATIONS.md | sort -u
```
기대 출력:
```
anthropics/claude-code#75318
anthropics/claude-code#75367
```

- [ ] **Step 3: Commit**

```bash
git add docs/suberpowers/MITIGATIONS.md
git commit -m "[M-4] 완화 등록부 추가: 완화 ↔ 업스트림 이슈 ↔ 제거 기준 연결"
```

### Task 3-R: quality 리뷰 반영 (M-4) — 실행 중 추가됨

Task 3 quality 리뷰(2026-08-14, 판정 With fixes)의 이슈를 반영하는 후속 커밋.
Step 1 마커 블록의 원문은 역사적 기록으로 두고, 최종 문구는 MITIGATIONS.md가 기준이다.
상세 근거: `~/.claude/suberpowers/reviews/2026-08-14-suberpower-task-3-quality.md`

- [ ] I-1: "독립 커밋" 서술을 커밋 현실(완화당 다중 커밋, M-2/M-3 태그 공유)에 맞게
  수정 — 역순 전체 revert, 커밋 공유 시 수동 삭제 경로 명시
- [ ] I-2: M-3 정식 기능 존치 시나리오의 지침 추가 (행 삭제로 추적 종료 +
  SKILL.md의 M-1/M-2 의존 참조 정리)
- [ ] I-3: 신규 완화 ID는 M-5부터 (M-4는 인프라 태그로 예약됨) + `[M-n]` 태그 의무 명시
- [ ] m-1/m-2: M-1 적용 위치 glob을 실제 파일 2종으로 정밀화, dispatch 계수 방법 명시
- plan 소관(m-3): Task 4 스크립트에 state_reason 표시 추가(duplicate closure 노이즈
  구분), 완화 제거 절차의 광역 `\[M-` grep을 완화별 태그로 정정 — plan에 직접 반영됨

---

### Task 4: 업스트림 상태 확인 스크립트 (M-4)

**Files:**
- Create: `scripts/check-upstream-fixes.sh`

- [ ] **Step 1: 스크립트 작성**

```bash
#!/usr/bin/env bash
# MITIGATIONS.md에 적힌 업스트림 이슈 상태를 확인하고, 닫힌 이슈가 있으면
# (--create-issue 옵션 시) 이 레포에 제거 검토 이슈를 생성한다.
# 로컬: bash scripts/check-upstream-fixes.sh        (상태 출력만)
# CI:   bash scripts/check-upstream-fixes.sh --create-issue
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REGISTRY="$REPO_DIR/docs/suberpowers/MITIGATIONS.md"
CREATE_ISSUE=false
[ "${1:-}" = "--create-issue" ] && CREATE_ISSUE=true

issues=$(grep -oE 'anthropics/claude-code#[0-9]+' "$REGISTRY" | sort -u) || true
if [ -z "$issues" ]; then
  echo "MITIGATIONS.md에서 추적할 이슈를 찾지 못했습니다" >&2
  exit 1
fi

closed_any=false
for ref in $issues; do
  num="${ref#*#}"
  state=$(gh api "repos/anthropics/claude-code/issues/$num" --jq '.state')
  reason=$(gh api "repos/anthropics/claude-code/issues/$num" --jq '.state_reason // ""')
  echo "$ref: $state${reason:+ ($reason)}"
  if [ "$state" = "closed" ]; then
    closed_any=true
    if $CREATE_ISSUE; then
      title="[upstream-fixed] claude-code#$num 해결됨 — 완화 조치 제거 검토"
      existing=$(gh issue list --search "\"$title\" in:title" --state all \
        --json number --jq '.[].number' | head -1)
      if [ -z "$existing" ]; then
        gh issue create --title "$title" --body "업스트림 이슈 https://github.com/anthropics/claude-code/issues/$num 이 닫혔습니다 (state_reason: ${reason:-unknown}).

주의: duplicate 등 실제 수정이 아닌 사유로 닫혔을 수 있습니다.
docs/suberpowers/MITIGATIONS.md의 공통 제거 기준(추적 이슈 모두 closed + 무재발 관찰)을
확인하고, 충족되면 등록부의 '제거 방법' 절차대로 revert 하세요."
        echo "  -> 제거 검토 이슈 생성됨"
      else
        echo "  -> 제거 검토 이슈가 이미 존재함 (#$existing)"
      fi
    fi
  fi
done

$closed_any || echo "모든 추적 이슈가 아직 open — 완화 유지"
```

- [ ] **Step 2: 실행 권한 부여 후 로컬 실행으로 검증**

실행:
```bash
chmod +x scripts/check-upstream-fixes.sh
bash scripts/check-upstream-fixes.sh
```
기대 출력 (2026-08-13 기준 두 이슈 모두 open):
```
anthropics/claude-code#75318: open
anthropics/claude-code#75367: open
모든 추적 이슈가 아직 open — 완화 유지
```
(`gh auth status`가 유효해야 한다. closed로 나오는 이슈가 있다면 그것대로 정상 동작 — 제거 검토를 시작하면 된다.)

- [ ] **Step 3: Commit**

```bash
git add scripts/check-upstream-fixes.sh
git commit -m "[M-4] 업스트림 이슈 상태 확인 스크립트 추가 (로컬/CI 겸용)"
```

### Task 4-R: quality 리뷰 반영 (M-4) — 실행 중 추가됨

Task 4 quality 리뷰(2026-08-14, 판정 With fixes, shellcheck 0건·실API 검증 포함).
상세 근거: `~/.claude/suberpowers/reviews/2026-08-14-suberpower-task-4-quality.md`

- [ ] I-1: 빈 레지스트리 가드가 pipefail로 dead code였던 문제 — `issues=$(grep ...) || true`
  한 줄 수정 (plan 원문 결함, Step 1 블록에도 반영됨). orchestrator가 직접 수정하고
  빈 레지스트리(메시지+exit 1)/정상(두 이슈 open+exit 0) 양 경로를 실행으로 검증
- 보류(리뷰어 판정 수용): m-1 search 인덱싱 의존(주간 주기에서 무관), m-2 404 시
  시끄러운 실패(의도된 동작), m-3 unknown arg 무시(CI에서 인자 고정)
- 참고: 이 레포는 fork가 아님(`isFork: false`) — plan 서두의 "fork" 언급은 GitHub
  Actions 60일 비활성 규칙과 무관하며, 스케줄 비활성화 규칙은 레포 종류와 무관하게 적용

---

### Task 5: GitHub Actions 주간 크론 (M-4)

**Files:**
- Create: `.github/workflows/upstream-fix-tracker.yml`

- [ ] **Step 1: 워크플로우 작성**

```yaml
name: upstream-fix-tracker

on:
  schedule:
    - cron: '17 22 * * 0' # 매주 월요일 07:17 KST (정각은 GitHub 혼잡 시간대라 임의 분 사용)
  workflow_dispatch: {}

permissions:
  issues: write
  contents: read

jobs:
  check:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - name: Check upstream issue states
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: bash scripts/check-upstream-fixes.sh --create-issue
```

- [ ] **Step 2: Commit & push**

```bash
git add .github/workflows/upstream-fix-tracker.yml
git commit -m "[M-4] 업스트림 수정 주간 추적 워크플로우 추가

매주 월요일 아침(KST) MITIGATIONS.md의 추적 이슈 상태를 확인하고,
닫힌 이슈가 있으면 제거 검토 이슈를 자동 생성한다."
git push origin HEAD
```
(스케줄 워크플로우는 기본 브랜치에 있어야 동작한다. 브랜치에서 작업 중이라면 merge 후 다음 step을 실행.)

- [ ] **Step 3: 수동 실행으로 검증**

실행:
```bash
gh workflow run upstream-fix-tracker.yml && sleep 10 && gh run list --workflow=upstream-fix-tracker.yml --limit 1
```
기대: 최신 run이 `completed  success`. 로그 확인은 `gh run view --log`, 출력에 Step 2(Task 4)와 동일한 상태 라인이 보여야 한다.

- [ ] **Step 4: 알림 설정 확인 (수동, 1회)**

GitHub에서 fork 레포 Watch 설정을 `Participating and @mentions` 이상 + Issues 포함으로 설정. 이슈 자동 생성 시 알림을 받는 경로다.

---

### Task 6: 버전 bump 및 배포

**Files:**
- Modify: `plugins/suberpower/.claude-plugin/plugin.json` (`"version": "1.2.0"` → `"1.3.0"`)
- Modify: `.claude-plugin/marketplace.json` (`"version": "1.2.0"` → `"1.3.0"`)

- [ ] **Step 1: 두 매니페스트의 버전을 1.3.0으로 변경**

두 파일에서 `"version": "1.2.0"`을 `"version": "1.3.0"`으로 교체.

- [ ] **Step 2: 검증**

실행:
```bash
grep -rn '"version"' plugins/suberpower/.claude-plugin/plugin.json .claude-plugin/marketplace.json
```
기대: 두 파일 모두 `1.3.0`, `1.2.0` 잔존 없음

- [ ] **Step 3: Commit & push**

```bash
git add plugins/suberpower/.claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "chore: 버전 1.3.0 — subagent 실패 완화(M-1~M-3) 및 업스트림 추적(M-4)"
git push origin HEAD
```

- [ ] **Step 4: 플러그인 반영 확인**

`~/.claude/settings.json`에 suberpower가 `autoUpdate: true`이므로 main 반영 후 자동 갱신된다. 새 Claude Code 세션에서 확인:

```bash
grep -rn "REPORT_FILE" ~/.claude/plugins/cache/suberpower/suberpower/1.3.0/skills/subagent-driven-development/ | head -3
```
기대: 매치 존재 (캐시가 아직 1.2.0이면 `claude plugin update suberpower` 실행)

---

## 완화 제거 절차 (업스트림 수정 후)

워크플로우가 "[upstream-fixed] ..." 이슈를 생성하면:

1. Claude Code를 최신으로 업데이트하고 릴리스 노트/이슈 코멘트에서 수정 버전을 확인
2. `MITIGATIONS.md`의 공통 제거 기준 충족 여부 확인 (2주 또는 reviewer 20회 무사고)
3. 완화별 태그로 커밋을 찾아(`git log --oneline --grep='\[M-1\]'` 등 — 광역 `\[M-` grep은
   [M-4] 인프라 커밋까지 매치하므로 사용하지 않는다) 최신 커밋부터 역순으로 revert.
   상세 절차와 M-2/M-3 커밋 공유 주의사항은 MITIGATIONS.md의 '제거 방법' 참조
   (M-3 분할은 리뷰 품질 관점에서 유지할지 별도 판단)
4. `MITIGATIONS.md` 행 삭제 → 남은 추적 대상이 없으면 워크플로우와 스크립트도 제거
5. 버전 bump 후 push
