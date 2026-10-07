---
name: writing-plans
description: spec 또는 요구사항이 있는 멀티스텝 작업을 코드 작성 전에 계획할 때 사용합니다
---

# Writing Plans

## Overview

이 코드베이스도, 이 spec도 본 적 없는 엔지니어를 위해 구현 plan을 작성합니다. 그 엔지니어는 정확한 인터페이스와 정확한 테스트를 알고 나면 프로젝트 언어에 맞는 관용적인 코드를 작성하고, plan이 열어 둔 부분에서는 합리적인 선택을 한다고 가정합니다. 그 엔지니어가 알 수 없는 것은 당신이 무엇을 결정했는가입니다: 어떤 파일, 어떤 이름과 signature, spec의 어떤 값, 어떤 테스트가 각 task를 증명하는지. 이것들을 문서화합니다. 전체 plan을 한 입 크기의 task로 나누어 제공합니다. DRY. YAGNI. TDD. 잦은 commit.

**시작 시 안내:** "writing-plans skill을 사용하여 구현 plan을 작성하겠습니다."

**맥락:** 격리된 worktree에서 작업 중이라면, 실행 시점에 `suberpower:using-git-worktrees` skill을 통해 생성되었어야 합니다.

**Plan 저장 위치:** `docs/suberpowers/plans/YYYY-MM-DD-<feature-name>.md`
- (Plan 위치에 대한 사용자 선호 설정이 이 기본값을 override합니다)

## Scope Check

spec이 여러 개의 독립적인 서브시스템을 다룬다면, brainstorming 중에 서브 프로젝트 spec으로 분리되었어야 합니다. 그렇지 않았다면, 별도의 plan들로 — 서브시스템당 하나씩 — 분리할 것을 제안합니다. 각 plan은 그 자체로 동작 가능하고 테스트 가능한 소프트웨어를 만들어내야 합니다.

## File Structure

task를 정의하기 전에, 어떤 파일이 생성 또는 수정될지, 그리고 각 파일이 무엇을 담당하는지 매핑합니다. 분해(decomposition) 결정이 여기서 확정됩니다.

- 명확한 경계와 잘 정의된 인터페이스를 가진 단위로 설계합니다. 각 파일은 하나의 명확한 책임을 가져야 합니다.
- 당신은 한 번에 context에 담을 수 있는 코드를 가장 잘 추론하며, 파일이 집중되어 있을수록 편집이 더 안정적입니다. 너무 많은 일을 하는 큰 파일보다는 작고 집중된 파일을 선호하세요.
- 함께 변경되는 파일들은 함께 위치해야 합니다. 기술 계층이 아니라 책임으로 분할하세요.
- 기존 코드베이스에서는 확립된 패턴을 따르세요. 코드베이스가 큰 파일을 사용한다면 일방적으로 재구조화하지 마세요 — 하지만 수정 중인 파일이 다루기 힘들 정도로 커졌다면, plan에 분할을 포함하는 것은 합리적입니다.

이 구조가 task 분해의 기준이 됩니다. 각 task는 독립적으로 의미가 있는 자기 완결적인 변경을 만들어내야 합니다.

## Task Right-Sizing

task는 자체 테스트 사이클을 갖추고 새 reviewer의 관문을 거칠 가치가 있는 가장 작은 단위입니다. task 경계를 그을 때: 준비(setup), 설정, scaffolding, 문서화 step은 그것을 필요로 하는 산출물의 task에 합치고, reviewer가 한 task는 거부하면서 이웃 task는 승인하는 것이 의미 있는 지점에서만 나누세요. 각 task는 독립적으로 테스트할 수 있는 산출물로 끝납니다.

## Step Granularity

**각 step은 확인 가능한 결과가 있는 하나의 액션입니다:**
- "실패하는 테스트 작성" - step
- "실패하는지 확인하기 위해 실행" - step
- "테스트를 통과시킬 최소한의 코드 구현" - step
- "테스트를 실행하여 통과하는지 확인" - step
- "Commit" - step

## Plan Document Header

**모든 plan은 반드시 이 헤더로 시작해야 합니다:**

