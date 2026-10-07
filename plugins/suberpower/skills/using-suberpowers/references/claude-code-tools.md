# Claude Code Tool 참고 사항

Claude Code는 기준 harness입니다: skill은 Claude Code의 어휘(subagent dispatch에는
`Agent`, todo, `Skill`)로 말합니다. 이 문서는 Claude Code가 skill의 기본 형태보다
plan을 더 저렴하게 실행할 수 있는 한 지점을 다룹니다. your human partner가 선택할
때만(opt-in) 적용되며, skill이 요구하는 것은 아무것도 바꾸지 않습니다.

## subagent-driven development를 더 저렴하게 조율하기

suberpower:subagent-driven-development 실행에서 가장 비싼 자리(실행 단위)는
controller 세션입니다: 모든 dispatch 결과와 모든 보고를 읽고, 대개 세션에서 가장 성능
좋은 모델로 실행됩니다. Claude Code는 중첩 subagent를 지원하므로(기본적으로 main
대화 아래 세 단계까지, `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`로 조정), 루프 전체를
한 단계 아래에서 실행할 수 있습니다.

your human partner가 요청하면 — 또는 세션 모델이 조율에 쓰기에는 너무 비싸다고
말했다면 — 중간 등급 모델로 orchestrator subagent **하나**를 dispatch하고, plan
경로와 함께 suberpower:subagent-driven-development를 처음부터 끝까지 사용하라는
지시를 주세요. orchestrator는 SDD skill의 '모델 선택'에 따라 자신의 implementer와
reviewer를 dispatch합니다. 작업 공간과 ledger는 디스크에 있으므로, 단계가 하나 더
생겨도 잃는 것이 없습니다. orchestrator의 최종 메시지에는 "Rulings I made(내가
내린 결정)" 목록이 원문 그대로 담겨야 합니다 — 결정은 그 목록을 통해 your human
partner에게 닿으므로, 요약하지 말고 그대로 전달하세요.

plan 전체를 실행할 때만 이렇게 하세요. 한 task의 dispatch만 중첩하면 얻는 것 없이
자리만 하나 늘어납니다.
