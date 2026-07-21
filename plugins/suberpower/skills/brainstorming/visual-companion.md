# Visual Companion 가이드

mockup, 다이어그램, 옵션을 보여주기 위한 브라우저 기반 시각적 brainstorming 동반자입니다.

## 언제 사용할까

세션별이 아닌 질문별로 결정하세요. 기준: **사용자가 읽는 것보다 보는 것이 더 잘 이해될까?**

콘텐츠 자체가 시각적일 때 **브라우저 사용**:

- **UI mockup** — 와이어프레임, 레이아웃, 내비게이션 구조, 컴포넌트 디자인
- **아키텍처 다이어그램** — 시스템 컴포넌트, 데이터 흐름, 관계 맵
- **나란히 놓인 시각적 비교** — 두 레이아웃, 두 색상 스키마, 두 디자인 방향 비교
- **디자인 다듬기** — 질문이 룩앤필, 간격, 시각적 위계에 관한 것일 때
- **공간적 관계** — 다이어그램으로 렌더링된 상태 머신, 플로우차트, 엔티티 관계

콘텐츠가 텍스트나 표 형식일 때 **터미널 사용**:

- **요구사항과 범위 질문** — "X가 무엇을 의미하는가?", "어떤 기능이 범위에 있는가?"
- **개념적 A/B/C 선택** — 말로 묘사된 접근 방식 중 선택
- **트레이드오프 목록** — 장단점, 비교 표
- **기술적 결정** — API 설계, 데이터 모델링, 아키텍처 접근 방식 선택
- **Clarifying questions** — 답이 시각적 선호가 아닌 단어인 모든 것

UI 주제 *에 대한* 질문이 자동으로 시각적 질문이 되는 것은 아닙니다. "어떤 종류의 마법사를 원하나요?"는 개념적 — 터미널을 사용하세요. "이 마법사 레이아웃 중 어느 것이 적절해 보이나요?"는 시각적 — 브라우저를 사용하세요.

## 작동 방식

서버는 HTML 파일이 있는 디렉토리를 감시하고 가장 최신 파일을 브라우저에 제공합니다. 당신은 `screen_dir`에 HTML 콘텐츠를 작성하고, 사용자는 브라우저에서 이를 보고 옵션을 선택하기 위해 클릭할 수 있습니다. 선택은 `state_dir/events`에 기록되며 다음 turn에서 읽을 수 있습니다.

**콘텐츠 fragment vs 전체 문서:** HTML 파일이 `<!DOCTYPE` 또는 `<html`로 시작하면 서버는 있는 그대로 제공합니다(helper script만 주입). 그렇지 않으면 서버는 자동으로 콘텐츠를 frame template으로 감쌉니다 — 헤더, CSS 테마, 선택 표시기, 모든 인터랙티브 인프라를 추가합니다. **기본적으로 콘텐츠 fragment를 작성하세요.** 페이지에 대한 완전한 제어가 필요할 때만 전체 문서를 작성하세요.

## 세션 시작

```bash
# 영속성과 함께 서버 시작 (mockup이 프로젝트에 저장됨)
scripts/start-server.sh --project-dir /path/to/project

# 반환: {"type":"server-started","port":52341,"url":"http://localhost:52341",
#           "screen_dir":"/path/to/project/.suberpowers/brainstorm/12345-1706000000/content",
#           "state_dir":"/path/to/project/.suberpowers/brainstorm/12345-1706000000/state"}
```

응답에서 `screen_dir`과 `state_dir`을 저장하세요. 사용자에게 URL을 열도록 알리세요.

**연결 정보 찾기:** 서버는 시작 시 JSON을 `$STATE_DIR/server-info`에 작성합니다. 서버를 백그라운드에서 실행했고 stdout을 캡처하지 못했다면, 그 파일을 읽어 URL과 포트를 얻으세요. `--project-dir`을 사용할 때는 `<project>/.suberpowers/brainstorm/`에서 세션 디렉토리를 확인하세요.

**참고:** 프로젝트 루트를 `--project-dir`로 전달하여 mockup이 `.suberpowers/brainstorm/`에 영속되고 서버 재시작에도 살아남도록 하세요. 이를 사용하지 않으면 파일은 `/tmp`로 가서 정리됩니다. 사용자에게 아직 추가되지 않았다면 `.suberpowers/`를 `.gitignore`에 추가하도록 상기시키세요.

**플랫폼별 서버 실행:**

**Claude Code (macOS / Linux):**
```bash
# 기본 모드가 동작합니다 — script가 서버를 자체적으로 백그라운드로 실행합니다
scripts/start-server.sh --project-dir /path/to/project
```

**Claude Code (Windows):**
```bash
# Windows는 자동 감지하여 foreground 모드를 사용하며, 이는 tool call을 차단합니다.
# 서버가 대화 turn에 걸쳐 살아남도록 Bash tool call에서 run_in_background: true를 사용하세요.
scripts/start-server.sh --project-dir /path/to/project
```
Bash tool을 통해 이를 호출할 때 `run_in_background: true`를 설정하세요. 그런 다음 다음 turn에서 `$STATE_DIR/server-info`를 읽어 URL과 포트를 얻으세요.

