# Creation Log: Systematic Debugging Skill

핵심 skill의 추출, 구조화, 그리고 bulletproofing에 대한 참조 예시.

## Source Material

`~/.claude/CLAUDE.md`에서 debugging framework 추출:
- 4-phase systematic 프로세스 (Investigation → Pattern Analysis → Hypothesis → Implementation)
- 핵심 명령: 항상 root cause를 찾고, 증상을 절대 fix하지 말 것
- 시간 압박과 합리화에 저항하도록 설계된 규칙

## 추출 결정사항

**포함할 것:**
- 모든 규칙을 포함한 완전한 4-phase framework
- anti-shortcut ("NEVER fix symptom", "STOP and re-analyze")
- 압박 저항 언어 ("even if faster", "even if I seem in a hurry")
- 각 phase의 구체적 단계

**제외할 것:**
- 프로젝트별 컨텍스트
- 같은 규칙의 반복 변형
- 서사적 설명 (원칙으로 압축됨)

## skill-creation/SKILL.md를 따른 구조

1. **풍부한 when_to_use** - 증상과 anti-pattern 포함
2. **Type: technique** - 단계가 있는 구체적 프로세스
3. **Keyword** - "root cause", "symptom", "workaround", "debugging", "investigation"
4. **Flowchart** - "fix 실패" → 재분석 대 더 많은 fix 추가에 대한 결정 지점
5. **Phase별 분류** - 스캔 가능한 체크리스트 형식
6. **Anti-pattern 섹션** - 하지 말아야 할 것 (이 skill에 핵심적)

## Bulletproofing 요소

압박 하의 합리화에 저항하도록 설계된 framework:

### 언어 선택
- "ALWAYS" / "NEVER" ("should" / "try to"가 아님)
- "even if faster" / "even if I seem in a hurry"
- "STOP and re-analyze" (명시적 일시 정지)
- "Don't skip past" (실제 행동을 잡음)

### 구조적 방어
- **Phase 1 필수** - 구현으로 건너뛸 수 없음
- **단일 hypothesis 규칙** - 사고를 강제, shotgun fix 방지
- **명시적 실패 모드** - 필수 행동과 함께 "IF your first fix doesn't work"
- **Anti-pattern 섹션** - shortcut이 정확히 어떻게 생겼는지 보여줌

### 중복성
- root cause 명령이 overview + when_to_use + Phase 1 + 구현 규칙에 등장
- "NEVER fix symptom"이 다른 컨텍스트에서 4번 등장
- 각 phase에 명시적 "don't skip" 지침

## 테스트 접근

skills/meta/testing-skills-with-subagents를 따른 4개의 검증 test 작성:

### Test 1: Academic Context (압박 없음)
- 단순한 bug, 시간 압박 없음
- **결과:** 완벽한 준수, 완전한 조사

### Test 2: 시간 압박 + 명백한 빠른 Fix
- "급한" 사용자, 증상 fix가 쉬워 보임
- **결과:** shortcut에 저항, 전체 프로세스 따름, 실제 root cause 발견

### Test 3: 복잡한 시스템 + 불확실성
- 다중 layer 실패, root cause를 찾을 수 있을지 불분명
- **결과:** 체계적 조사, 모든 layer를 추적, source 발견

### Test 4: 첫 Fix 실패
- hypothesis가 동작 안 함, 더 많은 fix 추가 유혹
- **결과:** 멈춤, 재분석, 새 hypothesis 형성 (shotgun 없음)

**모든 test 통과.** 합리화 발견되지 않음.

## 반복

### 초기 버전
- 완전한 4-phase framework
- Anti-pattern 섹션
- "fix 실패" 결정에 대한 flowchart

### Enhancement 1: TDD 참조
- skills/testing/test-driven-development에 대한 링크 추가
- TDD의 "simplest code" ≠ debugging의 "root cause"를 설명하는 note
- 방법론 간 혼동 방지

## 최종 결과

다음과 같은 bulletproof skill:
- ✅ root cause 조사를 명확히 명령
- ✅ 시간 압박 합리화에 저항
- ✅ 각 phase에 구체적 단계 제공
- ✅ anti-pattern을 명시적으로 보여줌
- ✅ 여러 압박 시나리오에서 테스트됨
- ✅ TDD와의 관계 명확화
- ✅ 사용 준비 완료

## 핵심 통찰

**가장 중요한 bulletproofing:** 그 순간 정당화되어 보이는 정확한 shortcut을 보여주는 anti-pattern 섹션. Claude가 "이 빠른 fix 하나만 추가할게"라고 생각할 때, 그 정확한 패턴이 잘못된 것으로 나열된 것을 보면 인지적 마찰이 생깁니다.

## 사용 예시

bug를 마주쳤을 때:
1. skill 로드: skills/debugging/systematic-debugging
2. overview 읽기 (10초) - 명령을 상기
3. Phase 1 체크리스트 따르기 - 강제된 조사
4. 건너뛰고 싶을 때 - anti-pattern을 보고, 멈춤
5. 모든 phase 완료 - root cause 발견

**시간 투자:** 5-10분
**시간 절약:** 증상 두더지 잡기에 쓸 몇 시간

---

*Created: 2025-10-03*
*목적: skill 추출과 bulletproofing을 위한 참조 예시*
