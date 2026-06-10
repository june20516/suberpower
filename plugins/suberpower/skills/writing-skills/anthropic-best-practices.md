# Skill authoring best practices

> Claude가 발견하고 성공적으로 사용할 수 있는 효과적인 Skill을 작성하는 방법을 배웁니다.

좋은 Skill은 간결하고, 잘 구조화되어 있으며, 실제 사용으로 테스트됩니다. 이 가이드는 Claude가 효과적으로 발견하고 사용할 수 있는 Skill 작성에 도움이 되는 실용적 작성 결정을 제공합니다.

Skill이 어떻게 작동하는지에 대한 개념적 배경은 [Skills overview](/en/docs/agents-and-tools/agent-skills/overview)를 참고하세요.

## 핵심 원칙

### 간결함이 핵심

[context window](https://platform.claude.com/docs/en/build-with-claude/context-windows)는 공공재입니다. 당신의 Skill은 Claude가 알아야 할 다른 모든 것과 context window를 공유합니다. 여기에는 다음이 포함됩니다:

* system prompt
* 대화 기록
* 다른 Skill들의 메타데이터
* 당신의 실제 요청

Skill의 모든 토큰이 즉각적인 비용을 갖는 것은 아닙니다. 시작 시에는 모든 Skill의 메타데이터(name과 description)만 사전 로드됩니다. Claude는 Skill이 관련 있을 때만 SKILL.md를 읽고, 필요할 때만 추가 파일을 읽습니다. 그러나 SKILL.md를 간결하게 유지하는 것은 여전히 중요합니다: Claude가 일단 로드하면, 모든 토큰이 대화 기록 및 다른 context와 경쟁합니다.

**기본 가정**: Claude는 이미 매우 똑똑합니다

Claude가 아직 갖고 있지 않은 context만 추가합니다. 각 정보 조각에 도전하세요:

* "Claude가 정말로 이 설명이 필요한가?"
* "Claude가 이미 안다고 가정해도 되는가?"
* "이 단락이 토큰 비용을 정당화하는가?"

**좋은 예: 간결함** (약 50 토큰):

````markdown  theme={null}
## Extract PDF text

Use pdfplumber for text extraction:

```python
import pdfplumber

with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
````

**나쁜 예: 너무 장황** (약 150 토큰):

```markdown  theme={null}
## Extract PDF text

PDF (Portable Document Format) files are a common file format that contains
text, images, and other content. To extract text from a PDF, you'll need to
use a library. There are many libraries available for PDF processing, but we
recommend pdfplumber because it's easy to use and handles most cases well.
First, you'll need to install it using pip. Then you can use the code below...
```

간결한 버전은 Claude가 PDF가 무엇이고 라이브러리가 어떻게 작동하는지 안다고 가정합니다.

### 적절한 자유도 설정

작업의 깨지기 쉬움과 가변성에 맞춰 구체성 수준을 맞춥니다.

**높은 자유도** (텍스트 기반 지시):

사용 시기:

* 여러 접근이 유효함
* 결정이 context에 따라 달라짐
* 휴리스틱이 접근을 가이드함

예시:

```markdown  theme={null}
## Code review process

1. Analyze the code structure and organization
2. Check for potential bugs or edge cases
3. Suggest improvements for readability and maintainability
4. Verify adherence to project conventions
```

**중간 자유도** (의사 코드 또는 매개변수가 있는 스크립트):

사용 시기:

* 선호되는 패턴이 존재함
* 어느 정도 변형이 수용 가능함
* 설정이 동작에 영향을 줌

예시:

````markdown  theme={null}
## Generate report

Use this template and customize as needed:

```python
def generate_report(data, format="markdown", include_charts=True):
    # Process data
    # Generate output in specified format
    # Optionally include visualizations
```
````

**낮은 자유도** (구체적 스크립트, 매개변수 거의 또는 전혀 없음):

사용 시기:

* 작업이 깨지기 쉽고 오류가 발생하기 쉬움
* 일관성이 중요함
* 특정 순서를 따라야 함

예시:

````markdown  theme={null}
## Database migration

Run exactly this script:

```bash
python scripts/migrate.py --verify --backup
```

Do not modify the command or add additional flags.
````

**비유**: Claude를 경로를 탐색하는 로봇이라고 생각하세요:

* **양쪽이 절벽인 좁은 다리**: 안전한 길은 하나뿐입니다. 구체적인 가드레일과 정확한 지시를 제공하세요 (낮은 자유도). 예: 정확한 순서로 실행되어야 하는 데이터베이스 마이그레이션.
* **위험 없는 열린 들판**: 여러 길이 성공으로 이어집니다. 일반적인 방향을 주고 Claude가 최선의 경로를 찾도록 신뢰하세요 (높은 자유도). 예: context가 최선의 접근을 결정하는 코드 리뷰.

### 사용할 모든 모델로 테스트하세요

Skill은 모델에 대한 추가물로 작동하므로, 효과는 기본 모델에 달려 있습니다. 사용할 계획인 모든 모델로 Skill을 테스트하세요.

**모델별 테스팅 고려사항**:

* **Claude Haiku** (빠르고 경제적): Skill이 충분한 가이던스를 제공하는가?
* **Claude Sonnet** (균형): Skill이 명확하고 효율적인가?
* **Claude Opus** (강력한 추론): Skill이 과한 설명을 피하는가?

Opus에 완벽하게 작동하는 것이 Haiku에는 더 많은 디테일이 필요할 수 있습니다. 여러 모델에서 Skill을 사용할 계획이라면, 모두에서 잘 작동하는 지시를 목표로 하세요.

## Skill 구조

<Note>
  **YAML Frontmatter**: SKILL.md frontmatter는 두 필드를 요구합니다:

  * `name` - Skill의 사람이 읽을 수 있는 이름 (최대 64자)
  * `description` - Skill이 무엇을 하고 언제 사용하는지에 대한 한 줄 설명 (최대 1024자)

  완전한 Skill 구조 디테일은 [Skills overview](/en/docs/agents-and-tools/agent-skills/overview#skill-structure)를 참고하세요.
</Note>

### 네이밍 규칙

Skill을 참조하고 논의하기 쉽도록 일관된 네이밍 패턴을 사용합니다. Skill이 제공하는 활동이나 능력을 명확히 묘사하므로 Skill 이름에 **gerund 형태** (동사 + -ing)를 권장합니다.

**좋은 네이밍 예시 (gerund 형태)**:

* "Processing PDFs"
* "Analyzing spreadsheets"
* "Managing databases"
* "Testing code"
* "Writing documentation"

**허용 가능한 대안**:

* 명사구: "PDF Processing", "Spreadsheet Analysis"
* 행동 중심: "Process PDFs", "Analyze Spreadsheets"

**피해야 할 것**:

* 모호한 이름: "Helper", "Utils", "Tools"
* 지나치게 일반적: "Documents", "Data", "Files"
* skill 컬렉션 내 일관성 없는 패턴

일관된 네이밍은 다음을 쉽게 만듭니다:

* 문서와 대화에서 Skill 참조
* Skill이 무엇을 하는지 한눈에 이해
* 여러 Skill을 조직하고 검색
* 전문적이고 응집된 skill 라이브러리 유지

### 효과적인 description 작성

`description` 필드는 Skill 발견을 가능하게 하며, Skill이 무엇을 하는지와 언제 사용하는지를 모두 포함해야 합니다.

<Warning>
  **항상 3인칭으로 작성하세요**. description은 system prompt에 주입되며, 일관성 없는 시점은 발견 문제를 일으킬 수 있습니다.

  * **Good:** "Processes Excel files and generates reports"
  * **Avoid:** "I can help you process Excel files"
  * **Avoid:** "You can use this to process Excel files"
</Warning>

**구체적이고 핵심 용어를 포함하세요**. Skill이 무엇을 하는지와 언제 사용하는지의 구체적 트리거/context를 모두 포함합니다.

각 Skill은 정확히 하나의 description 필드를 가집니다. description은 skill 선택에 결정적입니다: Claude는 잠재적으로 100개 이상의 사용 가능한 Skill에서 올바른 Skill을 선택하기 위해 이것을 사용합니다. description은 Claude가 언제 이 Skill을 선택할지 알 수 있도록 충분한 디테일을 제공해야 하며, SKILL.md의 나머지가 구현 디테일을 제공합니다.

효과적인 예시:

**PDF Processing skill:**

```yaml  theme={null}
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

**Excel Analysis skill:**

```yaml  theme={null}
description: Analyze Excel spreadsheets, create pivot tables, generate charts. Use when analyzing Excel files, spreadsheets, tabular data, or .xlsx files.
```

**Git Commit Helper skill:**

```yaml  theme={null}
description: Generate descriptive commit messages by analyzing git diffs. Use when the user asks for help writing commit messages or reviewing staged changes.
```

다음과 같은 모호한 description은 피하세요:

```yaml  theme={null}
description: Helps with documents
```

```yaml  theme={null}
description: Processes data
```

```yaml  theme={null}
description: Does stuff with files
```

### Progressive disclosure 패턴

SKILL.md는 온보딩 가이드의 목차처럼 필요에 따라 Claude를 자세한 자료로 안내하는 개요 역할을 합니다. progressive disclosure가 어떻게 작동하는지에 대한 설명은 overview의 [How Skills work](/en/docs/agents-and-tools/agent-skills/overview#how-skills-work)를 참고하세요.

**실용적 가이던스:**

* 최적 성능을 위해 SKILL.md 본문을 500줄 이하로 유지
* 이 한계에 가까워지면 내용을 별도 파일로 분할
* 지시, 코드, 리소스를 효과적으로 조직하기 위해 아래 패턴을 사용

#### 시각적 개요: 단순에서 복잡으로

기본 Skill은 메타데이터와 지시를 담은 SKILL.md 파일 하나로 시작합니다:

<img src="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=87782ff239b297d9a9e8e1b72ed72db9" alt="Simple SKILL.md file showing YAML frontmatter and markdown body" data-og-width="2048" width="2048" data-og-height="1153" height="1153" data-path="images/agent-skills-simple-file.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=280&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=c61cc33b6f5855809907f7fda94cd80e 280w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=560&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=90d2c0c1c76b36e8d485f49e0810dbfd 560w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=840&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=ad17d231ac7b0bea7e5b4d58fb4aeabb 840w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=1100&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=f5d0a7a3c668435bb0aee9a3a8f8c329 1100w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=1650&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=0e927c1af9de5799cfe557d12249f6e6 1650w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=2500&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=46bbb1a51dd4c8202a470ac8c80a893d 2500w" />

Skill이 커지면, Claude가 필요할 때만 로드하는 추가 콘텐츠를 번들링할 수 있습니다:

<img src="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=a5e0aa41e3d53985a7e3e43668a33ea3" alt="Bundling additional reference files like reference.md and forms.md." data-og-width="2048" width="2048" data-og-height="1327" height="1327" data-path="images/agent-skills-bundling-content.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=280&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=f8a0e73783e99b4a643d79eac86b70a2 280w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=560&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=dc510a2a9d3f14359416b706f067904a 560w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=840&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=82cd6286c966303f7dd914c28170e385 840w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=1100&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=56f3be36c77e4fe4b523df209a6824c6 1100w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=1650&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=d22b5161b2075656417d56f41a74f3dd 1650w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=2500&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=3dd4bdd6850ffcc96c6c45fcb0acd6eb 2500w" />

완전한 Skill 디렉터리 구조는 이렇게 보일 수 있습니다:

```
pdf/
├── SKILL.md              # 메인 지시 (트리거되면 로드됨)
├── FORMS.md              # 폼 채우기 가이드 (필요 시 로드)
├── reference.md          # API 참조 (필요 시 로드)
├── examples.md           # 사용 예시 (필요 시 로드)
└── scripts/
    ├── analyze_form.py   # 유틸리티 스크립트 (실행됨, 로드되지 않음)
    ├── fill_form.py      # 폼 채우기 스크립트
    └── validate.py       # 검증 스크립트
```

#### 패턴 1: 상위 수준 가이드와 참조

````markdown  theme={null}
---
name: PDF Processing
description: Extracts text and tables from PDF files, fills forms, and merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
---

# PDF Processing

## Quick start

Extract text with pdfplumber:
```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```

## Advanced features

**Form filling**: See [FORMS.md](FORMS.md) for complete guide
**API reference**: See [REFERENCE.md](REFERENCE.md) for all methods
**Examples**: See [EXAMPLES.md](EXAMPLES.md) for common patterns
````

Claude는 FORMS.md, REFERENCE.md 또는 EXAMPLES.md를 필요할 때만 로드합니다.

#### 패턴 2: 도메인 특화 조직

여러 도메인이 있는 Skill의 경우, 관련 없는 context 로딩을 피하기 위해 도메인별로 콘텐츠를 조직합니다. 사용자가 영업 지표에 대해 물으면, Claude는 finance나 marketing 데이터가 아닌 영업 관련 스키마만 읽으면 됩니다. 이는 토큰 사용량을 낮게 유지하고 context를 집중시킵니다.

```
bigquery-skill/
├── SKILL.md (개요 및 네비게이션)
└── reference/
    ├── finance.md (매출, 청구 지표)
    ├── sales.md (기회, 파이프라인)
    ├── product.md (API 사용량, 기능)
    └── marketing.md (캠페인, 어트리뷰션)
```

````markdown SKILL.md theme={null}
# BigQuery Data Analysis

## Available datasets

**Finance**: Revenue, ARR, billing → See [reference/finance.md](reference/finance.md)
**Sales**: Opportunities, pipeline, accounts → See [reference/sales.md](reference/sales.md)
**Product**: API usage, features, adoption → See [reference/product.md](reference/product.md)
**Marketing**: Campaigns, attribution, email → See [reference/marketing.md](reference/marketing.md)

## Quick search

Find specific metrics using grep:

```bash
grep -i "revenue" reference/finance.md
grep -i "pipeline" reference/sales.md
grep -i "api usage" reference/product.md
```
````

#### 패턴 3: 조건부 디테일

기본 콘텐츠를 보여주고, 고급 콘텐츠는 링크합니다:

```markdown  theme={null}
# DOCX Processing

## Creating documents

Use docx-js for new documents. See [DOCX-JS.md](DOCX-JS.md).

## Editing documents

For simple edits, modify the XML directly.

**For tracked changes**: See [REDLINING.md](REDLINING.md)
**For OOXML details**: See [OOXML.md](OOXML.md)
```

Claude는 사용자가 그 기능이 필요할 때만 REDLINING.md나 OOXML.md를 읽습니다.

### 깊게 중첩된 참조를 피하세요

Claude는 다른 참조된 파일에서 참조된 파일을 부분적으로 읽을 수 있습니다. 중첩 참조를 마주칠 때, Claude는 전체 파일을 읽기보다 `head -100`과 같은 명령으로 콘텐츠를 미리보기 할 수 있어 불완전한 정보로 이어집니다.

**참조를 SKILL.md에서 한 단계 깊이로 유지하세요**. 모든 참조 파일은 SKILL.md에서 직접 링크되어야 Claude가 필요할 때 완전한 파일을 읽도록 보장됩니다.

**나쁜 예: 너무 깊음**:

```markdown  theme={null}
# SKILL.md
See [advanced.md](advanced.md)...

# advanced.md
See [details.md](details.md)...

# details.md
Here's the actual information...
```

**좋은 예: 한 단계 깊이**:

```markdown  theme={null}
# SKILL.md

**Basic usage**: [instructions in SKILL.md]
**Advanced features**: See [advanced.md](advanced.md)
**API reference**: See [reference.md](reference.md)
**Examples**: See [examples.md](examples.md)
```

### 더 긴 참조 파일은 목차로 구조화

100줄 이상의 참조 파일에는 상단에 목차를 포함합니다. 이는 Claude가 부분 읽기로 미리보기 할 때조차 사용 가능한 정보의 전체 범위를 볼 수 있도록 보장합니다.

**예시**:

```markdown  theme={null}
# API Reference

## Contents
- Authentication and setup
- Core methods (create, read, update, delete)
- Advanced features (batch operations, webhooks)
- Error handling patterns
- Code examples

## Authentication and setup
...

## Core methods
...
```

Claude는 그러면 완전한 파일을 읽거나 필요에 따라 특정 섹션으로 이동할 수 있습니다.

이 파일시스템 기반 아키텍처가 어떻게 progressive disclosure를 가능하게 하는지에 대한 디테일은 아래 Advanced 섹션의 [Runtime environment](#runtime-environment) 섹션을 참고하세요.

## 워크플로우와 피드백 루프

### 복잡한 작업에 워크플로우 사용

복잡한 작업을 명확한 순차 단계로 분해합니다. 특히 복잡한 워크플로우의 경우, Claude가 응답에 복사하여 진행하면서 체크할 수 있는 체크리스트를 제공합니다.

**예시 1: 리서치 합성 워크플로우** (코드 없는 Skill용):

````markdown  theme={null}
## Research synthesis workflow

Copy this checklist and track your progress:

```
Research Progress:
- [ ] Step 1: Read all source documents
- [ ] Step 2: Identify key themes
- [ ] Step 3: Cross-reference claims
- [ ] Step 4: Create structured summary
- [ ] Step 5: Verify citations
```

**Step 1: Read all source documents**

Review each document in the `sources/` directory. Note the main arguments and supporting evidence.

**Step 2: Identify key themes**

Look for patterns across sources. What themes appear repeatedly? Where do sources agree or disagree?

**Step 3: Cross-reference claims**

For each major claim, verify it appears in the source material. Note which source supports each point.

**Step 4: Create structured summary**

Organize findings by theme. Include:
- Main claim
- Supporting evidence from sources
- Conflicting viewpoints (if any)

**Step 5: Verify citations**

Check that every claim references the correct source document. If citations are incomplete, return to Step 3.
````

이 예시는 워크플로우가 코드를 요구하지 않는 분석 작업에 어떻게 적용되는지 보여줍니다. 체크리스트 패턴은 어떤 복잡한 다단계 프로세스에도 작동합니다.

**예시 2: PDF 폼 채우기 워크플로우** (코드가 있는 Skill용):

````markdown  theme={null}
## PDF form filling workflow

Copy this checklist and check off items as you complete them:

```
Task Progress:
- [ ] Step 1: Analyze the form (run analyze_form.py)
- [ ] Step 2: Create field mapping (edit fields.json)
- [ ] Step 3: Validate mapping (run validate_fields.py)
- [ ] Step 4: Fill the form (run fill_form.py)
- [ ] Step 5: Verify output (run verify_output.py)
```

**Step 1: Analyze the form**

Run: `python scripts/analyze_form.py input.pdf`

This extracts form fields and their locations, saving to `fields.json`.

**Step 2: Create field mapping**

Edit `fields.json` to add values for each field.

**Step 3: Validate mapping**

Run: `python scripts/validate_fields.py fields.json`

Fix any validation errors before continuing.

**Step 4: Fill the form**

Run: `python scripts/fill_form.py input.pdf fields.json output.pdf`

**Step 5: Verify output**

Run: `python scripts/verify_output.py output.pdf`

If verification fails, return to Step 2.
````

명확한 단계는 Claude가 중요한 검증을 건너뛰는 것을 막습니다. 체크리스트는 Claude와 당신 모두가 다단계 워크플로우의 진행을 추적하는 데 도움이 됩니다.

### 피드백 루프 구현

**일반적인 패턴**: validator 실행 → 오류 수정 → 반복

이 패턴은 출력 품질을 크게 향상시킵니다.

**예시 1: 스타일 가이드 준수** (코드 없는 Skill용):

```markdown  theme={null}
## Content review process

1. Draft your content following the guidelines in STYLE_GUIDE.md
2. Review against the checklist:
   - Check terminology consistency
   - Verify examples follow the standard format
   - Confirm all required sections are present
3. If issues found:
   - Note each issue with specific section reference
   - Revise the content
   - Review the checklist again
4. Only proceed when all requirements are met
5. Finalize and save the document
```

이는 스크립트 대신 참조 문서를 사용한 검증 루프 패턴을 보여줍니다. "validator"는 STYLE\_GUIDE.md이고, Claude는 읽고 비교하여 검사를 수행합니다.

**예시 2: 문서 편집 프로세스** (코드가 있는 Skill용):

```markdown  theme={null}
## Document editing process

1. Make your edits to `word/document.xml`
2. **Validate immediately**: `python ooxml/scripts/validate.py unpacked_dir/`
3. If validation fails:
   - Review the error message carefully
   - Fix the issues in the XML
   - Run validation again
4. **Only proceed when validation passes**
5. Rebuild: `python ooxml/scripts/pack.py unpacked_dir/ output.docx`
6. Test the output document
```

검증 루프는 오류를 조기에 잡습니다.

## 콘텐츠 가이드라인

### 시간 민감 정보 피하기

오래되어 잘못될 정보를 포함하지 마세요:

**나쁜 예: 시간 민감** (틀려질 것):

```markdown  theme={null}
If you're doing this before August 2025, use the old API.
After August 2025, use the new API.
```

**좋은 예** ("old patterns" 섹션 사용):

```markdown  theme={null}
## Current method

Use the v2 API endpoint: `api.example.com/v2/messages`

## Old patterns

<details>
<summary>Legacy v1 API (deprecated 2025-08)</summary>

The v1 API used: `api.example.com/v1/messages`

This endpoint is no longer supported.
</details>
```

old patterns 섹션은 메인 콘텐츠를 어수선하게 하지 않으면서 역사적 맥락을 제공합니다.

### 일관된 용어 사용

하나의 용어를 선택하고 Skill 전체에서 사용:

**Good - 일관됨**:

* 항상 "API endpoint"
* 항상 "field"
* 항상 "extract"

**Bad - 일관되지 않음**:

* "API endpoint", "URL", "API route", "path" 혼용
* "field", "box", "element", "control" 혼용
* "extract", "pull", "get", "retrieve" 혼용

일관성은 Claude가 지시를 이해하고 따르는 데 도움이 됩니다.

## 일반적 패턴

### 템플릿 패턴

출력 형식을 위한 템플릿을 제공합니다. 엄격함의 수준을 필요에 맞춥니다.

**엄격한 요구사항** (API 응답이나 데이터 형식 등):

````markdown  theme={null}
## Report structure

ALWAYS use this exact template structure:

```markdown
# [Analysis Title]

## Executive summary
[One-paragraph overview of key findings]

## Key findings
- Finding 1 with supporting data
- Finding 2 with supporting data
- Finding 3 with supporting data

## Recommendations
1. Specific actionable recommendation
2. Specific actionable recommendation
```
````

**유연한 가이던스** (적응이 유용할 때):

````markdown  theme={null}
## Report structure

Here is a sensible default format, but use your best judgment based on the analysis:

```markdown
# [Analysis Title]

## Executive summary
[Overview]

## Key findings
[Adapt sections based on what you discover]

## Recommendations
[Tailor to the specific context]
```

Adjust sections as needed for the specific analysis type.
````

### 예시 패턴

출력 품질이 예시를 보는 것에 달려 있는 Skill의 경우, 일반 prompt에서처럼 input/output 쌍을 제공합니다:

````markdown  theme={null}
## Commit message format

Generate commit messages following these examples:

**Example 1:**
Input: Added user authentication with JWT tokens
Output:
```
feat(auth): implement JWT-based authentication

Add login endpoint and token validation middleware
```

**Example 2:**
Input: Fixed bug where dates displayed incorrectly in reports
Output:
```
fix(reports): correct date formatting in timezone conversion

Use UTC timestamps consistently across report generation
```

**Example 3:**
Input: Updated dependencies and refactored error handling
Output:
```
chore: update dependencies and refactor error handling

- Upgrade lodash to 4.17.21
- Standardize error response format across endpoints
```

Follow this style: type(scope): brief description, then detailed explanation.
````

예시는 Claude가 설명만으로는 알기 어려운 원하는 스타일과 디테일 수준을 더 명확히 이해하도록 돕습니다.

### 조건부 워크플로우 패턴

결정 지점을 통해 Claude를 안내합니다:

```markdown  theme={null}
## Document modification workflow

1. Determine the modification type:

   **Creating new content?** → Follow "Creation workflow" below
   **Editing existing content?** → Follow "Editing workflow" below

2. Creation workflow:
   - Use docx-js library
   - Build document from scratch
   - Export to .docx format

3. Editing workflow:
   - Unpack existing document
   - Modify XML directly
   - Validate after each change
   - Repack when complete
```

<Tip>
  워크플로우가 단계가 많아 크거나 복잡해지면, 별도 파일로 옮기고 Claude가 당면 작업에 따라 적절한 파일을 읽도록 지시하는 것을 고려하세요.
</Tip>

## 평가와 반복

### 평가를 먼저 구축

**광범위한 문서를 작성하기 전에 평가를 만드세요.** 이는 Skill이 상상된 것이 아닌 실제 문제를 해결하도록 보장합니다.

**평가 주도 개발:**

1. **빈틈 식별**: Skill 없이 대표적인 작업에서 Claude를 실행합니다. 구체적인 실패나 누락된 context를 기록합니다
2. **평가 만들기**: 이 빈틈을 테스트하는 시나리오 3개를 만듭니다
3. **베이스라인 설정**: Skill 없이 Claude의 성능을 측정합니다
4. **최소한의 지시 작성**: 빈틈에 대응하고 평가를 통과할 만큼만 콘텐츠를 만듭니다
5. **반복**: 평가를 실행하고, 베이스라인과 비교하며, 다듬습니다

이 접근은 실현되지 않을 수도 있는 요구사항을 예측하기보다 실제 문제를 해결하도록 보장합니다.

**평가 구조**:

```json  theme={null}
{
  "skills": ["pdf-processing"],
  "query": "Extract all text from this PDF file and save it to output.txt",
  "files": ["test-files/document.pdf"],
  "expected_behavior": [
    "Successfully reads the PDF file using an appropriate PDF processing library or command-line tool",
    "Extracts text content from all pages in the document without missing any pages",
    "Saves the extracted text to a file named output.txt in a clear, readable format"
  ]
}
```

<Note>
  이 예시는 단순한 테스팅 루브릭이 있는 데이터 주도 평가를 보여줍니다. 현재 이러한 평가를 실행하는 내장 방법은 제공하지 않습니다. 사용자가 자신의 평가 시스템을 만들 수 있습니다. 평가는 Skill 효과를 측정하기 위한 진실의 원천입니다.
</Note>

### Claude와 함께 반복적으로 Skill 개발

가장 효과적인 Skill 개발 프로세스는 Claude 자체를 포함합니다. Claude의 한 인스턴스("Claude A")와 작업하여 다른 인스턴스("Claude B")가 사용할 Skill을 만듭니다. Claude A는 당신이 지시를 설계하고 다듬는 것을 돕는 동안, Claude B는 실제 작업에서 그것을 테스트합니다. 이것이 작동하는 이유는 Claude 모델이 효과적인 agent 지시를 작성하는 방법과 agent가 어떤 정보가 필요한지 모두 이해하기 때문입니다.

**새 Skill 만들기:**

1. **Skill 없이 작업 완료**: Claude A와 일반 prompt를 사용해 문제를 해결합니다. 작업하면서 자연스럽게 context를 제공하고, 선호를 설명하고, 절차적 지식을 공유하게 됩니다. 반복해서 제공하는 정보가 무엇인지 주목합니다.

2. **재사용 가능한 패턴 식별**: 작업 완료 후, 비슷한 미래 작업에 유용할 어떤 context를 제공했는지 식별합니다.

   **예시**: BigQuery 분석을 진행했다면, 테이블 이름, 필드 정의, 필터링 규칙 ("항상 테스트 계정 제외" 등), 일반적인 쿼리 패턴을 제공했을 수 있습니다.

3. **Claude A에게 Skill을 만들어 달라고 요청**: "방금 사용한 이 BigQuery 분석 패턴을 담은 Skill을 만들어 줘. 테이블 스키마, 네이밍 규칙, 테스트 계정 필터링 규칙을 포함해."

   <Tip>
     Claude 모델은 Skill 형식과 구조를 기본적으로 이해합니다. Claude가 Skill 만들기를 돕도록 특별한 system prompt나 "writing skills" skill이 필요하지 않습니다. 그냥 Claude에게 Skill을 만들어 달라고 요청하면 적절한 frontmatter와 본문 콘텐츠가 있는 제대로 구조화된 SKILL.md 콘텐츠를 생성합니다.
   </Tip>

4. **간결성 검토**: Claude A가 불필요한 설명을 추가하지 않았는지 확인합니다. 물어보세요: "win rate가 무엇인지에 대한 설명은 제거해 줘 - Claude는 이미 알고 있어."

5. **정보 아키텍처 개선**: Claude A에게 콘텐츠를 더 효과적으로 조직하도록 요청합니다. 예: "테이블 스키마가 별도 참조 파일에 있도록 이것을 조직해 줘. 나중에 테이블을 더 추가할 수도 있어."

6. **비슷한 작업에서 테스트**: Skill을 Claude B (Skill이 로드된 새 인스턴스)와 관련 사용 사례에서 사용합니다. Claude B가 올바른 정보를 찾고, 규칙을 올바르게 적용하고, 작업을 성공적으로 처리하는지 관찰합니다.

7. **관찰에 기반한 반복**: Claude B가 어려움을 겪거나 무언가를 놓치면, 구체적으로 Claude A에게 돌아갑니다: "Claude가 이 Skill을 사용할 때, Q4에 대해 날짜로 필터링하는 것을 잊었어. 날짜 필터링 패턴에 대한 섹션을 추가해야 할까?"

**기존 Skill 반복:**

같은 계층적 패턴이 Skill을 개선할 때도 계속됩니다. 다음 사이를 번갈아 합니다:

* **Claude A와 작업** (Skill을 다듬는 데 도움이 되는 전문가)
* **Claude B와 테스팅** (실제 작업을 수행하기 위해 Skill을 사용하는 agent)
* **Claude B의 행동 관찰** 후 통찰을 Claude A에게 가져오기

1. **실제 워크플로우에서 Skill 사용**: 테스트 시나리오가 아닌 실제 작업을 Claude B (Skill 로드됨)에게 부여합니다

2. **Claude B의 행동 관찰**: 어려움을 겪는 곳, 성공하는 곳, 예상치 못한 선택을 하는 곳을 기록합니다

   **관찰 예시**: "Claude B에게 지역 매출 보고서를 요청했을 때, Skill이 이 규칙을 언급했음에도 테스트 계정을 필터링하는 것을 잊었어요."

3. **개선을 위해 Claude A로 돌아가기**: 현재 SKILL.md를 공유하고 관찰한 것을 설명합니다. 물어보세요: "지역 보고서를 요청했을 때 Claude B가 테스트 계정 필터링을 잊었어. Skill이 필터링을 언급하지만, 충분히 두드러지지 않은 것 같아?"

4. **Claude A의 제안 검토**: Claude A는 규칙을 더 두드러지게 만들기 위한 재조직, "always filter" 대신 "MUST filter"와 같은 더 강한 언어 사용, 워크플로우 섹션 재구조화를 제안할 수 있습니다.

5. **변경 사항 적용 및 테스트**: Claude A의 다듬기로 Skill을 업데이트한 다음, 비슷한 요청에서 Claude B로 다시 테스트합니다

6. **사용에 기반한 반복**: 새 시나리오를 마주칠 때 이 관찰-다듬기-테스트 사이클을 계속합니다. 각 반복은 가정이 아닌 실제 agent 행동에 기반해 Skill을 개선합니다.

**팀 피드백 모으기:**

1. 팀원과 Skill을 공유하고 사용을 관찰합니다
2. 물어보세요: Skill이 예상대로 활성화되는가? 지시가 명확한가? 무엇이 빠졌는가?
3. 자신의 사용 패턴의 사각지대에 대응하기 위해 피드백을 반영합니다

**이 접근이 작동하는 이유**: Claude A는 agent 요구를 이해하고, 당신은 도메인 전문성을 제공하고, Claude B는 실제 사용을 통해 빈틈을 드러내며, 반복적 다듬기는 가정이 아닌 관찰된 행동에 기반해 Skill을 개선합니다.

### Claude가 Skill을 어떻게 탐색하는지 관찰

Skill을 반복하면서, Claude가 실제로 그것을 어떻게 사용하는지 주목합니다. 주의해야 할 것:

* **예상치 못한 탐색 경로**: Claude가 당신이 예상하지 못한 순서로 파일을 읽는가? 이는 구조가 당신이 생각한 만큼 직관적이지 않다는 것을 시사할 수 있습니다
* **놓친 연결**: Claude가 중요한 파일에 대한 참조를 따라가지 못하는가? 링크가 더 명시적이거나 두드러져야 할 수 있습니다
* **특정 섹션에 대한 과의존**: Claude가 같은 파일을 반복해서 읽으면, 그 콘텐츠가 메인 SKILL.md에 있어야 하는지 고려합니다
* **무시된 콘텐츠**: Claude가 번들된 파일에 결코 접근하지 않으면, 불필요하거나 메인 지시에서 잘 신호되지 않았을 수 있습니다

가정이 아닌 이러한 관찰에 기반해 반복합니다. Skill 메타데이터의 'name'과 'description'은 특히 중요합니다. Claude는 현재 작업에 대한 응답으로 Skill을 트리거할지 결정할 때 이것을 사용합니다. Skill이 무엇을 하고 언제 사용되어야 하는지 명확히 묘사하는지 확인하세요.

## 피해야 할 안티 패턴

### Windows 스타일 경로 피하기

Windows에서도 항상 파일 경로에 forward slash를 사용합니다:

* ✓ **Good**: `scripts/helper.py`, `reference/guide.md`
* ✗ **Avoid**: `scripts\helper.py`, `reference\guide.md`

Unix 스타일 경로는 모든 플랫폼에서 작동하지만, Windows 스타일 경로는 Unix 시스템에서 오류를 일으킵니다.

### 너무 많은 옵션 제공 피하기

필요하지 않으면 여러 접근을 제시하지 마세요:

````markdown  theme={null}
**Bad example: Too many choices** (confusing):
"You can use pypdf, or pdfplumber, or PyMuPDF, or pdf2image, or..."

**Good example: Provide a default** (with escape hatch):
"Use pdfplumber for text extraction:
```python
import pdfplumber
```

For scanned PDFs requiring OCR, use pdf2image with pytesseract instead."
````

## Advanced: 실행 가능한 코드를 포함한 Skill

아래 섹션들은 실행 가능한 스크립트를 포함한 Skill에 집중합니다. Skill이 마크다운 지시만 사용한다면, [Checklist for effective Skills](#checklist-for-effective-skills)로 건너뛰세요.

### 해결하라, 떠넘기지 말라

Skill용 스크립트를 작성할 때, Claude에게 떠넘기지 말고 오류 상황을 처리하세요.

**좋은 예: 오류를 명시적으로 처리**:

```python  theme={null}
def process_file(path):
    """Process a file, creating it if it doesn't exist."""
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        # 실패하지 않고 기본 콘텐츠로 파일 생성
        print(f"File {path} not found, creating default")
        with open(path, 'w') as f:
            f.write('')
        return ''
    except PermissionError:
        # 실패하지 않고 대안 제공
        print(f"Cannot access {path}, using default")
        return ''
```

**나쁜 예: Claude에게 떠넘김**:

```python  theme={null}
def process_file(path):
    # 그냥 실패하고 Claude가 알아내게 함
    return open(path).read()
```

설정 매개변수도 "voodoo constant" (Ousterhout의 법칙)를 피하기 위해 정당화되고 문서화되어야 합니다. 올바른 값을 모른다면, Claude가 어떻게 결정할 수 있을까요?

**좋은 예: 자기 문서화**:

```python  theme={null}
# HTTP 요청은 보통 30초 안에 완료됨
# 더 긴 timeout은 느린 연결을 감안
REQUEST_TIMEOUT = 30

# 3번 재시도는 신뢰성 vs 속도를 균형 잡음
# 대부분의 일시적 실패는 두 번째 재시도로 해결됨
MAX_RETRIES = 3
```

**나쁜 예: 매직 넘버**:

```python  theme={null}
TIMEOUT = 47  # 왜 47?
RETRIES = 5   # 왜 5?
```

### 유틸리티 스크립트 제공

Claude가 스크립트를 작성할 수 있더라도, 사전 제작 스크립트는 이점이 있습니다:

**유틸리티 스크립트의 이점**:

* 생성된 코드보다 더 신뢰성 있음
* 토큰 절약 (코드를 context에 포함할 필요 없음)
* 시간 절약 (코드 생성 필요 없음)
* 사용 전반에 걸친 일관성 보장

<img src="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=4bbc45f2c2e0bee9f2f0d5da669bad00" alt="Bundling executable scripts alongside instruction files" data-og-width="2048" width="2048" data-og-height="1154" height="1154" data-path="images/agent-skills-executable-scripts.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=280&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=9a04e6535a8467bfeea492e517de389f 280w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=560&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=e49333ad90141af17c0d7651cca7216b 560w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=840&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=954265a5df52223d6572b6214168c428 840w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=1100&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=2ff7a2d8f2a83ee8af132b29f10150fd 1100w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=1650&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=48ab96245e04077f4d15e9170e081cfb 1650w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=2500&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=0301a6c8b3ee879497cc5b5483177c90 2500w" />

위 다이어그램은 실행 가능한 스크립트가 지시 파일과 함께 어떻게 작동하는지 보여줍니다. 지시 파일(forms.md)이 스크립트를 참조하고, Claude는 context에 그 내용을 로드하지 않고 실행할 수 있습니다.

**중요한 구분**: Claude가 다음 중 무엇을 해야 하는지 지시에서 명확히 하세요:

* **스크립트 실행** (가장 일반적): "Run `analyze_form.py` to extract fields"
* **참조로 읽기** (복잡한 로직용): "See `analyze_form.py` for the field extraction algorithm"

대부분의 유틸리티 스크립트에서는 더 신뢰성 있고 효율적이므로 실행이 선호됩니다. 스크립트 실행이 어떻게 작동하는지에 대한 디테일은 아래 [Runtime environment](#runtime-environment) 섹션을 참고하세요.

**예시**:

````markdown  theme={null}
## Utility scripts

**analyze_form.py**: Extract all form fields from PDF

```bash
python scripts/analyze_form.py input.pdf > fields.json
```

Output format:
```json
{
  "field_name": {"type": "text", "x": 100, "y": 200},
  "signature": {"type": "sig", "x": 150, "y": 500}
}
```

**validate_boxes.py**: Check for overlapping bounding boxes

```bash
python scripts/validate_boxes.py fields.json
# Returns: "OK" or lists conflicts
```

**fill_form.py**: Apply field values to PDF

```bash
python scripts/fill_form.py input.pdf fields.json output.pdf
```
````

### 시각 분석 사용

입력이 이미지로 렌더링될 수 있을 때, Claude가 분석하게 합니다:

````markdown  theme={null}
## Form layout analysis

1. Convert PDF to images:
   ```bash
   python scripts/pdf_to_images.py form.pdf
   ```

2. Analyze each page image to identify form fields
3. Claude can see field locations and types visually
````

<Note>
  이 예시에서는 `pdf_to_images.py` 스크립트를 직접 작성해야 합니다.
</Note>

Claude의 비전 기능은 레이아웃과 구조를 이해하는 데 도움이 됩니다.

### 검증 가능한 중간 출력 만들기

Claude가 복잡하고 열린 작업을 수행할 때 실수할 수 있습니다. "plan-validate-execute" 패턴은 Claude가 먼저 구조화된 형식으로 계획을 만든 다음, 실행 전에 스크립트로 그 계획을 검증하게 하여 오류를 조기에 잡습니다.

**예시**: 스프레드시트에 기반해 PDF의 50개 폼 필드를 업데이트하도록 Claude에게 요청한다고 상상해 보세요. 검증 없이는 Claude가 존재하지 않는 필드를 참조하거나, 충돌하는 값을 만들거나, 필수 필드를 놓치거나, 업데이트를 잘못 적용할 수 있습니다.

**해결책**: 위에 보여준 워크플로우 패턴(PDF 폼 채우기)을 사용하되, 변경 사항을 적용하기 전에 검증되는 중간 `changes.json` 파일을 추가합니다. 워크플로우는: 분석 → **계획 파일 생성** → **계획 검증** → 실행 → 검증이 됩니다.

**이 패턴이 작동하는 이유:**

* **오류를 조기에 잡음**: 변경 적용 전에 검증이 문제를 찾음
* **기계 검증 가능**: 스크립트가 객관적 검증을 제공
* **되돌릴 수 있는 계획**: Claude가 원본을 건드리지 않고 계획을 반복할 수 있음
* **명확한 디버깅**: 오류 메시지가 구체적 문제를 지목

**언제 사용**: 배치 작업, 파괴적 변경, 복잡한 검증 규칙, 위험 부담이 큰 작업.

**구현 팁**: Claude가 문제를 고치는 데 도움이 되도록 "Field 'signature\_date' not found. Available fields: customer\_name, order\_total, signature\_date\_signed"와 같은 구체적 오류 메시지로 검증 스크립트를 자세하게 만드세요.

### 패키지 의존성

Skill은 플랫폼별 제한이 있는 코드 실행 환경에서 실행됩니다:

* **claude.ai**: npm과 PyPI에서 패키지를 설치하고 GitHub repository에서 가져올 수 있음
* **Anthropic API**: 네트워크 액세스 없음, 런타임 패키지 설치 없음

SKILL.md에 필수 패키지를 나열하고 [code execution tool documentation](/en/docs/agents-and-tools/tool-use/code-execution-tool)에서 사용 가능한지 확인하세요.

### 런타임 환경

Skill은 파일시스템 액세스, bash 명령, 코드 실행 기능이 있는 코드 실행 환경에서 실행됩니다. 이 아키텍처의 개념적 설명은 overview의 [The Skills architecture](/en/docs/agents-and-tools/agent-skills/overview#the-skills-architecture)를 참고하세요.

**이것이 당신의 작성에 미치는 영향:**

**Claude가 Skill에 어떻게 접근하는가:**

1. **메타데이터 사전 로드**: 시작 시, 모든 Skill의 YAML frontmatter에서 name과 description이 system prompt에 로드됩니다
2. **파일은 온디맨드로 읽음**: Claude는 필요할 때 파일시스템에서 SKILL.md 및 다른 파일에 접근하기 위해 bash Read 도구를 사용합니다
3. **스크립트는 효율적으로 실행됨**: 유틸리티 스크립트는 전체 콘텐츠를 context에 로드하지 않고 bash를 통해 실행될 수 있습니다. 스크립트의 출력만 토큰을 소비합니다
4. **큰 파일에 대한 context 페널티 없음**: 참조 파일, 데이터, 문서는 실제로 읽힐 때까지 context 토큰을 소비하지 않습니다

* **파일 경로가 중요함**: Claude는 skill 디렉터리를 파일시스템처럼 탐색합니다. forward slash (`reference/guide.md`)를 사용하고, backslash를 사용하지 마세요
* **파일을 서술적으로 명명**: `doc2.md`가 아닌 `form_validation_rules.md`처럼 콘텐츠를 나타내는 이름을 사용
* **발견을 위해 조직**: 도메인이나 기능별로 디렉터리를 구조화
  * Good: `reference/finance.md`, `reference/sales.md`
  * Bad: `docs/file1.md`, `docs/file2.md`
* **포괄적인 리소스 번들링**: 완전한 API 문서, 광범위한 예시, 큰 데이터셋을 포함; 접근하기 전까지 context 페널티 없음
* **결정적 작업에는 스크립트 선호**: Claude에게 검증 코드를 생성하라고 요청하는 대신 `validate_form.py`를 작성
* **실행 의도 명확히**:
  * "Run `analyze_form.py` to extract fields" (실행)
  * "See `analyze_form.py` for the extraction algorithm" (참조로 읽기)
* **파일 액세스 패턴 테스트**: 실제 요청으로 테스트하여 Claude가 디렉터리 구조를 탐색할 수 있는지 검증

**예시:**

```
bigquery-skill/
├── SKILL.md (개요, 참조 파일을 가리킴)
└── reference/
    ├── finance.md (매출 지표)
    ├── sales.md (파이프라인 데이터)
    └── product.md (사용 분석)
```

사용자가 매출에 대해 물으면, Claude는 SKILL.md를 읽고, `reference/finance.md`에 대한 참조를 보고, 그 파일만 읽기 위해 bash를 호출합니다. sales.md와 product.md 파일은 필요할 때까지 파일시스템에 남아 0 context 토큰을 소비합니다. 이 파일시스템 기반 모델이 progressive disclosure를 가능하게 합니다. Claude는 각 작업이 요구하는 것을 정확히 탐색하고 선택적으로 로드할 수 있습니다.

기술적 아키텍처의 완전한 디테일은 Skills overview의 [How Skills work](/en/docs/agents-and-tools/agent-skills/overview#how-skills-work)를 참고하세요.

### MCP 도구 참조

Skill이 MCP (Model Context Protocol) 도구를 사용한다면, "tool not found" 오류를 피하기 위해 항상 정규화된 도구 이름을 사용하세요.

**형식**: `ServerName:tool_name`

**예시**:

```markdown  theme={null}
Use the BigQuery:bigquery_schema tool to retrieve table schemas.
Use the GitHub:create_issue tool to create issues.
```

여기서:

* `BigQuery`와 `GitHub`는 MCP 서버 이름
* `bigquery_schema`와 `create_issue`는 그 서버 안의 도구 이름

서버 접두사 없이는, 특히 여러 MCP 서버가 사용 가능할 때 Claude가 도구를 찾지 못할 수 있습니다.

### 도구가 설치되어 있다고 가정하지 말기

패키지가 사용 가능하다고 가정하지 마세요:

````markdown  theme={null}
**Bad example: Assumes installation**:
"Use the pdf library to process the file."

**Good example: Explicit about dependencies**:
"Install required package: `pip install pypdf`

Then use it:
```python
from pypdf import PdfReader
reader = PdfReader("file.pdf")
```"
````

## 기술 노트

### YAML frontmatter 요구사항

SKILL.md frontmatter는 `name` (최대 64자)과 `description` (최대 1024자) 필드를 요구합니다. 완전한 구조 디테일은 [Skills overview](/en/docs/agents-and-tools/agent-skills/overview#skill-structure)를 참고하세요.

### 토큰 예산

최적 성능을 위해 SKILL.md 본문을 500줄 이하로 유지하세요. 콘텐츠가 이를 초과하면, 앞서 설명한 progressive disclosure 패턴을 사용해 별도 파일로 분할합니다. 아키텍처 디테일은 [Skills overview](/en/docs/agents-and-tools/agent-skills/overview#how-skills-work)를 참고하세요.

## 효과적인 Skill 체크리스트

Skill을 공유하기 전에, 검증하세요:

### 핵심 품질

* [ ] description이 구체적이고 핵심 용어를 포함
* [ ] description이 Skill이 무엇을 하는지와 언제 사용하는지를 모두 포함
* [ ] SKILL.md 본문이 500줄 이하
* [ ] 추가 디테일은 별도 파일에 (필요시)
* [ ] 시간 민감 정보 없음 (또는 "old patterns" 섹션에 있음)
* [ ] 전반에 걸친 일관된 용어
* [ ] 예시가 추상적이지 않고 구체적
* [ ] 파일 참조가 한 단계 깊이
* [ ] progressive disclosure가 적절히 사용됨
* [ ] 워크플로우가 명확한 단계를 가짐

### 코드와 스크립트

* [ ] 스크립트가 Claude에게 떠넘기지 않고 문제를 해결
* [ ] 오류 처리가 명시적이고 도움이 됨
* [ ] "voodoo constants" 없음 (모든 값이 정당화됨)
* [ ] 필수 패키지가 지시에 나열되고 사용 가능한지 검증됨
* [ ] 스크립트가 명확한 문서를 가짐
* [ ] Windows 스타일 경로 없음 (모두 forward slash)
* [ ] 중요한 작업에 대한 검증/검증 단계
* [ ] 품질이 중요한 작업에 피드백 루프 포함

### 테스팅

* [ ] 최소 3개의 평가 생성
* [ ] Haiku, Sonnet, Opus로 테스트
* [ ] 실제 사용 시나리오로 테스트
* [ ] 팀 피드백 반영 (해당시)

## 다음 단계

<CardGroup cols={2}>
  <Card title="Get started with Agent Skills" icon="rocket" href="/en/docs/agents-and-tools/agent-skills/quickstart">
    Create your first Skill
  </Card>

  <Card title="Use Skills in Claude Code" icon="terminal" href="/en/docs/claude-code/skills">
    Create and manage Skills in Claude Code
  </Card>

  <Card title="Use Skills with the API" icon="code" href="/en/api/skills-guide">
    Upload and use Skills programmatically
  </Card>
</CardGroup>
