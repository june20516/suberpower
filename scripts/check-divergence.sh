#!/usr/bin/env bash
# 이 포크의 의도적 divergence가 유지되고 있는지 검증합니다.
# 근거와 정책은 docs/suberpowers/divergence.md 참조.
#
# 사용법:
#   ./scripts/check-divergence.sh                    평소 — auto 검사만
#   ./scripts/check-divergence.sh --sync             동기화 후 — 전 항목 게이트
#   ./scripts/check-divergence.sh --sync --ack D-002,D-005
#   ./scripts/check-divergence.sh --list             등급별 항목 목록
#
# 종료코드: 0 = 전부 통과, 1 = 파손 또는 미확인 항목 존재

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SYNC_MODE=0
LIST_ONLY=0
ACKED=""

while [ $# -gt 0 ]; do
  case "$1" in
    --sync) SYNC_MODE=1 ;;
    --list) LIST_ONLY=1 ;;
    --ack)  shift; ACKED="${1:-}" ;;
    --ack=*) ACKED="${1#--ack=}" ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) printf '알 수 없는 옵션: %s\n' "$1"; exit 2 ;;
  esac
  shift
done

PASS=0
FAIL=0
PENDING=0

ok()    { printf '  \033[32m✅\033[0m %s\n' "$1"; PASS=$((PASS+1)); }
bad()   { printf '  \033[31m❌\033[0m %s\n' "$1"; FAIL=$((FAIL+1)); }
wait_() { printf '  \033[33m⏳\033[0m %s\n' "$1"; PENDING=$((PENDING+1)); }
head_() { printf '\n\033[1m%s\033[0m\n' "$1"; }

is_acked() {
  case ",${ACKED}," in *",$1,"*) return 0 ;; *) return 1 ;; esac
}

# assisted/manual 항목 — ID|등급|질문
#   assisted: 동기화 skill이 subagent에게 판단을 위임할 질문
#   manual:   사람이 확인해야 하는 항목
NONAUTO_ITEMS='D-002|manual|upstream이 using-git-worktrees 또는 finishing-a-development-branch의 worktree 정리 판정을 변경했다면, 사람이 변경 의도를 읽고 반영 여부를 판단했는가?
D-005|assisted|새로 번역한 부분의 한국어가 자연스러운가? 직역투·비문·용어 불일치가 없는가?
D-006|assisted|원문의 강조 등급이 유지되었는가? 대문자 강조가 평서문으로 풀린 곳은 없는가?
D-007|assisted|번역하지 말아야 할 것(heading·기술 용어·상태값)을 번역하지 않았는가? 용어집 대응표를 따랐는가?
D-008|manual|upstream이 diagnosing의 github-issues.md, SKILL.md 5단계, 승인 관문 bullet, 위험 신호 표의 "upstream에 바로 올리자" 행 중 하나라도 변경했다면, 사람이 변경 의도를 읽고 upstream 보고 경로에 반영했는가? 포크 승인 관문과 위험 신호 행은 유지되었는가?'

SKILLS="plugins/suberpower/skills"

if [ "$LIST_ONLY" -eq 1 ]; then
  printf '\033[1mauto\033[0m      D-001 D-002 D-003 D-004 D-005 D-008\n'
  printf '\033[1massisted\033[0m  D-005 D-006 D-007\n'
  printf '\033[1mmanual\033[0m    D-002 D-008\n\n'
  printf '근거와 검증 방법: docs/suberpowers/divergence.md\n'
  exit 0
fi

# ---------------------------------------------------------------- D-001
head_ "D-001 · 네임스페이스 치환 (NEVER_OVERWRITE)"

for pat in 'superpowers:' 'docs/superpowers/' '\.superpowers/' '~/\.config/superpowers/' '~/\.claude/superpowers/'; do
  n=$(grep -rEc "$pat" plugins/ 2>/dev/null | awk -F: '{s+=$2} END{print s+0}')
  if [ "$n" -eq 0 ]; then ok "치환 완료: $pat 없음"
  else bad "치환 누락: $pat 이(가) $n 곳에 남아 있음"; fi
done

# upstream 저장소 식별자(obra/superpowers — 원작자 링크, gh --repo, repo: 검색어)와
# 외부 브랜드 자산 URL(brainstorming 로고 이미지)은 유지 대상이므로 제외하고,
# 브랜드·출처 표현으로 허용된 3곳 외에 bare 'superpowers'가 있으면 실패
allowed=3
found=$(grep -rn "superpowers" plugins/ 2>/dev/null | grep -v "obra/superpowers\|primeradiant\.com/brand/superpowers-visual-brainstorming-logo\.png" | wc -l | tr -d ' ')
if [ "$found" -eq "$allowed" ]; then
  ok "브랜드·출처 표현 ${allowed}곳만 남음 (허용 목록과 일치)"
else
  bad "bare 'superpowers'가 ${found}곳 (허용: $allowed). 신규 유입을 확인하세요:"
  grep -rn "superpowers" plugins/ 2>/dev/null | grep -v "obra/superpowers\|primeradiant\.com/brand/superpowers-visual-brainstorming-logo\.png" | sed 's/^/       /'
