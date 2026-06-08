#!/usr/bin/env bash
set -Eeuo pipefail

SRC_DIR="${1:-extracted/paxel-client/rails}"
OUT_DIR="${2:-manifests/paxel-client}"

if [ ! -d "$SRC_DIR" ]; then
  echo "error: source directory not found: $SRC_DIR" >&2
  echo "run ./scripts/extract-client-source.sh first" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

find "$SRC_DIR" \
  -path "$SRC_DIR/tmp/cache" -prune -o \
  -type f -print \
  | sort \
  | while IFS= read -r file; do
      rel="${file#$SRC_DIR/}"
      sha="$(sha256sum "$file" | awk '{print $1}')"
      bytes="$(wc -c < "$file" | tr -d ' ')"
      printf '%s\t%s\t%s\n' "$sha" "$bytes" "$rel"
    done > "$OUT_DIR/SHA256SUMS.tsv"

{
  echo "# Paxel Client Source Manifest"
  echo
  echo "Generated at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "Source dir: $SRC_DIR"
  echo
  echo "## Image Metadata"
  echo
  if [ -f "${SRC_DIR%/rails}/metadata.txt" ]; then
    sed 's/^/- /' "${SRC_DIR%/rails}/metadata.txt"
  else
    echo "- metadata.txt not found"
  fi
  echo
  echo "## File Counts"
  echo
  printf -- "- files: "
  wc -l < "$OUT_DIR/SHA256SUMS.tsv" | tr -d ' '
  echo
  printf -- "- ruby files: "
  find "$SRC_DIR" -path "$SRC_DIR/tmp/cache" -prune -o -name '*.rb' -print | wc -l | tr -d ' '
  echo
  printf -- "- rake files: "
  find "$SRC_DIR" -path "$SRC_DIR/tmp/cache" -prune -o -name '*.rake' -print | wc -l | tr -d ' '
  echo
  echo
  echo "## Verify"
  echo
  echo '```bash'
  echo "./scripts/generate-source-manifest.sh"
  echo "diff -u manifests/paxel-client/SHA256SUMS.tsv <(cat manifests/paxel-client/SHA256SUMS.tsv)"
  echo '```'
} > "$OUT_DIR/README.md"

echo "Wrote $OUT_DIR/SHA256SUMS.tsv"
echo "Wrote $OUT_DIR/README.md"

