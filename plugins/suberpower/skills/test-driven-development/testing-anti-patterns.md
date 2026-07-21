# Testing Anti-Patterns

**이 참조 자료를 로드해야 할 때:** test를 작성하거나 변경할 때, mock을 추가할 때, 또는 production 코드에 test 전용 메서드를 추가하려는 유혹이 들 때.

## 개요

test는 mock의 동작이 아니라 실제 동작을 검증해야 합니다. mock은 격리하기 위한 수단이지, test 대상이 아닙니다.

**핵심 원칙:** mock이 무엇을 하는지가 아니라 코드가 무엇을 하는지 test하세요.

**엄격한 TDD를 따르면 이러한 anti-pattern을 방지합니다.**

## 철의 법칙들

```
1. NEVER - mock의 동작을 test하지 말 것
2. NEVER - production 클래스에 test 전용 메서드를 추가하지 말 것
3. NEVER - 의존성을 이해하지 않고 mock하지 말 것
```

## Anti-Pattern 1: mock 동작 test

**위반:**
```typescript
// ❌ BAD: mock이 존재하는지 test
test('renders sidebar', () => {
  render(<Page />);
  expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument();
});
```

**왜 잘못되었나:**
- 컴포넌트가 작동하는 것이 아니라 mock이 작동하는 것을 검증함
- mock이 있으면 test 통과, 없으면 실패
- 실제 동작에 대해 아무것도 알려주지 않음

**human partner의 지적:** "우리가 mock의 동작을 test하고 있나요?"

**수정:**
```typescript
// ✅ GOOD: 실제 컴포넌트를 test하거나 mock하지 않기
test('renders sidebar', () => {
  render(<Page />);  // sidebar를 mock하지 않음
  expect(screen.getByRole('navigation')).toBeInTheDocument();
});

// 또는 격리를 위해 sidebar를 반드시 mock해야 한다면:
// mock에 대해 assert하지 않음 - sidebar가 있는 상태에서 Page의 동작을 test
```

### 게이트 함수

```
BEFORE - mock 요소에 대해 assert하기 전:
  질문: "실제 컴포넌트의 동작을 test하고 있는가, 아니면 그저 mock의 존재를 test하고 있는가?"

  IF mock의 존재를 test하고 있다면:
    STOP - assertion을 삭제하거나 컴포넌트의 mock을 해제할 것

  대신 실제 동작을 test할 것
```

## Anti-Pattern 2: production의 test 전용 메서드

**위반:**
```typescript
// ❌ BAD: destroy()는 test에서만 사용
class Session {
  async destroy() {  // production API처럼 보임!
    await this._workspaceManager?.destroyWorkspace(this.id);
    // ... 정리
  }
}

// test에서
afterEach(() => session.destroy());
```

**왜 잘못되었나:**
- production 클래스가 test 전용 코드로 오염됨
- production에서 실수로 호출되면 위험
- YAGNI와 관심사 분리 위반
- 객체 lifecycle과 엔티티 lifecycle을 혼동

**수정:**
```typescript
// ✅ GOOD: test 유틸리티가 test 정리를 처리
// Session은 destroy() 없음 - production에서 무상태

// test-utils/
export async function cleanupSession(session: Session) {
  const workspace = session.getWorkspaceInfo();
  if (workspace) {
    await workspaceManager.destroyWorkspace(workspace.id);
  }
}

// test에서
afterEach(() => cleanupSession(session));
```

### 게이트 함수

```
BEFORE - production 클래스에 메서드를 추가하기 전:
  질문: "이것은 test에서만 사용되는가?"

  IF 그렇다면:
    STOP - 추가하지 말 것
    대신 test 유틸리티에 넣을 것

  질문: "이 클래스가 이 리소스의 lifecycle을 소유하는가?"

  IF 아니라면:
    STOP - 이 메서드에는 잘못된 클래스임
```

## Anti-Pattern 3: 이해 없이 mock하기

**위반:**
```typescript
// ❌ BAD: mock이 test 로직을 깨뜨림
test('detects duplicate server', () => {
  // mock이 test가 의존하는 config 쓰기를 막음!
  vi.mock('ToolCatalog', () => ({
    discoverAndCacheTools: vi.fn().mockResolvedValue(undefined)
  }));

  await addServer(config);
  await addServer(config);  // throw해야 하지만 - 안 함!
});
```

**왜 잘못되었나:**
- mock된 메서드가 test가 의존하는 side effect (config 쓰기)를 가짐
- "안전하게" 하려고 과도하게 mock하면 실제 동작이 깨짐
- test가 잘못된 이유로 통과하거나 알 수 없게 실패

**수정:**
```typescript
// ✅ GOOD: 올바른 레벨에서 mock
test('detects duplicate server', () => {
  // 느린 부분만 mock, test가 필요로 하는 동작은 보존
  vi.mock('MCPServerManager'); // 느린 서버 시작만 mock

  await addServer(config);  // config 작성됨
  await addServer(config);  // 중복 감지됨 ✓
});
```

### 게이트 함수

