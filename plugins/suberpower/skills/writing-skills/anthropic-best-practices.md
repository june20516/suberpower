# Skill authoring best practices

> Claude가 발견하고 성공적으로 사용할 수 있는 효과적인 Skill을 작성하는 방법을 배웁니다.

좋은 Skill은 간결하고, 잘 구조화되어 있으며, 실제 사용으로 테스트됩니다. 이 가이드는 Claude가 효과적으로 발견하고 사용할 수 있는 Skill 작성에 도움이 되는 실용적 작성 결정을 제공합니다.

Skill이 어떻게 작동하는지에 대한 개념적 배경은 [Skills overview](/en/docs/agents-and-tools/agent-skills/overview)를 참고하세요.

## 핵심 원칙

### 간결함이 핵심

[context window](https://platform.claude.com/docs/en/build-with-claude/context-windows)는 공유 자원입니다. 당신의 Skill은 Claude가 알아야 할 다른 모든 것과 context window를 공유합니다. 여기에는 다음이 포함됩니다:

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
## PDF 텍스트 추출

텍스트 추출에는 pdfplumber를 사용하세요:

```python
import pdfplumber

with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
````

**나쁜 예: 너무 장황** (약 150 토큰):

```markdown  theme={null}
## PDF 텍스트 추출

PDF(Portable Document Format) 파일은 텍스트, 이미지, 기타 콘텐츠를 담는 일반적인
파일 형식입니다. PDF에서 텍스트를 추출하려면 라이브러리를 사용해야 합니다. PDF 처리를
위한 라이브러리는 많이 있지만, 저희는 pdfplumber를 추천합니다. 사용하기 쉽고 대부분의
경우를 잘 처리하기 때문입니다. 먼저 pip으로 설치해야 합니다. 그다음 아래 코드를 사용할 수
있습니다...
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
## 코드 review 프로세스

1. 코드 구조와 구성을 분석한다
2. 잠재적인 bug나 edge case를 확인한다
3. 가독성과 유지보수성 개선을 제안한다
4. 프로젝트 관례를 준수하는지 검증한다
```

**중간 자유도** (의사 코드 또는 매개변수가 있는 스크립트):

사용 시기:

* 선호되는 패턴이 존재함
* 어느 정도 변형이 수용 가능함
* 설정이 동작에 영향을 줌

예시:

````markdown  theme={null}
## 보고서 생성

이 템플릿을 사용하고 필요에 따라 수정하세요:

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
## 데이터베이스 마이그레이션

정확히 이 스크립트를 실행하세요:

```bash
python scripts/migrate.py --verify --backup
```

명령을 수정하거나 추가 flag를 붙이지 마세요.
````

**비유**: Claude를 경로를 탐색하는 로봇이라고 생각하세요:

* **양쪽이 절벽인 좁은 다리**: 안전한 길은 하나뿐입니다. 구체적인 가드레일과 정확한 지시를 제공하세요 (낮은 자유도). 예: 정확한 순서로 실행되어야 하는 데이터베이스 마이그레이션.
* **위험 없는 열린 들판**: 여러 길이 성공으로 이어집니다. 일반적인 방향을 주고 Claude가 최선의 경로를 찾도록 신뢰하세요 (높은 자유도). 예: context가 최선의 접근을 결정하는 코드 review.

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

  * **Good:** "Excel 파일을 처리하고 보고서를 생성합니다"
  * **Avoid:** "제가 Excel 파일 처리를 도와드릴 수 있습니다"
  * **Avoid:** "이것으로 Excel 파일을 처리할 수 있습니다"
</Warning>

**구체적이고 핵심 용어를 포함하세요**. Skill이 무엇을 하는지와 언제 사용하는지의 구체적 트리거/context를 모두 포함합니다.

각 Skill은 정확히 하나의 description 필드를 가집니다. description은 skill 선택에 결정적입니다: Claude는 잠재적으로 100개 이상의 사용 가능한 Skill에서 올바른 Skill을 선택하기 위해 이것을 사용합니다. description은 Claude가 언제 이 Skill을 선택할지 알 수 있도록 충분한 디테일을 제공해야 하며, SKILL.md의 나머지가 구현 디테일을 제공합니다.

효과적인 예시:

**PDF Processing skill:**

```yaml  theme={null}
description: PDF 파일에서 텍스트와 표를 추출하고, 폼을 채우고, 문서를 병합합니다. PDF 파일을 다루거나 사용자가 PDF, 폼, 문서 추출을 언급할 때 사용합니다.
```

**Excel Analysis skill:**

```yaml  theme={null}
description: Excel 스프레드시트를 분석하고, 피벗 테이블을 만들고, 차트를 생성합니다. Excel 파일, 스프레드시트, 표 형식 데이터, .xlsx 파일을 분석할 때 사용합니다.
```

**Git Commit Helper skill:**

```yaml  theme={null}
description: git diff를 분석하여 서술적인 commit 메시지를 생성합니다. 사용자가 commit 메시지 작성이나 staged 변경사항 review에 도움을 요청할 때 사용합니다.
```

다음과 같은 모호한 description은 피하세요:

```yaml  theme={null}
description: 문서 작업을 도와줍니다
```

```yaml  theme={null}
description: 데이터를 처리합니다
```

```yaml  theme={null}
description: 파일로 이것저것 합니다
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
description: PDF 파일에서 텍스트와 표를 추출하고, 폼을 채우고, 문서를 병합합니다. PDF 파일을 다루거나 사용자가 PDF, 폼, 문서 추출을 언급할 때 사용합니다.
---

# PDF Processing

## 빠른 시작

pdfplumber로 텍스트를 추출하세요:
```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```

## 고급 기능

**폼 채우기**: 전체 가이드는 [FORMS.md](FORMS.md) 참고
**API 참조**: 모든 메서드는 [REFERENCE.md](REFERENCE.md) 참고
**예시**: 일반적인 패턴은 [EXAMPLES.md](EXAMPLES.md) 참고
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

## 사용 가능한 데이터셋

**Finance**: 매출, ARR, 청구 → [reference/finance.md](reference/finance.md) 참고
**Sales**: 기회, 파이프라인, 계정 → [reference/sales.md](reference/sales.md) 참고
**Product**: API 사용량, 기능, 도입률 → [reference/product.md](reference/product.md) 참고
**Marketing**: 캠페인, 어트리뷰션, 이메일 → [reference/marketing.md](reference/marketing.md) 참고

## 빠른 검색

grep으로 특정 지표를 찾으세요:

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

## 문서 생성

새 문서에는 docx-js를 사용하세요. [DOCX-JS.md](DOCX-JS.md)를 참고하세요.

## 문서 편집

간단한 편집은 XML을 직접 수정하세요.

**변경 이력 추적**: [REDLINING.md](REDLINING.md) 참고
**OOXML 세부사항**: [OOXML.md](OOXML.md) 참고
```

Claude는 사용자가 그 기능이 필요할 때만 REDLINING.md나 OOXML.md를 읽습니다.

### 깊게 중첩된 참조를 피하세요

Claude는 다른 참조된 파일에서 참조된 파일을 부분적으로 읽을 수 있습니다. 중첩 참조를 마주칠 때, Claude는 전체 파일을 읽기보다 `head -100`과 같은 명령으로 콘텐츠를 미리보기 할 수 있어 불완전한 정보로 이어집니다.

**참조를 SKILL.md에서 한 단계 깊이로 유지하세요**. 모든 참조 파일은 SKILL.md에서 직접 링크되어야 Claude가 필요할 때 완전한 파일을 읽도록 보장됩니다.

**나쁜 예: 너무 깊음**:

```markdown  theme={null}
# SKILL.md
[advanced.md](advanced.md)를 참고하세요...

# advanced.md
[details.md](details.md)를 참고하세요...

# details.md
여기에 실제 정보가 있습니다...
```

**좋은 예: 한 단계 깊이**:

```markdown  theme={null}
# SKILL.md

**기본 사용법**: [SKILL.md 안의 지시]
**고급 기능**: [advanced.md](advanced.md) 참고
**API 참조**: [reference.md](reference.md) 참고
**예시**: [examples.md](examples.md) 참고
```

### 더 긴 참조 파일은 목차로 구조화

100줄 이상의 참조 파일에는 상단에 목차를 포함합니다. 이는 Claude가 부분 읽기로 미리보기 할 때조차 사용 가능한 정보의 전체 범위를 볼 수 있도록 보장합니다.

**예시**:

```markdown  theme={null}
# API Reference

## 목차
- 인증 및 설정
- 핵심 메서드 (create, read, update, delete)
- 고급 기능 (배치 작업, webhook)
- Error handling 패턴
- 코드 예시

## 인증 및 설정
...

## 핵심 메서드
...
```

Claude는 그러면 완전한 파일을 읽거나 필요에 따라 특정 섹션으로 이동할 수 있습니다.

이 파일시스템 기반 아키텍처가 어떻게 progressive disclosure를 가능하게 하는지에 대한 디테일은 아래 Advanced 섹션의 [Runtime environment](#runtime-environment) 섹션을 참고하세요.

## 워크플로우와 피드백 루프

### 복잡한 작업에 워크플로우 사용

복잡한 작업을 명확한 순차 단계로 분해합니다. 특히 복잡한 워크플로우의 경우, Claude가 응답에 복사하여 진행하면서 체크할 수 있는 체크리스트를 제공합니다.

**예시 1: 리서치 합성 워크플로우** (코드 없는 Skill용):

````markdown  theme={null}
## 리서치 합성 워크플로우

이 체크리스트를 복사해서 진행 상황을 추적하세요:

```
리서치 진행 상황:
- [ ] Step 1: 모든 원본 문서 읽기
- [ ] Step 2: 핵심 주제 식별
- [ ] Step 3: 주장 교차 확인
- [ ] Step 4: 구조화된 요약 작성
- [ ] Step 5: 인용 검증
```

**Step 1: 모든 원본 문서 읽기**

`sources/` 디렉터리의 각 문서를 검토하세요. 주요 논거와 뒷받침하는 근거를 기록하세요.

**Step 2: 핵심 주제 식별**

여러 출처에 걸친 패턴을 찾으세요. 어떤 주제가 반복해서 나타나는가? 출처들이 어디에서 일치하고 어디에서 엇갈리는가?

**Step 3: 주장 교차 확인**

주요 주장마다 그것이 원본 자료에 실제로 나오는지 검증하세요. 각 논점을 어떤 출처가 뒷받침하는지 기록하세요.

**Step 4: 구조화된 요약 작성**

발견한 것을 주제별로 정리하세요. 다음을 포함하세요:
- 주요 주장
- 출처에서 뒷받침하는 근거
- 상충하는 관점 (있는 경우)

**Step 5: 인용 검증**

모든 주장이 올바른 원본 문서를 참조하는지 확인하세요. 인용이 불완전하면 Step 3으로 돌아가세요.
````

이 예시는 워크플로우가 코드를 요구하지 않는 분석 작업에 어떻게 적용되는지 보여줍니다. 체크리스트 패턴은 어떤 복잡한 다단계 프로세스에도 작동합니다.

**예시 2: PDF 폼 채우기 워크플로우** (코드가 있는 Skill용):

````markdown  theme={null}
## PDF 폼 채우기 워크플로우

이 체크리스트를 복사해서 완료할 때마다 항목을 체크하세요:

```
작업 진행 상황:
- [ ] Step 1: 폼 분석 (analyze_form.py 실행)
- [ ] Step 2: 필드 매핑 생성 (fields.json 편집)
- [ ] Step 3: 매핑 검증 (validate_fields.py 실행)
- [ ] Step 4: 폼 채우기 (fill_form.py 실행)
- [ ] Step 5: 출력 검증 (verify_output.py 실행)
```

**Step 1: 폼 분석**

실행: `python scripts/analyze_form.py input.pdf`

폼 필드와 그 위치를 추출하여 `fields.json`에 저장합니다.

**Step 2: 필드 매핑 생성**

`fields.json`을 편집하여 각 필드의 값을 추가하세요.

**Step 3: 매핑 검증**

실행: `python scripts/validate_fields.py fields.json`

계속하기 전에 검증 오류를 모두 수정하세요.

**Step 4: 폼 채우기**

실행: `python scripts/fill_form.py input.pdf fields.json output.pdf`

**Step 5: 출력 검증**

실행: `python scripts/verify_output.py output.pdf`

검증에 실패하면 Step 2로 돌아가세요.
````

명확한 단계는 Claude가 중요한 검증을 건너뛰는 것을 막습니다. 체크리스트는 Claude와 당신 모두가 다단계 워크플로우의 진행을 추적하는 데 도움이 됩니다.

### 피드백 루프 구현

**일반적인 패턴**: validator 실행 → 오류 수정 → 반복

이 패턴은 출력 품질을 크게 향상시킵니다.

**예시 1: 스타일 가이드 준수** (코드 없는 Skill용):

```markdown  theme={null}
## 콘텐츠 review 프로세스

1. STYLE_GUIDE.md의 가이드라인에 따라 콘텐츠 초안을 작성한다
2. 체크리스트와 대조하여 review한다:
   - 용어 일관성 확인
   - 예시가 표준 형식을 따르는지 검증
   - 필수 섹션이 모두 있는지 확인
3. 이슈를 발견하면:
   - 각 이슈를 구체적인 섹션 참조와 함께 기록
   - 콘텐츠를 수정
   - 체크리스트를 다시 review
4. 모든 요구사항이 충족되었을 때만 진행한다
5. 문서를 마무리하고 저장한다
```

이는 스크립트 대신 참조 문서를 사용한 검증 루프 패턴을 보여줍니다. "validator"는 STYLE\_GUIDE.md이고, Claude는 읽고 비교하여 검사를 수행합니다.

**예시 2: 문서 편집 프로세스** (코드가 있는 Skill용):

```markdown  theme={null}
## 문서 편집 프로세스

1. `word/document.xml`을 편집한다
2. **즉시 검증**: `python ooxml/scripts/validate.py unpacked_dir/`
3. 검증에 실패하면:
   - 오류 메시지를 주의 깊게 확인
   - XML의 문제를 수정
   - 검증을 다시 실행
4. **검증을 통과했을 때만 진행한다**
5. 재빌드: `python ooxml/scripts/pack.py unpacked_dir/ output.docx`
6. 출력 문서를 테스트한다
```

검증 루프는 오류를 조기에 잡습니다.

## 콘텐츠 가이드라인

### 시간 민감 정보 피하기

오래되어 잘못될 정보를 포함하지 마세요:

**나쁜 예: 시간 민감** (틀려질 것):

```markdown  theme={null}
2025년 8월 이전에 작업한다면 예전 API를 사용하세요.
2025년 8월 이후에는 새 API를 사용하세요.
```

**좋은 예** ("old patterns" 섹션 사용):

```markdown  theme={null}
## 현재 방식

v2 API endpoint를 사용하세요: `api.example.com/v2/messages`

## 예전 패턴

<details>
<summary>Legacy v1 API (2025-08 deprecated)</summary>

v1 API는 다음을 사용했습니다: `api.example.com/v1/messages`

이 endpoint는 더 이상 지원되지 않습니다.
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
## 보고서 구조

ALWAYS 정확히 이 템플릿 구조를 사용하세요:

```markdown
# [분석 제목]

## 요약
[핵심 발견 사항에 대한 한 단락 개요]

## 주요 발견 사항
- 뒷받침하는 데이터와 함께 발견 사항 1
- 뒷받침하는 데이터와 함께 발견 사항 2
- 뒷받침하는 데이터와 함께 발견 사항 3

## 권장 사항
1. 구체적이고 실행 가능한 권장 사항
2. 구체적이고 실행 가능한 권장 사항
```
````

**유연한 가이던스** (적응이 유용할 때):

````markdown  theme={null}
## 보고서 구조

다음은 합리적인 기본 형식이지만, 분석 내용에 따라 최선의 판단을 사용하세요:

```markdown
# [분석 제목]

## 요약
[개요]

## 주요 발견 사항
[발견한 내용에 따라 섹션을 조정하세요]

## 권장 사항
[구체적인 맥락에 맞게 조정하세요]
```

구체적인 분석 유형에 맞게 필요에 따라 섹션을 조정하세요.
````

### 예시 패턴

출력 품질이 예시를 보는 것에 달려 있는 Skill의 경우, 일반 prompt에서처럼 input/output 쌍을 제공합니다:

````markdown  theme={null}
## Commit 메시지 형식

다음 예시를 따라 commit 메시지를 생성하세요:

**예시 1:**
입력: JWT 토큰으로 사용자 인증을 추가함
출력:
```
feat(auth): implement JWT-based authentication

Add login endpoint and token validation middleware
```

**예시 2:**
입력: 보고서에서 날짜가 잘못 표시되던 bug를 수정함
출력:
```
fix(reports): correct date formatting in timezone conversion

Use UTC timestamps consistently across report generation
```

**예시 3:**
입력: 의존성을 업데이트하고 error handling을 리팩터링함
출력:
```
chore: update dependencies and refactor error handling

- Upgrade lodash to 4.17.21
- Standardize error response format across endpoints
```

이 스타일을 따르세요: type(scope): 간략한 설명, 그다음 상세 설명.
````

예시는 Claude가 설명만으로는 알기 어려운 원하는 스타일과 디테일 수준을 더 명확히 이해하도록 돕습니다.

### 조건부 워크플로우 패턴

결정 지점을 통해 Claude를 안내합니다:

```markdown  theme={null}
## 문서 수정 워크플로우

1. 수정 유형을 판단한다:

   **새 콘텐츠를 만드나요?** → 아래 "생성 워크플로우"를 따르세요
   **기존 콘텐츠를 편집하나요?** → 아래 "편집 워크플로우"를 따르세요

2. 생성 워크플로우:
   - docx-js 라이브러리 사용
   - 문서를 처음부터 구성
   - .docx 형식으로 내보내기

3. 편집 워크플로우:
   - 기존 문서 압축 해제
   - XML을 직접 수정
   - 변경할 때마다 검증
   - 완료되면 다시 압축
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
  "query": "이 PDF 파일에서 모든 텍스트를 추출해서 output.txt에 저장해 줘",
  "files": ["test-files/document.pdf"],
  "expected_behavior": [
    "적절한 PDF 처리 라이브러리나 명령줄 도구를 사용해 PDF 파일을 성공적으로 읽는다",
    "문서의 모든 페이지에서 텍스트 콘텐츠를 빠짐없이 추출한다",
    "추출한 텍스트를 output.txt라는 파일에 명확하고 읽기 쉬운 형식으로 저장한다"
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
**나쁜 예: 선택지가 너무 많음** (혼란스러움):
"pypdf를 쓰거나, pdfplumber를 쓰거나, PyMuPDF를 쓰거나, pdf2image를 쓰거나..."

**좋은 예: 기본값 제시** (예외 경로 포함):
"텍스트 추출에는 pdfplumber를 사용하세요:
```python
import pdfplumber
```

OCR이 필요한 스캔된 PDF에는 대신 pdf2image와 pytesseract를 사용하세요."
````

## Advanced: 실행 가능한 코드를 포함한 Skill

아래 섹션들은 실행 가능한 스크립트를 포함한 Skill에 집중합니다. Skill이 마크다운 지시만 사용한다면, [Checklist for effective Skills](#checklist-for-effective-skills)로 건너뛰세요.

### 해결하라, 떠넘기지 말라

Skill용 스크립트를 작성할 때, Claude에게 떠넘기지 말고 오류 상황을 처리하세요.

**좋은 예: 오류를 명시적으로 처리**:

```python  theme={null}
def process_file(path):
    """파일을 처리하고, 존재하지 않으면 생성한다."""
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        # 실패하지 않고 기본 콘텐츠로 파일 생성
        print(f"파일 {path}을(를) 찾을 수 없어 기본값으로 생성합니다")
        with open(path, 'w') as f:
            f.write('')
        return ''
    except PermissionError:
        # 실패하지 않고 대안 제공
        print(f"{path}에 접근할 수 없어 기본값을 사용합니다")
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

* **스크립트 실행** (가장 일반적): "필드를 추출하려면 `analyze_form.py`를 실행하세요"
* **참조로 읽기** (복잡한 로직용): "필드 추출 알고리즘은 `analyze_form.py`를 참고하세요"

대부분의 유틸리티 스크립트에서는 더 신뢰성 있고 효율적이므로 실행이 선호됩니다. 스크립트 실행이 어떻게 작동하는지에 대한 디테일은 아래 [Runtime environment](#runtime-environment) 섹션을 참고하세요.

**예시**:

````markdown  theme={null}
## 유틸리티 스크립트

**analyze_form.py**: PDF에서 모든 폼 필드를 추출

```bash
python scripts/analyze_form.py input.pdf > fields.json
```

출력 형식:
```json
{
  "field_name": {"type": "text", "x": 100, "y": 200},
  "signature": {"type": "sig", "x": 150, "y": 500}
}
```

**validate_boxes.py**: 겹치는 bounding box가 있는지 확인

```bash
python scripts/validate_boxes.py fields.json
# 반환값: "OK" 또는 충돌 목록
```

**fill_form.py**: 필드 값을 PDF에 적용

```bash
python scripts/fill_form.py input.pdf fields.json output.pdf
```
````

### 시각 분석 사용

입력이 이미지로 렌더링될 수 있을 때, Claude가 분석하게 합니다:

````markdown  theme={null}
## 폼 레이아웃 분석

1. PDF를 이미지로 변환:
   ```bash
   python scripts/pdf_to_images.py form.pdf
   ```

2. 각 페이지 이미지를 분석하여 폼 필드를 식별
3. Claude가 필드 위치와 유형을 시각적으로 확인할 수 있음
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
  * "필드를 추출하려면 `analyze_form.py`를 실행하세요" (실행)
  * "추출 알고리즘은 `analyze_form.py`를 참고하세요" (참조로 읽기)
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
테이블 스키마를 가져오려면 BigQuery:bigquery_schema 도구를 사용하세요.
이슈를 생성하려면 GitHub:create_issue 도구를 사용하세요.
```

여기서:

* `BigQuery`와 `GitHub`는 MCP 서버 이름
* `bigquery_schema`와 `create_issue`는 그 서버 안의 도구 이름

서버 접두사 없이는, 특히 여러 MCP 서버가 사용 가능할 때 Claude가 도구를 찾지 못할 수 있습니다.

### 도구가 설치되어 있다고 가정하지 말기

패키지가 사용 가능하다고 가정하지 마세요:

````markdown  theme={null}
**나쁜 예: 설치되어 있다고 가정**:
"pdf 라이브러리를 사용해 파일을 처리하세요."

**좋은 예: 의존성을 명시**:
"필요한 패키지를 설치하세요: `pip install pypdf`

그다음 사용하세요:
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
* [ ] 중요한 작업에 대한 유효성 검사/결과 검증 단계
* [ ] 품질이 중요한 작업에 피드백 루프 포함

### 테스팅

* [ ] 최소 3개의 평가 생성
* [ ] Haiku, Sonnet, Opus로 테스트
* [ ] 실제 사용 시나리오로 테스트
* [ ] 팀 피드백 반영 (해당시)

## 다음 단계

<CardGroup cols={2}>
  <Card title="Agent Skills 시작하기" icon="rocket" href="/en/docs/agents-and-tools/agent-skills/quickstart">
    첫 Skill 만들기
  </Card>

  <Card title="Claude Code에서 Skill 사용하기" icon="terminal" href="/en/docs/claude-code/skills">
    Claude Code에서 Skill 만들고 관리하기
  </Card>

  <Card title="API로 Skill 사용하기" icon="code" href="/en/api/skills-guide">
    프로그래밍 방식으로 Skill 업로드하고 사용하기
  </Card>
</CardGroup>
