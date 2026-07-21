#!/usr/bin/env bash
# 이 포크의 의도적 divergence가 유지되고 있는지 검증합니다.
# 근거와 정책은 docs/suberpowers/divergence.md 참조.
#
# 사용법:  ./scripts/check-divergence.sh
# 종료코드: 0 = 전부 통과, 1 = 하나 이상 파손

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PASS=0
FAIL=0

ok()   { printf '  \033[32m✅\033[0m %s\n' "$1"; PASS=$((PASS+1)); }
bad()  { printf '  \033[31m❌\033[0m %s\n' "$1"; FAIL=$((FAIL+1)); }
head_() { printf '\n\033[1m%s\033[0m\n' "$1"; }

SKILLS="plugins/suberpower/skills"

# ---------------------------------------------------------------- D-001
head_ "D-001 · 네임스페이스 치환 (NEVER_OVERWRITE)"

for pat in 'superpowers:' 'docs/superpowers/' '\.superpowers/' '~/\.config/superpowers/' '~/\.claude/superpowers/'; do
  n=$(grep -rEc "$pat" plugins/ 2>/dev/null | awk -F: '{s+=$2} END{print s+0}')
  if [ "$n" -eq 0 ]; then ok "치환 완료: $pat 없음"
  else bad "치환 누락: $pat 이(가) $n 곳에 남아 있음"; fi
done

# upstream 저장소 URL(원작자 링크)은 유지 대상이므로 제외하고,
# 브랜드·출처 표현으로 허용된 3곳 외에 bare 'superpowers'가 있으면 실패
allowed=3
found=$(grep -rn "superpowers" plugins/ 2>/dev/null | grep -v "github.com/obra/superpowers" | wc -l | tr -d ' ')
if [ "$found" -eq "$allowed" ]; then
  ok "브랜드·출처 표현 ${allowed}곳만 남음 (허용 목록과 일치)"
else
  bad "bare 'superpowers'가 ${found}곳 (허용: $allowed). 신규 유입을 확인하세요:"
  grep -rn "superpowers" plugins/ 2>/dev/null | grep -v "github.com/obra/superpowers" | sed 's/^/       /'
fi

# ---------------------------------------------------------------- D-002
head_ "D-002 · using-git-worktrees 전면 재작성 (MANUAL_MERGE)"

WT="$SKILLS/using-git-worktrees/SKILL.md"
if [ -f "$WT" ]; then
  while IFS= read -r marker; do
    if grep -qF "$marker" "$WT"; then ok "마커 유지: $marker"
    else bad "마커 소실: $marker — upstream 판본으로 덮어썼는지 확인하세요"; fi
  done <<'MARKERS'
~/.claude/suberpowers/worktrees/
Step 0: Detect Existing Isolation
git worktree add
MARKERS
else
  bad "파일 없음: $WT"
fi

# ---------------------------------------------------------------- D-003
head_ "D-003 · description 규약 (TRANSLATE_ON_SYNC)"

d_bad=0
for f in "$SKILLS"/*/SKILL.md; do
  name=$(basename "$(dirname "$f")")
  desc=$(grep -m1 '^description:' "$f" | sed 's/^description: *//')
  if [ -z "$desc" ]; then bad "$name — description 없음"; d_bad=1; continue; fi
  if ! printf '%s' "$desc" | perl -CSD -ne 'exit(/\p{Hangul}/ ? 0 : 1)'; then
    bad "$name — 한글 없음 (번역 누락)"; d_bad=1; continue
  fi
  if ! printf '%s' "$desc" | grep -q "사용"; then
    bad "$name — '사용'을 포함하지 않음 (트리거 조건 서술 아님)"; d_bad=1; continue
  fi
  if printf '%s' "$desc" | grep -qi '^"\?Use when'; then
    bad "$name — upstream 형식('Use when…')이 그대로 남음"; d_bad=1; continue
  fi
done
[ "$d_bad" -eq 0 ] && ok "SKILL.md $(ls -d "$SKILLS"/*/ | wc -l | tr -d ' ')개 모두 규약 준수"

# ---------------------------------------------------------------- D-004
head_ "D-004 · 플러그인 식별자 (NEVER_OVERWRITE)"

pn=$(grep -m1 '"name"' plugins/suberpower/.claude-plugin/plugin.json | sed 's/.*: *"\(.*\)".*/\1/')
[ "$pn" = "suberpower" ] && ok "plugin.json name = suberpower" || bad "plugin.json name = '$pn' (기대: suberpower)"

mn=$(grep -m1 '"name"' .claude-plugin/marketplace.json | sed 's/.*: *"\(.*\)".*/\1/')
[ "$mn" = "suberpower" ] && ok "marketplace.json name = suberpower" || bad "marketplace.json name = '$mn' (기대: suberpower)"

[ -d "$SKILLS/using-suberpowers" ] && ok "using-suberpowers/ 존재" || bad "using-suberpowers/ 없음"
[ -d "$SKILLS/using-superpowers" ] && bad "using-superpowers/ 가 되살아남 (rename 누락)" || ok "using-superpowers/ 부재"

# ---------------------------------------------------------------- D-005
head_ "D-005 · 한국어 번역 유지 (TRANSLATE_ON_SYNC)"

MIN=400
t_bad=0
for f in "$SKILLS"/*/SKILL.md; do
  name=$(basename "$(dirname "$f")")
  n=$(perl -CSD -ne '$c += () = /\p{Hangul}/g; END{print $c+0}' "$f")
  if [ "$n" -lt "$MIN" ]; then
    bad "$name — 한글 ${n}자 (최소 ${MIN}자). 번역 없이 덮어썼는지 확인하세요"; t_bad=1
  fi
done
[ "$t_bad" -eq 0 ] && ok "모든 SKILL.md가 한글 ${MIN}자 이상"

# ---------------------------------------------------------------- 결과
printf '\n────────────────────────────────────\n'
if [ "$FAIL" -eq 0 ]; then
  printf '\033[32m전부 통과\033[0m  (%d개 검사)\n' "$PASS"
  exit 0
else
  printf '\033[31m%d개 파손\033[0m / %d개 통과\n' "$FAIL" "$PASS"
  printf '근거와 정책: docs/suberpowers/divergence.md\n'
  exit 1
fi
