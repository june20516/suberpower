# 번역 용어집 및 표기 규칙

이 포크(suberpower)가 upstream [obra/superpowers](https://github.com/obra/superpowers)를 한국어로 옮길 때 따르는 규칙입니다. upstream 변경분을 새로 반영할 때 이 문서를 기준으로 삼습니다.

---

## 1. 기본 원칙

**산문만 번역하고, 구조와 기술 어휘는 영문으로 둡니다.**

| 대상 | 처리 | 예 |
|---|---|---|
| 산문 | 한국어 | 본문 설명, 목록 항목, 표 내용 |
| `##` heading | **파일의 기존 관례를 따름** (영문 파일은 영문 유지) | `## Overview`, `## When to Use` — 아래 참고 |
| 기술 용어 | **영문 유지** | skill, subagent, commit, test, mock, edge case, dispatch |
| 상태값 | **영문 유지** | `DONE`, `BLOCKED`, `NEEDS_CONTEXT`, `DONE_WITH_CONCERNS` |
| 의사코드 제어 키워드 | **영문 + 대시** | `BEFORE - …하기 전:`, `IF …라면:`, `STOP - …` |

영문 뒤에는 조사를 그대로 붙입니다: `dispatch하고`, `commit하세요`, `review하며`.

**heading은 각 파일의 기존 관례를 우선합니다.** 이미 heading이 번역된 파일은 새 heading도 번역하고, 출력 형식 heading·판정 토큰·ledger 토큰은 영문으로 둡니다. 새로 추가되는 파일은 같은 skill 디렉터리의 기존 파일 관례를 따르고, skill 자체가 새것이면 heading을 번역합니다(포크 다수 관례).

### description 작성 규칙

한국어로 **트리거 조건을 서술하고 `사용`을 포함**합니다. 트리거 절 뒤에 대시로 부연을 붙이는 형태도 씁니다. (upstream은 `"Use when..."`으로 시작하는 형식)

```yaml
# ✅ 현재 세션에서 독립적인 task로 구성된 implementation plan을 실행할 때 사용합니다
# ✅ 모든 대화를 시작할 때 사용합니다 - skill을 찾고 사용하는 방법을 확립하며, …
# ❌ Use when executing implementation plans with independent tasks
# ❌ plan 실행 시 사용 - task마다 subagent를 dispatch하고 code review 수행  (워크플로우 요약 금지)
```

이 규칙은 [divergence.md의 D-003](./divergence.md#d-003--description-규약)에서 기계적으로 검증됩니다.

---

## 2. 강조 계층 보존 (중요)

영어는 **대문자를 강조 등급으로** 쓰지만 한국어에는 대소문자가 없습니다. 그대로 옮기면 최상위 경고가 평서문으로 내려앉아 **지시의 구속력이 실제로 약해집니다.**

원문의 등급을 서식으로 복원합니다:

| 등급 | 표기 | 예 |
|---|---|---|
| 최상위 | 영문 대문자 토큰 유지 | `IMPORTANT:`, `CRITICAL:`, `THIS IS EXTREMELY IMPORTANT.` |
| 상위 | 영문 라벨 + 대시 | `STOP - 다음 경우 escalate하세요`, `DO NOT:` / `DO:` |
| 중간 | 굵게 | `**절대**`, `**반드시**` |
| 하위 | 평문 | |

**`MUST` → `반드시`, `Never` → `절대 …하지 마세요`** 처럼 한국어 대응이 확실한 것은 번역하되, 강도를 떨어뜨리지 않습니다.

> 실제 사례: `CRITICAL:` → `중요:`, `Never silently produce…` → `…내놓지 마세요`로 옮겼다가
> subagent 지시문의 구속력이 낮아져 되돌린 적이 있습니다.

---

## 3. 용어 대응표

| 원어 | 표기 | 비고 |
|---|---|---|
| context (LLM) | `context` | 세션 context, subagent에 전달하는 context |
| context (일반 배경) | `맥락` | 프로젝트 맥락, 역사적 맥락 |
| review | `review` | `리뷰` 사용 안 함 |
| self-review | `self-review` | `자기/자체 review` 사용 안 함 |
| escalate | `escalate` | `에스컬레이션` 사용 안 함 |
| guidance | `지침` | |
| guideline | `가이드라인` | guidance와 구분 |
| loophole | `허점` | `구멍` 사용 안 함 |
| compliance | `준수` / `준수율` | `따름`(명사) 사용 안 함 |
| adapt (코드를) | `참고해 고쳐 쓰다` | `각색` 금지 (소설 각색으로 읽힘) |
| directory | `디렉터리` | 표준어 |
| refactoring | `리팩터링` | 표준어 |
| your human partner | `your human partner` | `사람 파트너` 사용 안 함. upstream의 `your partner` 변형도 이 표기로 통일 |
| synthesis | `종합` | `합성`(화학) 금지 |
| academic (비판적 맥락) | `이론적` / `탁상공론식` | `학술적` 금지 |
| systematic errors | `같은 실수를 일관되게 반복` | `체계적인 오류` 금지 (반대 인상) |
| shared resource | `공유 자원` | `공공재` 금지 (경제학 용어, 의미 반대) |
| voice (인칭) | `인칭` | `시점` 금지 (時點으로 읽힘) |
| source of truth | `기준점` | |
| over/under-building | `과잉 구현과 구현 누락` | |
| scene-setting | `배경 설명` | `장면 설정` 금지 |
| finding (review) | `지적 사항` | |
| fix round | `수정 라운드` | |
| verdict | `판정` | reviewer가 내리는 것. 판정 토큰(`Approved`, `ADDRESSED` 등)은 영문 유지 |
| adjudicate | `판결` | controller가 내리는 것. `판정`(verdict)과 구분 |
| ruling | `결정` | ledger 토큰 `Ruling:`은 영문 유지 |
| fix report | `수정 보고서` | |
| scoped re-review | `범위 한정 re-review` | |
| gap (spec) | `공백` | `격차` 사용 안 함 |
| pre-flight (review) | `사전 점검` | |
| park (finding) | `보류` | ledger 토큰 `parked`는 영문 유지 |
| fix wave | `일괄 수정` | `수정 물결` 금지 (직역투) |
| executor | `실행자` | inline executor → `inline 실행자` |
| fix pass | `수정 패스` | fix wave(`일괄 수정`)와 구분 |
| re-grade | `등급 재평가` / `등급을 다시 매기다` | |
| completion contract | `완료 계약` | |
| deferred (minor) | `연기된` | ledger 토큰 `minor (deferred)`는 영문 유지 |
| gate | `관문` | 단, 이름 붙은 의사코드 구조 Gate Function은 각 파일 기존 표기를 따름(TDD: 게이트 함수, verification-before-completion: 영문 heading) |
| transcript/transcription (plan이 코드를 베낀 것) | `옮겨 적기` / `옮겨 적은 것` | `전사본` 금지 |
| transcript (세션 대화 기록) | `transcript` | 영문 유지. Claude Code 세션 jsonl |
| copy (UI·사용자 노출 텍스트) | `문구` | 복사 아님. 필요하면 `사용자 노출 문구` |
| version floor | `최소 버전` | |
| coordinator | `조율자` | controller(영문 유지)와 구분 |
| instruction file | `instruction 파일` | CLAUDE.md 등 지시 파일의 일반화 |
| name (the break/change) | `특정하다` / `구체적으로 말하다` | `명명`(이름 붙이기) 금지. test 제목 짓기로 오독됨 |
| break (test가 잡아내는) | `깨짐` | |
| code under test | `test 대상 코드` | `테스트 대상 코드` 사용 안 함 |
| hand-derived / hand-checked | `손으로 도출한` / `손으로 검증한` | `직접`(본인이)과 구분 |
| mutation check | `mutation 점검` | |
| pressure test (skill 검증) | `압박 테스트` | writing-skills 기존 표기가 정본 |
| handoff (단계 간 넘김) | `handoff` | 영문 유지. executing-plans 기존 표기가 정본. 예: `planning handoff` |
| probe (spike의 조사 계획) | `probe` | 영문 유지 |
| throwaway | `버릴 코드` | 코드가 아닐 수 있으면 `버릴 산출물` |
| design brief | `설계 개요` | |
| just-in-time | `필요한 시점에` | |
| ratchet (one-way) | `한 방향으로만` | 비유를 풀어 서술. 예: `경로 변경은 한 방향으로만 일어납니다` |
| control (test arm) | `대조군` | 지침 없는 대조군 |
| arm (비교 실험의 한쪽) | `~쪽` | 예: `금지 쪽`, `레시피 쪽` |
| nuance clause | `단서 조항` | "~가 아니면" 류. exemption clause와 구분 |
| exemption clause | `예외 조항` | "~에는 적용되지 않음" 류. nuance clause와 구분 |
| observable predicate | `관찰 가능한 판별 조건` | |
| underlying model | `기반 모델` | `기본 모델` 사용 안 함. `파일시스템 기반 모델`(filesystem-based)과는 문맥으로 구분 |
| micro-test | `micro-test` | 영문 유지. 조사를 붙여 `micro-test하다` |
| Skill Discovery Optimization (SDO) | `Skill Discovery Optimization (SDO)` | heading·약어 모두 영문 유지. 본문 참조(`SDO 섹션`)가 heading 문자열에 의존. 구 명칭 CSO |
| session | `세션` | 포크 다수 표기. 영문 `session` 사용 안 함 |
| child (spawn된 agent) | `자식` | SDD 대기 규칙 번역이 정본. codex-tools.md도 이 표기 |
| parent agent | `상위 agent` | |
| seat (비용 맥락의 실행 단위) | `자리` | 맥락 없이 처음 나오면 `자리(실행 단위)`로 한 번 풀어 씀. 예: `review 자리` |
| bounded stretch / bounded wait | `기한을 정한 대기` | 동사형 `기한을 정해 기다리다`. 한 번의 대기는 `대기 구간`. SDD 표기가 정본 |
| Superpowers (브랜드, 문서 첫 등장) | `Superpowers(suberpowers 포크)` | 이후 등장은 `suberpowers`. 단, upstream 자체를 가리키면(예: 포크 이전 문서) `Superpowers` |

---

## 4. 번역하지 않는 것

- **코드**와 식별자, 파일 경로, 명령어
- **실제 코드에 존재하는 test 제목** — `"should abort tool with partial output capture"`
- **테스트 러너가 출력하는 문자열** — `FAIL: expected 'Email required', got undefined`
- **철의 법칙(Iron Law)** — `NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST` 등 3종 (파일 간 통일)
- **고유명사** — `Visual Companion`, `Brainstorm Companion`, skill 이름(`writing-plans`)
- **brainstorming 경로 분류명** — `spike` / `bounded` / `architectural` (라벨은 `Spike` / `Bounded` / `Architectural`)
- **gerund 네이밍 규칙 예시** — `"Processing PDFs"` 등. 영어 `-ing` 형태를 가르치는 내용이라 한국어 대응이 없음
- **Conventional Commits 예시** — `feat(auth): implement JWT-based authentication`
- **약속된 신호 문구** — `"Strange things are afoot at the Circle K"` (v6.4.2에서 upstream 제거)
- **인용 문헌**, 이미지 태그, 외부 링크

---

## 5. 치환 시 함정 (실제로 밟은 것들)

**① 합성어·부분 문자열**
`리뷰` → `review` 일괄 치환 시 **`어트리뷰션`**(attribution)이 깨집니다. lookbehind로 보호해야 합니다.

```bash
perl -i -pe 's/(?<!어트)리뷰/review/g'
```

**② 경로·고유명사에 박힌 단어**
`parallel` → `병렬` 후보 8건이 전부 skill 이름 `dispatching-parallel-agents` 경로였습니다. **치환 대상 0건.**

**③ 받침 변화에 따른 조사 오류**
`가이던스`(받침 없음) → `지침`(받침 있음) 치환 후 `지침를`이 생깁니다. 함께 교정해야 합니다.

| 받침 없음 → 있음 | 를→을, 는→은, 가→이, 와→과, 로→으로 |

**④ perl 인코딩**
한글 패턴에 `-CSD`를 쓰면 명령줄 패턴이 디코딩되지 않아 매칭이 실패합니다. **바이트 모드(`perl -i -pe`)로 실행**하세요.

---

## 6. 문체 규칙

- 하나의 표·목록 안에서 **경어체/평어체/명령형을 섞지 않습니다**
- 지시문(subagent에게 전달되는 프롬프트)은 **명령형으로 통일** — 금지 항목을 명사형(`~하는 것`)으로 두면 나열처럼 읽혀 구속력이 떨어집니다
- 단수 대상에 `그들의` 금지 — 영어 singular they의 직역. `implementer의`처럼 명시하거나 생략
- 같은 영어 문단이 여러 파일에 중복될 때는 **정본을 정해 동기화**합니다

---

## 7. 의도적 divergence

**→ [divergence.md](./divergence.md)로 분리되었습니다.**

이 포크가 upstream과 의도적으로 다른 지점은 별도 문서에서 근거·정책과 함께 관리하며, `./scripts/check-divergence.sh`로 기계 검증합니다. 동기화 작업 후 반드시 실행하세요.

---

## 8. upstream 비교 시 기준

**반드시 "포크 시점의 upstream"과 비교합니다. 현재 `main`과 비교하면 안 됩니다.**

upstream이 그 사이 스스로 고친 것을 "포크의 번역 결함"으로 오판하게 됩니다. 실제로 그런 오판이 있었습니다 — `writing-skills/SKILL.md`의 목록 번호 결함(`1,3,4,5,6`)과 `### 4` 중복은 포크 시점 upstream(`4fd9aa2`, 2026-03-24)에도 있던 upstream 결함이었고, upstream이 이후 수정했습니다.

```bash
# 기준 시점 이전의 마지막 upstream 커밋
gh api "repos/obra/superpowers/commits?path=<경로>&until=<ISO8601>&per_page=1" --jq '.[0].sha'
```

구조 대조에는 heading 수 / 목록 항목 수 / 코드펜스 수를 사용합니다. 단, 코드펜스 안의 `# 주석`이 heading으로 오탐되므로 확인이 필요합니다.
