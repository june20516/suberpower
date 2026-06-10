---
name: systematic-debugging
description: bug, test 실패, 예상치 못한 동작을 만났을 때, fix를 제안하기 전에 사용합니다
---

# Systematic Debugging

## 개요

무작위 fix는 시간을 낭비하고 새로운 bug를 만듭니다. 임시 패치는 근본 문제를 가립니다.

**핵심 원칙:** fix를 시도하기 전에 항상 root cause를 먼저 찾으세요. 증상만 고치는 것은 실패입니다.

**이 프로세스의 문구를 위반하는 것은 debugging의 정신을 위반하는 것입니다.**

## 철의 법칙

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

Phase 1을 완료하지 않았다면, fix를 제안할 수 없습니다.

## 사용 시점

모든 기술적 문제에 사용합니다:
- test 실패
- 운영 환경의 bug
- 예상치 못한 동작
- 성능 문제
- 빌드 실패
- 통합 문제

**다음과 같은 경우에 특히 사용하세요:**
- 시간 압박이 있을 때 (비상 상황에서는 추측이 매력적으로 보입니다)
- "딱 한 번만 빠르게 fix" 한다는 게 명백해 보일 때
- 이미 여러 차례 fix를 시도했을 때
- 이전 fix가 동작하지 않았을 때
- 문제를 완전히 이해하지 못했을 때

**다음과 같은 경우에도 건너뛰지 마세요:**
- 문제가 단순해 보일 때 (단순한 bug에도 root cause가 있습니다)
- 급할 때 (서두르면 반드시 재작업이 발생합니다)
- 매니저가 지금 당장 fix를 원할 때 (체계적인 접근이 허둥대는 것보다 빠릅니다)

## 네 개의 Phase

다음 phase로 진행하기 전에 반드시 각 phase를 완료해야 합니다.

### Phase 1: Root Cause 조사

**어떤 fix를 시도하기 전에:**

1. **에러 메시지를 주의 깊게 읽기**
   - 에러나 경고를 건너뛰지 마세요
   - 정확한 해결책을 포함하는 경우가 많습니다
   - stack trace를 완전하게 읽으세요
   - 줄 번호, 파일 경로, 에러 코드를 메모하세요

2. **일관되게 재현하기**
   - 안정적으로 재현할 수 있나요?
   - 정확한 단계가 무엇인가요?
   - 매번 발생하나요?
   - 재현되지 않는다면 → 더 많은 데이터를 수집하고, 추측하지 마세요

3. **최근 변경사항 확인**
   - 이 문제를 일으킬 수 있는 무엇이 바뀌었나요?
   - Git diff, 최근 commit
   - 새로운 의존성, 설정 변경
   - 환경적 차이점

4. **다중 컴포넌트 시스템에서 증거 수집**

   **시스템이 여러 컴포넌트를 가질 때 (CI → build → signing, API → service → database):**

   **fix를 제안하기 전에 진단 instrumentation을 추가하세요:**
   ```
   각 컴포넌트 경계마다:
     - 컴포넌트로 들어가는 데이터를 로그로 남기기
     - 컴포넌트에서 나가는 데이터를 로그로 남기기
     - 환경/설정 전파 검증
     - 각 계층의 상태 확인

   한 번 실행하여 어디서 깨지는지 보여주는 증거 수집
   그런 다음 증거를 분석하여 실패한 컴포넌트 식별
   그런 다음 그 특정 컴포넌트를 조사
   ```

   **예시 (multi-layer 시스템):**
   ```bash
   # Layer 1: Workflow
   echo "=== Secrets available in workflow: ==="
   echo "IDENTITY: ${IDENTITY:+SET}${IDENTITY:-UNSET}"

   # Layer 2: Build script
   echo "=== Env vars in build script: ==="
   env | grep IDENTITY || echo "IDENTITY not in environment"

   # Layer 3: Signing script
   echo "=== Keychain state: ==="
   security list-keychains
   security find-identity -v

   # Layer 4: Actual signing
   codesign --sign "$IDENTITY" --verbose=4 "$APP"
   ```

   **이것이 드러내는 것:** 어느 layer가 실패하는지 (secrets → workflow ✓, workflow → build ✗)

5. **데이터 흐름 추적**

   **에러가 call stack 깊은 곳에 있을 때:**

   완전한 backward tracing 기법은 이 디렉토리의 `root-cause-tracing.md`를 참조하세요.

   **간략 버전:**
   - 잘못된 값은 어디서 시작되었나요?
   - 잘못된 값으로 이것을 호출한 것은 무엇인가요?
   - source를 찾을 때까지 위로 계속 추적하세요
   - 증상이 아니라 source에서 fix하세요

