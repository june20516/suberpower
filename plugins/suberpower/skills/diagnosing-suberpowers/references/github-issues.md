# GitHub issue

<!-- DIVERGENCE:D-008 start -->
`gh`가 설치되어 있고 인증되어 있으면 `gh`를 쓰세요. 인증, rate limit, JSON을
알아서 처리합니다. 없으면 curl로 공개 API를 쓰고, 그것도 안 되면 your human
partner가 직접 여는 URL을 주세요.

**승인 관문.** your human partner가 정확한 문구를 승인하기 전에는 어느
저장소에도 issue나 comment를 **절대** 만들지 마세요. upstream 보고는 포크
issue와 **별도로** 다시 승인을 받아야 합니다. 포크 issue를 승인받았다고
upstream 보고까지 승인받은 것은 아닙니다.

## 저장소

| 이름 | 저장소 | 쓰는 언어 |
|---|---|---|
| upstream | `obra/superpowers` | 영어만 |
| 포크 | `june20516/suberpower` | 한국어 가능 |

포크를 쓰다가 생긴 문제는 번역이나 포크 고유 수정이 원인일 수 있습니다. 그래서
새 보고는 포크에 먼저 하고, upstream 보고는 포크 issue를 검토한 뒤 선택 동작으로만
제안합니다.

## 검색

같은 검색어로 upstream을 먼저, 그다음 포크를 검색하세요. 두 검색 모두 열린
issue와 닫힌 issue를 함께 찾습니다. 저장소마다 `gh` → curl → URL 순서로
fallback하세요.

### 1. upstream

```bash
gh search issues --repo obra/superpowers --limit 10 "<terms>" \
  --json number,state,title --jq '.[] | "\(.number)\t\(.state)\t\(.title)"'
```

`gh`가 없을 때(인증 없이 분당 10회):

```bash
curl -s -H "Accept: application/vnd.github+json" \
  "https://api.github.com/search/issues?q=repo:obra/superpowers+is:issue+<url-encoded terms>&per_page=10" \
  | jq -r '.items[] | "\(.number)\t\(.state)\t\(.title)"'
```

curl도 없으면 `https://github.com/obra/superpowers/issues?q=<terms>`를 주세요.

### 2. 포크

```bash
gh search issues --repo june20516/suberpower --limit 10 "<terms>" \
  --json number,state,title --jq '.[] | "\(.number)\t\(.state)\t\(.title)"'
```

`gh`가 없을 때:

```bash
curl -s -H "Accept: application/vnd.github+json" \
  "https://api.github.com/search/issues?q=repo:june20516/suberpower+is:issue+<url-encoded terms>&per_page=10" \
  | jq -r '.items[] | "\(.number)\t\(.state)\t\(.title)"'
```

curl도 없으면 `https://github.com/june20516/suberpower/issues?q=<terms>`를 주세요.

결과는 저장소를 구분해 한 번에 보여 주세요(예: `upstream #123 open <title>`,
`포크 #4 closed <title>`). 한 저장소의 검색이 모든 단계에서 실패했다면 일치
없음으로 치지 말고, 실패했다는 사실을 함께 알리세요.

## 일치하는 issue가 있을 때

- **upstream에서 일치:** 가장 가까운 upstream issue에 report를 덧붙이자고 먼저
  제안하세요. upstream issue에 다는 comment는 영어로 씁니다.
- **포크에서 일치:** 가장 가까운 포크 issue에 report를 덧붙이자고 제안하세요.
  한국어로 써도 됩니다.
- **양쪽 모두 일치:** 둘 다 보여 주고, 어느 issue에 덧붙일지 your human
  partner가 고르게 하세요.

comment 본문은 작업 공간에 파일로 쓰고, 정확한 문구를 보여 준 뒤, 승인을 받은
후에만 올리세요. `<repo>`는 고른 issue의 저장소(`obra/superpowers` 또는
`june20516/suberpower`)입니다.

```bash
gh issue comment <number> --repo <repo> --body-file <path>
```

`gh`가 없으면 `https://github.com/<repo>/issues/<number>`를 주고, 본문은
파일에서 붙여 넣으라고 안내하세요. `gh`는 파일을 첨부할 수 없습니다. bundle이
있으면 your human partner가 브라우저에서 첨부할 수 있도록 그 경로를 주세요.

## 생성 (포크)

일치하는 issue가 없으면 포크에 먼저 만드세요.

`templates/issue.md`를 채워 작업 공간에 쓰세요. 양식의 heading, 표의 field
이름, checkbox 문구는 영문 그대로 두고, 내용은 한국어로 채워도 됩니다. 정확한
문구를 보여 주고, 승인을 받은 후에:

```bash
gh issue create --repo june20516/suberpower --title "<title>" --body-file <path>
```

