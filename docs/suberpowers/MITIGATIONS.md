# 완화 조치 등록부 (Mitigations Registry)

Claude Code harness 버그를 우회하기 위해 이 fork에 추가된 완화 조치들의 등록부입니다.

`.github/workflows/upstream-fix-tracker.yml`이 **이 파일에서 `anthropics/claude-code#NNN`
패턴을 읽어** 업스트림 이슈 상태를 매주 확인하고, 이슈가 닫히면 이 레포에 제거 검토
이슈를 자동 생성합니다. 즉, 이 파일이 추적 대상의 단일 소스입니다 — 새 완화를 추가하면
반드시 여기에 행을 추가하세요.

| ID | 완화 내용 | 적용 위치 | 업스트림 이슈 | 제거 기준 |
|----|----------|----------|--------------|----------|
| M-1 | reviewer 보고서 체크포인트 (파일에 점진 기록 + 3줄 최종 메시지) | subagent-driven-development/*-prompt.md, requesting-code-review/code-reviewer.md, requesting-code-review/SKILL.md | anthropics/claude-code#75318 | 아래 공통 기준 |
| M-2 | subagent 실패 감지·재dispatch 프로토콜 | subagent-driven-development/SKILL.md | anthropics/claude-code#75318 | 아래 공통 기준 |
| M-3 | 대형 diff 리뷰 범위 분할 (500줄/8파일 초과 시) | subagent-driven-development/SKILL.md | anthropics/claude-code#75318 | 공통 기준. 단 분할 자체는 리뷰 품질에도 이로우므로 유지 여부 별도 판단 |

증상 상세 리포트(같은 버그의 duplicate, 함께 추적): anthropics/claude-code#75367

## 공통 제거 기준

1. 추적 중인 업스트림 이슈가 모두 closed
2. Claude Code를 수정 버전으로 업데이트한 뒤, subagent-driven-development 실전 사용
   2주(또는 reviewer dispatch 20회) 동안 "응답 없이 종료" 재발 없음

## 제거 방법

각 완화는 커밋 메시지 앞에 `[M-n]` 태그를 달고 독립 커밋으로 존재합니다.

```bash
git log --oneline --grep='\[M-1\]'   # 해당 완화의 커밋 찾기
git revert <hash>                    # 제거 (충돌 시 해당 섹션 수동 삭제)
```

제거 후: 이 파일에서 해당 행을 삭제하고, 남은 행이 없으면 워크플로우
(`.github/workflows/upstream-fix-tracker.yml`)와 `scripts/check-upstream-fixes.sh`도
함께 제거한 뒤 plugin 버전을 bump하세요.
