# Code Quality Reviewer Prompt 템플릿

code quality reviewer subagent를 dispatch할 때 이 템플릿을 사용하세요.

**목적:** 구현이 잘 만들어졌는지 검증 (깔끔하고, 테스트되고, 유지보수 가능한지)

**spec 준수 review가 통과한 후에만 dispatch하세요.**

```
Task tool (general-purpose):
  Use template at requesting-code-review/code-reviewer.md

  DESCRIPTION: [task summary, from implementer's report]
  PLAN_OR_REQUIREMENTS: Task N from [plan-file]
  BASE_SHA: [commit before task]
  HEAD_SHA: [current commit]
```

**표준 code quality 관심사 외에, reviewer는 다음을 확인해야 합니다:**
- 각 파일이 잘 정의된 인터페이스로 하나의 명확한 책임을 가지는가?
- 단위가 독립적으로 이해되고 테스트될 수 있도록 분해되어 있는가?
- 구현이 plan의 파일 구조를 따르고 있는가?
- 이 구현이 이미 큰 새 파일을 만들었거나, 기존 파일을 크게 키웠는가? (기존에 존재하던 파일 크기를 표시하지 말 것 — 이 변경이 기여한 부분에 집중할 것.)

**Code reviewer가 반환하는 것:** 강점, 이슈 (Critical/Important/Minor), 평가
