# suberpower

[obra/superpowers](https://github.com/obra/superpowers)의 한국어 번역 포크입니다. TDD·디버깅·협업·계획·worktree 등 핵심 워크플로우 스킬을 한국어로 제공하며, worktree 방식을 개인 취향에 맞게 커스터마이징하기 위한 개인용 포크입니다.

원본과 구분하기 위해 의도적으로 `suberpower`로 명명했습니다. 스킬 호출 네임스페이스는 `suberpower:<skill-name>` 형태입니다.

## 설치

```bash
claude plugin marketplace add june20516/suberpower
claude plugin install suberpower@suberpower
```

원본 `superpowers`와 동시에 활성화하면 SessionStart 훅이 중복되므로, 둘 중 하나만 사용하세요.

## 구성

- `plugins/suberpower/skills/` — 한국어로 번역된 스킬 14종
- `plugins/suberpower/hooks/` — SessionStart 훅 (매 세션 시작 시 `using-suberpowers` 주입)

## 라이선스 / 원작자

MIT License. 원작자: Jesse Vincent ([obra/superpowers](https://github.com/obra/superpowers)). 자세한 내용은 [LICENSE](./LICENSE)를 참고하세요.
