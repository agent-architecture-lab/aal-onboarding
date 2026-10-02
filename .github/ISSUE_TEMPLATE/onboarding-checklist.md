---
name: 온보딩 체크리스트
about: 크루원 1명당 1개 — 3-Day 온보딩 진행 상황을 체크해요
title: "[온보딩] <GitHub ID>"
labels: onboarding
assignees: ''
---

> 가이드: [README](https://github.com/agent-architecture-lab/aal-onboarding#readme) · 이 이슈는 공개예요. 키·메일·실명은 적지 마세요.

**OS**: macOS / Windows(WSL2) / Linux
**트랙**: 공통 / 터미널이 낯선 크루 / 개발자·데이터

## Day 1 — 계정·도구
- [ ] [디스코드 서버](https://discord.gg/WF8cTKNUy) 참여 + 리더에게 GitHub ID · LLM 사용 경로 · OS 전송
- [ ] (Windows) WSL2 Ubuntu 설치
- [ ] 새 터미널에서 `which git gh uv codex` 4줄 모두 경로 출력
- [ ] `git config --global user.name / user.email` 설정 (noreply 메일 권장)

## Day 2 — 연결 (10/3 팀 OT)
- [ ] `agent-architecture-lab` 조직 초대 수락
- [ ] `gh auth login` + `gh auth setup-git`
- [ ] `codex login status` 로그인 상태, `~/.codex/config.toml` 권한 기본값 설정
- [ ] (권장) Context7 MCP 등록
- [ ] 교재 clone + `uv` 환경 + `.env` 구성
- [ ] `codex doctor` 에 ✗ 없음

## Day 3 — 활용
- [ ] 예시 프롬프트 3개 이상 써 보기
- [ ] Codex가 push·PR 같은 쓰기 작업 전에 승인을 요청하는 것 확인
- [ ] 자기소개 PR (`crew/<GitHub ID>.md`) 머지
- [ ] 교재 폴더에서 `.venv/bin/python -c "import agentic_architectures"` 성공, `git status` 에 `.env` 없음

## aal-doctor 결과

`bash ~/aal/aal-onboarding/scripts/aal-doctor.sh ~/aal/all-agentic-architectures` 출력을 붙여 주세요.
✘ 가 있으면 먼저 디스코드에서 `/doctor` 에 같은 출력을 붙여 해결책을 확인해요(본인에게만 보여요).

```
(여기에 붙여넣기)
```

## 막혔던 점 (선택)

가이드 v0.2 의 「자주 막히는 점」에 반영할게요. 증상 · 원인(아는 만큼) · 해결 순서로 적어 주세요.
