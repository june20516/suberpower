# 번역 용어집 및 표기 규칙

이 포크(suberpower)가 upstream [obra/superpowers](https://github.com/obra/superpowers)를 한국어로 옮길 때 따르는 규칙입니다. upstream 변경분을 새로 반영할 때 이 문서를 기준으로 삼습니다.

---

## 1. 기본 원칙

**산문만 번역하고, 구조와 기술 어휘는 영문으로 둡니다.**

| 대상 | 처리 | 예 |
|---|---|---|
| 산문 | 한국어 | 본문 설명, 목록 항목, 표 내용 |
| `##` heading | **영문 유지** | `## Overview`, `## When to Use` |
| 기술 용어 | **영문 유지** | skill, subagent, commit, test, mock, edge case, dispatch |
| 상태값 | **영문 유지** | `DONE`, `BLOCKED`, `NEEDS_CONTEXT`, `DONE_WITH_CONCERNS` |
| 의사코드 제어 키워드 | **영문 + 대시** | `BEFORE - …하기 전:`, `IF …라면:`, `STOP - …` |

영문 뒤에는 조사를 그대로 붙입니다: `dispatch하고`, `commit하세요`, `review하며`.

### description 작성 규칙

`"...할 때 사용합니다"`로 **끝맺습니다**. (upstream은 `"Use when..."`으로 시작하는 형식)

```yaml
# ✅ 현재 세션에서 독립적인 task로 구성된 implementation plan을 실행할 때 사용합니다
# ❌ plan 실행 시 사용 - task마다 subagent를 dispatch하고 code review 수행  (워크플로우 요약 금지)
```

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
| your human partner | `your human partner` | `사람 파트너` 사용 안 함 |
| synthesis | `종합` | `합성`(화학) 금지 |
| academic (비판적 맥락) | `이론적` / `탁상공론식` | `학술적` 금지 |
| systematic errors | `같은 실수를 일관되게 반복` | `체계적인 오류` 금지 (반대 인상) |
| shared resource | `공유 자원` | `공공재` 금지 (경제학 용어, 의미 반대) |
| voice (인칭) | `인칭` | `시점` 금지 (時點으로 읽힘) |
| source of truth | `기준점` | |
| over/under-building | `과잉 구현과 구현 누락` | |
| scene-setting | `배경 설명` | `장면 설정` 금지 |

---

## 4. 번역하지 않는 것

- **코드**와 식별자, 파일 경로, 명령어
- **실제 코드에 존재하는 test 제목** — `"should abort tool with partial output capture"`
- **테스트 러너가 출력하는 문자열** — `FAIL: expected 'Email required', got undefined`
- **철의 법칙(Iron Law)** — `NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST` 등 3종 (파일 간 통일)
- **고유명사** — `Visual Companion`, `Brainstorm Companion`, skill 이름(`writing-plans`)
- **gerund 네이밍 규칙 예시** — `"Processing PDFs"` 등. 영어 `-ing` 형태를 가르치는 내용이라 한국어 대응이 없음
- **Conventional Commits 예시** — `feat(auth): implement JWT-based authentication`
- **약속된 신호 문구** — `"Strange things are afoot at the Circle K"`
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

## 7. 의도적 divergence (동기화 시 덮어쓰지 말 것)

upstream을 반영할 때 아래는 이 포크의 커스터마이징이므로 보존합니다.

| 대상 | 내용 |
|---|---|
| 네임스페이스 | `superpowers` → `suberpower` (플러그인), `suberpowers` (경로/디렉터리) |
| skill 호출 | `suberpower:<skill-name>` |
| `using-git-worktrees/SKILL.md` | 전면 재작성 — native 위임 대신 git 직접 조작, 전역 경로 고정, base/이름 질문 단계 |
| 경로 | `docs/superpowers/` → `docs/suberpowers/`, `~/.claude/suberpowers/` |
| 브랜드 표기 | `Suberpowers`, 원작자 표기 유지 |
| description 형식 | `"...할 때 사용합니다"` (upstream은 `"Use when..."`) |

---

## 8. upstream 비교 시 기준

**반드시 "포크 시점의 upstream"과 비교합니다. 현재 `main`과 비교하면 안 됩니다.**

upstream이 그 사이 스스로 고친 것을 "포크의 번역 결함"으로 오판하게 됩니다. 실제로 그런 오판이 있었습니다 — `writing-skills/SKILL.md`의 목록 번호 결함(`1,3,4,5,6`)과 `### 4` 중복은 포크 시점 upstream(`4fd9aa2`, 2026-03-24)에도 있던 upstream 결함이었고, upstream이 이후 수정했습니다.

```bash
# 기준 시점 이전의 마지막 upstream 커밋
gh api "repos/obra/superpowers/commits?path=<경로>&until=<ISO8601>&per_page=1" --jq '.[0].sha'
```

구조 대조에는 heading 수 / 목록 항목 수 / 코드펜스 수를 사용합니다. 단, 코드펜스 안의 `# 주석`이 heading으로 오탐되므로 확인이 필요합니다.
