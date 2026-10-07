# 좋은 test 작성하기

**이 참조 자료를 로드해야 할 때:** test를 작성하거나 변경할 때, mock을 추가할 때, 또는
test용 정리/헬퍼 메서드를 추가할 때.

## 개요

test는 구체적인 깨짐을 잡아내기 위해 존재합니다. 여기의 모든 내용은 두 가지 원칙을
따릅니다:

```
1. 모든 test는 자신이 잡아내는 깨짐을 특정한다
2. 모든 test는 실제 대상을 실행한다
```

엄격한 TDD를 따르면 둘 다 자연스럽게 지켜집니다. 먼저 작성되어 실제 코드에 대해
실패하는 것을 확인한 test는 실패할 수 있음을 이미 증명했고, 실제 의존성이 느리거나
외부에 있다고 드러날 때에만 mock을 쓸 자격을 얻습니다.

## 원칙 1: 깨짐을 특정하기

test 본문을 작성하기 전에 답하세요: **어떤 production 변경이 이 test를 실패시켜야
하는가 — 그리고 그 변경은 버그인가, 결정인가?** test는 잘못된 분기, 누락된 side
effect, 잘못된 인자, 경계 case, 깨진 계약을 잡아낼 때 존재 이유를 얻습니다.

**기대값은 독립적으로 도출하세요.** literal과 손으로 검증한 fixture를 사용하세요.
literal `want` 값을 가진 table-driven test가 권장하는 형태입니다. test 대상 코드나
그 헬퍼가 계산한 기대값은 그 코드가 무엇을 하든 통과합니다:

```typescript
// ❌ 거울(mirror) assertion: 같은 builder가 양쪽을 계산함 — 항상 참
const expected = buildSearchQuery({ tag: 'urgent' });
expect(buildSearchQuery({ tag: 'urgent' })).toBe(expected);

// ✅ 손으로 도출한 literal
expect(buildSearchQuery({ tag: 'urgent' })).toBe('tag:"urgent"');
```

**change detector 금지.** 의도적인 결정 — 상수의 값, 메시지의 정확한 문구, private
구조 — 만이 test를 실패시킬 수 있다면, 그 test는 재설계 때마다 울리고 버그 앞에서는
잠들어 있습니다. 그 결정에 의존하는 동작을 test하세요. `expect(MAX_RETRIES).toBe(5)`가
아니라 "실패한 호출은 5번 재시도되고 6번째 시도는 절대 일어나지 않는다"를 test하세요.

**텍스트가 아니라 동작.** script, skill, config가 정확한 한 줄을 포함한다고
assert하는 것은 소스가 소스라는 것만 증명합니다. script는 통제된 입력으로 실행하고
출력, side effect, 종료 코드를 assert하세요. agent에게 지시하는 문서는 그 문서를
소비하는 agent의 동작으로 test합니다(suberpower:writing-skills). 사람을 위한 산문은
test가 전혀 필요 없습니다.

**프레임워크가 아니라 당신의 코드.** 코드가 경계에서 맺는 계약을 test하세요 — 등록한
route, 내보내는 query, 생성하는 payload. upstream의 메커니즘은 그 maintainer가 작성할
test입니다(전형적인 예: 라우터가 등록된 handler를 호출하는지 assert하는 것 — 그것은
당신의 test가 아니라 프레임워크의 test입니다). upstream 동작이 정말로 예상 밖이었다면,
그 가정을 명시하는 좁은 characterization test 하나를 작성하세요. 같은 경계는 당신의
코드 내부에도 적용됩니다. 생성자, getter, 상수, 단순 전달은 검증, 정규화, 기본값 지정,
파생, 강제, side effect 유발을 할 때에만 test 대상이 됩니다. 그렇지 않다면 그것에
의존하는, 소비자에게 처음 보이는 결과를 assert하세요.

### 게이트 함수

```
BEFORE - test 본문을 작성하기 전:
  이 test를 실패시킬 production 변경을 구체적으로 말할 것.

  특정할 수 없음            → 관찰 가능한 동작을 중심으로 재설계할 것
  "소스 텍스트가 바뀌었다"  → 산출물을 실행하고 그 효과를 assert할 것
  의도적 결정뿐임           → change detector임; 그 결정에 의존하는
                              동작을 test할 것

  기대값이 test 대상 코드 없이 도출되었는지 확인할 것.
  IF 코드의 로직이나 헬퍼를 재사용한다면:
    literal이나 손으로 검증한 fixture로 교체할 것
```

## 원칙 2: 실제 대상을 실행하기

**mock은 assertion의 대상이 될 수 없습니다.** mock assertion은 mock이 있으면 통과하고
없으면 실패합니다 — 컴포넌트에 대해서는 아무것도 말해주지 않습니다. 실제 컴포넌트의
동작을 assert하세요. 확인하고 있는 것이 mock이라면, mock을 해제하거나 assertion을
삭제하세요.

```typescript
// ✅ 실제 동작
expect(screen.getByRole('navigation')).toBeInTheDocument();

// ❌ mock의 존재
expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument();
```

**your human partner의 지적:** "우리가 mock의 동작을 test하고 있나요?"

**올바른 레벨에서 mock하세요.** 실제 메서드를 대체하기 전에 그 메서드의 side effect를
모두 파악하세요. 느리거나 외부에 있는 작업을 mock하고, test가 의존하는 것은 실제로
유지하세요. 확실하지 않다면, 먼저 실제 구현으로 test를 실행해 무엇이 실제로 일어나야
하는지 관찰하세요.

