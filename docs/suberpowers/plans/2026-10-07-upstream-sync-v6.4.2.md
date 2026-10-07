# Upstream 동기화 (v6.4.2) Implementation Plan

> **agentic worker에게:** REQUIRED SUB-SKILL: 이 plan을 task 단위로 구현하려면 suberpower:subagent-driven-development(권장) 또는 suberpower:executing-plans를 사용하세요. Step은 추적을 위해 checkbox(`- [ ]`) 문법을 사용합니다.

**Goal:** 포크를 upstream obra/superpowers 최신 정식 릴리스 **v6.4.2**(`8ca22db`)에 동기화하고, 완화책 M-1~M-3을 upstream 설계로 대체한다.

**Architecture:** upstream을 로컬 ref로 가져와 baseline(`6fd4507`)→v6.4.2 변경을 skill 단위로 반영한다. 마크다운은 v6.4.2 원문을 기준으로 번역하되 바뀌지 않은 문단은 기존 포크 번역을 재사용하고, 코드(스크립트)는 `git merge-file`로 3-way 병합해 포크의 한국어 UI·네임스페이스 치환을 보존한다. 의도적 divergence는 `scripts/check-divergence.sh --sync`로 게이트한다.

**Tech Stack:** Markdown, bash, Node.js(brainstorming server), git

---

## 결정 사항 (2026-10-07 사용자 확정)

| 항목 | 결정 |
|---|---|
| 동기화 대상 | v6.4.2 (`8ca22db`, 2026-09-25). upstream `main` == v6.4.2, 미릴리스 커밋 없음 |
| M-1·M-2·M-3 | 전부 제거하고 upstream 방식을 따른다. 근거: Claude Code 2.1.257에서 subagent 스트림 중단 자동 이어가기 수정 배포, 로컬 실측 2.1.257+ subagent 341회 중 해당 증상 0건. #75318은 open(stale)이지만 실질 해결로 판단 |
| D-002 (worktree) | **포크 우선.** `using-git-worktrees`는 upstream 변경을 반영하지 않는다. `finishing-a-development-branch`의 전역 worktree 경로 인식도 보존한다 |
| 그 외 skill | upstream 그대로 번역 반영 |
| diagnosing skill 이슈 흐름 | 중복 검색은 upstream(`obra/superpowers`) → 포크(`june20516/suberpower`) 순. 신규 보고는 포크에 먼저 하고, 포크 이슈를 검토한 뒤 같은 내용을 영어로 옮겨 upstream에도 보고하는 것을 **선택 동작**으로 제안 |
| 실행 방식 | Subagent-Driven |
| 버전 | `1.3.0` → `2.0.0` (reviewer prompt 파일 삭제·`executing-plans` 동작 변경으로 하위 호환 깨짐) |

## Global Constraints

모든 task에 그대로 적용된다.

1. **네임스페이스 치환 (D-001)** — upstream 문자열을 다음과 같이 바꾼다. upstream 저장소 식별자 `obra/superpowers`(URL·`gh --repo` 인자 모두)는 바꾸지 않는다.

   | upstream | 포크 |
   |---|---|
   | `superpowers:<skill>` | `suberpower:<skill>` |
   | `using-superpowers` | `using-suberpowers` |
   | `docs/superpowers/` | `docs/suberpowers/` |
   | `.superpowers/` (repo 내 작업 공간, 예: `.superpowers/sdd/`) | `.suberpowers/` |
   | `~/.superpowers/` | `~/.claude/suberpowers/` |
   | `~/.config/superpowers/` | `~/.claude/suberpowers/` |
   | 브랜드 표현 `Superpowers` | `Superpowers(suberpowers 포크)` — 문서당 첫 등장만 부연, 이후 `suberpowers` |

   bare 소문자 `superpowers`는 `plugins/` 전체에서 기존 허용 3곳 외에 새로 생기면 안 된다.
