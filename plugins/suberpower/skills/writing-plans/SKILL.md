---
name: writing-plans
description: spec 또는 요구사항이 있는 멀티스텝 작업을 코드 작성 전에 계획할 때 사용합니다
---

# Writing Plans

## Overview

엔지니어가 우리 코드베이스에 대한 컨텍스트가 전혀 없고 취향도 의심스럽다는 가정 하에 포괄적인 구현 plan을 작성합니다. 각 task에서 어떤 파일을 다루어야 하는지, 코드, 테스트, 참고해야 할 docs, 테스트 방법 등 그들이 알아야 할 모든 것을 문서화합니다. 전체 plan을 한 입 크기의 task로 나누어 제공합니다. DRY. YAGNI. TDD. 잦은 commit.

그들이 숙련된 개발자이지만 우리 도구나 문제 영역에 대해서는 거의 모른다고 가정합니다. 좋은 테스트 설계에 대해서도 잘 모른다고 가정합니다.

**시작 시 알림:** "writing-plans skill을 사용하여 구현 plan을 작성하겠습니다."

**컨텍스트:** 격리된 worktree에서 작업 중이라면, 실행 시점에 `suberpower:using-git-worktrees` skill을 통해 생성되었어야 합니다.

**Plan 저장 위치:** `docs/suberpowers/plans/YYYY-MM-DD-<feature-name>.md`
- (Plan 위치에 대한 사용자 선호 설정이 이 기본값을 override 합니다)

## Scope Check

spec이 여러 개의 독립적인 서브시스템을 다룬다면, brainstorming 중에 서브 프로젝트 spec으로 분리되었어야 합니다. 그렇지 않았다면, 별도의 plan들로 — 서브시스템당 하나씩 — 분리할 것을 제안합니다. 각 plan은 그 자체로 동작 가능하고 테스트 가능한 소프트웨어를 만들어내야 합니다.

## File Structure

task를 정의하기 전에, 어떤 파일이 생성 또는 수정될지, 그리고 각 파일이 무엇을 담당하는지 매핑합니다. 분해(decomposition) 결정이 여기서 확정됩니다.

- 명확한 경계와 잘 정의된 인터페이스를 가진 단위로 설계합니다. 각 파일은 하나의 명확한 책임을 가져야 합니다.
- 한 번에 컨텍스트에 담을 수 있는 코드일수록 추론이 가장 잘 되고, 파일이 focused 되어 있을수록 편집이 더 신뢰성 있습니다. 너무 많은 일을 하는 큰 파일보다는 작고 focused 된 파일을 선호하세요.
- 함께 변경되는 파일들은 함께 위치해야 합니다. 기술 계층이 아니라 책임으로 분할하세요.
- 기존 코드베이스에서는 확립된 패턴을 따르세요. 코드베이스가 큰 파일을 사용한다면 일방적으로 재구조화하지 마세요 — 하지만 수정 중인 파일이 다루기 힘들 정도로 커졌다면, plan에 분할을 포함하는 것은 합리적입니다.

이 구조가 task 분해를 알려줍니다. 각 task는 독립적으로 의미가 있는 자기 완결적인 변경을 만들어내야 합니다.

## Bite-Sized Task Granularity

**각 step은 하나의 액션입니다 (2-5분):**
- "실패하는 테스트 작성" - step
- "실패하는지 확인하기 위해 실행" - step
- "테스트를 통과시킬 최소한의 코드 구현" - step
- "테스트를 실행하여 통과하는지 확인" - step
- "Commit" - step

## Plan Document Header

**모든 plan은 반드시 이 헤더로 시작해야 합니다:**

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use suberpower:subagent-driven-development (recommended) or suberpower:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Task Structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## No Placeholders

모든 step은 엔지니어에게 필요한 실제 내용을 포함해야 합니다. 다음은 **plan 실패** 사례 — 절대 작성하지 마세요:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (실제 테스트 코드 없이)
- "Similar to Task N" (코드를 반복해서 적으세요 — 엔지니어가 task를 순서대로 읽지 않을 수 있습니다)
- 무엇을 할지만 설명하고 어떻게 할지는 보여주지 않는 step (코드 step에는 코드 블록 필수)
- 어떤 task에서도 정의되지 않은 type, function, method에 대한 참조

## Remember
- 항상 정확한 파일 경로
- 모든 step에 완전한 코드 — step이 코드를 변경한다면 코드를 보여주세요
- 예상 출력을 포함한 정확한 명령어
- DRY, YAGNI, TDD, 잦은 commit

## Self-Review

전체 plan을 작성한 후, spec을 새로운 눈으로 보고 plan을 그에 대조해 확인합니다. 이것은 스스로 실행하는 체크리스트입니다 — subagent dispatch가 아닙니다.

**1. Spec coverage:** spec의 각 섹션/요구사항을 훑어봅니다. 그것을 구현하는 task를 가리킬 수 있나요? 누락된 부분을 나열합니다.

**2. Placeholder scan:** 위 "No Placeholders" 섹션의 패턴 중 하나라도 plan에 있는지 — 위험 신호를 검색합니다. 수정합니다.

**3. Type consistency:** 후반 task에서 사용한 type, method signature, property 이름이 이전 task에서 정의한 것과 일치하나요? Task 3에서 `clearLayers()`라 부른 함수를 Task 7에서 `clearFullLayers()`로 부르면 버그입니다.

문제를 발견하면 즉석에서 수정합니다. 다시 리뷰할 필요 없습니다 — 그냥 수정하고 넘어가세요. spec 요구사항인데 해당 task가 없다면 task를 추가합니다.

## Execution Handoff

plan을 저장한 후, 실행 선택지를 제시합니다:

**"Plan이 완성되어 `docs/suberpowers/plans/<filename>.md`에 저장되었습니다. 두 가지 실행 옵션이 있습니다:**

**1. Subagent-Driven (권장)** - task마다 새로운 subagent를 dispatch하고, task 사이에 리뷰하며, 빠르게 iteration합니다

**2. Inline Execution** - executing-plans를 사용해 이 세션에서 task를 실행하고, checkpoint와 함께 배치 실행합니다

**어떤 방식을 선택하시겠습니까?"**

**Subagent-Driven을 선택한 경우:**
- **REQUIRED SUB-SKILL:** Use suberpower:subagent-driven-development
- task마다 새로운 subagent + 2단계 리뷰

**Inline Execution을 선택한 경우:**
- **REQUIRED SUB-SKILL:** Use suberpower:executing-plans
- 리뷰를 위한 checkpoint와 함께 배치 실행
