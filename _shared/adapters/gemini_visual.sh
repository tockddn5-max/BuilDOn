#!/usr/bin/env bash
# gemini_visual.sh — gemini 멀티모달(이미지) 검수 어댑터.
# gemini의 @파일 참조는 워크스페이스(cwd) 내부 파일만 읽으므로, 이미지를 staging cwd에
# 복사한 뒤 상대경로(@shotN.ext)로 참조한다(한글/공백 경로 회피).
# 사용: bash _shared/adapters/gemini_visual.sh <prompt-file> <image...>
# stdout = 모델 응답 텍스트. 필요 env: GEMINI_API_KEY (없으면 Windows User-env에서 로드 시도).
# 시간: 이미지 분석은 느림(~200s). GEMINI_VISUAL_TIMEOUT(기본 280s)로 조절.
set -euo pipefail

PROMPT="${1:?usage: gemini_visual.sh <prompt-file> <image...>}"; shift
[ -f "$PROMPT" ] || { echo "prompt 파일 없음: $PROMPT" >&2; exit 6; }
[ "$#" -ge 1 ] || { echo "이미지 최소 1개 필요" >&2; exit 6; }

key="${GEMINI_API_KEY:-}"
if [ -z "$key" ] && command -v powershell >/dev/null 2>&1; then
  key="$(powershell -NoProfile -Command '[Environment]::GetEnvironmentVariable("GEMINI_API_KEY","User")' 2>/dev/null | tr -d '\r\n')"
fi
[ -n "$key" ] || { echo "GEMINI_API_KEY 없음 (setx 후 재시작 또는 env 설정)" >&2; exit 4; }

STAGE="$(mktemp -d)"; trap 'rm -rf -- "$STAGE"' EXIT
refs=""; i=0
for img in "$@"; do
  [ -f "$img" ] || { echo "이미지 없음: $img" >&2; exit 6; }
  i=$((i+1)); ext="${img##*.}"; nm="shot${i}.${ext}"
  cp -- "$img" "$STAGE/$nm"
  refs="${refs}@${nm} "
done
full="${refs}
$(cat -- "$PROMPT")"

TMO="${GEMINI_VISUAL_TIMEOUT:-420}"   # 이미지 분석은 느리고 503 재시도가 붙을 수 있음. 다중 이미지는 run_in_background 권장.
cd "$STAGE"
GEMINI_API_KEY="$key" GEMINI_CLI_TRUST_WORKSPACE=true \
  timeout "$TMO" gemini --prompt "$full" --approval-mode plan --skip-trust </dev/null