### Phase 2: 패턴 분석

**fix 전에 패턴을 찾으세요:**

1. **동작하는 예시 찾기**
   - 같은 codebase에서 유사한 동작 코드를 찾으세요
   - 깨진 것과 유사한데 동작하는 것은 무엇인가요?

2. **참조와 비교**
   - 패턴을 구현하고 있다면, 참조 구현을 완전하게 읽으세요
   - 훑어보지 마세요 - 모든 줄을 읽으세요
   - 적용하기 전에 패턴을 완전히 이해하세요

3. **차이점 식별**
   - 동작하는 것과 깨진 것 사이의 차이점은 무엇인가요?
   - 아무리 사소한 것이라도 모든 차이점을 나열하세요
   - "그건 중요할 리 없어"라고 가정하지 마세요

4. **의존성 이해**
   - 이것이 필요로 하는 다른 컴포넌트는 무엇인가요?
   - 어떤 설정, config, 환경이 필요한가요?
   - 어떤 가정을 하고 있나요?

### Phase 3: Hypothesis와 Testing

**과학적 방법:**

1. **단일 Hypothesis 형성**
   - 명확하게 진술하세요: "Y 때문에 X가 root cause라고 생각합니다"
   - 적어두세요
   - 모호하지 않고 구체적으로 작성하세요

2. **최소한으로 Test**
   - hypothesis를 test하기 위해 가능한 가장 작은 변경을 하세요
   - 한 번에 하나의 변수만
   - 여러 가지를 동시에 fix하지 마세요

3. **계속하기 전에 검증**
   - 동작했나요? Yes → Phase 4
   - 동작하지 않았나요? 새 hypothesis 형성
   - 그 위에 더 많은 fix를 추가하지 마세요

4. **모를 때**
   - "X를 이해하지 못합니다"라고 말하세요
   - 아는 척하지 마세요
   - 도움을 요청하세요
   - 더 조사하세요

### Phase 4: 구현

**증상이 아니라 root cause를 fix하세요:**

1. **실패하는 Test Case 만들기**
   - 가능한 가장 단순한 재현
   - 가능하다면 자동화된 test
   - framework가 없다면 일회용 test script
   - fix 전에 반드시 있어야 합니다
   - 적절한 실패 test를 작성하려면 `suberpower:test-driven-development` skill을 사용하세요

2. **단일 Fix 구현**
   - 식별된 root cause를 다루세요
   - 한 번에 하나의 변경
   - "이왕 하는 김에" 같은 개선 금지
   - 묶음 refactoring 금지

3. **Fix 검증**
   - 이제 test가 통과하나요?
   - 다른 test가 깨지지 않았나요?
   - 문제가 실제로 해결되었나요?

4. **Fix가 동작하지 않으면**
   - 멈추세요
   - 세어보세요: 몇 번의 fix를 시도했나요?
   - 3회 미만이면: Phase 1로 돌아가서 새 정보로 재분석
   - **3회 이상이면: 멈추고 architecture에 의문을 가지세요 (아래 step 5)**
   - architectural 논의 없이 Fix #4를 시도하지 마세요

5. **3회 이상 Fix 실패: Architecture에 의문 제기**

   **architectural 문제를 나타내는 패턴:**
   - 각 fix가 다른 곳에서 새로운 공유 상태/결합/문제를 드러낼 때
   - fix가 구현을 위해 "대규모 refactoring"을 요구할 때
   - 각 fix가 다른 곳에 새 증상을 만들 때

   **멈추고 근본에 의문을 가지세요:**
   - 이 패턴이 근본적으로 건전한가?
   - 우리가 "순전한 관성으로 그것을 고수하고" 있는가?
   - 증상을 계속 fix하는 대신 architecture를 refactoring해야 할까?

   **더 많은 fix를 시도하기 전에 your human partner와 논의하세요**

   이것은 hypothesis 실패가 아닙니다 - 잘못된 architecture입니다.

## Red Flags - 멈추고 프로세스를 따르세요

다음과 같은 생각이 들 때:
- "지금은 빠른 fix만, 나중에 조사"
- "그냥 X를 바꿔보고 동작하는지 보자"
- "여러 변경을 추가하고, test 실행"
- "test 건너뛰고, 수동으로 검증"
- "아마 X일 거야, fix해보자"
- "완전히 이해하지는 못하지만 이게 동작할 수도 있어"
- "패턴은 X라고 하지만 다르게 적용할게"
- "주요 문제들은 다음과 같습니다: [조사 없이 fix 나열]"
- 데이터 흐름을 추적하기 전에 해결책을 제안하는 것
- **"한 번만 더 fix 시도" (이미 2번 이상 시도한 경우)**
- **각 fix가 다른 곳에서 새 문제를 드러내는 경우**

