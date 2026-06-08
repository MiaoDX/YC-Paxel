#!/usr/bin/env bash
set -Eeuo pipefail

SRC_DIR="${1:-extracted/paxel-client/rails}"

if [ ! -d "$SRC_DIR" ]; then
  echo "error: source directory not found: $SRC_DIR" >&2
  echo "run ./scripts/extract-client-source.sh first" >&2
  exit 1
fi

echo "== Paxel Client Source Audit =="
echo "source: $SRC_DIR"
echo

echo "== Basic Counts =="
printf "files: "
find "$SRC_DIR" -path "$SRC_DIR/tmp/cache" -prune -o -type f -print | wc -l | tr -d ' '
echo
printf "ruby files: "
find "$SRC_DIR" -path "$SRC_DIR/tmp/cache" -prune -o -name '*.rb' -print | wc -l | tr -d ' '
echo
printf "rake files: "
find "$SRC_DIR" -path "$SRC_DIR/tmp/cache" -prune -o -name '*.rake' -print | wc -l | tr -d ' '
echo
echo

echo "== Entrypoint =="
sed -n '1,80p' "$SRC_DIR/bin/client-entrypoint" 2>/dev/null || true
echo

echo "== Outbound Network References =="
rg -n "Faraday|Net::HTTP|URI\\.join|YC_LLM_PROXY_URL|YC_RESULTS_ENDPOINT|X-YC-Token|x-api-key|CLIENT_SENTRY_DSN|Sentry" \
  "$SRC_DIR/app" "$SRC_DIR/lib" "$SRC_DIR/config" 2>/dev/null || true
echo

echo "== Docker/Host Mount Sensitive Paths =="
rg -n "/transcripts|/codex_sessions|/cursor_sessions|/opencode_sessions|/gemini_sessions|/repo|/git_metrics.txt|/rails/data|/rails/cache|/logs" \
  "$SRC_DIR/app" "$SRC_DIR/lib" "$SRC_DIR/config" "$SRC_DIR/bin" 2>/dev/null || true
echo

echo "== Shell Execution / File System Hotspots =="
rg -n "system\\(|exec\\(|spawn\\(|Open3|IO\\.popen|File\\.read|File\\.write|FileUtils|docker|git -C|rm -rf|curl|wget" \
  "$SRC_DIR/app" "$SRC_DIR/lib" "$SRC_DIR/config" "$SRC_DIR/bin" 2>/dev/null || true
echo

echo "== Redaction / Scrubbing References =="
rg -n "SecretScrubber|scrub|redact|DecisionTextRedactor|ToolInputSummarizer|MAX_.*LENGTH|UPLOAD_.*LIMIT" \
  "$SRC_DIR/app" "$SRC_DIR/lib" 2>/dev/null || true
echo

echo "== License Files In Extracted App =="
find "$SRC_DIR" -maxdepth 3 \( -iname 'license*' -o -iname 'copying*' -o -iname 'notice*' \) -print || true
echo

echo "== Done =="