**Codex:**
```bash
# Codex는 백그라운드 프로세스를 회수합니다. script가 CODEX_CI를 자동 감지하여
# foreground 모드로 전환합니다. 평소처럼 실행하세요 — 추가 플래그가 필요 없습니다
scripts/start-server.sh --project-dir /path/to/project
```

**Gemini CLI:**
```bash
# --foreground를 사용하고 shell tool call에 is_background: true를 설정하여
# 프로세스가 turn에 걸쳐 살아남도록 하세요
scripts/start-server.sh --project-dir /path/to/project --foreground
```

**기타 환경:** 서버는 대화 turn에 걸쳐 백그라운드에서 계속 실행되어야 합니다. 환경이 분리된(detached) 프로세스를 회수한다면, `--foreground`를 사용하고 플랫폼의 백그라운드 실행 메커니즘으로 명령어를 실행하세요.

URL이 브라우저에서 접근 불가능하다면(원격/컨테이너화된 설정에서 흔함), non-loopback 호스트에 바인딩하세요:

```bash
scripts/start-server.sh \
  --project-dir /path/to/project \
  --host 0.0.0.0 \
  --url-host localhost
```

반환되는 URL JSON에 어떤 호스트명을 출력할지 제어하려면 `--url-host`를 사용하세요.

## 루프

1. **서버가 살아있는지 확인**한 다음, `screen_dir`의 새 파일에 **HTML을 작성**하세요:
   - 각 쓰기 전에 `$STATE_DIR/server-info`가 존재하는지 확인하세요. 없거나(또는 `$STATE_DIR/server-stopped`가 존재한다면), 서버가 종료된 것이므로 — 계속하기 전에 `start-server.sh`로 재시작하세요. 서버는 30분간 비활성 시 자동 종료됩니다.
   - 의미 있는 파일명을 사용하세요: `platform.html`, `visual-style.html`, `layout.html`
   - **파일명을 재사용하지 마세요** — 각 화면은 새 파일을 얻습니다
   - Write tool 사용 — **cat/heredoc을 절대 사용하지 마세요**(터미널에 노이즈를 덤프함)
   - 서버는 자동으로 최신 파일을 제공합니다

2. **사용자에게 무엇을 기대할지 알리고 turn을 종료하세요:**
   - URL을 매번 상기시키세요(첫 단계뿐 아니라)
   - 화면에 무엇이 있는지 간단한 텍스트 요약을 제공하세요(예: "홈페이지 레이아웃 3가지를 보여드리고 있습니다")
   - 터미널에서 응답하도록 요청하세요: "한번 보시고 어떠신지 알려주세요. 원하시면 옵션을 클릭해서 선택하셔도 됩니다."

3. **다음 turn에서** — 사용자가 터미널에서 응답한 후:
   - `$STATE_DIR/events`가 존재하면 읽으세요 — 이는 사용자의 브라우저 상호작용(클릭, 선택)을 JSON 라인으로 포함합니다
   - 사용자의 터미널 텍스트와 병합하여 전체 그림을 얻으세요
   - 터미널 메시지가 주요 피드백이며, `state_dir/events`는 구조화된 상호작용 데이터를 제공합니다

4. **반복 또는 진행** — 피드백이 현재 화면을 바꾸면 새 파일을 작성하세요(예: `layout-v2.html`). 현재 단계가 검증되었을 때만 다음 질문으로 넘어가세요.

5. **터미널로 돌아갈 때 unload** — 다음 단계가 브라우저가 필요 없을 때(예: clarifying question, 트레이드오프 논의), waiting 화면을 push하여 오래된 콘텐츠를 지우세요:

   ```html
   <!-- filename: waiting.html (or waiting-2.html, etc.) -->
   <div style="display:flex;align-items:center;justify-content:center;min-height:60vh">
     <p class="subtitle">Continuing in terminal...</p>
   </div>
   ```

   이는 대화가 진행되었는데도 사용자가 해결된 선택을 응시하는 것을 막아줍니다. 다음 시각적 질문이 나올 때 평소처럼 새 콘텐츠 파일을 push하세요.

6. 완료될 때까지 반복하세요.

## 콘텐츠 Fragment 작성

페이지 안에 들어가는 콘텐츠만 작성하세요. 서버가 자동으로 frame template(헤더, 테마 CSS, 선택 표시기, 모든 인터랙티브 인프라)으로 감쌉니다.

**최소 예시:**

```html
<h2>Which layout works better?</h2>
<p class="subtitle">Consider readability and visual hierarchy</p>

<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>Single Column</h3>
      <p>Clean, focused reading experience</p>
    </div>
  </div>
  <div class="option" data-choice="b" onclick="toggleSelect(this)">
    <div class="letter">B</div>
    <div class="content">
      <h3>Two Column</h3>
      <p>Sidebar navigation with main content</p>
    </div>
  </div>
</div>
```

이게 전부입니다. `<html>`, CSS, `<script>` 태그가 필요 없습니다. 서버가 그 모든 것을 제공합니다.