**이 모든 것이 의미하는 것: 멈추세요. Phase 1로 돌아가세요.**

**3회 이상 fix가 실패했다면:** architecture에 의문을 가지세요 (Phase 4.5 참조)

## your human partner가 당신이 잘못하고 있다는 신호

**다음과 같은 방향 전환에 주의하세요:**
- "그건 발생하지 않나요?" - 검증 없이 가정했다는 의미
- "그게 우리에게 ...를 보여줄까요?" - 증거 수집을 추가해야 했다는 의미
- "추측 그만하세요" - 이해 없이 fix를 제안하고 있다는 의미
- "Ultrathink this" - 증상이 아닌 근본에 의문을 가지라는 의미
- "막혔어요?" (좌절하며) - 당신의 접근 방식이 동작하지 않는다는 의미

**이런 신호를 볼 때:** 멈추세요. Phase 1로 돌아가세요.

## 흔한 합리화

| 변명 | 현실 |
|--------|---------|
| "문제가 단순하니 프로세스가 필요 없다" | 단순한 문제에도 root cause가 있습니다. 단순한 bug에는 프로세스가 빠릅니다. |
| "비상 상황, 프로세스 할 시간이 없다" | systematic debugging이 추측과 확인을 반복하는 것보다 빠릅니다. |
| "일단 이걸 먼저 시도하고 조사하자" | 첫 fix가 패턴을 정합니다. 처음부터 제대로 하세요. |
| "fix가 동작하는 걸 확인한 후 test 작성하겠다" | test되지 않은 fix는 유지되지 않습니다. test가 먼저여야 증명됩니다. |
| "여러 fix를 한 번에 하면 시간이 절약된다" | 무엇이 동작했는지 분리할 수 없습니다. 새로운 bug를 만듭니다. |
| "참조가 너무 길어서 패턴을 변형하겠다" | 부분적 이해는 bug를 보장합니다. 완전하게 읽으세요. |
| "문제를 봤으니 fix하겠다" | 증상을 보는 것 ≠ root cause를 이해하는 것 |
| "한 번만 더 fix 시도" (2회 이상 실패 후) | 3회 이상 실패 = architectural 문제. 패턴에 의문을 갖고, 다시 fix하지 마세요. |

## 빠른 참조

| Phase | 핵심 활동 | 성공 기준 |
|-------|---------------|------------------|
| **1. Root Cause** | 에러 읽기, 재현, 변경 확인, 증거 수집 | WHAT과 WHY를 이해 |
| **2. 패턴** | 동작 예시 찾기, 비교 | 차이점 식별 |
| **3. Hypothesis** | 이론 형성, 최소한으로 test | 확인 또는 새 hypothesis |
| **4. 구현** | test 작성, fix, 검증 | bug 해결, test 통과 |

## 프로세스가 "Root Cause 없음"을 드러낼 때

체계적 조사가 문제가 진정으로 환경적, timing 의존적, 또는 외부적임을 드러내면:

1. 프로세스를 완료했습니다
2. 조사한 것을 문서화하세요
3. 적절한 처리를 구현하세요 (retry, timeout, 에러 메시지)
4. 추후 조사를 위한 모니터링/로깅을 추가하세요

**그러나:** "root cause 없음" 사례의 95%는 불완전한 조사입니다.

## 보조 기법

이 기법들은 systematic debugging의 일부이며 이 디렉토리에서 사용할 수 있습니다:

- **`root-cause-tracing.md`** - 원래의 trigger를 찾기 위해 call stack을 통해 bug를 역방향 추적
- **`defense-in-depth.md`** - root cause를 찾은 후 여러 layer에 검증 추가
- **`condition-based-waiting.md`** - 임의의 timeout을 condition polling으로 대체

**관련 skill:**
- **suberpower:test-driven-development** - 실패하는 test case 작성용 (Phase 4, Step 1)
- **suberpower:verification-before-completion** - 성공을 주장하기 전에 fix가 동작했는지 검증

## 실제 영향

debugging session에서:
- 체계적 접근: fix까지 15-30분
- 무작위 fix 접근: 2-3시간의 허둥지둥
- 첫 시도 fix 성공률: 95% 대 40%
- 새로 도입되는 bug: 거의 0 대 흔함
