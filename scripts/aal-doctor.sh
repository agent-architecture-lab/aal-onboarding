#!/usr/bin/env bash
# aal-doctor — 에이전트 아키텍처 랩 온보딩 Day 2 상태 점검 (읽기 전용)
#
#   bash aal-doctor.sh                 # 도구·로그인·조직 접근
#   bash aal-doctor.sh <교재 레포 경로>  # + 교재 .venv·패키지·.env
#
# 아무것도 설치·수정하지 않아요. 키·토큰·메일 값은 출력하지 않고 "채워져 있는지"만 봐요.
# 출력은 공개 이슈에 붙여도 되도록 홈 경로를 ~ 로 바꿔 보여줘요.
# macOS 기본 bash(3.2)에서도 돌아가도록 bash 4 전용 문법은 쓰지 않아요.
set -u

ORG="agent-architecture-lab"
LAB_DIR="${1:-}"
CODEX_CONFIG="${CODEX_HOME:-$HOME/.codex}/config.toml"

FAILS=0
WARNS=0
ok()   { echo "  ✔ $*"; }
ng()   { echo "  ✘ $*"; FAILS=$((FAILS + 1)); }
warn() { echo "  – $*"; WARNS=$((WARNS + 1)); }
tilde() { local t="~"; echo "${1/#"$HOME"/$t}"; }   # bash 5.2 는 치환 문자열의 ~ 를 다시 펼쳐서 변수로 넘겨요

# .env 에서 KEY 의 값을 읽어요 (마지막 줄 우선, 따옴표·인라인 주석·공백 제거). 값은 출력하지 않아요.
env_value() {
  local file="$1" key="$2" line val
  line=$(grep -E "^[[:space:]]*(export[[:space:]]+)?${key}[[:space:]]*=" "$file" 2>/dev/null | tail -n 1)
  [ -z "$line" ] && return 0
  val="${line#*=}"
  val="${val%%[[:space:]]#*}"
  val="${val#"${val%%[![:space:]]*}"}"
  val="${val%"${val##*[![:space:]]}"}"
  val="${val#\"}"; val="${val%\"}"
  val="${val#\'}"; val="${val%\'}"
  printf '%s' "$val"
}

echo "== aal-doctor · $(date '+%Y-%m-%d %H:%M') · $(uname -s) $(uname -m)"

echo "== 1. CLI"
for c in git gh uv codex; do
  if p=$(command -v "$c" 2>/dev/null); then ok "$c → $(tilde "$p")"; else ng "$c 없음 — README Day 1 설치·PATH 점검"; fi
done
command -v python3 >/dev/null 2>&1 && ok "python3 $(python3 -c 'import platform; print(platform.python_version())' 2>/dev/null)" || warn "python3 없음 (uv 가 대신 받아요)"

echo "== 2. git 작성자"
name=$(git config --global user.name 2>/dev/null || true)
email=$(git config --global user.email 2>/dev/null || true)
[ -n "$name" ] && ok "user.name = $name" || ng "user.name 미설정 — git config --global user.name \"<GitHub ID>\""
if [ -z "$email" ]; then
  ng "user.email 미설정"
else
  case "$email" in
    *@users.noreply.github.com) ok "user.email 설정됨 (GitHub noreply)" ;;
    *) warn "user.email 설정됨 (noreply 아님 — 공개 레포 커밋에 메일이 보여요)" ;;
  esac
fi

echo "== 3. GitHub"
if ! command -v gh >/dev/null 2>&1; then
  ng "gh 없음 — 건너뜀"
elif ! gh auth status >/dev/null 2>&1; then
  ng "gh 로그인 안 됨 — gh auth login && gh auth setup-git"
else
  login=$(gh api user --jq .login 2>/dev/null || true)
  ok "gh 로그인 (${login:-계정 확인 실패})"
  state=$(gh api "user/memberships/orgs/$ORG" --jq .state 2>/dev/null || true)
  case "$state" in
    active)  ok "$ORG 조직 멤버" ;;
    pending) ng "$ORG 초대 수락 전 — https://github.com/orgs/$ORG/invitation" ;;
    *)       ng "$ORG 조직 멤버 아님 — 리더에게 GitHub ID 를 보냈는지, 맞는 계정으로 로그인했는지 확인" ;;
  esac
  if git config --global --get-regexp '^credential\..*helper' 2>/dev/null | grep -q 'gh'; then
    ok "git 이 gh 로그인 정보를 사용 (gh auth setup-git)"
  else
    warn "gh auth setup-git 미실행 — HTTPS push 때 비밀번호를 물을 수 있어요"
  fi
fi

echo "== 4. Codex"
if ! command -v codex >/dev/null 2>&1; then
  ng "codex 없음 — 건너뜀"