라벨은 붙이지 마세요. 포크에는 `bug`·`automated-issue-report` 라벨도
`diagnosis_report.md` 템플릿도 없습니다. skill로 올린 issue라는 표시는 양식
footer가 합니다. `gh`는 파일을 첨부할 수 없습니다. issue가 생긴 뒤 your human
partner가 브라우저에서 첨부할 수 있도록 bundle 경로를 주세요.

`gh`가 없으면 미리 채운 링크를 주세요:

```
https://github.com/june20516/suberpower/issues/new?title=<url-encoded title>&body=<url-encoded body>
```

GitHub는 약 8,000자를 넘는 URL을 거부합니다. 넘으면 title만 담은 링크를 주고,
본문은 파일에서 붙여 넣으라고 안내하세요. 한국어는 URL 인코딩하면 글자당 9자가
되므로 금방 넘습니다. 이 경우 issue가 생긴 뒤 그 URL을 알려 달라고 하세요.
다음 절의 검토에 필요합니다.

## upstream 보고 (선택)

포크 issue가 생긴 뒤에만 진행합니다.

1. **검토.** 생성된 포크 issue를 다시 읽으세요.

   ```bash
   gh issue view <number> --repo june20516/suberpower
   ```

   `gh`가 없으면 작업 공간의 본문 파일을 읽으세요. 검토 결과를 한 줄로 보여
   주세요. 특히 원인이 번역이나 포크 고유 수정(포크 저장소
   `docs/suberpowers/divergence.md`의 D-항목)일 가능성이 있는지 밝히세요. 로컬에
   그 파일이 없으면
   `https://github.com/june20516/suberpower/blob/main/docs/suberpowers/divergence.md`를
   읽으세요. 이 검토는 보고할 저장소를 정하기 위한 것입니다. 엄격한 규칙대로
   skill의 결함을 지목하거나 수정을 제안하지 마세요. 그 가능성이 높으면 upstream
   보고를 권하지 않는다고 말하세요.
2. **제안.** 같은 내용을 upstream에도 보고할지 선택 동작으로 한 번 물어보세요.
   your human partner가 거절하거나 답하지 않으면 여기서 멈춥니다.
3. **영어 본문.** 승인하면 포크 issue 내용을 영어로 옮겨 작업 공간에 별도
   파일(예: `issue-upstream.en.md`)로 쓰세요.
   - 양식 heading과 문구는 upstream 원문을 쓰세요:
     `## Is this a Superpowers issue or a platform issue?`, checkbox
     `I confirmed this issue does not occur without Superpowers installed`,
     Environment 표의 `Superpowers version` 행. 포크 양식의
     `Is this a suberpowers issue…` 문구는 포크 issue용입니다.
   - `## What happened?` 첫 문단에 이것이 Superpowers의 한국어 포크
     (suberpowers, `june20516/suberpower`)에서 관찰된 것임을 밝히세요. 예:
     `Observed in suberpowers, a Korean translation fork of Superpowers (june20516/suberpower), at <version> (<sha>).`
   - 한국어 prompt와 인용은 영어로 옮기고 `(translated from Korean)`을 붙이세요.
   - footer 첫 문장은
     `Filed with the diagnosing-suberpowers skill (Korean fork of Superpowers).`로
     쓰고, 둘째 문장은 양식 그대로 두세요.
   - 본문 끝에 포크 issue 링크를 붙이세요:
     `Fork issue: https://github.com/june20516/suberpower/issues/<number>`.

   정확한 문구를 보여 주고, **다시** 승인을 받은 후에만:

   ```bash
   gh issue create --repo obra/superpowers --title "<English title>" --body-file <path> \
     --label bug --label automated-issue-report
   ```

   reporter에게 push 권한이 없으면 GitHub가 라벨을 조용히 버리므로, 라벨은
   collaborator가 올릴 때만 붙습니다. skill로 올린 issue라는 표시는 footer가
   합니다. `gh`는 파일을 첨부할 수 없습니다. bundle을 첨부하려면, bundle에
   한국어 산문이 섞여 있다고 알리고 첨부 여부는 your human partner가 정하게
   하세요. 첨부한다면 issue가 생긴 뒤 브라우저에서 첨부할 수 있도록 경로를
   주세요.

   `gh`가 없으면 `diagnosis_report.md` 템플릿으로 미리 채운 링크를 주세요. 이
   템플릿은 reporter와 관계없이 두 라벨을 모두 붙입니다:

   ```
   https://github.com/obra/superpowers/issues/new?template=diagnosis_report.md&title=<url-encoded title>&body=<url-encoded body>
   ```

   GitHub는 약 8,000자를 넘는 URL을 거부합니다. 넘으면 title만 담은 링크를
   주고, 본문은 파일에서 붙여 넣으라고 안내하세요.
<!-- DIVERGENCE:D-008 end -->
