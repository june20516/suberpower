# 완화 조치 등록부 (Mitigations Registry)

Claude Code harness 버그를 우회하기 위해 이 fork에 추가된 완화 조치들의 등록부입니다.

`.github/workflows/upstream-fix-tracker.yml`이 호출하는 `scripts/check-upstream-fixes.sh`가
**이 파일에서 `anthropics/claude-code#NNN` 패턴을 읽어** 업스트림 이슈 상태를 매주 확인하고,
이슈가 닫히면 이 레포에 제거 검토 이슈를 자동 생성합니다. 즉, 이 파일이 추적 대상의 단일
소스입니다 — 새 완화를 추가하면 반드시 여기에 행을 추가하고, 커밋 메시지에 `[M-n]` 태그를
다세요. 새 완화의 ID는 M-5부터 사용하세요 (M-4는 이 추적 인프라 자체의 커밋 태그로 사용
중). (같은 스크립트를 로컬에서 직접 실행해 상태만 확인할 수도 있습니다.)

| ID | 완화 내용 | 적용 위치 | 업스트림 이슈 | 제거 기준 |
|----|----------|----------|--------------|----------|
| M-1 | reviewer 보고서 체크포인트 (파일에 점진 기록 + 3줄 최종 메시지) | subagent-driven-development/spec-reviewer-prompt.md·code-quality-reviewer-prompt.md, requesting-code-review/code-reviewer.md, requesting-code-review/SKILL.md | anthropics/claude-code#75318 | 아래 공통 기준 |
| M-2 | subagent 실패 감지·재dispatch 프로토콜 | subagent-driven-development/SKILL.md | anthropics/claude-code#75318 | 아래 공통 기준 |
| M-3 | 대형 diff 리뷰 범위 분할 (500줄/8파일 초과 시) | subagent-driven-development/SKILL.md | anthropics/claude-code#75318 | 공통 기준. 단 분할 자체는 리뷰 품질에도 이로우므로 유지 여부 별도 판단 |

증상 상세 리포트(같은 버그의 duplicate, 함께 추적): anthropics/claude-code#75367

## 공통 제거 기준

1. 추적 중인 업스트림 이슈가 모두 closed
2. Claude Code를 수정 버전으로 업데이트한 뒤, subagent-driven-development 실전 사용
   2주(또는 reviewer dispatch 20회) 동안 "응답 없이 종료" 재발 없음
   (dispatch 횟수는 해당 기간 `~/.claude/suberpowers/reviews/`의 보고서 파일 수로 센다.
   재발하면 사례를 이 파일에 메모로 남겨 관찰 기간을 리셋한다)

## 제거 방법

각 완화의 커밋은 커밋 메시지 앞에 `[M-n]` 태그를 답니다. 한 완화가 여러 커밋일 수
있습니다 (본 구현 + 리뷰 반영 등).

```bash
git log --oneline --grep='\[M-1\]'   # 해당 완화의 커밋 찾기 (여러 개일 수 있음)
git revert <h3> <h2> <h1>            # 최신 커밋부터 역순으로 모두 revert
                                     # (충돌 시 해당 완화의 섹션을 수동 삭제)
```

주의사항:
- **M-2와 M-3은 커밋을 공유합니다** (`[M-2][M-3]` 태그, 같은 SKILL.md 수정). 둘 중
  하나만 제거할 때는 revert 대신 SKILL.md에서 해당 완화의 섹션만 수동 삭제하세요.
- **M-3을 완화가 아닌 정식 기능으로 존치**하기로 결정한 경우: 이 표에서 M-3 행을
  삭제해 추적을 종료하고, SKILL.md의 M-3 섹션에서 "완화" 표기와 M-1/M-2 의존 참조
  (REPORT_FILE 계약 포함)를 존치 형태로 고쳐 쓰세요.
- 자동 생성된 제거 검토 이슈는 기준 미충족 상태에서 close하지 마세요 — 제목 중복
  검사가 closed 이슈도 포함하므로 한 번 닫으면 재생성·재알림이 영구히 없습니다.
  기준 충족 전까지는 open 유지 + 라벨로 관리하세요.

제거 후: 이 파일에서 해당 행을 삭제하고(마지막 행이라면 표 밖의 관련 이슈 참조 —
duplicate 리포트 언급 줄 — 도 함께 삭제), 남은 행이 없으면 워크플로우
(`.github/workflows/upstream-fix-tracker.yml`)와 `scripts/check-upstream-fixes.sh`도
함께 제거한 뒤 plugin 버전을 bump하세요.
