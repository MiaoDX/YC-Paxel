#!/usr/bin/env bash
set -Eeuo pipefail

IMAGE="${PAXEL_CLIENT_IMAGE:-ghcr.io/yc-software/paxel-client:latest}"
OUT_DIR="${1:-extracted/paxel-client}"

if ! command -v docker >/dev/null 2>&1; then
  echo "error: docker is required" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

echo "Pulling image: $IMAGE"
docker pull "$IMAGE"

cid=""
cleanup() {
  if [ -n "$cid" ]; then
    docker rm -f "$cid" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

cid="$(docker create "$IMAGE")"

echo "Writing image metadata..."
docker image inspect "$IMAGE" > "$OUT_DIR/image.inspect.json"

echo "Extracting /rails to $OUT_DIR/rails ..."
rm -rf "$OUT_DIR/rails"
docker cp "$cid:/rails" "$OUT_DIR/rails"

digest="$(docker image inspect "$IMAGE" | jq -r '.[0].RepoDigests[0] // ""' 2>/dev/null || true)"
revision="$(docker image inspect "$IMAGE" | jq -r '.[0].Config.Labels["org.opencontainers.image.revision"] // ""' 2>/dev/null || true)"
source_url="$(docker image inspect "$IMAGE" | jq -r '.[0].Config.Labels["org.opencontainers.image.source"] // ""' 2>/dev/null || true)"
created="$(docker image inspect "$IMAGE" | jq -r '.[0].Created // ""' 2>/dev/null || true)"
version=""
[ -f "$OUT_DIR/rails/VERSION" ] && version="$(tr -d '[:space:]' < "$OUT_DIR/rails/VERSION")"

{
  echo "image=$IMAGE"
  echo "digest=$digest"
  echo "created=$created"
  echo "revision=$revision"
  echo "source_url=$source_url"
  echo "client_version=$version"
  echo "entrypoint=/rails/bin/client-entrypoint"
  echo "runtime_command=bin/rails client:analyze"
  echo
  echo "first_party_license_files:"
  find "$OUT_DIR/rails" -maxdepth 3 \( -iname 'license*' -o -iname 'copying*' -o -iname 'notice*' \) -print | sed "s#^$OUT_DIR/##" || true
  echo
  echo "file_counts:"
  printf "ruby_files="
  find "$OUT_DIR/rails" -path "$OUT_DIR/rails/tmp/cache" -prune -o -name '*.rb' -print | wc -l | tr -d ' '
  echo
  printf "rake_files="
  find "$OUT_DIR/rails" -path "$OUT_DIR/rails/tmp/cache" -prune -o -name '*.rake' -print | wc -l | tr -d ' '
  echo
} > "$OUT_DIR/metadata.txt"

echo "Done."
echo "Metadata: $OUT_DIR/metadata.txt"
echo "Source snapshot: $OUT_DIR/rails"
echo
echo "Note: extracted Paxel files are third-party material and are intentionally git-ignored."