else
  ok "$(codex --version 2>/dev/null | head -n 1)"
  if codex login status >/dev/null 2>&1; then ok "codex 로그인"; else ng "codex 로그인 안 됨 — codex 실행 후 Sign in with ChatGPT"; fi
  if [ -f "$CODEX_CONFIG" ]; then
    if grep -Eq '^[[:space:]]*sandbox_mode[[:space:]]*=[[:space:]]*"danger-full-access"' "$CODEX_CONFIG"; then
      ng "sandbox_mode = danger-full-access — 랩 기본값 workspace-write 로 바꿔 주세요"
    elif grep -Eq '^[[:space:]]*sandbox_mode[[:space:]]*=' "$CODEX_CONFIG" && grep -Eq '^[[:space:]]*approval_policy[[:space:]]*=[[:space:]]*"on-request"' "$CODEX_CONFIG"; then
      ok "권한 기본값 (approval_policy·sandbox_mode) 설정됨"
    else
      warn "권한 기본값 미설정 — README Day 2 「Codex」 2번"
    fi
    grep -Eq '^\[mcp_servers\.context7\]' "$CODEX_CONFIG" && ok "Context7 MCP 등록" || warn "Context7 MCP 미등록 (권장)"
  else
    warn "$(tilde "$CODEX_CONFIG") 없음 — 권한 기본값 미설정"
  fi
fi

if [ -n "$LAB_DIR" ]; then
  echo "== 5. 교재 환경 ($(tilde "$LAB_DIR"))"
  if [ ! -d "$LAB_DIR" ]; then
    ng "폴더 없음"
  else
    py="$LAB_DIR/.venv/bin/python"
    if [ -x "$py" ]; then
      ok ".venv (Python $("$py" -c 'import platform; print(platform.python_version())' 2>/dev/null))"
      if "$py" -c 'import agentic_architectures' >/dev/null 2>&1; then ok "agentic_architectures import"; else ng "agentic_architectures import 실패 — uv pip install -e \".[dev,test,openai,faiss,tavily,networkx]\""; fi
    else
      ng ".venv 없음 — uv venv --python 3.12"
    fi

    envf="$LAB_DIR/.env"
    if [ ! -f "$envf" ]; then
      ng ".env 없음 — cp .env.example .env"
    else
      provider=$(env_value "$envf" LLM_PROVIDER)
      case "$provider" in
        openai)    keyvar=OPENAI_API_KEY ;;
        anthropic) keyvar=ANTHROPIC_API_KEY ;;
        nebius)    keyvar=NEBIUS_API_KEY ;;
        groq)      keyvar=GROQ_API_KEY ;;
        together)  keyvar=TOGETHER_API_KEY ;;
        fireworks) keyvar=FIREWORKS_API_KEY ;;
        mistralai) keyvar=MISTRAL_API_KEY ;;
        google)    keyvar=GOOGLE_API_KEY ;;
        ollama)    keyvar="" ;;
        *)         keyvar="?" ;;
      esac
      if [ "$keyvar" = "?" ]; then
        ng "LLM_PROVIDER 값 확인 필요 (${provider:-비어 있음})"
      elif [ -z "$keyvar" ]; then
        ok "LLM_PROVIDER = ollama (키 불필요)"
      elif [ -n "$(env_value "$envf" "$keyvar")" ]; then
        ok "LLM_PROVIDER = $provider, $keyvar 채워짐"
      else
        warn "LLM_PROVIDER = $provider, $keyvar 비어 있음 — 노트북 읽기는 되지만 실행은 안 돼요"
      fi
      tracing=$(env_value "$envf" LANGCHAIN_TRACING_V2)
      if [ "$tracing" = "true" ] && [ -z "$(env_value "$envf" LANGSMITH_API_KEY)" ]; then
        warn "LANGCHAIN_TRACING_V2=true 인데 LANGSMITH_API_KEY 비어 있음 — false 권장"
      fi
      if git -C "$LAB_DIR" ls-files --error-unmatch .env >/dev/null 2>&1; then
        ng ".env 가 git 에 추적되고 있어요 — 커밋 금지, 리더에게 알리고 키 폐기"
      elif git -C "$LAB_DIR" check-ignore -q .env 2>/dev/null; then
        ok ".env 는 git 에서 제외됨"
      else
        ng ".env 가 .gitignore 에 없음 — 커밋되지 않게 추가"
      fi
    fi
  fi
fi

echo "== 결과: 필수 실패 $FAILS · 권장 $WARNS"
if [ "$FAILS" -eq 0 ]; then
  echo "필수 항목 통과. 이 출력을 온보딩 체크리스트 이슈에 붙여 주세요."
else
  echo "✘ 항목을 README 「자주 막히는 점」에서 찾아보고, 안 되면 이 출력을 디스코드에 올려 주세요."
fi
[ "$FAILS" -eq 0 ]
