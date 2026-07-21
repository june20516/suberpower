# Defense-in-Depth Validation

## 개요

유효하지 않은 데이터로 인한 bug를 fix할 때, 한 곳에 검증을 추가하는 것으로 충분하게 느껴집니다. 그러나 그 단일 체크는 다른 code path, refactoring, 또는 mock에 의해 우회될 수 있습니다.

**핵심 원칙:** 데이터가 통과하는 모든 layer에서 검증하세요. bug를 구조적으로 불가능하게 만드세요.

## 왜 여러 Layer인가

단일 검증: "bug를 fix했다"
여러 layer: "bug를 불가능하게 만들었다"

다른 layer는 다른 케이스를 잡습니다:
- entry validation은 대부분의 bug를 잡습니다
- business logic은 edge case를 잡습니다
- environment guards는 맥락별 위험을 막습니다
- debug logging은 다른 layer가 실패할 때 도움이 됩니다

## 네 개의 Layer

### Layer 1: Entry Point Validation
**목적:** API 경계에서 명백히 유효하지 않은 입력을 거부

```typescript
function createProject(name: string, workingDirectory: string) {
  if (!workingDirectory || workingDirectory.trim() === '') {
    throw new Error('workingDirectory cannot be empty');
  }
  if (!existsSync(workingDirectory)) {
    throw new Error(`workingDirectory does not exist: ${workingDirectory}`);
  }
  if (!statSync(workingDirectory).isDirectory()) {
    throw new Error(`workingDirectory is not a directory: ${workingDirectory}`);
  }
  // ... proceed
}
```

### Layer 2: Business Logic Validation
**목적:** 데이터가 이 작업에 적합한지 보장

```typescript
function initializeWorkspace(projectDir: string, sessionId: string) {
  if (!projectDir) {
    throw new Error('projectDir required for workspace initialization');
  }
  // ... proceed
}
```

### Layer 3: Environment Guards
**목적:** 특정 맥락에서 위험한 작업 방지

```typescript
async function gitInit(directory: string) {
  // In tests, refuse git init outside temp directories
  if (process.env.NODE_ENV === 'test') {
    const normalized = normalize(resolve(directory));
    const tmpDir = normalize(resolve(tmpdir()));

    if (!normalized.startsWith(tmpDir)) {
      throw new Error(
        `Refusing git init outside temp dir during tests: ${directory}`
      );
    }
  }
  // ... proceed
}
```

### Layer 4: Debug Instrumentation
**목적:** 포렌식을 위한 맥락 캡처

```typescript
async function gitInit(directory: string) {
  const stack = new Error().stack;
  logger.debug('About to git init', {
    directory,
    cwd: process.cwd(),
    stack,
  });
  // ... proceed
}
```

## 패턴 적용

bug를 발견했을 때:

1. **데이터 흐름 추적** - 잘못된 값이 어디서 시작되는가? 어디서 사용되는가?
2. **모든 checkpoint 매핑** - 데이터가 통과하는 모든 지점을 나열
3. **각 layer에 검증 추가** - entry, business, environment, debug
4. **각 layer 테스트** - layer 1을 우회해 보고, layer 2가 잡는지 검증

## Session 예시

bug: 빈 `projectDir`이 소스 코드에서 `git init`을 일으킴

**데이터 흐름:**
1. test setup → 빈 문자열
2. `Project.create(name, '')`
3. `WorkspaceManager.createWorkspace('')`
4. `git init`이 `process.cwd()`에서 실행

**추가된 네 개의 layer:**
- Layer 1: `Project.create()`가 비어 있지 않음/존재함/쓰기 가능함을 검증
- Layer 2: `WorkspaceManager`가 projectDir이 비어 있지 않음을 검증
- Layer 3: `WorktreeManager`가 test에서 tmpdir 외부의 git init을 거부
- Layer 4: git init 전 stack trace 로깅

**결과:** 1847개 모든 test 통과, bug 재현 불가

## 핵심 통찰

네 개 layer 모두 필요했습니다. 테스트 중에 각 layer가 다른 layer가 놓친 bug를 잡았습니다:
- 다른 code path는 entry validation을 우회
- mock은 business logic 체크를 우회
- 다른 플랫폼의 edge case는 environment guards가 필요
- debug logging은 구조적 오용을 식별

**하나의 검증 지점에서 멈추지 마세요.** 모든 layer에 체크를 추가하세요.