```typescript
// ❌ 중복 감지가 읽는 config 쓰기를 mock이 삼켜버림
vi.mock('ToolCatalog', () => ({
  discoverAndCacheTools: vi.fn().mockResolvedValue(undefined)
}));

// ✅ 느린 서버 시작만 mock, config 쓰기는 실제로 유지
vi.mock('MCPServerManager');
```

**test double을 구체적으로 만드세요.** 인자, 호출 횟수, 순서가 계약의 일부라면 그것을
assert하세요 — 무엇이든 받아들이는 fake는 아무것도 검증하지 못합니다. 각 분기(성공,
에러, 잘못된 형식)에 별도의 fixture나 spy를 주어, 잘못된 분기가 기대값을 충족할 수
없게 하세요.

**실제 데이터를 완전하게 반영하세요.** test가 읽는 필드만이 아니라 실제로 존재하는
구조 전체 — 문서화된 모든 필드 — 를 mock하세요. 부분적 mock은 downstream 코드가 생략된
필드를 읽을 때 조용히 실패합니다. test는 통과하지만 integration은 깨집니다.

**production 클래스에는 production 메서드만 둡니다.** test에서만 필요한 정리 코드는
test 유틸리티에 두고, production 클래스의 `destroy()` 같은 형태로 절대 두지
마세요. 질문하세요: 이 메서드는 test에서만 호출되는가? 이 클래스가 이 리소스의
lifecycle을 소유하는가? 첫 질문에 "예", 두 번째에 "아니오"라면 → test 유틸리티로.

**복잡한 mock보다 실제 컴포넌트를 선호하세요.** mock setup이 test 로직보다 커지거나,
mock이 실제 컴포넌트에 있는 메서드를 놓치거나, mock이 바뀔 때 test가 깨진다면, 실제
컴포넌트를 사용하는 integration test로 전환하세요. **your human partner의 질문:**
"여기서 mock을 사용해야 하나요?"

### 게이트 함수

```
BEFORE - mock이나 test 헬퍼를 추가하기 전:
  실제 메서드의 side effect를 나열할 것. test가 의존하는 것은
  실제로 유지하고 — 그 아래의 느린/외부 레벨을 mock할 것.

  mock response는 실제 구조 전체를 반영할 것.

  test에서만 호출하는 메서드는 production이 아니라 test 유틸리티에 둘 것.

  mock 자체에 assert하려는 참인가?
    mock을 해제하거나 assertion을 삭제할 것.
```

## test는 implementation과 함께 내보냅니다

TDD 사이클 — 실패하는 test, 최소 implementation, 리팩터링 — 이 "완료"의 의미입니다.
동작에 필요한 test를, 그리고 그것만 함께 내보내세요. 사소한 코드와 사람을 위한 산문은
test가 필요 없고, 절차를 채우려고 작성한 test는 영원히 유지보수 비용을 치르게 합니다.

## Mutation 점검

마무리하기 전에, production 코드를 머릿속으로 변형(mutate)해 보세요. 현실적인 변형
각각에 대해 적어도 하나의 test가 실패해야 합니다:

- 잘못된 상수나 인자
- 잘못된 분기 handler
- 누락된 상태 변경이나 side effect
- 빈 값 또는 기본값 반환
- 0, 빈 값, nil, 권한 없음, 잘못된 형식 입력에 대한 검증 누락

아무것도 잡아내지 못하는 변형은 그 동작이 보호받지 못하고 있다는 표시입니다 — 또는
test가 동어반복이라는 표시입니다.

## 빠른 참조

| 이럴 때... | 할 일 |
|-------------|-----|
| 어떤 test든 작성할 때 | 잡아내는 깨짐을 특정 — 결정이 아니라 버그 |
| 기대값을 만들 때 | 손으로 도출, test 대상 코드로 절대 만들지 않음 |
| script나 문서를 test할 때 | 실행하거나 / 소비자를 압박 테스트, 텍스트를 절대 grep하지 않음 |
| 의존성 test에 손이 갈 때 | 문서화된 그쪽 메커니즘이 아니라 당신의 경계 계약을 test |
| mock된 요소에 assert하고 싶을 때 | 실제 컴포넌트를 test하거나 mock을 해제 |
| 메서드를 mock하려 할 때 | side effect를 파악하고, 느린/외부 레벨을 mock |
| mock response를 만들 때 | 실제 구조를 완전하게 반영 |
| test에서만 쓰는 정리 코드가 필요할 때 | test 유틸리티에 둠 |
| mock setup이 불어나는 것이 보일 때 | 실제 컴포넌트를 사용하는 integration test로 전환 |
| test 파일을 마무리할 때 | mutation 점검을 실행 |

## 경고 신호

- setup과 assertion이 같은 객체를 공유해 동일함이 보장됨
- panic, crash, 누락된 selector를 통해서만 test가 실패할 수 있음
- 모든 의도적 변경에는 test가 실패하지만, 우발적인 깨짐에는 절대 실패하지 않음
- 기대값이 루프, builder, 헬퍼 뒤에 숨어 있음
- test가 소스 텍스트를 grep하거나, 제거된 symbol이 계속 제거되어 있는지 assert함
- 프레임워크만 남아도 test가 여전히 의미가 있음
- test가 coverage를 위해 존재하고, 어떤 side effect나 결과도 확인하지 않음
- assertion이 `*-mock` test ID를 확인하거나, mock을 제거하면 실패함
- 메서드가 test 파일에서만 호출됨
- mock setup이 test의 절반 이상이거나, 왜 mock이 필요한지 설명할 수 없음
- "안전을 위해" mock함
