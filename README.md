# 에이전트 아키텍처 랩 3-Day 온보딩 — Codex·GitHub 실습환경 세팅

2026-10-02 · v0.2 초안 (디스코드 봇 `/doctor` 안내 추가 · 10/3 팀 오리엔테이션 검증 결과는 OT 후 반영) · 문의: 리더 Pio ([디스코드 서버](https://discord.gg/WF8cTKNUy))

크루원은 1주차(10/8) 전까지 **Codex CLI · GitHub · 교재 실습 환경**을 세팅하고, Codex로 교재 노트북을 읽고 실행하고, 첫 PR을 올릴 수 있게 됩니다. 이 문서는 잇츠(IT's) 스터디 5기 「에이전트 아키텍처 랩」 크루원용 온보딩 가이드예요.

**필요한 것**

- GitHub 계정 (개인 계정이면 돼요)
- ChatGPT 계정 — Plus 이상 플랜이면 Codex에 바로 로그인돼요. 플랜이 없으면 OpenAI API 키로도 쓸 수 있어요(크레딧은 리더 공지)
- 디스코드 — [디스코드 서버](https://discord.gg/WF8cTKNUy)에 먼저 들어와 주세요 (정규 세션 100% 온라인)
- macOS 12+ 또는 Windows 11 + **WSL2(Ubuntu)** — Codex 공식 지원 범위예요. Linux도 돼요
- 터미널이 처음이면 → [터미널이 낯선 크루 트랙](#터미널이-낯선-크루-트랙--화이트글러브-15분)

**OT 전에 [디스코드 서버](https://discord.gg/WF8cTKNUy)에 들어와서 리더에게 DM으로 한 번에 보낼 것** (초대·발급에 시간이 걸려요)

1. **GitHub ID** — `agent-architecture-lab` 조직 초대용. 없으면 비공개 레포 접근과 브랜치 push가 막혀요
2. **LLM 사용 경로** — ChatGPT 유료 플랜 유무 / API 키 필요 여부 (크레딧 안내 기준)
3. **OS** — macOS / Windows — OT 때 트랙 배정용

> 크루원이 매주 작업할 **실습 레포 주소는 10/3 OT에서 공지**해요. 이 가이드의 실습은 공개 교재 레포와 이 레포만으로 끝낼 수 있게 짜여 있어요.

## 3일 세팅 순서

Day 1은 도구, Day 2는 연결(10/3 OT 현장), Day 3은 Codex로 실제로 써 보고 체크리스트를 통과하는 날이에요.

| Day | 할 일 | 끝났다는 기준 |
| --- | --- | --- |
| **Day 1** 계정·도구 (~10/3 OT 전) | 디스코드 참여 → GitHub 가입·ID 전송 → (Windows) WSL2 → git·gh·uv·codex 설치 → PATH 점검 → git 작성자 설정 | 새 터미널에서 `which git gh uv codex` 가 4줄 모두 경로를 출력 |
| **Day 2** 연결 (10/3 팀 OT) | 조직 초대 수락 → `gh auth login` → Codex 로그인·권한 설정 → 교재 clone·`uv` 환경·`.env` → Context7 MCP → 점검 스크립트 (✘ 가 있으면 디스코드 `/doctor`) | `aal-doctor.sh` 필수 항목 모두 ✔, `codex doctor` 에 ✗ 없음 |
| **Day 3** 활용 (10/4~10/7) | 예시 프롬프트로 시험 → 자기소개 PR → 체크리스트 이슈 close | 아래 [검증 체크리스트](#검증-체크리스트) 전 항목 통과 |

## Day 1 — 계정·도구

터미널이 `git`·`gh`·`uv`·`codex` 를 찾을 수 있는 상태까지 만드는 날이에요.

1. [디스코드 서버](https://discord.gg/WF8cTKNUy) 참여 → [github.com](https://github.com) 가입(이미 있으면 생략) → 2단계 인증(2FA) 켜기 → 리더에게 GitHub ID 보내기
2. **(Windows만) WSL2 설치** — PowerShell을 *관리자 권한*으로 열고 `wsl --install` → 재부팅 → Ubuntu 사용자 이름·비밀번호 만들기. **이후 모든 명령은 Ubuntu 터미널에서** 실행하고, 작업 폴더는 `~/`(리눅스 홈) 아래에 둬요. `/mnt/c/...` 에서 작업하면 느리고 권한 문제가 생겨요.
3. 터미널에서 기본 도구 설치

macOS:

```bash
# Homebrew (없으면)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# git · GitHub CLI · uv(파이썬 환경) · Codex CLI
brew install git gh uv
brew install --cask codex
```

Windows(WSL2 Ubuntu) · Linux:

```bash
sudo apt update && sudo apt install -y git curl

# GitHub CLI — 공식 apt 저장소 (https://github.com/cli/cli/blob/trunk/docs/install_linux.md)
(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
  && sudo mkdir -p -m 755 /etc/apt/keyrings \
  && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
  && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && sudo mkdir -p -m 755 /etc/apt/sources.list.d \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh -y

# uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Codex CLI
curl -fsSL https://chatgpt.com/codex/install.sh | sh
```

4. **PATH 점검 (가장 많이 막히는 곳)** — `uv`·`codex` 는 `~/.local/bin` 에 설치되는 경우가 많아요. 이 경로가 PATH에 없으면 `command not found` 가 나요.

macOS (zsh):

```bash
grep -q 'brew shellenv' ~/.zprofile 2>/dev/null || echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile   # Intel 맥은 /usr/local/bin/brew
grep -q '.local/bin' ~/.zshrc 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
exec zsh -l
which git gh uv codex   # 4줄 모두 경로가 나오면 성공
```

WSL2 · Linux (bash):

```bash
grep -q '.local/bin' ~/.bashrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
exec bash -l
which git gh uv codex   # 4줄 모두 경로가 나오면 성공
```

5. **git 작성자 설정** — 이 레포는 공개(public)라 커밋 메일이 그대로 보여요. GitHub이 주는 noreply 메일을 권장해요([Settings → Emails](https://github.com/settings/emails)에서 확인).

```bash
git config --global user.name  "<GitHub ID>"
git config --global user.email "<숫자>+<GitHub ID>@users.noreply.github.com"   # GitHub 계정에 연결된 메일이어야 커밋이 내 프로필에 연결돼요
```

6. 위의 "리더에게 보낼 것" 3가지를 오늘 보내기

## Day 2 — 연결

10/3 팀 OT에서 함께 진행해요. 순서가 중요해요: **조직 초대 수락 → `gh auth login` → Codex 로그인 → 교재 환경 → 점검.**

### GitHub

1. 메일 또는 [조직 초대 페이지](https://github.com/orgs/agent-architecture-lab/invitation)에서 `agent-architecture-lab` 초대 **수락**
2. GitHub CLI 로그인 — `GitHub.com` → `HTTPS` → `Login with a web browser` 를 고르면 돼요. HTTPS 방식이라 SSH 키는 없어도 돼요.

```bash
gh auth login
gh auth setup-git     # git push 할 때 gh 로그인 정보를 쓰게 해요
gh auth status        # Logged in to github.com account <ID> 가 보이면 성공
```

### Codex

1. 로그인 — 터미널에서 `codex` 실행 → **Sign in with ChatGPT** 선택 → 브라우저에서 로그인

```bash
codex                                            # ChatGPT 플랜으로 로그인 (권장)
printenv OPENAI_API_KEY | codex login --with-api-key   # API 키로 로그인할 때
codex login --device-auth                        # WSL 등에서 브라우저가 안 열릴 때 (코드 입력 방식)
codex login status                               # 로그인 상태 확인
```

2. **권한 기본값 설정 — "읽기는 자유, 쓰기는 승인"**. `~/.codex/config.toml` 에 아래 두 줄을 넣어요. 작업 폴더 안에서는 Codex가 읽고 고치지만, 그 밖으로 나가는 일(작업 폴더 밖 쓰기, 네트워크가 필요한 명령 등)은 매번 승인을 요청해요.

```toml
approval_policy = "on-request"
sandbox_mode    = "workspace-write"
```

> `--dangerously-bypass-approvals-and-sandbox` 와 `sandbox_mode = "danger-full-access"` 는 이 랩에서 쓰지 않아요.

### 커넥터 (MCP)

| MCP | 용도 | 우선순위 | 설치 |
| --- | --- | --- | --- |
| Context7 | LangGraph·LangChain·OpenAI SDK 최신 문서 조회 | 권장 | `codex mcp add context7 --url https://mcp.context7.com/mcp` |
| GitHub | 이슈·PR 작업 | 불필요 | Codex가 `gh` CLI를 직접 써요 |

`codex mcp list` 로 상태를 볼 수 있어요. Context7은 API 키 없이도 동작하고, [무료 키](https://context7.com)를 받으면 `CONTEXT7_API_KEY` 환경변수에 넣고 `--bearer-token-env-var CONTEXT7_API_KEY` 를 붙여 다시 추가하면 한도가 넉넉해져요.

### 교재 실습 환경

교재는 [`all-agentic-architectures`](https://github.com/FareedKhan-dev/all-agentic-architectures)예요 — LangGraph로 구현한 35개 아키텍처 + 실행 결과가 담긴 노트북. 우리 랩의 핵심 원칙인 **deterministic-picker**("LLM은 범주형 판단만, 최종 결정은 코드가")도 이 교재에서 왔어요.

```bash
mkdir -p ~/aal && cd ~/aal
gh repo clone FareedKhan-dev/all-agentic-architectures
gh repo clone agent-architecture-lab/aal-onboarding     # 이 가이드 + 점검 스크립트 + Day 3 자기소개 PR

cd ~/aal/all-agentic-architectures
uv venv --python 3.12
source .venv/bin/activate
uv pip install -e ".[dev,test,openai,faiss,tavily,networkx]"
cp .env.example .env
```

> 교재 폴더에서는 `uv run` 대신 **`source .venv/bin/activate` 로 환경을 켠 뒤** `python`·`jupyter`·`pytest` 를 써요. `uv run` 은 교재 레포에 `uv.lock` 을 새로 만들고 환경을 다시 맞추려 해요. 새 터미널을 열 때마다 `source .venv/bin/activate` 를 다시 해요.

`.env` 를 열어 아래 값만 바꿔요. **`.env` 는 절대 커밋하지 않아요**(교재 레포의 `.gitignore` 에 이미 들어 있어요).

```dotenv
LLM_PROVIDER=openai
# 리더 공지가 있으면 그 모델로
LLM_MODEL=gpt-4o-mini
# Codex용 ChatGPT 로그인과 별개로, 노트북 실행에는 API 키가 필요해요
OPENAI_API_KEY=sk-...
# (선택) 웹 검색용 — Tool Use·ReAct·Planning·Meta-Controller 가 써요(7주차 전까지 권장). 무료 1,000회/월
TAVILY_API_KEY=
# (선택) 실행 추적. 키가 없으면 아래를 false 로
LANGSMITH_API_KEY=
LANGCHAIN_TRACING_V2=false
```

같은 키가 파일 안에 두 번 있으면 아래쪽 값이 쓰여요. `.env.example` 에 있던 줄을 직접 고치는 게 가장 안전해요.

> API 키가 없어도 시작할 수 있어요. 교재 노트북에는 실행 결과가 이미 들어 있어서 **읽기만으로 학습**이 되고, 로컬 모델([Ollama](https://ollama.com), `LLM_PROVIDER=ollama`)로 비용 없이 실행할 수도 있어요(느려요).

### 점검

```bash
bash ~/aal/aal-onboarding/scripts/aal-doctor.sh ~/aal/all-agentic-architectures
codex doctor
```

`aal-doctor.sh` 는 **읽기만** 해요(설치·수정 없음, 키 값은 출력하지 않고 있는지만 봐요). 필수 항목이 모두 ✔ 면 결과를 Day 3 체크리스트 이슈에 붙여 주세요. `codex doctor` 는 ✗ 가 없으면 돼요(⚠ 는 괜찮아요).

**✘ 가 있으면 디스코드에서 `/doctor`** — [디스코드 서버](https://discord.gg/WF8cTKNUy)의 아무 채널에서 `/doctor` 를 입력하면 입력창이 떠요. `aal-doctor.sh` 출력 **전체**를 붙여 넣으면 ✘·– 항목마다 해결책을 짝지어 알려줘요.

- 답변은 **본인에게만** 보여요. 채널에 출력을 그대로 올릴 필요가 없어요.
- 출력에는 키 값이 없어요. 실수로 API 키·토큰을 함께 붙이면 봇이 알아채고 폐기를 안내해요 — 그 키는 바로 폐기(revoke)해 주세요.
- 고친 뒤 `aal-doctor.sh` 를 다시 돌려 모두 ✔ 인지 확인해요.
- 봇이 응답하지 않으면 아래 [자주 막히는 점](#자주-막히는-점) 표에 같은 해결책이 있어요. 그래도 안 되면 봇을 멘션해 질문 스레드를 열어요.

## Day 3 — 활용

아래 프롬프트를 그대로 말해 보고, 체크리스트를 모두 통과하면 온보딩 완료예요.

### 써 보기

교재 폴더에서 `codex` 를 실행한 뒤 말해 보세요 (`cd ~/aal/all-agentic-architectures && codex`).

| 해 볼 것 | 이렇게 말해보세요 |
| --- | --- |
| 레포 파악 | "README 기준으로 이 레포 구조와 deterministic-picker 패턴이 뭔지 설명해줘" |
| 코드 읽기 | "`src/agentic_architectures/architectures/reflection.py` 에서 생성→비평→수정 루프가 어떻게 도는지 그림으로 설명해줘" |
| 노트북 | "`notebooks/01_reflection.ipynb` 의 실행 결과를 요약하고, 내가 직접 다시 실행하려면 뭘 해야 하는지 알려줘" |
| 1주차 예습 | "Reflection 패턴을 커뮤니티 지원서 스크리닝에 쓴다면, LLM이 범주형으로만 판단해야 할 항목과 코드가 결정해야 할 항목을 나눠줘" |
| 문서 조회 | "context7 로 LangGraph StateGraph 최신 사용법 찾아서 reflection.py 와 비교해줘" |
| 첫 PR | (`cd ~/aal/aal-onboarding && codex`) "`crew/_template.md` 를 복사해 `crew/<내 GitHub ID>.md` 를 채우고, 브랜치를 만들어 PR 올려줘" — push·PR 직전에 **승인 요청이 뜨는지** 확인해요 |

노트북을 직접 실행할 때는 교재 폴더에서 `source .venv/bin/activate && jupyter lab`. API 호출 비용이 드니 한 번에 하나씩 돌려요.

### 검증 체크리스트

[온보딩 체크리스트 이슈](https://github.com/agent-architecture-lab/aal-onboarding/issues/new?template=onboarding-checklist.md)를 하나 열어서 체크하며 진행해요.

- [ ] 터미널 새 창에서 `which git gh uv codex` 가 4줄 모두 경로를 출력해요
- [ ] `gh auth status` 로그인 + `agent-architecture-lab` 조직 멤버예요 (`aal-doctor.sh` 의 조직 접근 항목 ✔)
- [ ] `codex login status` 가 로그인 상태이고, `codex doctor` 에 ✗ 가 없어요
- [ ] 교재 폴더에서 `.venv/bin/python -c "import agentic_architectures"` 가 에러 없이 끝나고, `git status` 에 `.env` 가 보이지 않아요
- [ ] Codex가 push·PR 같은 쓰기 작업 전에 승인을 요청해요 (승인 거절해도 돼요)
- [ ] 자기소개 PR(`crew/<GitHub ID>.md`)이 리뷰를 거쳐 머지됐어요
- [ ] `aal-doctor.sh` 필수 항목이 모두 ✔ 이고, 결과를 체크리스트 이슈에 붙였어요

## 8주 운영 — 일정·작업 방식·자료

### 일정

정규 모임은 **매주 목요일 19:30–21:30, [디스코드 서버](https://discord.gg/WF8cTKNUy)**(100% 온라인)예요.

| 구분 | 날짜 | 모듈 | 패턴 |
| --- | --- | --- | --- |
| 잇츠 스터디 오리엔테이션 | 10/2(금) | — | — |
| 팀 오리엔테이션 | 10/3(토) | Chapter 0 — 환경설정 (이 문서) | — |
| 1주차 | 10/8(목) | 스크리닝·매칭 에이전트 (착수) | Reflection |
| 2주차 | 10/15(목) | 스크리닝·매칭 에이전트 (완료) | Reflection |
| 3주차 | 10/22(목) | FAQ 에이전트 (착수) | RAG |
| 4주차 | 10/29(목) | FAQ 에이전트 (완료) | RAG |
| 5주차 | 11/5(목) | 회고 피드백 에이전트 (착수) | Multi-Agent |
| 6주차 | 11/12(목) | 회고 피드백 에이전트 (완료) | Multi-Agent |
| 7주차 | 11/19(목) | 오케스트레이터 통합 설계 | 3패턴 통합 |
| 8주차 | 11/26(목) | 오케스트레이터 통합 완료 + 리허설 | 3패턴 통합 |
| 성과공유회 | 12/16(수) | 최종 발표 | — |

**완주 기준**: 8회 중 6회 이상 출석 + 담당 트랙 1개 이상 배포.
**팀 목표**: 아키텍처 구현 18개(6명×3개), 커밋 150개 이상, End-to-End 성공률 80% 이상.

### 작업 방식

- 모든 과제·진행 상황은 **GitHub Issues + Projects 보드**로 관리해요. Notion은 쓰지 않아요.
- 변경은 항상 **브랜치 → PR → 리뷰 → 머지**. `main` 에 직접 push하지 않아요.
- 질문·막힘은 디스코드에서 **봇을 멘션해 질문 스레드**로 남기고, 재현 가능한 문제는 이 레포에 이슈로 올려요. 이 가이드의 오류를 발견하면 바로 PR 주세요.

### 랩 디스코드 봇

| 명령 | 하는 일 | 보이는 범위 |
| --- | --- | --- |
| `/doctor` | `aal-doctor.sh` 출력을 붙이면 ✘·– 항목마다 해결책을 짝지어요 | 본인만 |
| `/onboarding` | 크루별 [온보딩 체크리스트 이슈](https://github.com/agent-architecture-lab/aal-onboarding/issues) 진척 | 채널 |
| `/schedule` | 다음 정규 모임·모듈·예습 노트북 | 채널 |
| `@봇 질문 내용` | 그 메시지로 질문 스레드를 열어요 | 채널 |
| `/help` | 명령어 안내 | 본인만 |

정규 모임 날 18:30에는 공지 채널에 리마인더가 올라와요. 봇은 LLM 없이 규칙으로만 답하고(1주차 기준), 지정 채널과 자기가 연 스레드에만 글을 써요. GitHub은 읽기만 해요. 3주차부터는 크루가 만든 에이전트가 이 봇에 하나씩 붙어요.

### 주차별 예습 자료 (v0.1 제안)

| 주차 | 모듈 | 필수 | 심화 |
| --- | --- | --- | --- |
| 1–2주차 | 스크리닝·매칭 | `01_reflection` | `18_reflexion` · `20_chain_of_verification` |
| 3–4주차 | FAQ | `23_agentic_rag` | `24_corrective_rag` · `25_self_rag` · `26_adaptive_rag` |
| 5–6주차 | 회고 피드백 | `05_multi_agent` | `07_blackboard` · `28_debate` |
| 7–8주차 | 오케스트레이터 | `11_meta_controller` | 앞 3패턴 복습 |

노트북은 모두 교재 레포의 `notebooks/` 에 있어요.

### 레퍼런스 지도

| 영역 | 자료 |
| --- | --- |
| 교재 | [`all-agentic-architectures`](https://github.com/FareedKhan-dev/all-agentic-architectures) — 35개 아키텍처, 이 중 Reflection·RAG·Multi-Agent 3패턴을 실전 모듈에 적용 |
| 목표 수준 | [가짜연구소 `Agent_is_all_you_need`](https://github.com/Pseudo-Lab/Agent_is_all_you_need) 동급 이상 |
| 핸즈온 포맷 | [`ccw-hands-on-lab`](https://whchoi98.github.io/ccw-hands-on-lab/) |
| 도구 문서 | [Codex](https://developers.openai.com/codex) · [LangGraph](https://langchain-ai.github.io/langgraph/) · [uv](https://docs.astral.sh/uv/) · [GitHub CLI](https://cli.github.com/manual/) |

## 권한·보안 원칙

**읽기는 자유, 쓰기는 승인.** Codex가 파일·노트북을 읽는 건 바로 하게 두고, 바꾸는 작업(push, PR 생성·코멘트, 작업 폴더 밖 수정)은 매번 본인이 확인해요.

- Codex 권한은 `approval_policy = "on-request"` + `sandbox_mode = "workspace-write"` 로 둬요. 승인 없이 모든 걸 실행하는 옵션은 쓰지 않아요.
- 남의 브랜치·PR에 push하지 않아요. Codex에게 PR을 맡길 때도 대상 브랜치와 레포를 확인한 뒤 승인해요.
- API 키·토큰은 `.env` 에만 두고 커밋·디스코드·채팅·프롬프트에 붙이지 않아요. 커밋 전 `git status` 로 `.env` 가 없는지 봐요. **실수로 올렸다면 히스토리 삭제보다 키 폐기(revoke)가 먼저**이고, 바로 리더에게 알려요.
- 시크릿이 담긴 셸에서 `set -x` 를 쓰지 않아요.
- 실습 데이터는 **합성(가짜) 데이터만** 써요. 실제 지원서·실명·연락처·디스코드 대화 원문은 레포와 프롬프트에 넣지 않아요 — 이 레포는 공개예요.
- 에이전트 설계는 **deterministic-picker**를 따라요: LLM은 범주형 판단(예/아니오, 등급, 카테고리)만, 최종 결정(점수 합산·선발·라우팅)은 코드가 해요.
- 회사 계정·사내 코드·업무 데이터는 실습에 쓰지 않아요. 개인 도구 설정과 일반화된 교훈만 가져와요.

## 터미널이 낯선 크루 트랙 — 화이트글러브 (15분)

터미널이 낯선 분은 OT에서 리더와 함께 진행해요. 본인이 누르는 건 \[로그인\]·\[연결\]·\[Commit\]뿐이에요.

1. [디스코드 서버](https://discord.gg/WF8cTKNUy) 참여 → GitHub 가입 → 리더에게 ID 전송 → 조직 초대 수락 (전부 브라우저)
2. **자기소개 PR을 브라우저로** — 이 레포의 `crew/` 폴더 → \[Add file\] → \[Create new file\] → `crew/<GitHub ID>.md` 에 [템플릿](crew/_template.md) 내용 붙여넣고 채우기 → \[Commit changes\] → "Create a new branch… and start a pull request" 선택
3. 교재 노트북은 GitHub에서 바로 열어 읽어요 — 실행 결과가 이미 들어 있어요
4. ChatGPT 유료 플랜이 있으면 [Codex 웹](https://chatgpt.com/codex)에 GitHub을 연결해 브라우저에서 Codex를 써 볼 수 있어요
5. 로컬 설치(Day 1~2)는 OT 이후 리더와 화면 공유로 페어 진행 — 막히면 디스코드에서 봇을 멘션해 질문 스레드를 열고, 막힌 화면 캡처를 거기에 올려 주세요

## 개발자·데이터 트랙

공통 세팅에 더해 아래를 맞추면 좋아요.

### 교재 개발 도구

```bash
cd ~/aal/all-agentic-architectures
source .venv/bin/activate
pre-commit install      # 커밋 전 ruff lint·format 자동 실행 (교재 설정 그대로)
pytest -q               # 오프라인 단위 테스트 — LLM 호출 없음 (실제 호출 테스트는 RUN_INTEGRATION=1 일 때만)
jupyter lab             # 노트북
```

### 추천 도구

| 도구 | 용도 | 설치 |
| --- | --- | --- |
| Docker | Neo4j·Qdrant가 필요한 노트북(`12_graph_memory`, `27_graph_rag` 등) — 교재 `docker/` 의 compose 사용 | [Docker Desktop](https://www.docker.com/products/docker-desktop/) (WSL2 연동 켜기) |
| Claude Code (선택) | Codex와 병행해 써 보고 싶을 때 | `curl -fsSL https://claude.ai/install.sh \| bash` — 레포 규칙은 `AGENTS.md` 하나로 관리하고, `CLAUDE.md` 에는 `@AGENTS.md` 한 줄만 둬요 |

### 반복 업무 자동화 (선택)

`codex exec "..."` 로 Codex를 비대화형으로 돌릴 수 있어요. 예: 매주 목요일 세션 전 "이번 주 내 PR·이슈 요약" 을 만들어 디스코드에 붙이기. 읽기 위주로만 설계하고, 쓰기 작업은 자동화하지 않아요.

## 자주 막히는 점

> 아직 예상 목록이에요. 10/3 OT에서 실제로 겪은 증상으로 교체·보강해요. 디스코드 `/doctor` 에 `aal-doctor.sh` 결과를 붙이면 이 표의 해결책을 항목별로 짝지어 줘요. 그래도 안 되면 봇을 멘션해 질문 스레드를 열어 주세요.

| 증상 | 원인 | 해결 |
| --- | --- | --- |
| `command not found: codex` / `uv` | `~/.local/bin` 이 PATH에 없음 | Day 1의 PATH 점검 실행 후 새 터미널 |
| `zsh: command not found: brew` (맥) | `.zprofile` 에 `brew shellenv` 없음 | Day 1의 PATH 점검 첫 줄 |
| WSL에서 로그인 브라우저가 안 열림 | WSL에서 Windows 브라우저 호출 실패 | `codex login --device-auth` / `gh auth login` 은 화면의 코드를 브라우저에 직접 입력 |
| `gh repo clone agent-architecture-lab/...` 가 `not found` | 조직 초대 미수락이거나 다른 계정으로 로그인 | 초대 수락 → `gh auth status` 로 계정 확인 |
| `git push` 가 `403` / `Permission denied` | `gh auth setup-git` 을 안 했거나, 그 레포에 쓰기 권한이 없음 | `gh auth setup-git` 후 재시도. 그래도 막히면 `gh repo fork --remote` 로 내 fork에 push → `gh pr create` |
| 교재 폴더에 `uv.lock` 이 새로 생김 | 교재 폴더에서 `uv run` 을 씀 | `rm uv.lock` 후 `source .venv/bin/activate` 로 실행 |
| `pytest` 에서 Planning·ReAct·ToolUse·MetaController 12개 실패 (`tavily_api_key`) | `TAVILY_API_KEY` 가 비어 있음 | 무료 키를 `.env` 에 넣거나, 테스트만 돌릴 땐 `TAVILY_API_KEY=dummy pytest -q` |
| `uv pip install` 중 패키지 빌드 실패 | 너무 새 파이썬 버전에 맞는 wheel이 없음 | `rm -rf .venv && uv venv --python 3.12` 후 재설치 |
| 노트북 실행 시 `AuthenticationError` / 401 | `.env` 키가 비었거나 `LLM_PROVIDER` 와 키가 안 맞음 | `LLM_PROVIDER=openai` + `OPENAI_API_KEY` 확인 |
| LangSmith 관련 경고·에러 | 키 없이 `LANGCHAIN_TRACING_V2=true` | `LANGCHAIN_TRACING_V2=false` |
| `codex login status` 가 `Not logged in` | 로그인 만료 | `codex` 다시 실행해 로그인 |
| WSL에서 모든 게 느림 | `/mnt/c/...` 아래에서 작업 | `~/aal` 로 옮겨서 작업 |

## 부록

### A. 점검 스크립트 (`scripts/aal-doctor.sh`)

Day 2 상태를 한 번에 확인해요. 여러 번 실행해도 안전하고, **아무것도 설치·수정하지 않아요.** 키는 값이 아니라 "채워져 있는지"만 봐요.

```bash
bash ~/aal/aal-onboarding/scripts/aal-doctor.sh                                  # 도구·로그인·조직 접근
bash ~/aal/aal-onboarding/scripts/aal-doctor.sh ~/aal/all-agentic-architectures  # + 교재 환경·.env
```

점검 항목: CLI 4종(git·gh·uv·codex) 경로, git 작성자, `gh` 로그인과 `agent-architecture-lab` 조직 접근, Codex 로그인·권한 기본값, (경로를 주면) 교재 `.venv`·패키지 import·`.env` 필수 키·`.env` 의 git 제외 여부.

결과에 ✘ 가 있으면 디스코드 `/doctor` 에 출력 전체를 붙여 해결책을 받아요(본인에게만 보여요).

### B. Codex 설정 예시 (`~/.codex/config.toml`)

```toml
approval_policy = "on-request"
sandbox_mode    = "workspace-write"

[mcp_servers.context7]
url = "https://mcp.context7.com/mcp"
```

### C. 다음 버전에서 추가할 것

- **`aal-skills` 플러그인** — 랩 공용 Codex 스킬·플러그인 마켓플레이스(`codex plugin marketplace add agent-architecture-lab/aal-skills`). 설정·점검을 스킬로 대신해 주는 `aal-setup`·`aal-doctor` 를 준비 중이에요.
- 실습 레포 주소와 `AGENTS.md` 규칙 요약
- GitHub Pages 배포

### 변경 이력

| 날짜 | 내용 |
| --- | --- |
| 2026-10-02 | v0.2 초안 — 디스코드 봇([aal-bot](https://github.com/agent-architecture-lab/aal-bot), 조직 멤버만 열람) 안내 추가: Day 2 점검·자주 막히는 점·화이트글러브 트랙에 `/doctor`·질문 스레드 흐름, 「랩 디스코드 봇」 명령표. 「자주 막히는 점」 실측 반영은 10/3 OT 후 |
| 2026-10-02 | v0.1 초판 — 3-Day 온보딩 구조를 랩(Codex·GitHub·교재)에 맞게 작성. Codex CLI 0.160 기준 명령 확인, Linux(Ubuntu 24.04)에서 교재 설치·테스트(283 passed)·`aal-doctor.sh` 사전 실행. macOS·WSL2는 10/3 팀 OT 현장 검증 예정 |
