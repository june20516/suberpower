# Upstream 동기화 상태

이 포크가 어느 upstream 시점을 기준으로 하는지 기록합니다. **upstream과 비교할 때는 항상 아래 baseline SHA를 기준으로 삼습니다.** 현재 `main`과 비교하면 upstream이 그 사이 스스로 고친 것을 포크의 결함으로 오판하게 됩니다.

Upstream: [obra/superpowers](https://github.com/obra/superpowers)

---

## 현재 baseline

| 항목 | 값 |
|---|---|
| Upstream SHA | `6fd4507659784c351abbd2bc264c7162cfd386dc` |
| Upstream 날짜 | 2026-05-29 |
| 포크 최초 커밋 | 2026-06-10 (`74f1f9e`) |
| 마지막 동기화 | 없음 (최초 포크 이후 미동기화) |

**주의:** upstream 저장소는 skill을 `skills/<name>/`에 두고, 이 포크는 `plugins/suberpower/skills/<name>/`에 둡니다. 경로 대응에 유의하세요.

---

## 미반영 변경 (2026-07-21 확인)

baseline 이후 upstream `skills/` 경로에 **83개 커밋**이 쌓여 있습니다. 현재 upstream HEAD는 `d884ae0` (2026-07-02).

확인된 주요 변경:

| 파일 | 변경 |
|---|---|
| `subagent-driven-development/SKILL.md` | 섹션 5개 추가 — `Pre-Flight Plan Review`, `Handling Reviewer ⚠️ Items`, `Constructing Reviewer Prompts`, `File Handoffs`, `Durable Progress` |
| `writing-skills/SKILL.md` | `Claude Search Optimization (CSO)` → `Skill Discovery Optimization (SDO)` 개명, `Match the Form to the Failure` 섹션 추가 |
| `writing-skills/SKILL.md` | 목록 번호 결함(`1,3,4,5,6`)과 `### 4` 중복을 upstream도 수정 — **이 포크는 이미 동일하게 반영 완료** |

전수 조사는 하지 않았습니다. 동기화 작업 시 다시 산정하세요.

---

## 동기화 절차

1. **비교** — baseline SHA와 현재 upstream HEAD 사이의 `skills/` 변경을 산정
2. **보고·선별** — 사용자에게 정리해 보고하고, 반영 대상과 커스터마이징 의사를 확인
3. **번역 적용** — [translation-glossary.md](./translation-glossary.md)의 규칙에 따라 번역
4. **배포** — `plugin.json`·`marketplace.json` version bump 후 commit
5. **이 파일의 baseline SHA를 갱신**

### 유용한 명령

```bash
# baseline 이후 skills/ 변경 커밋
gh api "repos/obra/superpowers/commits?path=skills&since=<BASELINE_DATE>&per_page=100" \
  --jq '.[] | "\(.commit.author.date[0:10])  \(.commit.message | split("\n")[0])"'

# 특정 파일을 baseline 시점 상태로 가져오기
gh api "repos/obra/superpowers/contents/skills/<path>?ref=<BASELINE_SHA>" --jq '.content' | base64 -d

# 특정 시점 이전의 마지막 커밋 SHA
gh api "repos/obra/superpowers/commits?path=<경로>&until=<ISO8601>&per_page=1" --jq '.[0].sha'
```

---

## 동기화에서 제외할 것

이 포크의 의도적 커스터마이징입니다. upstream 변경으로 덮어쓰지 마세요. 전체 목록은 [translation-glossary.md의 7절](./translation-glossary.md#7-의도적-divergence-동기화-시-덮어쓰지-말-것)을 참고하세요.

- 네임스페이스 치환 (`superpowers` → `suberpower` / `suberpowers`)
- `using-git-worktrees/SKILL.md` — 전면 재작성됨
- description 형식 (`"...할 때 사용합니다"`)
- 브랜드 표기
