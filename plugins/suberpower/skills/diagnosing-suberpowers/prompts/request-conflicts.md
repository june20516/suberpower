`prompts/analyst-common.md`를 먼저 읽으세요. 거기에 당신의 역할, 입력,
context 안전 규칙, 반환 형식이 있습니다. 이 파일은 차원을 추가합니다.

Dimension: Request conflicts

1. 모든 사람의 prompt를 줄, turn과 함께 나열하세요. 각각에서 그 안에 담긴
   지시(명령문, 제약, "don't"/"하지 마", "always"/"항상", "never"/"절대",
   "only"/"오직", 범위 진술)를 추출하세요.
2. 다음을 보고하세요:
   - 동시에 따를 수 없는 사람의 지시 두 개(줄과 함께 둘 다 인용)와 assistant가
     한 일;
   - 세션에 로드된 instruction 파일(CLAUDE.md, AGENTS.md, GEMINI.md, 또는
     harness의 동등한 파일. 경로는 case 파일에 있음)과 충돌하는 사람의 지시(둘
     다 인용);
   - 단계, skill, 규칙을 건너뛰거나 무시하거나 무효화하라는 사람의 지시와 그
     뒤에 일어난 일;
   - 답이 범위를 바꾼 경우에 한해, assistant가 명확히 해 달라고 물은 지시와
     그 답.
3. your human partner가 옳았는지는 판단하지 마세요. 충돌과 assistant의 해결
   방식을 보고하세요.
