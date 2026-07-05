#!/usr/bin/env bash
# doctor.sh — MultiAgent 프리플라이트. 워커에 의존하기 전에 도구/인증 가용성을 한 번에 점검.
# 사용: bash _shared/adapters/doctor.sh [--smoke]
#   --smoke : gemini에 실제 초경량 호출 1회(가용성 확정). 없으면 존재/키만 점검.
# 종료코드: FAIL 0건이면 0, 있으면 1.
set -uo pipefail

ok=0; warn=0; fail=0
say() { printf '%-6s %s\n' "$1" "$2"; }
need() { if command -v "$1" >/dev/null 2>&1; then say "[OK]" "$1 ($(command -v "$1"))"; ok=$((ok+1)); else say "[FAIL]" "$1 없음 — $2"; fail=$((fail+1)); fi; }

echo "== MultiAgent Doctor =="
need jq     "JSON 파싱 필수(디스패처)"
need codex  "codex-main/codex-critic 워커"
need gemini "gemini 워커(디자인/UX 검수)"
need git    "codex 워커 안전망"

if command -v timeout >/dev/null 2>&1 || command -v gtimeout >/dev/null 2>&1; then
  say "[OK]" "timeout"; ok=$((ok+1))
else
  say "[WARN]" "coreutils timeout 없음 — call_worker.sh는 python3 폴백 사용"; warn=$((warn+1))
fi

# gemini 키: 현재 env → 없으면 Windows User-env(레지스트리)에서 확인
key="${GEMINI_API_KEY:-}"
src="env"
if [ -z "$key" ] && command -v powershell >/dev/null 2>&1; then
  key="$(powershell -NoProfile -Command '[Environment]::GetEnvironmentVariable("GEMINI_API_KEY","User")' 2>/dev/null | tr -d '\r\n')"
  src="setx(User-env)"
fi
if [ -n "$key" ]; then
  say "[OK]" "GEMINI_API_KEY 존재 (len=${#key}, src=$src)"; ok=$((ok+1))
else
  say "[WARN]" "GEMINI_API_KEY 미설정 — gemini 워커 호출 불가 (setx GEMINI_API_KEY \"...\" 후 재시작)"; warn=$((warn+1))
fi

if [ "${1:-}" = "--smoke" ] && [ -n "$key" ]; then
  echo "-- gemini smoke --"
  tb="$(mktemp)"; printf 'Reply with exactly: DOCTOR_OK' > "$tb"
  if GEMINI_API_KEY="$key" GEMINI_CLI_TRUST_WORKSPACE=true timeout 150 \
       gemini --prompt "$(cat "$tb")" --approval-mode plan --skip-trust </dev/null 2>/dev/null | grep -qi "DOCTOR_OK"; then
    say "[OK]" "gemini 응답 정상"; ok=$((ok+1))
  else
    say "[FAIL]" "gemini 스모크 실패(키 무효/네트워크/트러스트 확인)"; fail=$((fail+1))
  fi
  rm -f "$tb"
fi

echo "== 요약: OK=$ok  WARN=$warn  FAIL=$fail =="
[ "$fail" -eq 0 ]
