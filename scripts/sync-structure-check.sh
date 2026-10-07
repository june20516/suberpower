#!/usr/bin/env bash
# 포크 번역 파일과 upstream 원문의 마크다운 구조를 비교합니다.
# upstream 원문은 `git show upstream-v6.4.2:<upstream-path>`로 읽습니다.
#
# 사용법:
#   ./scripts/sync-structure-check.sh <fork-file> <upstream-path>
#
# 비교 항목 (코드펜스 밖 기준):
#   heading 수      ^#{1,6}<공백>
#   코드펜스 수     ```로 시작하는 줄
#   목록 항목 수    ^\s*([-*]|[0-9]+\.)<공백>
#
# 종료코드: 0 = heading/코드펜스 일치 (목록 차이는 경고만), 1 = 불일치, 2 = 사용 오류

set -uo pipefail

UPSTREAM_REF="upstream-v6.4.2"

if [ $# -ne 2 ]; then
  printf '사용법: %s <fork-file> <upstream-path>\n' "$0"
  exit 2
fi

FORK_FILE="$1"
UPSTREAM_PATH="$2"

if [ ! -f "$FORK_FILE" ]; then
  printf '포크 파일을 찾을 수 없습니다: %s\n' "$FORK_FILE"
  exit 2
fi

UPSTREAM_CONTENT="$(git show "${UPSTREAM_REF}:${UPSTREAM_PATH}" 2>/dev/null)" || {
  printf 'upstream 파일을 읽을 수 없습니다: %s:%s\n' "$UPSTREAM_REF" "$UPSTREAM_PATH"
  exit 2
}

# 표준입력 마크다운에서 "heading 수 코드펜스 수 목록 수"를 출력합니다.
count_structure() {
  awk '
    /^[[:space:]]*```/ { fences++; in_fence = !in_fence; next }
    in_fence { next }
    /^#{1,6} / { headings++; next }
    /^[[:space:]]*([-*]|[0-9]+\.) / { items++ }
    END { printf "%d %d %d\n", headings, fences, items }
  '
}

read -r FORK_H FORK_F FORK_L < <(count_structure < "$FORK_FILE")
read -r UP_H UP_F UP_L < <(printf '%s\n' "$UPSTREAM_CONTENT" | count_structure)

printf '%-14s %8s %8s\n' "항목" "fork" "upstream"
printf '%-14s %8d %8d\n' "heading" "$FORK_H" "$UP_H"
printf '%-14s %8d %8d\n' "코드펜스" "$FORK_F" "$UP_F"
printf '%-14s %8d %8d\n' "목록 항목" "$FORK_L" "$UP_L"

STATUS=0
if [ "$FORK_H" -ne "$UP_H" ]; then
  printf '불일치: heading 수가 다릅니다 (fork %d, upstream %d)\n' "$FORK_H" "$UP_H"
  STATUS=1
fi
if [ "$FORK_F" -ne "$UP_F" ]; then
  printf '불일치: 코드펜스 수가 다릅니다 (fork %d, upstream %d)\n' "$FORK_F" "$UP_F"
  STATUS=1
fi
if [ "$FORK_L" -ne "$UP_L" ]; then
  printf '경고: 목록 항목 수가 다릅니다 (fork %d, upstream %d)\n' "$FORK_L" "$UP_L"
fi

[ "$STATUS" -eq 0 ] && printf '구조 일치\n'
exit "$STATUS"