2. **번역 규칙** — `docs/suberpowers/translation-glossary.md` 전체를 따른다. 특히: 산문만 번역(heading·기술 용어·상태값·코드 유지), 강조 등급 보존(`CRITICAL:`/`IMPORTANT:` 영문 유지, `STOP -`, `DO NOT:`), subagent 지시문은 명령형, 용어 대응표(review·context·escalate 등).
3. **description (D-003)** — 한국어 트리거 조건 + `사용` 포함, `Use when`으로 시작 금지, 워크플로우 요약 금지.
4. **기존 번역 재사용** — upstream 문단이 baseline과 같으면 포크의 기존 번역을 그대로 쓴다. 바뀐 문단만 새로 번역한다. 같은 영어 문단이 여러 파일에 있으면 한 정본 번역을 공유한다.
5. **스크립트·코드 파일** — 주석과 사용자 노출 문자열의 번역 여부는 같은 디렉터리 기존 포크 파일의 관례를 따른다 (brainstorming UI는 한국어화되어 있음, 쉘 스크립트 주석은 포크에 선례 없음 → 영어 유지). 실행 권한(`chmod +x`)은 upstream과 같게 유지한다.
6. **D-002 보호** — `plugins/suberpowers/skills/using-git-worktrees/SKILL.md`는 수정하지 않는다. 다른 skill이 upstream 원문에서 프로젝트 내 `.worktrees/` 생성을 전제로 서술하면, 포크의 전역 경로(`~/.claude/suberpowers/worktrees/`) 서술로 맞춘다.
7. **commit** — skill(또는 Task) 단위로 commit. 메시지는 기존 관례대로 한국어 `동기화: <대상> (v6.4.2)` 형식. 끝에 attribution 두 줄을 붙인다.

## Interfaces

| 이름 | 생성 | 소비 | 계약 |
|---|---|---|---|
| `upstream-v6.4.2` / `upstream-base` (로컬 tag) | Task 0 | 전 Task | upstream v6.4.2와 baseline `6fd4507`. `git show upstream-v6.4.2:skills/<path>`로 원문을 읽는다 |
| `sdd-workspace PLAN_FILE` | Task 2 | Task 2·3 | 출력: `<repo-root>/.suberpowers/sdd/<slug>/` 절대경로 |
| `task-brief PLAN_FILE N [OUTFILE]` | Task 2 | Task 2·3 | 기본 OUTFILE `.suberpowers/sdd/<slug>/task-<N>-brief.md` |
| `review-package PLAN_FILE BASE HEAD [OUTFILE]` | Task 2 | Task 2·5 | 기본 OUTFILE `.suberpowers/sdd/<slug>/review-<base7>..<head7>.diff`, 비정상 범위는 exit 3 |
| `task-start PLAN_FILE N` / `task-done PLAN_FILE N BASE -- CMD...` | Task 3 | Task 3 | upstream과 동일. `task-start`는 `../../subagent-driven-development/scripts/task-brief` 경로로 호출 |
| `scripts/sync-structure-check.sh <fork-file> <upstream-path>` | Task 0 | 전 Task 검증 | heading 수·코드펜스 수·목록 항목 수를 나란히 출력하고 heading/코드펜스 수가 다르면 exit 1 |

---

### Task 0: 준비 — upstream ref와 구조 비교 도구

**Files:**
- Create: `scripts/sync-structure-check.sh`

- [ ] **Step 1: upstream ref 가져오기**

```bash
git fetch --no-tags https://github.com/obra/superpowers.git \
  refs/tags/v6.4.2:refs/tags/upstream-v6.4.2
git tag upstream-base 6fd4507659784c351abbd2bc264c7162cfd386dc
git rev-parse --short "upstream-v6.4.2^{commit}"   # 기대: 8ca22db (annotated tag라 ^{commit} 필요)
```

로컬 tag는 push하지 않는다 (`git push --tags` 금지).

- [ ] **Step 2: 반영 대상 목록 확인**

```bash
git diff --stat=200 upstream-base upstream-v6.4.2 -- skills hooks | cat
```

기대: `72 files changed` (`.claude-plugin/*` 포함 시). 이 목록이 Task 1~13의 범위다.

- [ ] **Step 3: 구조 비교 스크립트 작성**

