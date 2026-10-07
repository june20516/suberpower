`prompts/analyst-common.md`를 먼저 읽으세요. 거기에 당신의 역할, 입력,
context 안전 규칙, 반환 형식이 있습니다. 이 파일은 차원을 추가합니다.

Dimension: Stumbles

세션이 앞으로 나아가지 못하고 멈춘 지점(막힘)을 모두 찾으세요.

출처는 다음과 같으며, 각각 case 파일의 근거 있는 레코드 의미와 추출 명령을
사용해 줄 번호를 찾으세요:
- 오류로 표시된 tool 결과, 0이 아닌 종료 코드, 명시적인 실패 레코드;
- 실패한 shell 명령(결과의 0이 아닌 종료 코드, "command not
  found", "No such file");
- 재시도: 오류 후 같은 turn 안에서 다시 보낸 같은 tool
  호출;
- 되돌린 편집: 이전 내용을 복원하는 편집이 뒤따른 편집, 또는 세션이 건드린
  파일에 대한 `git checkout`/`git restore`/`git revert`/`git reset`;
- assistant 텍스트의 되짚기("actually", "let me instead", "that was
  wrong", "I misread", 또는 "아니 잠깐", "대신 이렇게", "제가 잘못 읽었" 같은
  한국어 표현);
- 사람의 정정: assistant의 바로 앞 행동을 반박하거나 바로잡는 사람의 prompt;
- 권한 거부, hook 실패, API 오류, rate limit, 중단된 turn, 그리고 작업 도중
  일어난 context overflow나 compaction.

막힘마다 줄, turn, 무엇이 실패했는지, 그다음 무슨 일이 있었는지(같은 turn에서
회복 / N번 줄에서 나중에 회복 / 회복하지 못함)를 보고하세요. 똑같은 실패가
반복되면 횟수와 함께 finding 하나로 묶으세요.
