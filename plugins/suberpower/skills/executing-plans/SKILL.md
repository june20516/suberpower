---
name: executing-plans
description: 작성된 implementation plan을 review checkpoint와 함께 별도 session에서 실행할 때 사용합니다
---

# Executing Plans

## Overview

plan을 load하고, 비판적으로 review하며, 모든 task를 실행하고, 완료 시 보고합니다.

**시작 시 알립니다:** "executing-plans skill을 사용하여 이 plan을 구현합니다."

**참고:** Superpowers(suberpowers 포크)는 subagent에 access할 수 있을 때 훨씬 잘 동작한다고 human partner에게 알려주세요. subagent를 지원하는 platform(예: Claude Code 또는 Codex)에서 실행하면 작업 품질이 크게 향상됩니다. subagent를 사용할 수 있다면, 이 skill 대신 suberpower:subagent-driven-development를 사용하세요.

## The Process

### Step 1: Load and Review Plan
1. plan 파일을 읽습니다
2. 비판적으로 review합니다 - plan에 대한 질문이나 우려 사항을 식별합니다
3. 우려 사항이 있는 경우: 시작하기 전에 human partner에게 제기합니다
4. 우려 사항이 없는 경우: TodoWrite를 생성하고 진행합니다

### Step 2: Execute Tasks

각 task에 대해:
1. in_progress로 표시합니다
2. 각 단계를 정확히 따릅니다 (plan은 작은 단위의 step을 가지고 있습니다)
3. 명시된 대로 verification을 실행합니다
4. completed로 표시합니다

### Step 3: Complete Development

모든 task가 완료되고 verify된 후:
- 알립니다: "이 작업을 완료하기 위해 finishing-a-development-branch skill을 사용합니다."
- **REQUIRED SUB-SKILL:** suberpower:finishing-a-development-branch를 사용합니다
- 해당 skill을 따라 test를 verify하고, option을 제시하며, 선택을 실행합니다

## When to Stop and Ask for Help

**다음의 경우 즉시 실행을 중단합니다:**
- blocker에 부딪힌 경우 (dependency 누락, test 실패, instruction 불명확)
- plan에 시작을 막는 치명적인 gap이 있는 경우
- instruction을 이해하지 못하는 경우
- verification이 반복적으로 실패하는 경우

**추측하지 말고 명확한 설명을 요청하세요.**

## When to Revisit Earlier Steps

**다음의 경우 Review (Step 1)로 돌아갑니다:**
- partner가 당신의 feedback을 바탕으로 plan을 업데이트한 경우
- 근본적인 접근 방식을 재고해야 하는 경우

**blocker를 억지로 돌파하지 마세요** - 멈추고 질문하세요.

## Remember
- 먼저 plan을 비판적으로 review합니다
- plan step을 정확히 따릅니다
- verification을 건너뛰지 않습니다
- plan이 지시할 때 skill을 참조합니다
- 막혔을 때 중단하고, 추측하지 않습니다
- 명시적인 user 동의 없이는 main/master branch에서 구현을 시작하지 않습니다

## Integration

**Required workflow skills:**
- **suberpower:using-git-worktrees** - 격리된 workspace를 보장합니다 (생성하거나 기존 workspace를 verify)
- **suberpower:writing-plans** - 이 skill이 실행하는 plan을 생성합니다
- **suberpower:finishing-a-development-branch** - 모든 task 후 development를 완료합니다