```
BEFORE - 어떤 메서드든 mock하기 전:
  STOP - 아직 mock하지 말 것

  1. 질문: "실제 메서드는 어떤 side effect를 가지는가?"
  2. 질문: "이 test가 그 side effect 중 어느 하나에라도 의존하는가?"
  3. 질문: "이 test가 무엇을 필요로 하는지 완전히 이해하고 있는가?"

  IF side effect에 의존한다면:
    더 낮은 레벨에서 mock할 것 (실제로 느리거나 외부에 있는 작업)
    OR 필요한 동작을 보존하는 test double을 사용할 것
    NOT test가 의존하는 상위 레벨 메서드를 mock하는 것

  IF test가 무엇에 의존하는지 확실하지 않다면:
    FIRST 실제 구현으로 test를 실행할 것
    무엇이 실제로 일어나야 하는지 관찰할 것
    THEN 올바른 레벨에서 최소한의 mocking을 추가할 것

  위험 신호:
    - "안전하게 하려고 이걸 mock해야지"
    - "이건 느릴 수 있으니 mock하는 게 낫겠어"
    - 의존성 사슬을 이해하지 않고 mocking하는 것
```

## Anti-Pattern 4: 불완전한 mock

**위반:**
```typescript
// ❌ BAD: 부분적 mock - 필요하다고 생각한 필드만
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' }
  // 누락: downstream 코드가 사용하는 metadata
};

// 나중에: 코드가 response.metadata.requestId에 접근할 때 깨짐
```

**왜 잘못되었나:**
- **부분적 mock은 구조적 가정을 숨김** - 알고 있는 필드만 mock함
- **downstream 코드가 포함하지 않은 필드에 의존할 수 있음** - 조용한 실패
- **test는 통과하지만 integration이 실패** - mock은 불완전, 실제 API는 완전
- **잘못된 확신** - test가 실제 동작에 대해 아무것도 증명하지 못함

**철의 법칙:** 지금 작성 중인 test가 사용하는 필드뿐만 아니라 실제로 존재하는 COMPLETE 데이터 구조를 mock하세요.

**수정:**
```typescript
// ✅ GOOD: 실제 API 완전성을 반영
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' },
  metadata: { requestId: 'req-789', timestamp: 1234567890 }
  // 실제 API가 반환하는 모든 필드
};
```

### 게이트 함수

```
BEFORE - mock response를 만들기 전:
  확인: "실제 API response는 어떤 필드를 포함하는가?"

  할 일:
    1. 문서/예제에서 실제 API response를 조사할 것
    2. 시스템이 downstream에서 사용할 수 있는 ALL 필드를 포함할 것
    3. mock이 실제 response 스키마와 완전히 일치하는지 검증할 것

  중요:
    mock을 만든다면 ENTIRE 구조를 이해해야 함
    부분적 mock은 코드가 생략된 필드에 의존할 때 조용히 실패함

  확실하지 않다면: 문서화된 모든 필드를 포함할 것
```

## Anti-Pattern 5: 사후 고려된 integration test

**위반:**
```
✅ Implementation 완료
❌ test 미작성
"test 준비 완료"
```

**왜 잘못되었나:**
- testing은 implementation의 일부이지, 선택적 후속 작업이 아님
- TDD는 이것을 잡았을 것
- test 없이 완료를 주장할 수 없음

**수정:**
```
TDD 사이클:
1. 실패하는 test 작성
2. 통과하도록 implementation
3. 리팩터링
4. 그 후에 완료를 주장
```

## mock이 너무 복잡해질 때

**경고 신호:**
- mock setup이 test 로직보다 길어짐
- test를 통과시키기 위해 모든 것을 mock
- mock이 실제 컴포넌트의 메서드를 놓침
- mock이 변경되면 test가 깨짐

**human partner의 질문:** "여기서 mock을 사용해야 하나요?"

**고려:** 실제 컴포넌트를 사용하는 integration test가 복잡한 mock보다 종종 더 단순함

## TDD가 이러한 anti-pattern을 방지합니다

**TDD가 도움이 되는 이유:**
1. **test 먼저 작성** → 실제로 무엇을 test하는지 생각하게 강제함
2. **실패 확인** → test가 mock이 아닌 실제 동작을 test함을 확인
3. **최소 implementation** → test 전용 메서드가 슬며시 들어오지 않음
4. **실제 의존성** → mock 전에 test가 실제로 무엇을 필요로 하는지 확인

**mock 동작을 test하고 있다면, TDD를 위반한 것입니다** - 실제 코드에 대해 test가 실패하는 것을 보지 않고 mock을 추가한 것입니다.

## 빠른 참조

| Anti-Pattern | 수정 |
|--------------|-----|
| mock 요소에 대한 assert | 실제 컴포넌트를 test하거나 mock하지 않기 |
| production의 test 전용 메서드 | test 유틸리티로 이동 |
| 이해 없는 mock | 의존성을 먼저 이해, 최소한으로 mock |
| 불완전한 mock | 실제 API를 완전하게 반영 |
| 사후 고려된 test | TDD - test 먼저 |
| 과도하게 복잡한 mock | integration test 고려 |

## 위험 신호

- `*-mock` test ID에 대한 assertion
- test 파일에서만 호출되는 메서드
- mock setup이 test의 50% 이상
- mock을 제거하면 test가 실패
- 왜 mock이 필요한지 설명 못 함
- "안전을 위해" mocking

## 결론

**mock은 격리하기 위한 도구이지, test할 대상이 아닙니다.**

TDD가 mock 동작을 test하고 있음을 드러낸다면, 잘못된 길로 간 것입니다.

수정: 실제 동작을 test하거나, 왜 mock하는지 자체를 의심하세요.