```markdown
# [기능 이름] Implementation Plan

> **agentic worker에게:** REQUIRED SUB-SKILL: 이 plan을 task 단위로 구현하려면 suberpower:subagent-driven-development(권장) 또는 suberpower:executing-plans를 사용하세요. Step은 추적을 위해 checkbox(`- [ ]`) 문법을 사용합니다.

**Goal:** [무엇을 만드는지 한 문장으로]

**Architecture:** [접근 방식에 대해 2-3문장]

**Tech Stack:** [핵심 기술/라이브러리]

**Spec:** [이 plan이 구현하는 spec/설계 문서의 경로 — plan은 spec을 근거로
논증하므로 spec이 plan과 함께 전달됩니다. 실행자는 둘 다 읽습니다]

## Global Constraints

[spec의 프로젝트 전반 요구사항 — 최소 버전, 의존성 제한, 이름과 문구 규칙,
플랫폼 요구사항 — 한 줄에 하나씩, 정확한 값은 spec에서 그대로 옮겨
적습니다. 모든 task의 요구사항에는 이 섹션이 암묵적으로
포함됩니다.]

## Review Focus

[spec이 함축하지만 어떤 task의 테스트도 다루지 않는 입력 유형 또는 실패
양상 중, 이 소프트웨어를 쓰는 사람에게 문제를 일으킬 가능성이 가장 높은 다섯 가지
— 한 줄에 하나씩, 입력이나 조건, 그리고 합리적인 사람이 기대할 동작을 함께 적고,
가능성이 높은 것부터 나열합니다. spec은 비전 문서입니다: 소프트웨어가 해야 할
일을 말할 뿐 소프트웨어가 마주칠 모든 것을 말하지는 않으며, spec이 어떤 입력에
대해 침묵한다고 해서 그 입력이 프로그램을 망가뜨려도 된다는 허락은 아닙니다.
이 목록은 spec을 앞에 두고 여기에 한 번 작성합니다. 그런 다음 각 줄마다,
그것을 고정하는 테스트를 해당 코드를 소유한 task에 그 task의 step 형식대로
추가합니다.]

---
```

## Task Structure

````markdown
### Task N: [컴포넌트 이름]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Interfaces:**
- Consumes: [이 task가 앞선 task에서 사용하는 것 — 정확한 signature]
- Produces: [이후 task가 의존하는 것 — 정확한 함수 이름, 파라미터 타입과
  반환 타입. task의 implementer는 자기 task만 봅니다. 이웃 task가 쓰는
  이름과 타입은 이 블록을 통해 알게 됩니다.]

- [ ] **Step 1: 실패하는 test 작성**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: test를 실행하여 실패를 확인**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: `exact/path/to/file.py`에 `function(input: InputType) -> ResultType` 구현**

signature와 테스트가 선택의 여지를 남길 때(어떤 라이브러리 호출, 어떤 자료구조)는
접근 방식을 한 줄로 적습니다. 코드 블록은 signature와 테스트가 결정하지 못하는
알고리즘에만 씁니다.

- [ ] **Step 4: test를 실행하여 통과를 확인**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## What a Step Contains

step은 implementer가 그 step에서 작성할 수 있는 합리적인 결과가 정확히 하나뿐일 때 완성된 것입니다. 요구사항은 그것이 전부입니다: 완전함이 아니라, 모호하지 않음입니다. 각 종류의 step은 자신을 모호하지 않게 만드는 것만 담고, 그 이상은 담지 않습니다:

- **테스트 step:** 테스트 이름과 assertion을 코드로, spec의 정확한 값을 넣어서 적습니다.
- **코드 step:** 정확한 signature(이름, 파라미터, 반환 타입), 그 코드가 위치할 파일, 그리고 spec이 고정한 구체적인 값을 적습니다. body는 implementer가 작성합니다. body는 signature와 테스트가 결정하지 못하는 알고리즘이거나, spec이 고정한 정확한 문구일 때만 적습니다.
- **검증 step:** 실행할 명령과, 통과를 뜻하는 출력을 적습니다.
- **다른 task 참조:** 무엇을 사용할지는 그 task의 Interfaces 블록이 알려 줍니다. plan은 그 task의 코드를 반복하지 않습니다.

plan은 implementer가 혼자서는 내릴 수 없는 결정의 집합입니다. 설명하는 코드보다 긴 plan은 plan 대신 코드를 써 버린 것입니다. 아무것도 결정하지 않는 줄("TBD", "edge case 처리", "적절한 validation 추가", "위 내용에 대한 테스트 작성", 어떤 task도 정의하지 않는 type이나 function)은 정반대의 실패이며, self-review가 둘 다 잡아냅니다.

## Self-Review

전체 plan을 작성한 후, spec을 새로운 눈으로 보고 plan을 그에 대조해 확인합니다. 이것은 스스로 실행하는 체크리스트입니다 — subagent dispatch가 아닙니다.

