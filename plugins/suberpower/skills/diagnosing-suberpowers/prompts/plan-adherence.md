`prompts/analyst-common.md`를 먼저 읽으세요. 거기에 당신의 역할, 입력,
context 안전 규칙, 반환 형식이 있습니다. 이 파일은 차원을 추가합니다.

Dimension: Plan adherence

세션이 합의한 plan을 복원한 다음, plan의 각 단계를 실제로 일어난 일과
대응시키세요. 여기서 "plan"은 합의된 모든 행동 방침을 뜻하며, git commit이
아닙니다.

1. 합의된 plan을 찾으세요: 대화에서 합의된 설계나 plan(사람의 "yes/ok/go
   ahead" 직전의 assistant 텍스트를 찾으세요), 세션 중에 작성된 spec이나
   plan 파일(`docs/`, `plans/`, `specs/` 아래, 또는 사람이 지목한 파일에 쓰는
   tool 호출), case 파일에서 의미가 확립된 todo 목록 레코드, 또는 assistant
   텍스트 안의 번호 매긴 checklist. plan의 각 단계를 `path:line`과 함께
   인용하세요.
2. plan과 그 실행 사이에 있는 구조적 event를 표시하세요: 탐색 단계에서 식별된
   compaction event, resume, 중단된 turn, 연관된 세션 dispatch. 그 줄 번호를
   기록하세요. 이런 event 직후의 plan 이탈은 별개의 finding입니다.
3. plan의 각 단계마다 그것을 실행한 tool 호출과 assistant 텍스트를 찾거나,
   실행한 것이 없음을 확인하세요. 다음을 보고하세요:
   - 건너뛴 단계(실행을 찾지 못함. plan 단계를 인용);
   - 순서가 바뀐 단계(줄 번호가 순서를 보여 줌);
   - 조용히 바뀐 단계(실행이 plan 단계와 다르고 assistant가 그것을 한 번도
     알리지 않음. 둘 다 인용);
   - 만들어 낸 단계(어떤 plan 단계도 다루지 않는 작업);
   - 구조적 event 직후의 이탈(그 event 줄과 처음으로 어긋난 행동을 인용).
4. 복원할 수 있는 plan이 없으면, 확인한 줄과 함께 그것을 유일한 finding으로
   보고하세요.
