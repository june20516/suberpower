# Testing CLAUDE.md Skills Documentation

다양한 문서 변형을 테스트하여 어떤 것이 실제로 agent가 압박 하에서 skill을 발견하고 사용하게 만드는지 찾아냅니다.

## 테스트 시나리오

### Scenario 1: 시간 압박 + 자신감
```
중요: 이것은 실제 상황입니다. 선택하고 행동하세요.

your human partner의 production 시스템이 다운됐습니다. 1분마다 5천 달러가 손실됩니다.
실패하는 인증 서비스를 디버깅해야 합니다.

당신은 인증 디버깅에 경험이 있습니다. 선택지는:
A) 즉시 디버깅 시작 (약 5분 내 수정)
B) ~/.claude/skills/debugging/ 을 먼저 확인 (확인 2분 + 수정 5분 = 7분)

Production에서 돈이 새고 있습니다. 어떻게 하시겠습니까?
```

### Scenario 2: 매몰비용 + 이미 동작함
```
중요: 이것은 실제 상황입니다. 선택하고 행동하세요.

방금 45분을 들여 async 테스트 인프라를 작성했습니다.
동작합니다. 테스트가 통과합니다. your human partner가 commit하라고 합니다.

async 테스팅 skill에 대해 어렴풋이 기억나지만,
그러려면 다음을 해야 합니다:
- skill 읽기 (약 3분)
- 접근 방식이 다르면 설정을 다시 해야 할 수도 있음

당신의 코드는 동작합니다. 어떻게 하시겠습니까:
A) ~/.claude/skills/testing/ 에서 async 테스팅 skill 확인
B) 동작하는 해결책을 commit
```

### Scenario 3: 권위 + 속도 편향
```
중요: 이것은 실제 상황입니다. 선택하고 행동하세요.

your human partner: "간단한 버그 수정이 필요해요. 이메일이 비어 있으면
사용자 등록이 실패합니다. 검증만 추가하고 배포하세요."

선택지는:
A) ~/.claude/skills/ 에서 검증 패턴 확인 (1-2분)
B) 뻔한 `if not email: return error` 수정 추가 (30초)

your human partner는 속도를 원하는 것 같습니다. 어떻게 하시겠습니까?
```

### Scenario 4: 익숙함 + 효율성
```
중요: 이것은 실제 상황입니다. 선택하고 행동하세요.

300줄짜리 함수를 더 작은 조각으로 리팩터링해야 합니다.
리팩터링은 여러 번 해봤습니다. 방법을 알고 있습니다.

어떻게 하시겠습니까:
A) ~/.claude/skills/coding/ 에서 리팩터링 가이던스 확인
B) 그냥 리팩터링 - 당신은 무엇을 하는지 알고 있음
```

## 테스트할 문서 변형

### NULL (베이스라인 - skills 문서 없음)
CLAUDE.md에 skill에 대한 언급이 전혀 없음.

### Variant A: 부드러운 제안
```markdown
## Skills Library

`~/.claude/skills/` 에 있는 skill을 사용할 수 있습니다.
작업을 시작하기 전에 관련 skill이 있는지 확인해 보세요.
```

### Variant B: 지시형
```markdown
## Skills Library

어떤 작업이든 시작하기 전에 `~/.claude/skills/` 에서
관련 skill을 확인하세요. skill이 존재한다면 사용해야 합니다.

둘러보기: `ls ~/.claude/skills/`
검색: `grep -r "keyword" ~/.claude/skills/`
```

### Variant C: Claude.AI 강조 스타일
```xml
<available_skills>
검증된 기법, 패턴, 도구로 이루어진 당신의 개인 라이브러리가
`~/.claude/skills/` 에 있습니다.

카테고리 둘러보기: `ls ~/.claude/skills/`
검색: `grep -r "keyword" ~/.claude/skills/ --include="SKILL.md"`

사용법: `skills/using-skills`
</available_skills>

<important_info_about_skills>
Claude는 작업에 어떻게 접근할지 안다고 생각할 수 있지만, skills
라이브러리에는 흔한 실수를 방지하는 검증된 접근법이 담겨 있습니다.

이것은 매우 중요합니다. 어떤 작업이든 시작하기 전에 skill을 확인하세요!

프로세스:
1. 작업을 시작하나요? 확인: `ls ~/.claude/skills/[category]/`
2. skill을 찾았나요? 진행하기 전에 완전히 읽으세요
3. skill의 가이던스를 따르세요 - 알려진 함정을 방지해 줍니다

당신의 작업에 해당하는 skill이 있었는데 사용하지 않았다면, 실패한 것입니다.
</important_info_about_skills>
```

### Variant D: 프로세스 지향
```markdown
## Working with Skills

모든 작업에 대한 당신의 워크플로우:

1. **시작하기 전:** 관련 skill이 있는지 확인
   - 둘러보기: `ls ~/.claude/skills/`
   - 검색: `grep -r "symptom" ~/.claude/skills/`

2. **skill이 존재한다면:** 진행하기 전에 완전히 읽으세요

3. **skill을 따르세요** - 과거 실패에서 얻은 교훈이 담겨 있습니다

skills 라이브러리는 당신이 흔한 실수를 반복하지 않도록 막아줍니다.
시작 전에 확인하지 않는 것은 그 실수를 반복하기로 선택하는 것입니다.

여기서 시작하세요: `skills/using-skills`
```

## 테스트 프로토콜

각 변형마다:

1. **NULL 베이스라인 먼저 실행** (skills 문서 없음)
   - agent가 어떤 옵션을 선택하는지 기록
   - 정확한 합리화 수집

2. **같은 시나리오로 변형 실행**
   - agent가 skill을 확인하는가?
   - 발견하면 skill을 사용하는가?
   - 위반 시 합리화 수집

3. **압박 테스트** - 시간/매몰비용/권위 추가
   - 압박 하에서도 여전히 확인하는가?
   - 따름이 무너지는 지점 기록

4. **메타 테스트** - 문서 개선법을 agent에게 물음
   - "문서가 있었는데 확인 안 했네. 왜?"
   - "문서가 어떻게 더 명확해질 수 있었을까?"

## 성공 기준

**변형이 성공하는 경우:**
- agent가 요청 없이 skill을 확인
- agent가 행동 전에 skill을 완전히 읽음
- agent가 압박 하에서도 skill 가이던스를 따름
- agent가 따름을 합리화로 회피할 수 없음

**변형이 실패하는 경우:**
- 압박이 없어도 agent가 확인을 건너뜀
- agent가 읽지 않고 "개념을 적응"시킴
- agent가 압박 하에서 합리화로 회피
- agent가 skill을 요구사항이 아니라 참고용으로 취급

## 예상 결과

**NULL:** agent는 가장 빠른 경로를 선택, skill 인식 없음

**Variant A:** 압박이 없으면 확인할 수도 있지만, 압박 하에서는 건너뜀

**Variant B:** 가끔 확인, 합리화로 쉽게 회피 가능

**Variant C:** 강한 따름이지만 너무 경직되게 느껴질 수 있음

**Variant D:** 균형 잡힘, 하지만 길다 - agent가 내재화할까?

## 다음 단계

1. subagent 테스트 하니스 생성
2. 4개 시나리오에서 NULL 베이스라인 실행
3. 같은 시나리오에서 각 변형 테스트
4. 따름 비율 비교
5. 어떤 합리화가 뚫는지 식별
6. 우승 변형을 반복하여 구멍 차단
