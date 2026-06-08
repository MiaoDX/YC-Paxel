# Extracting The Paxel Client Source Snapshot

This guide explains how to extract the client-side files from the published
Paxel Docker image for local inspection.

## Why Extract Locally

Paxel reads local coding-agent transcripts and sends selected analysis data to
YC services. Before running that workflow against sensitive sessions, you may
want to inspect the shipped client implementation.

The public image includes a Rails app under `/rails`. The local upload wrapper
mounts transcripts and optional repository data into the container, then the
container entrypoint runs:

```bash
bin/rails client:analyze
```

## Extraction Command

From the repository root:

```bash
./scripts/extract-client-source.sh
```

Optional custom output directory:

```bash
./scripts/extract-client-source.sh extracted/paxel-client-$(date +%Y%m%d)
```

Optional custom image:

```bash
PAXEL_CLIENT_IMAGE=ghcr.io/yc-software/paxel-client:latest ./scripts/extract-client-source.sh
```

## Output

The script writes:

```text
extracted/paxel-client/
  image.inspect.json
  metadata.txt
  rails/
    VERSION
    Gemfile
    Gemfile.lock
    Rakefile
    app/
    bin/
    config/
    db/
    lib/
```

The extracted tree is ignored by git.

## Useful Inspection Commands

Show image metadata:

```bash
cat extracted/paxel-client/metadata.txt
```

Show the entrypoint:

```bash
sed -n '1,120p' extracted/paxel-client/rails/bin/client-entrypoint
```

Show the analyzer task:

```bash
sed -n '1,240p' extracted/paxel-client/rails/lib/tasks/analyze_local.rake
```

Find client pipeline stages:

```bash
rg -n 'run_step|upload_results|YC_LLM_PROXY_URL|YC_RESULTS_ENDPOINT' \
  extracted/paxel-client/rails/app/services/client_pipeline.rb
```

Find outbound network/proxy references:

```bash
rg -n 'Faraday|Net::HTTP|YC_LLM_PROXY_URL|YC_RESULTS_ENDPOINT|X-YC-Token|x-api-key' \
  extracted/paxel-client/rails/app extracted/paxel-client/rails/lib
```

Check whether a project license is present in the extracted app:

```bash
find extracted/paxel-client/rails -maxdepth 3 \
  \( -iname 'license*' -o -iname 'copying*' -o -iname 'notice*' \)
```

## Current Observations

For the image inspected on 2026-06-08:

- The image contains the runnable client analyzer source snapshot.
- The app root is `/rails`.
- The entrypoint is `/rails/bin/client-entrypoint`.
- The client version is `0.3.39.1`.
- The OCI source label points to `https://github.com/yc-software/paxel`.
- The public GitHub URL for that repo returned 404 during inspection.
- No `.git` directory was present in `/rails`.
- No first-party project license file was present in `/rails`.

## Legal / Maintenance Note

This repository is for local inspection and learning. It does not claim ownership
of extracted Paxel files and does not relicense them. If YC publishes an official
source repository and license, use that official source instead.