fi

# ---------------------------------------------------------------- D-002
head_ "D-002 · using-git-worktrees 전면 재작성과 전역 worktree 경로 인식 (MANUAL_MERGE)"

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

# finishing-a-development-branch의 worktree 정리 판정이 전역 경로를 인식하는지
#   보호 구역 안의 설명 문장이 아니라 판정 조건 줄(WORKTREE_PATH가 있는 줄)을 검사합니다
FIN="$SKILLS/finishing-a-development-branch/SKILL.md"
GLOBAL_WT='~/.claude/suberpowers/worktrees/'
if [ -f "$FIN" ]; then
  fin_start=$(grep -c 'DIVERGENCE:D-002 start' "$FIN")
  fin_end=$(grep -c 'DIVERGENCE:D-002 end' "$FIN")
  in_block=$(awk -v path="$GLOBAL_WT" '
    /DIVERGENCE:D-002 start/ { inside = 1; next }
    /DIVERGENCE:D-002 end/   { inside = 0; next }
    inside && index($0, "WORKTREE_PATH") && index($0, path) { found = 1 }
    END { print found + 0 }
  ' "$FIN")
  if ! grep -qF "$GLOBAL_WT" "$FIN"; then
    bad "finishing 전역 경로 소실: $GLOBAL_WT — provenance 판정이 upstream 판본으로 덮였는지 확인하세요"
  elif [ "$fin_start" -eq 0 ] || [ "$fin_start" -ne "$fin_end" ]; then
    bad "finishing D-002 마커 짝 불일치 (start ${fin_start}, end ${fin_end})"
  elif [ "$in_block" -ne 1 ]; then
    bad "finishing 판정 조건 줄(D-002 보호 구역 안, WORKTREE_PATH)에 전역 경로 없음"
  else
    ok "finishing 전역 경로 유지: $GLOBAL_WT (D-002 보호 구역의 판정 조건 줄)"
  fi
  # 합리화 표의 정리 대상 행은 마커 밖에 있으므로 표 행 존재만 느슨하게 검사합니다
  if grep -E '^\|' "$FIN" | grep -qF "$GLOBAL_WT"; then
    ok "finishing 합리화 표 행에 전역 경로 유지"
  else
    bad "finishing 합리화 표 행에 전역 경로 없음 — upstream 판본으로 되돌아갔는지 확인하세요"
  fi
else
  bad "파일 없음: $FIN"
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

# ---------------------------------------------------------------- D-008
head_ "D-008 · diagnosing 이슈 흐름 (MANUAL_MERGE)"

DIAG="$SKILLS/diagnosing-suberpowers"
DIAG_SKILL="$DIAG/SKILL.md"
GH_ISSUES="$DIAG/references/github-issues.md"
UPSTREAM_REPO='obra/superpowers'
FORK_REPO='june20516/suberpower'
SKILL_GATE='포크 issue 승인은 upstream 보고 승인이 아닙니다'
SKILL_RED_FLAG='upstream에 바로 올리자'
ISSUES_GATE='**별도로** 다시 승인'

for f in "$GH_ISSUES" "$DIAG_SKILL"; do
  if [ ! -f "$f" ]; then bad "파일 없음: $f"; continue; fi
  s=$(grep -c 'DIVERGENCE:D-008 start' "$f")
  e=$(grep -c 'DIVERGENCE:D-008 end' "$f")
  if [ "$s" -gt 0 ] && [ "$s" -eq "$e" ]; then ok "D-008 마커 짝 유지: $f"
  else bad "D-008 마커 짝 불일치: $f (start ${s}, end ${e}) — upstream 판본으로 덮었는지 확인하세요"; fi
done

if [ -f "$DIAG_SKILL" ]; then
  # 승인 관문의 별도 승인 문장은 D-008 보호 구역 안에 있어야 합니다
  gate_in_block=$(awk -v gate="$SKILL_GATE" '
    /DIVERGENCE:D-008 start/ { inside = 1; next }
    /DIVERGENCE:D-008 end/   { inside = 0; next }
    inside && index($0, gate) { found = 1 }
    END { print found + 0 }
  ' "$DIAG_SKILL")
  if [ "$gate_in_block" -eq 1 ]; then ok "SKILL.md 승인 관문의 upstream 별도 승인 문장 유지 (D-008 보호 구역)"
  else bad "SKILL.md 승인 관문에 '$SKILL_GATE' 없음 (D-008 보호 구역 안) — upstream 판본으로 덮었는지 확인하세요"; fi

  # 위험 신호 표 행은 표 안이라 마커를 둘 수 없으므로 표 행 존재만 검사합니다
  if grep -E '^\|' "$DIAG_SKILL" | grep -qF "$SKILL_RED_FLAG"; then ok "SKILL.md 위험 신호 표에 포크 우선 보고 행 유지"
  else bad "SKILL.md 위험 신호 표에 '$SKILL_RED_FLAG' 행 없음 — upstream 표로 되돌아갔는지 확인하세요"; fi
fi

if [ -f "$GH_ISSUES" ]; then
  if grep -qF "$FORK_REPO" "$GH_ISSUES"; then ok "포크 저장소 유지: $FORK_REPO"
  else bad "포크 저장소 소실: $FORK_REPO — 포크 우선 보고 흐름이 upstream 판본으로 덮였는지 확인하세요"; fi

  if grep -qF "$ISSUES_GATE" "$GH_ISSUES"; then ok "github-issues.md upstream 별도 승인 문장 유지"
  else bad "github-issues.md에 '$ISSUES_GATE' 없음 — upstream 별도 승인 관문이 사라졌는지 확인하세요"; fi

  # '## 검색' 절 안에서 각 저장소가 처음 등장하는 줄 번호를 비교합니다
  order=$(awk -v up="$UPSTREAM_REPO" -v fork="$FORK_REPO" '
    /^## / { in_search = ($0 ~ /^## 검색/); if (in_search) has_heading = 1 }
    in_search && !up_line   && index($0, up)   { up_line = NR }
    in_search && !fork_line && index($0, fork) { fork_line = NR }
    END { print has_heading + 0, up_line + 0, fork_line + 0 }
  ' "$GH_ISSUES")
  read -r has_search up_line fork_line <<< "$order"
  if [ "$has_search" -eq 0 ]; then
    bad "'## 검색' 절 없음 — heading이 upstream 판본(## Search 등)으로 덮였는지 확인하세요"
  elif [ "$up_line" -eq 0 ] || [ "$fork_line" -eq 0 ]; then
    bad "검색 절에 두 저장소가 모두 있지 않음 (upstream 줄 ${up_line}, 포크 줄 ${fork_line})"
  elif [ "$up_line" -lt "$fork_line" ]; then
    ok "검색 순서 유지: $UPSTREAM_REPO(${up_line}행) → $FORK_REPO(${fork_line}행)"
  else
    bad "검색 순서 뒤집힘: $FORK_REPO(${fork_line}행)가 $UPSTREAM_REPO(${up_line}행)보다 먼저"
  fi
fi

# ------------------------------------------------------- 보호 구역 마커
head_ "보호 구역 마커 (auto)"

markers=$(grep -rhoE 'DIVERGENCE:D-[0-9]{3} (start|end)' plugins/ docs/ 2>/dev/null || true)
if [ -z "$markers" ]; then
  ok "사용 중인 보호 구역 없음"
else
  m_bad=0
  for id in $(printf '%s\n' "$markers" | grep -oE 'D-[0-9]{3}' | sort -u); do
    s=$(printf '%s\n' "$markers" | grep -c "$id start")
    e=$(printf '%s\n' "$markers" | grep -c "$id end")
    if [ "$s" -ne "$e" ]; then
      bad "$id — 마커 짝이 맞지 않음 (start ${s}, end ${e})"; m_bad=1
    elif ! grep -q "^## ${id} " docs/suberpowers/divergence.md; then
      bad "$id — 마커는 있으나 divergence.md에 등록되지 않음"; m_bad=1
    fi
  done
  [ "$m_bad" -eq 0 ] && ok "모든 보호 구역이 짝이 맞고 등록되어 있음"
fi

# ------------------------------------------------- assisted / manual 항목
head_ "assisted · manual 항목"

if [ "$SYNC_MODE" -eq 0 ]; then
  printf '  평소 실행에서는 건너뜁니다. 동기화 후에는 --sync로 실행하세요.\n'
  printf '  대상: %s\n' "$(printf '%s\n' "$NONAUTO_ITEMS" | cut -d'|' -f1 | tr '\n' ' ')"
else
  while IFS='|' read -r id tier question; do
    [ -n "$id" ] || continue
    if is_acked "$id"; then
      ok "$id ($tier) 확인 완료"
    else
      wait_ "$id ($tier) 미확인 — $question"
    fi
  done <<< "$NONAUTO_ITEMS"
  if [ "$PENDING" -gt 0 ]; then
    printf '\n  확인 후 다시 실행하세요:\n'
    printf '    ./scripts/check-divergence.sh --sync --ack %s\n' \
      "$(printf '%s\n' "$NONAUTO_ITEMS" | cut -d'|' -f1 | paste -sd, -)"
  fi
fi

# ---------------------------------------------------------------- 결과
printf '\n────────────────────────────────────\n'
if [ "$FAIL" -eq 0 ] && [ "$PENDING" -eq 0 ]; then
  printf '\033[32m전부 통과\033[0m  (auto %d개' "$PASS"
  [ "$SYNC_MODE" -eq 1 ] && printf ', assisted·manual 확인 완료'
  printf ')\n'
  exit 0
fi

[ "$FAIL"    -gt 0 ] && printf '\033[31m%d개 파손\033[0m\n' "$FAIL"
[ "$PENDING" -gt 0 ] && printf '\033[33m%d개 미확인\033[0m — 기계로 검증할 수 없는 항목입니다. 확인 없이 통과시키지 마세요.\n' "$PENDING"
printf '%d개 통과\n' "$PASS"
printf '근거와 정책: docs/suberpowers/divergence.md\n'
exit 1
