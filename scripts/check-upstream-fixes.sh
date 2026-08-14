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

issues=$(grep -oE 'anthropics/claude-code#[0-9]+' "$REGISTRY" | sort -u)
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