## 사용 가능한 CSS 클래스

frame template은 콘텐츠를 위한 다음 CSS 클래스를 제공합니다:

### Options (A/B/C 선택)

```html
<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>Title</h3>
      <p>Description</p>
    </div>
  </div>
</div>
```

**다중 선택:** 사용자가 여러 옵션을 선택하도록 하려면 컨테이너에 `data-multiselect`를 추가하세요. 각 클릭이 항목을 토글합니다. 표시기 바는 개수를 보여줍니다.

```html
<div class="options" data-multiselect>
  <!-- same option markup — users can select/deselect multiple -->
</div>
```

### Cards (시각적 디자인)

```html
<div class="cards">
  <div class="card" data-choice="design1" onclick="toggleSelect(this)">
    <div class="card-image"><!-- mockup content --></div>
    <div class="card-body">
      <h3>Name</h3>
      <p>Description</p>
    </div>
  </div>
</div>
```

### Mockup 컨테이너

```html
<div class="mockup">
  <div class="mockup-header">Preview: Dashboard Layout</div>
  <div class="mockup-body"><!-- your mockup HTML --></div>
</div>
```

### Split view (나란히)

```html
<div class="split">
  <div class="mockup"><!-- left --></div>
  <div class="mockup"><!-- right --></div>
</div>
```

### Pros/Cons

```html
<div class="pros-cons">
  <div class="pros"><h4>Pros</h4><ul><li>Benefit</li></ul></div>
  <div class="cons"><h4>Cons</h4><ul><li>Drawback</li></ul></div>
</div>
```

### Mock 엘리먼트 (와이어프레임 빌딩 블록)

```html
<div class="mock-nav">Logo | Home | About | Contact</div>
<div style="display: flex;">
  <div class="mock-sidebar">Navigation</div>
  <div class="mock-content">Main content area</div>
</div>
<button class="mock-button">Action Button</button>
<input class="mock-input" placeholder="Input field">
<div class="placeholder">Placeholder area</div>
```

### 타이포그래피와 섹션

- `h2` — 페이지 제목
- `h3` — 섹션 헤딩
- `.subtitle` — 제목 아래의 보조 텍스트
- `.section` — 하단 마진이 있는 콘텐츠 블록
- `.label` — 작은 대문자 라벨 텍스트

## 브라우저 이벤트 포맷

사용자가 브라우저에서 옵션을 클릭하면, 상호작용이 `$STATE_DIR/events`에 기록됩니다(라인당 하나의 JSON 객체). 새 화면을 push하면 파일이 자동으로 지워집니다.

```jsonl
{"type":"click","choice":"a","text":"Option A - Simple Layout","timestamp":1706000101}
{"type":"click","choice":"c","text":"Option C - Complex Grid","timestamp":1706000108}
{"type":"click","choice":"b","text":"Option B - Hybrid","timestamp":1706000115}
```

전체 이벤트 스트림은 사용자의 탐색 경로를 보여줍니다 — 그들은 결정 전에 여러 옵션을 클릭할 수 있습니다. 마지막 `choice` 이벤트가 일반적으로 최종 선택이지만, 클릭 패턴은 물어볼 가치가 있는 망설임이나 선호를 드러낼 수 있습니다.

`$STATE_DIR/events`가 존재하지 않으면 사용자가 브라우저와 상호작용하지 않은 것이므로 — 터미널 텍스트만 사용하세요.

## 디자인 팁

- **질문에 맞춰 충실도 조정** — 레이아웃에는 와이어프레임, 다듬기 질문에는 polish
- **각 페이지에서 질문 설명** — "하나 고르세요"가 아니라 "어느 레이아웃이 더 전문적으로 느껴지시나요?"
- **진행 전에 반복** — 피드백이 현재 화면을 바꾸면 새 버전을 작성하세요
- 화면당 **최대 2~4개 옵션**
- **중요할 때는 실제 콘텐츠 사용** — 사진 포트폴리오라면 실제 이미지(Unsplash)를 사용하세요. Placeholder 콘텐츠는 디자인 문제를 가립니다.
- **mockup을 단순하게 유지** — 픽셀 완벽한 디자인이 아닌 레이아웃과 구조에 집중하세요

## 파일 네이밍

- 의미 있는 이름 사용: `platform.html`, `visual-style.html`, `layout.html`
- 파일명을 재사용하지 마세요 — 각 화면은 새 파일이어야 합니다
- 반복의 경우: `layout-v2.html`, `layout-v3.html`처럼 버전 접미사를 추가하세요
- 서버는 수정 시간 기준으로 가장 최신 파일을 제공합니다

## 정리하기

```bash
scripts/stop-server.sh $SESSION_DIR
```

세션이 `--project-dir`을 사용했다면 mockup 파일은 나중 참조를 위해 `.suberpowers/brainstorm/`에 영속됩니다. `/tmp` 세션만 중지 시 삭제됩니다.

## 참조

- Frame template (CSS 참조): `scripts/frame-template.html`
- Helper script (클라이언트 측): `scripts/helper.js`
