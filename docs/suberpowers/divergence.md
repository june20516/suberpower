# 이 포크의 의도적 Divergence

**upstream을 반영하기 전에 이 문서를 가장 먼저 읽으세요.**

여기 적힌 항목은 이 포크가 upstream([obra/superpowers](https://github.com/obra/superpowers))과 **의도적으로** 다른 지점입니다. 번역 규칙이 "어떻게 옮길까"라면, 이 문서는 **"이 포크가 왜 포크인가"**입니다. 동기화 과정에서 가장 조용히 파괴되는 것이기도 합니다.

```bash
./scripts/check-divergence.sh          # 평소: 자동 검사만
./scripts/check-divergence.sh --sync   # 동기화 후: 전 항목 게이트
```

동기화 작업을 마친 뒤 **반드시** `--sync`로 실행하세요. 실패하면 upstream 변경이 포크의 정체성을 덮어쓴 것입니다.

---

## 정책 종류

upstream 변경을 만났을 때 **무엇을 할지**입니다.

| 정책 | 의미 |
|---|---|
| `NEVER_OVERWRITE` | upstream이 어떻게 바뀌든 이 형태를 유지합니다 |
| `MANUAL_MERGE` | upstream 변경을 자동 적용하지 말고, 사람이 판단해 선별 반영합니다 |
| `TRANSLATE_ON_SYNC` | upstream 변경을 가져오되 이 포크의 규약으로 변환해 적용합니다 |

## 검증 등급

divergence가 **유지되었는지 어떻게 확인할지**입니다. 한 항목이 여러 등급을 가질 수 있습니다.

| 등급 | 동작 | 쓰는 경우 |
|---|---|---|
| `auto` | 스크립트가 통과/실패를 판정 | 문자열·경로·구조처럼 기계로 셀 수 있는 것 |
| `assisted` | 스크립트는 판정하지 않고 **질문을 출력**. 동기화 skill이 subagent에게 근거와 함께 판단을 위임 | 의미·톤·품질처럼 읽어야 아는 것 |
| `manual` | 스크립트가 **확인 필요 항목으로 출력하고 실패**. 사람이 확인했다고 명시해야 통과 | 판단이 갈리고 책임 소재가 사람에게 있는 것 |

**`assisted`와 `manual`은 `--sync` 모드에서 확인(ack) 없이는 통과하지 않습니다.**

```bash
./scripts/check-divergence.sh --sync --ack D-002,D-006
```

이것이 이 계약서의 핵심입니다. 기계로 못 재는 항목이 **조용히 사라지지 않고**, 확인을 강제받습니다.

## 보호 구역 마커

의미적 divergence를 기계 검사로 바꾸는 장치입니다. 이 포크가 재작성한 블록을 마커로 감싸면, 마커 존재 여부를 `auto`로 검증할 수 있습니다.

```markdown
<!-- DIVERGENCE:D-00N start -->
…이 포크가 재작성한 내용…
<!-- DIVERGENCE:D-00N end -->
```

스크립트는 마커의 짝이 맞는지, 그리고 마커의 ID가 이 문서에 등록되어 있는지 확인합니다. 내용까지 고정하고 싶다면 해시 대조를 추가할 수 있지만, 현재 필요한 곳이 없어 넣지 않았습니다.

---

## D-001 · 네임스페이스 치환

**범위:** `plugins/` 전체
**정책:** `NEVER_OVERWRITE`
**검증 등급:** `auto`

`superpowers` → `suberpower`(플러그인 이름) / `suberpowers`(경로·디렉터리).

**근거:** 원본 `superpowers`와 동시에 활성화하면 SessionStart 훅이 중복 주입됩니다. 이름이 겹치면 어느 쪽이 로드됐는지 구분할 수 없습니다.

**검증:**
- `plugins/`에 `superpowers:` (skill 호출 네임스페이스) → 0건
- `plugins/`에 `docs/superpowers/`, `.superpowers/`, `~/.config/superpowers/`, `~/.claude/superpowers/` → 0건
- upstream 저장소 식별자(`obra/superpowers` — 원작자 링크 `github.com/obra/superpowers`, `gh --repo obra/superpowers`, 검색어 `repo:obra/superpowers` 포함)는 저장소를 가리키는 이름이므로 **검사에서 제외** (스크립트는 `obra/superpowers`가 든 줄을 제외)
- 외부 브랜드 자산 URL(brainstorming `server.cjs`의 로고 이미지 `primeradiant.com/brand/superpowers-visual-brainstorming-logo.png`)은 바꾸면 자산이 깨지므로 **검사에서 제외** (스크립트는 이 파일명이 든 줄만 제외)
- 그 외 `superpowers` 문자열은 아래 3곳만 허용 (브랜드성 표현 + 출처 설명)

| 위치 | 내용 |
|---|---|
| `hooks/session-start:2` | 주석 `SessionStart hook for superpowers plugin (suberpower fork)` |
| `hooks/session-start:35` | 주입 문구 `You have superpowers. (이 포크: suberpowers)` |
| `.claude-plugin/plugin.json` | `superpowers 스킬 라이브러리의 한국어 포크: …` |

> 브랜드성 일반 표현은 원문을 살리되 **이 포크임을 괄호로 부연**합니다. 설계 근거는 [2026-06-10 spec](./specs/2026-06-10-worktree-skill-improvement-design.md)의 4-C 참조.

---

## D-002 · `using-git-worktrees` 전면 재작성과 전역 worktree 경로 인식

**범위:** `plugins/suberpower/skills/using-git-worktrees/SKILL.md`, `plugins/suberpower/skills/finishing-a-development-branch/SKILL.md` (전역 경로 인식 블록)
**정책:** `MANUAL_MERGE`
**검증 등급:** `auto` + `manual`

upstream의 native 위임 방식을 걷어내고 **git 직접 조작**으로 재작성했습니다. worktree를 프로젝트 밖 전역 경로에 만들고, base 브랜치와 이름을 사용자에게 확인하는 단계를 신설했습니다.

**근거:** 프로젝트 내부에 worktree를 만들면 메인 repo의 `git status`/`diff`가 오염됩니다. 랜덤 브랜치명 생성과 base 브랜치 임의 선택도 개인 워크플로우와 맞지 않았습니다.

`finishing-a-development-branch`는 "이 worktree를 우리가 만들었는가"(provenance)로 정리 여부를 정합니다. upstream은 v6.0.0에서 전역 경로를 이 판정에서 뺐지만, 이 포크는 worktree를 전역 경로에 만들므로 판정이 `~/.claude/suberpowers/worktrees/`를 인식하지 못하면 이 포크가 만든 worktree가 정리되지 않습니다. 그래서 Step 6의 판정 블록을 D-002 보호 구역 마커로 감쌉니다. 합리화 표의 정리 대상 행(마커 밖)도 같은 경로 목록을 유지합니다. upstream이 Step 6 조건 문장을 바꾸면 새 문장에 전역 경로(`~`·`$HOME` 병기)를 다시 넣습니다.

**검증 (`auto`):** 아래 마커가 모두 존재해야 합니다.
- `~/.claude/suberpowers/worktrees/` (전역 경로 고정)
- `Step 0: Detect Existing Isolation` (기존 isolation 감지)
- `git worktree add` (git 직접 조작)
- finishing-a-development-branch에 `~/.claude/suberpowers/worktrees/` 존재 (+ D-002 마커 짝, 마커 구역 안의 `WORKTREE_PATH` 조건 줄에 경로가 있음)
- finishing-a-development-branch 합리화 표 행(`|`로 시작하는 줄)에 `~/.claude/suberpowers/worktrees/` 존재

**검증 (`manual`):** 이번 동기화에서 upstream이 이 범위를 변경했다면, 사람이 변경 의도를 읽고 반영 여부를 판단했는가?

**동기화 시:** upstream이 이 범위를 바꿔도 **자동 적용하지 마세요.** 변경 의도를 읽고, 이 포크의 재작성본에 반영할 가치가 있는 것만 손으로 옮깁니다.

---

## D-003 · description 규약

**범위:** 모든 `plugins/suberpower/skills/*/SKILL.md`
**정책:** `TRANSLATE_ON_SYNC`
**검증 등급:** `auto`

upstream은 `"Use when..."`으로 **시작**합니다. 이 포크는 **한국어로 트리거 조건을 서술하고 `사용`을 포함**합니다. 트리거 절 뒤에 대시로 부연을 붙이는 형태도 사용합니다.

```yaml
# ✅ 현재 세션에서 독립적인 task로 구성된 implementation plan을 실행할 때 사용합니다
# ✅ 모든 대화를 시작할 때 사용합니다 - skill을 찾고 사용하는 방법을 확립하며, …
# ❌ Use when executing implementation plans with independent tasks
# ❌ plan 실행 시 사용 - task마다 subagent를 dispatch하고 code review 수행   (워크플로우 요약 금지)
```

**근거:** description은 skill 선택에 직접 쓰입니다. 포크 전체가 한국어인데 description만 영어면 트리거 판단이 어긋납니다.

**검증:** 모든 SKILL.md의 `description`이
- 한글을 포함하고
- `사용`을 포함하며
- `Use when`으로 시작하지 않음

---

## D-004 · 플러그인 식별자

**범위:** `plugins/suberpower/.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`
**정책:** `NEVER_OVERWRITE`
**검증 등급:** `auto`

플러그인 이름은 `suberpower`, skill 호출 네임스페이스는 `suberpower:<skill-name>`, `using-superpowers` skill은 `using-suberpowers`로 rename되어 있습니다.

**근거:** D-001과 동일 — 원본과의 공존 및 식별.

**검증:**
- `plugin.json`의 `name` == `suberpower`
- `marketplace.json`의 플러그인 `name` == `suberpower`
- `skills/using-suberpowers/` 존재, `skills/using-superpowers/` 부재

---

## D-005 · 한국어 번역 유지

**범위:** 모든 `plugins/suberpower/skills/*/SKILL.md`
**정책:** `TRANSLATE_ON_SYNC`
**검증 등급:** `auto` + `assisted`

이 포크의 존재 이유입니다. upstream 파일을 번역 없이 그대로 덮어쓰면 즉시 파손됩니다.

**근거:** 동기화 중 가장 흔한 사고가 "upstream 파일을 그대로 복사"입니다. 이 검사가 그것을 잡습니다.

**검증 (`auto`):** 각 SKILL.md의 한글 문자 수가 **400자 이상** (현재 최솟값 531자, `requesting-code-review`).

**검증 (`assisted`):** 새로 번역한 부분의 한국어가 자연스러운가? 직역투·비문·용어 불일치가 없는가?

번역 규칙 전문은 [translation-glossary.md](./translation-glossary.md)를 참조하세요.

---

## D-006 · 강조 계층 보존

**범위:** 모든 번역 대상 문서
**정책:** `TRANSLATE_ON_SYNC`
**검증 등급:** `assisted`

영어는 대문자를 강조 등급으로 쓰지만 한국어에는 대소문자가 없습니다. 그대로 옮기면 최상위 경고가 평서문으로 내려앉아 **지시의 구속력이 실제로 약해집니다.** 원문의 등급을 서식으로 복원합니다.

| 등급 | 표기 |
|---|---|
| 최상위 | 영문 대문자 토큰 유지 (`IMPORTANT:`, `CRITICAL:`) |
| 상위 | 영문 라벨 + 대시 (`STOP - …`, `DO NOT:`) |
| 중간 | 굵게 (`**절대**`, `**반드시**`) |

**근거:** `CRITICAL:` → `중요:`, `Never silently produce…` → `…내놓지 마세요`로 옮겼다가 subagent 지시문의 구속력이 낮아진 사례가 있습니다. 어휘는 정확했지만 등급이 한 단계 내려앉았습니다.

**왜 `assisted`인가:** 토큰 개수를 세는 것만으로는 부족합니다. 원문의 어느 문장이 어느 등급이었는지, 번역이 그 등급을 유지했는지는 **읽어야 압니다.**

**검증 (`assisted`):** 이번에 번역한 부분에서, 원문의 강조 등급이 유지되었는가? 대문자 강조가 평서문으로 풀린 곳은 없는가?

상세 규칙은 [translation-glossary.md 2절](./translation-glossary.md#2-강조-계층-보존-중요)을 참조하세요.

---

## D-007 · 산문만 번역

**범위:** 모든 번역 대상 문서
**정책:** `TRANSLATE_ON_SYNC`
**검증 등급:** `assisted`

산문은 한국어로 옮기되, **구조와 기술 어휘는 영문으로 둡니다.** `##` heading, 기술 용어(skill·subagent·commit·test), 상태값(`DONE`/`BLOCKED`), 의사코드 제어 키워드는 영문 유지입니다.

**근거:** 상태값이나 heading을 번역하면 다른 파일의 참조가 깨집니다. 기술 용어를 음차하면 오히려 읽기 어려워집니다.

**왜 `assisted`인가:** "이 단어가 기술 용어인가 일반 명사인가"는 문맥 판단입니다. `context`(LLM) / `맥락`(일반 배경) 구분이 대표적입니다. 기계로는 못 가릅니다.

**검증 (`assisted`):** 번역하지 말아야 할 것을 번역하지 않았는가? 용어집의 대응표를 따랐는가? 반대로, 번역해야 할 산문이 영문으로 남지 않았는가?

용어 대응표는 [translation-glossary.md 3절](./translation-glossary.md#3-용어-대응표)을 참조하세요.

---

## D-008 · diagnosing 이슈 흐름 (upstream→포크 검색, 포크 우선 보고)

**범위:** `plugins/suberpower/skills/diagnosing-suberpowers/references/github-issues.md` (본문 전체), `plugins/suberpower/skills/diagnosing-suberpowers/SKILL.md` (5단계 GitHub issues, 엄격한 규칙의 승인 관문, 위험 신호 표의 "upstream에 바로 올리자" 행)
**정책:** `MANUAL_MERGE`
**검증 등급:** `auto` + `manual`

upstream은 `obra/superpowers`에서 검색하고 일치가 없으면 그곳에 바로 issue를 만듭니다. 이 포크는 흐름을 이렇게 바꿨습니다.

1. 검색: upstream(`obra/superpowers`)을 먼저, 그다음 포크(`june20516/suberpower`)를 같은 검색어로 검색
2. 보고는 포크 쪽이 기본: upstream에서 일치해도 일치한 포크 issue에 덧붙이거나, 없으면 포크에 새로 생성 (라벨·`diagnosis_report.md` 템플릿 없음, 내용은 한국어 가능, upstream에서만 일치했다면 그 링크를 본문에 기재)
3. upstream 보고: 포크 쪽 기록이 생긴 뒤, report가 인용한 증거와 D-항목 범위가 겹치는지 사실만 밝히고(원인 판단·권고 없음) **선택 동작**으로만 제안 — 일치한 upstream issue에 comment 또는 새 issue. 승인하면 영어로 옮긴 별도 본문을 보여 주고 **별도 승인** 후 게시 (한국어 포크에서 관찰했다는 사실과 포크 issue 링크 명시, 새 issue는 upstream 원문 양식 heading 사용)

github-issues.md 본문, SKILL.md 5단계, SKILL.md 승인 관문은 D-008 보호 구역 마커(start·end 한 쌍)로 감쌌습니다. 위험 신호 행은 표 안이라 마커를 두면 표가 끊기므로 행 문자열 검사로 보호합니다.

**근거:** 포크를 쓰다가 생긴 문제는 번역이나 포크 고유 수정(이 문서의 D-항목)이 원인일 수 있습니다. upstream에 바로 보고하면 원작자에게 오보가 될 위험이 있습니다. upstream 보고는 영어로, 선택 동작으로, 별도 승인을 받아서만 합니다 — 2026-10-07 사용자 결정.

**검증 (`auto`):**
- `github-issues.md`와 `SKILL.md` 각각에 D-008 마커 짝이 맞음
- SKILL.md D-008 보호 구역 안에 `포크 issue 승인은 upstream 보고 승인이 아닙니다` 존재 (승인 관문)
- SKILL.md 위험 신호 표 행(`|`로 시작하는 줄)에 `upstream에 바로 올리자` 존재
- `github-issues.md`에 `june20516/suberpower` 존재
- `github-issues.md`에 `**별도로** 다시 승인` 존재 (upstream 별도 승인 관문)
- `github-issues.md`에 `## 검색` 절이 있고, 그 절에서 `obra/superpowers`가 `june20516/suberpower`보다 먼저 등장

**검증 (`manual`):** 이번 동기화에서 upstream이 diagnosing의 `github-issues.md`나 SKILL.md 5단계를 변경했다면, 사람이 변경 의도를 읽고 upstream 보고 경로에 반영했는가?

**동기화 시:** upstream이 `github-issues.md`나 SKILL.md 5단계를 바꿔도 **자동 적용하지 마세요.** 바뀐 명령·플래그·URL·한계(예: 8,000자, 라벨, 템플릿 이름)는 upstream 보고 경로(`## upstream 보고 (선택)`)와 upstream 검색에만 옮기고, 포크 경로에는 포크에 실제로 있는 것만 반영합니다. 검색 순서(upstream → 포크), 포크 우선 생성, upstream 보고의 선택·영어·별도 승인은 유지합니다. upstream 양식(`templates/issue.md`)의 heading이 바뀌면 `## upstream 보고 (선택)`이 인용하는 원문 heading도 함께 고칩니다.

---

## 항목 추가 방법

새 divergence가 생기면:

1. 이 문서에 `D-00N` 항목 추가 — **범위 / 정책 / 검증 등급 / 근거 / 검증 방법**
2. 등급별로 처리:
   - `auto` → `scripts/check-divergence.sh`에 검사 함수 추가
   - `assisted` → 스크립트의 `ASSISTED_ITEMS`에 질문 등록
   - `manual` → 스크립트의 `MANUAL_ITEMS`에 확인 항목 등록
3. `./scripts/check-divergence.sh --sync --ack <필요한 ID>`로 통과 확인 후 commit

**근거를 반드시 적으세요.** 근거 없는 divergence는 나중에 "upstream과 다르네" 하며 되돌려집니다.

**기계로 못 잰다고 등급을 생략하지 마세요.** 등급 없는 항목은 스크립트에서 사라지고, 사라진 divergence는 다음 동기화에서 조용히 파괴됩니다. 최소한 `assisted`로 등록해 질문이라도 남기세요.
