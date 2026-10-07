`prompts/analyst-common.md`를 먼저 읽으세요. 거기에 당신의 역할, 입력,
context 안전 규칙, 반환 형식이 있습니다. 이 파일은 차원을 추가합니다.

Dimension: Skill timeline

사람의 turn별로 skill과 plugin 사용 기록을 만들고, 그다음 빈틈을 찾으세요.

1. 사람의 prompt를 줄 번호, timestamp와 함께 나열하세요.
2. case 파일에서 확립된 skill 호출과 귀속(attribution)의 의미를 사용해,
   모든 명시적 호출, 활성 skill 귀속, `SKILL.md`라는 이름의 파일 읽기를
   나열하세요. 줄, skill 이름, 그것이 일어난 사람의 turn을 기록하세요.
3. 진단 대상 플러그인 `suberpower`가 아닌 plugin, skill, agent type, MCP
   server, hook 중 사용된 것을 모두 나열하세요. case 파일에 기록된, 근거 있는
   tool, 귀속, agent dispatch, MCP, hook의 의미만 사용하고, `suberpower` 이외의
   것과 연관된 값을 식별하세요. 원본 Superpowers 플러그인이 함께 설치되어
   있었다면 그 네임스페이스로 된 skill 호출도 `suberpower` 이외의 plugin으로
   다루세요.
4. 사람의 turn마다 요청 텍스트를 설치된 suberpowers skill의 트리거 설명과
   비교하세요(`<install root>/skills/*/SKILL.md` frontmatter의 `description`
   줄을 읽으세요. install root는 case 파일에 있습니다). 다음을 finding으로
   보고하세요:
   - 호출된 skill과 그 직전의 요청(호출이 적으면 호출마다 finding 하나도
     괜찮고, 많으면 skill별로 묶으세요);
   - 요청이 어떤 skill의 트리거 설명과 일치하는데 그 turn에 호출이 없는
     turn(어느 설명이 일치했는지 밝히고 요청을 인용하세요);
   - 일치하는 요청보다 한 turn 이상 늦게 호출된 skill(지연);
   - 사용된 `suberpower` 이외의 plugin/skill/tool 각각과 그 위치.

놓치거나 늦은 트리거가 잘못이었는지는 말하지 마세요. 일치와 부재를
보고하세요. 판단은 읽는 사람이 합니다.