**1. Spec coverage:** spec의 각 섹션/요구사항을 훑어봅니다. 그것을 구현하는 task를 가리킬 수 있나요? 누락된 부분을 나열합니다.

**2. Step scan:** 모든 step은 implementer가 작성할 합리적인 결과를 정확히 하나로 좁혀야 하며, 어떤 step도 그 이상을 담아서는 안 됩니다: 아무것도 결정하지 않는 줄은 공백이고, signature와 테스트가 이미 결정하는 함수 body는 코드를 옮겨 적은 것일 뿐입니다. 둘 다 고치세요.

**3. Type consistency:** 후반 task에서 사용한 type, method signature, property 이름이 이전 task에서 정의한 것과 일치하나요? Task 3에서 `clearLayers()`라 부른 함수를 Task 7에서 `clearFullLayers()`로 부르면 버그입니다.

**4. Review Focus:** spec이 함축하는 각 입력 유형 또는 실패 양상마다, 테스트로 그것을 다루는 task가 있나요? 다뤄지지 않은 것 중 사람에게 문제를 일으킬 가능성이 가장 높은 다섯 가지를 Review Focus 섹션에 넣고, 그 섹션의 각 줄에 해당하는 테스트를 그 코드를 소유한 task에 추가합니다. 빈 섹션은 점검했지만 하나도 찾지 못했다는 뜻이지, 점검을 건너뛰었다는 뜻이 아닙니다.

**5. Proportion:** plan의 길이를 spec의 길이와 비교합니다. 구현 대상 spec보다 몇 배나 긴 plan은 plan이 아니라 프로그램을 옮겨 적은 사본입니다. 코드 블록이 문서의 대부분을 차지한다면, body를 signature, 테스트 이름, assertion으로 바꾸고, 각 step이 여전히 모호하지 않은지 확인합니다.

문제를 발견하면 즉석에서 수정합니다. 다시 review할 필요 없습니다 — 그냥 수정하고 넘어가세요. spec 요구사항인데 해당 task가 없다면 task를 추가합니다.

## Execution Handoff

plan을 저장하고 self-review한 뒤, your human partner가 읽을 수 있도록 plan의 링크를 제시하세요. your human partner가 이미 실행 방식을 명시적으로 정해 두었다면, plan을 review하고 원하는 바를 담고 있는지 확인해 달라고 요청하세요. 구현 전에 그 review를 기다린 다음, 정해 둔 방식을 사용하세요. 그렇지 않다면, 구현 전에 plan을 review하고 실행 방식을 골라 달라고 요청하세요.

**실행 방식이 아직 정해지지 않았을 때:**

**"Plan이 완성되어 `docs/suberpowers/plans/<filename>.md`에 저장되었습니다. plan을 review해 주세요. 어떤 실행 방식을 원하시나요?**

- **Subagent-driven** - task마다 새 subagent가 구현하고, 다음 task가 시작되기 전에 새 reviewer가 점검하며, 마지막에 브랜치 전체를 review합니다. 가장 철저합니다. task마다, review마다 새 context 비용이 듭니다.
- **Native** - 이 harness가 작업을 실행하는 방식 그대로, 제가 이 세션에서 모든 task를 직접 구현하고, 마지막에 가장 강력한 모델의 새 reviewer 하나가 브랜치 전체를 점검합니다. 가장 저렴하고 빠릅니다. 마지막까지 독립적인 review는 없습니다. 설계는 plan이 담고 있으므로 중간 등급 세션 모델에서도 잘 돌아갑니다.

**이 plan에는 <둘 중 하나>를 권장합니다. 이유: <plan에서 근거를 든 한 문장: task들이 서로의 인터페이스에 얼마나 의존하는지, task가 몇 개인지, 실수가 그대로 출시되면 비용이 얼마인지>. plan이 원하시는 바를 담고 있나요? 그리고 어떤 방식으로 진행할까요?"**

**실행 방식이 이미 정해져 있을 때:**

**"Plan이 완성되어 `docs/suberpowers/plans/<filename>.md`에 저장되었습니다. plan을 review해 주세요. 원하시는 바를 담고 있나요?"**

**Subagent-driven을 선택한 경우:**
- **REQUIRED SUB-SKILL:** Use suberpower:subagent-driven-development

**Native를 선택한 경우:**
- **REQUIRED SUB-SKILL:** Use suberpower:executing-plans
