# Code Quality Reviewer Prompt 템플릿

code quality reviewer subagent를 dispatch할 때 이 템플릿을 사용하세요.

**목적:** 구현이 잘 만들어졌는지 검증 (깔끔하고, 테스트되고, 유지보수 가능한지)

**spec 준수 review가 통과한 후에만 dispatch하세요.**

**dispatch 전 준비 (M-1 체크포인트):** report 파일 경로를 먼저 만드세요.

```bash
mkdir -p ~/.claude/suberpowers/reviews
find ~/.claude/suberpowers/reviews -type f -name '*.md' -mtime +14 -delete  # 14일 지난 보고서 청소
# 예: ~/.claude/suberpowers/reviews/2026-08-13-myproject-task-3-quality.md
REPORT_FILE=~/.claude/suberpowers/reviews/$(date +%Y-%m-%d)-<프로젝트>-task-<N>-quality.md
# 재review 라운드는 -r2, -r3 접미사로 새 파일을 쓴다 (이전 라운드 보고서를 덮어쓰지 않는다)
```

```
Task tool (general-purpose):
  requesting-code-review/code-reviewer.md의 템플릿을 사용

  DESCRIPTION: [implementer 보고서에서 가져온 task 요약]
  PLAN_OR_REQUIREMENTS: [plan-file]의 Task N
  BASE_SHA: [task 이전 commit]
  HEAD_SHA: [현재 commit]
  REPORT_FILE: [위에서 만든 경로]
```

**표준 code quality 관심사 외에, reviewer는 다음을 확인해야 합니다:**
- 각 파일이 잘 정의된 인터페이스로 하나의 명확한 책임을 가지는가?
- 단위가 독립적으로 이해되고 테스트될 수 있도록 분해되어 있는가?
- 구현이 plan의 파일 구조를 따르고 있는가?
- 이 구현이 이미 큰 새 파일을 만들었거나, 기존 파일을 크게 키웠는가? (기존에 존재하던 파일 크기를 표시하지 말 것 — 이 변경이 기여한 부분에 집중할 것.)

**Code reviewer가 반환하는 것:** 3줄 요약 (REPORT_FILE 경로, 판정, 이슈 개수). 전체 보고서는 REPORT_FILE에 있으므로 **orchestrator는 통지를 받으면 반드시 REPORT_FILE을 Read로 읽으세요.**

**reviewer가 응답 없이 종료된 경우:** REPORT_FILE에 부분 보고서가 남아 있을 수 있습니다. SKILL.md의 "Subagent 실패 처리" 섹션을 따르세요.
