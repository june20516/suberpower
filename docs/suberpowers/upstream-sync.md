# Upstream 동기화 상태

이 포크가 어느 upstream 시점을 기준으로 하는지 기록합니다. **upstream과 비교할 때는 항상 아래 baseline SHA를 기준으로 삼습니다.** 현재 `main`과 비교하면 upstream이 그 사이 스스로 고친 것을 포크의 결함으로 오판하게 됩니다.

Upstream: [obra/superpowers](https://github.com/obra/superpowers)

---

## 현재 baseline

| 항목 | 값 |
|---|---|
| Upstream SHA | `8ca22dba9a94f28898bbce59f2537ff4d87c747d` |
| Upstream 날짜 | 2026-09-25 |
| 기준 릴리스 | `v6.4.2` |
| 포크 최초 커밋 | 2026-06-10 (`74f1f9e`) |
| 마지막 동기화 | 2026-10-07 (이전 baseline `6fd4507`, 2026-05-29) |

**주의:** upstream 저장소는 skill을 `skills/<name>/`에 두고, 이 포크는 `plugins/suberpower/skills/<name>/`에 둡니다. 경로 대응에 유의하세요.

---

## 미반영 변경: 없음 (v6.4.2 기준, 2026-10-07)

---

## 동기화 절차

0. **[divergence.md](./divergence.md) 확인** — 이 포크가 upstream과 의도적으로 다른 지점. 자동 반영 대상에서 제외할 것을 먼저 파악합니다
1. **비교** — baseline SHA와 최신 upstream 릴리스 사이의 `skills/` 변경을 산정. upstream `main`이 아니라 **정식 릴리스 tag** 기준으로 비교합니다 (`gh api repos/obra/superpowers/releases --jq '.[0].tag_name'`). 미릴리스 커밋은 다음 릴리스에서 반영합니다
2. **보고·선별** — 사용자에게 정리해 보고하고, 반영 대상과 커스터마이징 의사를 확인
3. **번역 적용** — [translation-glossary.md](./translation-glossary.md)의 규칙에 따라 번역
4. **검증** — `./scripts/check-divergence.sh --sync` 실행. auto 검사 실패는 divergence 파괴이므로 배포 전에 복구합니다. `assisted`·`manual` 항목은 확인 후 `--ack`로 명시해야 통과합니다
5. **배포** — `plugin.json`·`marketplace.json` version bump 후 commit
6. **이 파일의 baseline SHA를 갱신** — 기준 릴리스·날짜와 "이번 동기화의 포크 고유 사항"도 함께 갱신. 기준 upstream 버전 표기 3곳(`plugins/suberpower/.claude-plugin/plugin.json`·`.claude-plugin/marketplace.json`의 description, `README.md`의 "기준 upstream" 줄)도 새 릴리스로 바꿉니다

### 유용한 명령

```bash
# baseline 이후 skills/ 변경 커밋
gh api "repos/obra/superpowers/commits?path=skills&since=<BASELINE_DATE>&per_page=100" \
  --jq '.[] | "\(.commit.author.date[0:10])  \(.commit.message | split("\n")[0])"'

# 특정 파일을 baseline 시점 상태로 가져오기
gh api "repos/obra/superpowers/contents/skills/<path>?ref=<BASELINE_SHA>" --jq '.content' | base64 -d

# 특정 시점 이전의 마지막 커밋 SHA
gh api "repos/obra/superpowers/commits?path=<경로>&until=<ISO8601>&per_page=1" --jq '.[0].sha'

# 최신 정식 릴리스 tag
gh api repos/obra/superpowers/releases --jq '.[0].tag_name'

# 릴리스 tag를 로컬 tag로 가져오기 (upstream remote·tag 전체를 들이지 않음)
git fetch --no-tags https://github.com/obra/superpowers.git refs/tags/<tag>:refs/tags/upstream-<tag>
git rev-parse "upstream-<tag>^{commit}"          # baseline 표에 적을 전체 SHA
git diff <BASELINE_SHA> upstream-<tag> -- skills/  # 변경 산정

# 번역 파일과 upstream 원문의 마크다운 구조(heading·코드펜스·목록 수) 비교
# 스크립트 안의 UPSTREAM_REF를 이번 tag(upstream-<tag>)로 먼저 바꿉니다
./scripts/sync-structure-check.sh plugins/suberpower/skills/<name>/SKILL.md skills/<name>/SKILL.md
# exit 0 = heading·코드펜스 일치 (목록 차이는 경고), 1 = 불일치
```

---

## 이번 동기화의 포크 고유 사항 (v6.4.2)

다음 동기화 담당자를 위한 목록입니다. upstream과 비교해 차이가 보여도 아래 항목은 결함이 아닙니다.

**의도적 미반영**
- `using-git-worktrees` 전체 — D-002, 사용자 결정 "worktree는 포크 우선". `sync-structure-check.sh`에서 이 skill만 MISMATCH가 나는 것이 정상입니다
- `finishing-a-development-branch`의 전역 worktree 경로 인식 — D-002 확장. upstream은 전역 경로를 정리 판정에서 뺐지만 이 포크는 유지합니다

**포크 고유 개조**
- `diagnosing-suberpowers` 이슈 흐름 — D-008. upstream→포크 순으로 검색, 포크 우선 보고, upstream 보고는 영어·선택·별도 승인

**포크 고유 코드 변경**
- brainstorming `scripts/server.cjs` — 버전 manifest 탐색 목록에 `.claude-plugin/plugin.json` 추가 (포크에는 `package.json`이 없음)
- brainstorming `scripts/server.cjs` — 텔레메트리(버전이 붙은 Prime Radiant 로고 요청) **기본 꺼짐**. `SUBERPOWERS_ENABLE_TELEMETRY`를 켰을 때만 로고를 불러오며, upstream 끄기 변수(`SUPERPOWERS_DISABLE_TELEMETRY` 등)가 우선합니다 (2026-10-07 사용자 결정). 로고가 없을 때 화면 표기도 `Prime Radiant Suberpowers` 대신 `Suberpowers`
- `skills/writing-skills/package.json` = `{"type":"module"}` 추가 — `render-graphs.js`가 ESM이기 때문입니다. plugin 루트에 두면 `server.cjs`의 버전 탐색이 먼저 읽으므로 이 디렉터리에만 둡니다
- diagnosing `prompts/stumbles.md` — 한국어 되짚기 표현 예시 추가

**완화책 제거**
- M-1~M-3 제거 — [MITIGATIONS.md](./MITIGATIONS.md)의 `## 종료된 완화` 참조

**알려진 upstream 결함 (포크도 동일)**
- `executing-plans/scripts/task-done` — 출력이 없는 test command는 통과해도 exit 1로 끝나고 ledger에 기록되지 않습니다 (`set -euo pipefail` 아래에서 빈 로그를 `grep`). upstream 보고 후보입니다
- upstream `skills/using-superpowers/references/codex-tools.md`가 `finishing-a-development-branch`의 환경 감지를 Step 1로 잘못 가리킵니다 — 포크는 Step 2로 바로잡았습니다 (포크 고유 수정)

---

## 동기화에서 제외할 것

**→ [divergence.md](./divergence.md)** — 근거·정책과 함께 관리되며 기계 검증됩니다.

```bash
./scripts/check-divergence.sh
```