`scripts/sync-structure-check.sh <fork-file> <upstream-path>`:
- upstream 원문은 `git show upstream-v6.4.2:<upstream-path>`로 읽는다
- 코드펜스 밖의 `^#{1,6} ` 줄 수, 코드펜스(```` ``` ````) 줄 수, 코드펜스 밖의 목록 항목(`^\s*([-*]|[0-9]+\.) `) 수를 양쪽에서 세어 표로 출력
- heading 수나 코드펜스 수가 다르면 exit 1, 목록 수 차이는 경고만

- [ ] **Step 4: 스크립트 동작 확인**

```bash
chmod +x scripts/sync-structure-check.sh
scripts/sync-structure-check.sh plugins/suberpower/skills/using-git-worktrees/SKILL.md skills/using-git-worktrees/SKILL.md; echo "exit $?"
```

기대: D-002 재작성 파일이므로 heading 수가 달라 `exit 1`. 같은 내용의 파일(`git show upstream-v6.4.2:skills/brainstorming/spec-document-reviewer-prompt.md > /tmp/x.md` 후 자기 자신과 비교)은 `exit 0`.

- [ ] **Step 5: Commit**

```bash
git add scripts/sync-structure-check.sh
git commit -m "동기화 준비: upstream 대비 구조 비교 스크립트 추가"
```

---

### Task 1: 완화 추적 인프라 종료 (M-1~M-3, M-4)

**Files:**
- Modify: `docs/suberpowers/MITIGATIONS.md`
- Delete: `.github/workflows/upstream-fix-tracker.yml`, `scripts/check-upstream-fixes.sh`

skill 본문의 M-1~M-3 내용은 Task 2·5에서 upstream 원문으로 교체되며 사라진다. 이 Task는 등록부와 자동화만 정리한다.

- [ ] **Step 1: 등록부 갱신** — 표의 M-1~M-3 행과 duplicate 리포트 언급 줄을 삭제하고, 표 위에 "현재 등록된 완화 없음"을 적는다. 문서 끝에 `## 종료된 완화` 섹션을 추가해 한 줄씩 기록한다: `M-1~M-3 (anthropics/claude-code#75318) — 2026-10-07 종료. Claude Code 2.1.257 수정 + 로컬 실측(2.1.257+ subagent 341회 중 증상 0건). upstream v6.4.2의 파일 핸드오프·리뷰 흐름으로 대체.` 새 완화를 추가할 때는 워크플로우와 스크립트를 git 이력(`git show e2e0d33:scripts/check-upstream-fixes.sh`)에서 복원하라는 안내 한 줄을 남긴다.
- [ ] **Step 2: 자동화 삭제**

```bash
git rm .github/workflows/upstream-fix-tracker.yml scripts/check-upstream-fixes.sh
```

- [ ] **Step 3: 잔여 참조 확인**

```bash
grep -rn "check-upstream-fixes\|upstream-fix-tracker" --exclude-dir=.git . | grep -v "docs/suberpowers/plans/"
```

기대: `MITIGATIONS.md`의 복원 안내 줄만 남음.

- [ ] **Step 4: Commit** — `정리: 완화 M-1~M-3 종료 및 추적 자동화 제거`

---

### Task 2: subagent-driven-development

**Files:**
- Modify: `plugins/suberpower/skills/subagent-driven-development/SKILL.md` (upstream +617줄 규모 재구성 — 사실상 새 번역)
- Modify: `plugins/suberpower/skills/subagent-driven-development/implementer-prompt.md`
- Create: `.../subagent-driven-development/task-reviewer-prompt.md`, `re-review-prompt.md`
- Create: `.../subagent-driven-development/scripts/sdd-workspace`, `task-brief`, `review-package`
- Delete: `.../subagent-driven-development/spec-reviewer-prompt.md`, `code-quality-reviewer-prompt.md`

- [ ] **Step 1: 스크립트 3개 반영** — `git show upstream-v6.4.2:skills/subagent-driven-development/scripts/<name>`을 그대로 옮기고 `.superpowers/` → `.suberpowers/` 치환만 한다 (주석 포함). `chmod +x`.
- [ ] **Step 2: 스크립트 smoke test**

```bash
S=plugins/suberpower/skills/subagent-driven-development/scripts
for f in $S/*; do bash -n "$f" && echo "ok $f"; done
P=docs/suberpowers/plans/2026-10-07-upstream-sync-v6.4.2.md
$S/sdd-workspace "$P"             # 기대: .../.suberpowers/sdd/2026-10-07-upstream-sync-v6.4.2 로 끝나는 절대경로
$S/task-brief "$P" 0 && head -3 "$($S/sdd-workspace "$P")/task-0-brief.md"   # 기대: "### Task 0: 준비" 줄
$S/review-package "$P" HEAD HEAD; echo "exit $?"   # 기대: exit 3 (빈 범위 거부)
git status --short .suberpowers   # 기대: 출력 없음 (self-ignoring)
rm -rf .suberpowers
```

- [ ] **Step 3: 삭제** — `git rm` spec-reviewer-prompt.md, code-quality-reviewer-prompt.md.
- [ ] **Step 4: prompt 3개 번역** — `implementer-prompt.md`(기존 번역 재사용 + 변경분), `task-reviewer-prompt.md`, `re-review-prompt.md`(신규). subagent 지시문이므로 명령형·강조 등급 보존. 스크립트 경로·변수 placeholder(`[PLAN_FILE]` 등)는 원문 유지.
- [ ] **Step 5: SKILL.md 번역** — v6.4.2 원문 전체를 번역한다. 포크의 `## Subagent 실패 처리 (완화 M-2 …)`, `## 리뷰 범위 분할 (완화 M-3)` 섹션과 REPORT_FILE·`~/.claude/suberpowers/reviews/` 언급은 원문에 없으므로 남기지 않는다. worktree 언급은 Global Constraint 6을 따른다.
- [ ] **Step 6: 검증**

```bash
for f in SKILL.md implementer-prompt.md task-reviewer-prompt.md re-review-prompt.md; do
  scripts/sync-structure-check.sh plugins/suberpower/skills/subagent-driven-development/$f skills/subagent-driven-development/$f || echo "MISMATCH $f"
done
grep -rn "suberpowers/reviews\|75318\|리뷰 범위 분할\|Subagent 실패 처리\|spec-reviewer-prompt\|code-quality-reviewer-prompt\|M-2\|M-3" plugins/
```

기대: MISMATCH 없음, grep 출력 없음 (Task 5 완료 전이면 `requesting-code-review`의 M-1 잔여는 허용 — Task 5에서 제거).

- [ ] **Step 7: Commit** — `동기화: subagent-driven-development (v6.4.2) — 단일 task reviewer·파일 핸드오프, M-2/M-3 제거`

---

### Task 3: executing-plans

**Files:**
- Modify: `plugins/suberpower/skills/executing-plans/SKILL.md` (70줄 → Native 실행 모드 재구축)
- Create: `.../executing-plans/scripts/task-start`, `task-done`

- [ ] **Step 1: 스크립트 반영** — 원문 복사 + `.superpowers/` 치환, `chmod +x`, `bash -n` 통과 확인.
- [ ] **Step 2: smoke test**

```bash
E=plugins/suberpower/skills/executing-plans/scripts
P=docs/suberpowers/plans/2026-10-07-upstream-sync-v6.4.2.md
$E/task-start "$P" 0          # 기대: "brief: …/task-0-brief.md" 와 "base: <40자 SHA>" 두 줄
B=$(git rev-parse HEAD); $E/task-done "$P" 0 "$B" -- echo "1 passed"; echo "exit $?"    # 기대: exit 0, ledger(progress.md)에 완료 줄 추가 (출력 없는 명령은 upstream 결함으로 exit 1)
$E/task-done "$P" 0 "$B" -- false; echo "exit $?"   # 기대: exit 1, ledger 변화 없음
rm -rf .suberpowers
```

- [ ] **Step 3: SKILL.md 번역** — 새로 번역. Native/Subagent-driven 용어는 영문 유지. 구조 검증 후 commit — `동기화: executing-plans (v6.4.2) — Native 실행 모드`

---

### Task 4: writing-plans

**Files:**
- Modify: `plugins/suberpower/skills/writing-plans/SKILL.md`
- Delete: `plugins/suberpower/skills/writing-plans/plan-document-reviewer-prompt.md`

- [ ] **Step 1:** `git rm` plan-document-reviewer-prompt.md. 다른 파일이 참조하는지 `grep -rn "plan-document-reviewer" plugins/` — 기대: 출력 없음.
- [ ] **Step 2:** SKILL.md 번역 반영. Global Constraints·Interfaces·Review Focus·`Spec:` 포인터·"What a Step Contains" 섹션 포함. plan 저장 경로는 `docs/suberpowers/plans/`.
- [ ] **Step 3:** 구조 검증 → commit — `동기화: writing-plans (v6.4.2) — 결정 중심 plan`

---

### Task 5: requesting-code-review · receiving-code-review

**Files:**
- Modify: `plugins/suberpower/skills/requesting-code-review/SKILL.md`, `code-reviewer.md`
- Modify: `plugins/suberpower/skills/receiving-code-review/SKILL.md`

- [ ] **Step 1:** 세 파일을 v6.4.2 기준으로 반영. requesting-code-review의 M-1 내용(REPORT_FILE 계약, `~/.claude/suberpowers/reviews/`, 3줄 최종 메시지)은 원문에 없으므로 제거된다. `BASE_SHA` 대안은 `git merge-base origin/main HEAD`. 포크 requesting-code-review/SKILL.md에 남은 삭제된 SDD 섹션(`리뷰 범위 분할`·`Subagent 실패 처리`) 참조도 원문 기준 교체로 사라져야 한다. 용어는 translation-glossary.md 3절(Task 2에서 추가된 지적 사항·수정 라운드 등)을 따른다.
- [ ] **Step 2: 검증**

```bash
grep -rn "suberpowers/reviews\|75318\|리뷰 범위 분할\|Subagent 실패 처리\|M-1" plugins/   # 기대: 출력 없음
```

구조 검증 후 commit — `동기화: code review skill 2종 (v6.4.2), M-1 제거`

---

### Task 6: test-driven-development

**Files:**
- Modify: `plugins/suberpower/skills/test-driven-development/SKILL.md`
- Create: `.../test-driven-development/writing-good-tests.md`
- Delete: `.../test-driven-development/testing-anti-patterns.md`

- [ ] **Step 1:** `git rm` testing-anti-patterns.md, writing-good-tests.md 신규 번역 (GOOD/BAD 예시 코드는 번역하지 않음, 코드 주석은 기존 포크 TDD 파일 관례를 따름).
- [ ] **Step 2:** SKILL.md 반영 — 철의 법칙 문구는 영문 그대로(용어집 4절). `grep -rn "testing-anti-patterns" plugins/` 기대: 출력 없음.
- [ ] **Step 3:** 구조 검증 → commit — `동기화: test-driven-development (v6.4.2)`

---

### Task 7: brainstorming

**Files:**
- Modify: `plugins/suberpower/skills/brainstorming/SKILL.md`, `visual-companion.md`, `spec-document-reviewer-prompt.md`
- Modify: `plugins/suberpower/skills/brainstorming/scripts/server.cjs`, `helper.js`, `start-server.sh`, `stop-server.sh`, `frame-template.html`

- [ ] **Step 1: 스크립트 3-way 병합** — 각 스크립트에 대해:

```bash
F=server.cjs   # helper.js, start-server.sh, stop-server.sh, frame-template.html 반복
git show upstream-base:skills/brainstorming/scripts/$F > /tmp/base-$F
git show upstream-v6.4.2:skills/brainstorming/scripts/$F > /tmp/up-$F
git merge-file plugins/suberpower/skills/brainstorming/scripts/$F /tmp/base-$F /tmp/up-$F; echo "conflicts $?"
```

충돌은 "upstream 로직 + 포크의 한국어 UI 문자열·`suberpowers` 치환"으로 해소한다. 병합 후 upstream이 새로 추가한 사용자 노출 문자열은 한국어로 옮기고, 새 경로 문자열은 D-001 치환한다.
- [ ] **Step 2: 동작 확인**

```bash
cd plugins/suberpower/skills/brainstorming/scripts
node --check server.cjs && node --check helper.js && bash -n start-server.sh && bash -n stop-server.sh
./start-server.sh --project-dir "$(mktemp -d)"   # 기대: JSON 한 줄에 url 포함
```

출력된 url을 `curl -s <url> | grep -c "<title>"`로 확인(기대: 1), 이후 `./stop-server.sh <출력의 screen_dir>`로 종료. 인자 형식은 병합된 `start-server.sh` 상단 사용법을 따른다.
- [ ] **Step 3:** 마크다운 3개 반영 (spike/bounded/architectural 분류 용어는 영문 유지). 구조 검증 → commit — `동기화: brainstorming (v6.4.2)`

---

### Task 8: finishing-a-development-branch (D-002 연동)

**Files:**
- Modify: `plugins/suberpower/skills/finishing-a-development-branch/SKILL.md`
- Modify: `scripts/check-divergence.sh`, `docs/suberpowers/divergence.md`

- [ ] **Step 1:** v6.4.2 기준으로 번역 반영 (Discard 옵션 제거, forge 중립 PR, untracked 파일 보호, provenance 버그 수정 포함). **포크 보존:** worktree 정리 대상 인식 목록에 `~/.claude/suberpowers/worktrees/`를 유지한다 (커밋 `d51996d`의 의도). upstream이 legacy 전역 경로 제거를 근거로 서술한 문장은 포크 전역 경로 기준으로 고쳐 쓴다.
- [ ] **Step 2: 보호 마커** — 전역 경로 인식 블록을 D-002 보호 구역 마커(divergence.md「보호 구역 마커」형식의 start·end 주석 한 쌍)로 감싼다.
- [ ] **Step 3: 검사 확장** — `divergence.md` D-002의 범위에 이 파일을 추가하고 auto 검증 항목 "finishing-a-development-branch에 `~/.claude/suberpowers/worktrees/` 존재"를 적는다. `check-divergence.sh`의 D-002 블록에 같은 검사를 추가한다.
- [ ] **Step 4: 검증**

```bash
./scripts/check-divergence.sh | grep -A6 "D-002"   # 기대: 새 항목 포함 전부 ✅
```

- [ ] **Step 5:** commit — `동기화: finishing-a-development-branch (v6.4.2), 전역 worktree 경로 보존(D-002)`

---

### Task 9: 소규모 변경 skill 묶음

**Files:**
- Modify: `dispatching-parallel-agents/SKILL.md`, `verification-before-completion/SKILL.md`
- Modify: `systematic-debugging/SKILL.md`, `root-cause-tracing.md`, `find-polluter.sh`
- Modify: `writing-skills/SKILL.md`, `anthropic-best-practices.md`, `persuasion-principles.md`, `render-graphs.js`

(모두 `plugins/suberpower/skills/` 하위)

- [ ] **Step 1:** 마크다운은 대부분 삭제 위주(Bottom Line / Key Principles 등 recap 섹션 제거)다. `git diff upstream-base upstream-v6.4.2 -- skills/<path>`의 hunk 단위로 포크 번역본에 같은 변경을 적용한다. writing-skills의 `CSO` → `SDO` 개명, `Match the Form to the Failure` 섹션 추가 포함.
- [ ] **Step 2:** `find-polluter.sh`, `render-graphs.js`는 Task 7 Step 1과 같은 `git merge-file` 방식. 이후 `bash -n find-polluter.sh`, `node --check render-graphs.js`.
- [ ] **Step 3:** find-polluter 동작 확인

```bash
T=$(mktemp -d); mkdir -p $T/src/a; touch $T/src/top.test.ts $T/src/a/x.test.ts
(cd $T && bash "$OLDPWD/plugins/suberpower/skills/systematic-debugging/find-polluter.sh" .nonexistent 'src/**/*.test.ts' 2>&1 | grep -i "found")
```

기대: `Found 2` (top 레벨 포함). 인자 순서는 병합된 스크립트 상단 사용법을 따른다.
- [ ] **Step 4:** 각 마크다운 구조 검증 → commit — `동기화: 소규모 변경 skill 묶음 (v6.4.2)`

---

### Task 10: using-suberpowers와 harness reference

**Files:**
- Modify: `plugins/suberpower/skills/using-suberpowers/SKILL.md`
- Modify: `.../using-suberpowers/references/codex-tools.md`, `gemini-tools.md`
- Create: `.../references/antigravity-tools.md`, `claude-code-tools.md`, `hermes-tools.md`, `muse-tools.md`, `pi-tools.md`
- Delete: `.../references/copilot-tools.md`

upstream 경로는 `skills/using-superpowers/`다.

- [ ] **Step 1:** SKILL.md를 v6.4.2 기준으로 반영 (graphviz 다이어그램 제거, Instruction-Priority 통합, How to Access Skills 축소). 이 파일은 SessionStart 훅이 매 세션 주입하므로 frontmatter와 첫 heading 구조를 바꾸지 않았는지 확인한다.
- [ ] **Step 2:** references 생성·수정·삭제. 표의 도구 이름은 번역하지 않는다. 포크 `gemini-tools.md`의 삭제된 SDD prompt(`spec-reviewer-prompt.md`·`code-quality-reviewer-prompt.md`) 참조는 원문 기준 갱신으로 사라져야 한다.
- [ ] **Step 3: 주입 확인**

```bash
CLAUDE_PLUGIN_ROOT=$PWD/plugins/suberpower plugins/suberpower/hooks/session-start | python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d['hookSpecificOutput']['additionalContext']))"
```

기대: 유효한 JSON, 길이 출력 (기존보다 짧아짐).
- [ ] **Step 4:** commit — `동기화: using-suberpowers와 harness reference (v6.4.2)`

---

### Task 11: diagnosing-suberpowers (신규 skill, 이슈 흐름 개조)

**Files:**
- Create: `plugins/suberpower/skills/diagnosing-suberpowers/` — upstream `skills/diagnosing-superpowers/`의 20개 파일 (SKILL.md, prompts/ 11, references/ 4, templates/ 4)
- Modify: `scripts/check-divergence.sh`, `docs/suberpowers/divergence.md` (D-001 예외 확장, D-008 신설)

upstream 원문의 이슈 흐름: SKILL.md 5단계가 `references/github-issues.md`로 `obra/superpowers`의 open·closed 이슈를 검색 → 일치하면 가장 가까운 이슈에 보고서 덧붙이기를 제안 → 없으면 `templates/issue.md`를 채워 정확한 본문을 보여주고 승인 후 생성.

- [ ] **Step 1: 기본 번역** — 디렉터리명·`name:`을 `diagnosing-suberpowers`로 하고 전 파일 번역. Global Constraint 1 치환에 더해:
  - 작업 공간 `~/.superpowers/diagnosing-superpowers/<session-id>/` → `~/.claude/suberpowers/diagnosing/<session-id>/`
  - transcript에서 skill 호출을 찾는 지시(예: `skill-timeline.md`의 "something other than `superpowers`")는 이 포크 세션을 진단하도록 `suberpower`로 바꾼다
  - templates/의 출력 양식 heading은 영문 유지, 설명 산문만 번역
- [ ] **Step 2: 이슈 흐름 개조 — `references/github-issues.md`를 다음 구조로 재작성한다**
  - `## 저장소` — 두 저장소를 정의: upstream `obra/superpowers`, 포크 `june20516/suberpower`
  - `## Search` — **upstream 먼저, 그다음 포크** 순으로 같은 검색어를 실행한다. 각 저장소에 원문의 gh → curl → URL 3단 fallback을 그대로 적용한다. 결과는 저장소를 구분해 함께 보여준다
  - `## 일치하는 이슈가 있을 때` — upstream 일치가 있으면 그 이슈에 보고서 덧붙이기를 우선 제안하고, 포크 일치가 있으면 포크 이슈에 덧붙이기를 제안한다. 양쪽 모두 일치하면 둘 다 제시하고 your human partner가 고른다
  - `## File` — 일치가 없으면 **포크에 먼저** 생성한다 (`gh issue create --repo june20516/suberpower --title … --body-file …`, 라벨 없음 — 포크에는 `automated-issue-report` 라벨·`diagnosis_report.md` 템플릿이 없음. gh 없을 때 URL은 `https://github.com/june20516/suberpower/issues/new?title=…&body=…`)
  - `## upstream 보고 (선택)` — 포크 이슈 생성 후, 생성된 포크 이슈를 다시 읽어 검토 결과(번역·포크 수정이 원인일 가능성 여부)를 한 줄로 보여주고, **같은 내용을 upstream에도 보고할지 선택 동작으로 제안**한다. upstream 본문은 포크 이슈 내용을 **영어로 옮긴** 것이다 — 영어 본문을 workspace에 파일로 쓰고 정확한 텍스트를 보여준 뒤, 승인 시에만 원문의 upstream 생성 명령(라벨 2개, `template=diagnosis_report.md` URL fallback 포함)으로 생성하고, 본문 끝에 포크 이슈 링크를 붙인다. 승인 없이 upstream에 생성하지 않는다
  - SKILL.md 5단계와 Red Flags의 "승인 전 issue·comment 금지" 문장을 위 순서에 맞게 고쳐 쓴다 (upstream 보고는 별도 승인이 필요하다는 점 명시)
- [ ] **Step 3: 보호 마커와 divergence 등록**
  - 개조한 `github-issues.md` 본문 전체와 SKILL.md 5단계를 D-008 보호 구역 마커(divergence.md「보호 구역 마커」형식의 start·end 주석 한 쌍)로 감싼다
  - `divergence.md`에 `D-008 · diagnosing 이슈 흐름 (upstream→포크 검색, 포크 우선 보고)` 추가 — 정책 `MANUAL_MERGE`, 등급 `auto`(마커 존재 + `june20516/suberpower` 존재), 근거: 포크 사용 중 생긴 문제는 번역·포크 수정이 원인일 수 있어 upstream 직접 보고는 오보 위험
  - `check-divergence.sh`에 D-008 auto 검사 추가, `--list` 출력에 D-008 추가
  - D-001 bare `superpowers` 검사의 예외를 `github.com/obra/superpowers` → `obra/superpowers`로 넓히고, `divergence.md` D-001 검증 설명도 같이 고친다
- [ ] **Step 4: 검증**

```bash
D=plugins/suberpower/skills/diagnosing-suberpowers
find $D -type f | wc -l                                       # 기대: 20
grep -rn "superpowers" $D | grep -v "obra/superpowers"         # 기대: 출력 없음
grep -n "obra/superpowers\|june20516/suberpower" $D/references/github-issues.md   # 기대: Search 절에서 obra가 june20516보다 먼저 등장
scripts/sync-structure-check.sh $D/SKILL.md skills/diagnosing-superpowers/SKILL.md
./scripts/check-divergence.sh | grep -A4 "D-001\|D-008"         # 기대: 전부 ✅
```

`github-issues.md`는 의도적 재구성이므로 구조 비교 대상에서 제외한다.

- [ ] **Step 5:** commit — `동기화: diagnosing-suberpowers skill 추가 (v6.4.2), 이슈 흐름 upstream→포크 검색·포크 우선 보고(D-008)`

---

### Task 12: hooks

**Files:**
- Modify: `plugins/suberpower/hooks/hooks.json`, `plugins/suberpower/hooks/session-start`

- [ ] **Step 1:** `hooks.json`에 `"shell": "bash"` 추가 (upstream과 동일 위치).
- [ ] **Step 2:** `session-start`를 `git merge-file`로 병합 — legacy skills 경고 블록 제거, Muse 분기 추가, `printf … | cat` 적용. 포크의 `suberpower:using-suberpowers` 문구, `You have superpowers. (이 포크: suberpowers)`, 주석 2행은 보존.
- [ ] **Step 3: 검증**

```bash
bash -n plugins/suberpower/hooks/session-start
CLAUDE_PLUGIN_ROOT=$PWD/plugins/suberpower plugins/suberpower/hooks/session-start | python3 -m json.tool > /dev/null && echo ok
./scripts/check-divergence.sh | grep -A8 "D-001"   # 기대: 전부 ✅ (허용 3곳 유지)
```

허용 위치의 줄 번호가 바뀌었으면 `divergence.md` D-001 표의 줄 번호를 갱신한다.
- [ ] **Step 4:** commit — `동기화: hooks (v6.4.2) — bash shell 지정, legacy 경고 제거`

---

### Task 13: 문서·버전·마무리

**Files:**
- Modify: `docs/suberpowers/upstream-sync.md`, `docs/suberpowers/translation-glossary.md`(새 용어가 생긴 경우만), `README.md`(skill 목록·완화 언급이 있으면)
- Modify: `plugins/suberpower/.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`

- [ ] **Step 1: 잔여 참조 전수 검사**

```bash
grep -rn "spec-reviewer-prompt\|code-quality-reviewer-prompt\|testing-anti-patterns\|plan-document-reviewer\|copilot-tools\|suberpowers/reviews\|75318\|리뷰 범위 분할\|Subagent 실패 처리\|diagnosing-superpowers" plugins/ README.md
```

기대: 출력 없음.
- [ ] **Step 2: upstream-sync.md 갱신** — baseline 표: SHA `8ca22db…`(전체 SHA는 `git rev-parse upstream-v6.4.2`), 날짜 2026-09-25, 기준 릴리스 `v6.4.2`, 마지막 동기화 2026-10-07. "미반영 변경" 섹션을 "없음 (v6.4.2 기준)"으로 바꾸고, 동기화 절차 1단계에 "정식 릴리스 tag 기준으로 비교한다(`gh api repos/obra/superpowers/releases`)"를 추가. 이번 동기화의 의도적 미반영 목록(using-git-worktrees 전체, finishing의 전역 경로, diagnosing 이슈 흐름 D-008)을 기록.
- [ ] **Step 3: 버전 bump** — 두 파일의 `"version": "1.3.0"` → `"2.0.0"`.
- [ ] **Step 4: 최종 게이트**

```bash
./scripts/check-divergence.sh --sync
```

`assisted`(D-005·D-006·D-007)는 번역된 파일 목록을 근거로 판단을 subagent에게 맡기고, `manual`(D-002·D-008)은 사용자 확인을 받은 뒤:

```bash
./scripts/check-divergence.sh --sync --ack D-002,D-005,D-006,D-007,D-008; echo "exit $?"   # 기대: exit 0
```

- [ ] **Step 5:** commit — `chore: 버전 2.0.0 — upstream v6.4.2 동기화`

---

## Review Focus

테스트로 직접 잡히지 않는 실패 지점과 그것을 잡는 위치:

1. **`.superpowers/` 치환 누락으로 SDD 작업 공간이 upstream 경로에 생성** — Task 2 Step 2의 `sdd-workspace` 출력 경로 검사, Task 13 `check-divergence.sh`의 D-001.
2. **포크 전역 worktree 경로가 finishing 재번역 중 소실** — Task 8의 D-002 auto 검사 확장.
3. **삭제된 prompt 파일을 다른 skill이 계속 참조** — Task 13 Step 1 grep.
4. **brainstorming 스크립트 병합 시 한국어 UI 문자열이 영어로 회귀** — Task 7 Step 1 충돌 해소 규칙, Step 2 실행 확인.
5. **SessionStart 주입 JSON 파손** — Task 10 Step 3, Task 12 Step 3의 JSON 파싱.
6. **diagnosing이 승인 없이 upstream에 이슈 생성** — Task 11 Step 2의 "upstream 보고 (선택)" 절과 Red Flags 수정, 최종 리뷰에서 승인 게이트 문장 확인.
