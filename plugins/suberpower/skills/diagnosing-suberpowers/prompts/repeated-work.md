`prompts/analyst-common.md`를 먼저 읽으세요. 거기에 당신의 역할, 입력,
context 안전 규칙, 반환 형식이 있습니다. 이 파일은 차원을 추가합니다.

Dimension: Repeated work

세션이 두 번 이상 한 작업을 찾으세요.

1. 모든 tool 호출을 `(line, turn, tool, key)`로 추출하세요. `key`는 다음과
   같습니다: 읽기/편집/쓰기는 파일 경로, shell 호출은 명령 텍스트(끝의 공백은
   제거하고 명령 전체를 유지), subagent dispatch는 `description`과 prompt의
   처음 80자, 검색은 query.
2. `(tool, key)`로 묶고, 기준값 이상인 묶음을 보고하세요:

   | 범주 | 기준값 | 예외 |
   |---|---|---|
   | 읽기, 검색 | 3 | |
   | 편집 | 2 | |
   | shell 명령 | 2 | 상태 확인과 test 실행(`git status`, `ls`, `pwd`, test runner) |
   | subagent dispatch | 같은 description으로 2 | |
3. 묶음마다 반복 사이에 무언가 바뀌었는지(그 파일에 대한 쓰기, compaction,
   사람의 정정) 확인하세요. 어느 경우인지 밝히세요. 편집 후 다시 읽기는
   finding이 아니고, compaction 후 다시 읽기는 compaction에 귀속되는
   finding이며, 사이에 아무것도 없는 다시 읽기는 그 자체로 finding입니다.
4. 다시 도출한 결정을 찾으세요: 세션 앞부분에서 이미 내린 결론(같은 파일,
   같은 설계 선택, 같은 실행 명령)에 다시 도달하는 assistant 텍스트. 두 곳을
   모두 인용하세요.
5. 묶음 하나당 finding 하나로, 첫 줄과 마지막 줄 번호, 횟수를 함께 쓰세요.
