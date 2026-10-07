`prompts/analyst-common.md`를 먼저 읽으세요. 거기에 당신의 역할, 입력,
context 안전 규칙, 반환 형식이 있습니다. 이 파일은 차원을 추가합니다.

Dimension: Quality evidence

과정을 그 과정 스스로의 주장에 비추어 판단하세요. 이것은 code review가
아닙니다. 세션이 만든 코드를 평가하지 마세요.

1. Test: 모든 test 실행(`test`, `pytest`, `npm test`, `cargo test`,
   `go test`, `bats`, `bash tests/…`를 포함하는 명령, 또는 instruction 파일에
   명시된 프로젝트의 runner)을 결과 줄과 함께 찾으세요. 실패한 실행과 그다음
   assistant가 한 일을 보고하세요.
2. 주장 뒤의 검증: 완료, 수정됨, 통과, 검증됨, 동작함, 끝남을 주장하는
   assistant 텍스트를 찾으세요. 각각에 대해 같은 turn 안에서 거슬러 올라가
   그것을 보여 주는 tool 결과(test 실행, 명령 출력, diff)를 찾으세요. 그
   turn 안에 뒷받침하는 결과가 없는 주장을 보고하세요.
3. Commit: 모든 `git commit`을 메시지와 함께 찾고, 각 메시지를 직전 turn의
   tool 호출과 비교하세요. 어떤 tool 호출도 수행하지 않은 작업을 메시지가
   주장하는 commit, 그리고 합의된 plan이 commit한다고 했는데 한 번도 commit되지
   않은 작업을 보고하세요.
4. Review feedback: reviewer(사람이든 subagent든)가 지적한 곳에서 그에 대한
   대응을 찾으세요. 수긍했지만 반영하지 않은 지적과, 이유를 밝히지 않고 기각한
   지적을 보고하세요.
5. 수용 기준: case 파일의 문제 진술이나 합의된 plan이 기준을 명시했다면,
   각각을 met / not met / not checked로 증거 줄과 함께 보고하세요.
