# YC-Paxel Client Analyzer Inspection Kit

This repository documents how to inspect the client-side Paxel analyzer that is
published as a Docker image:

```text
ghcr.io/yc-software/paxel-client:latest
```

The goal is learning and security review. Paxel analyzes local coding-agent
sessions, so it is reasonable to inspect what the client image contains before
running it against private transcripts.

## What This Repository Contains

- A repeatable extraction script for the client-side files shipped in the image.
- A guide explaining what gets extracted and how to inspect it.
- Notes about the license boundary and official Paxel links.

This repository does **not** commit the extracted Paxel/Y Combinator source code.
The client image includes a Rails application under `/rails`, but the image does
not include a project license file or git history. The MIT license in this repo
applies only to the documentation and scripts authored here.

## Quick Start

Requirements:

- Docker
- Bash
- `jq` for prettier metadata output, optional

Extract the client files locally:

```bash
./scripts/extract-client-source.sh
```

By default, this writes to:

```text
extracted/paxel-client/rails/
```

The `extracted/` directory is intentionally ignored by git.

Generate hashes and run a basic audit summary:

```bash
./scripts/generate-source-manifest.sh
./scripts/audit-client-source.sh | tee tmp/audit.txt
```

## What Is In The Image

Based on the current published image inspected on 2026-06-08:

```text
Image: ghcr.io/yc-software/paxel-client:latest
Digest: ghcr.io/yc-software/paxel-client@sha256:5c5759b6763cca306cba30383d637c89a7c80926f5bde568a43c637f4be40f99
Image revision: a294a3a69589301774b04cb9e923344d8fc8652a
Image source label: https://github.com/yc-software/paxel
Client version: 0.3.39.1
Entrypoint: /rails/bin/client-entrypoint
Runtime command: bin/rails client:analyze
```

The image includes the client analyzer implementation under `/rails`, including
models, services, config, local schema, and rake tasks. It does not include `.git`,
tests, a Dockerfile, or a project license file.

## Official Links

- Paxel landing page: https://paxel.ycombinator.com/
- Upload script: https://paxel.ycombinator.com/upload.sh
- Data handling: https://paxel.ycombinator.com/data-handling
- Terms: https://paxel.ycombinator.com/terms
- Container package: https://github.com/orgs/yc-software/packages/container/package/paxel-client
- Image source label target: https://github.com/yc-software/paxel

## License Boundary

The extraction script and this documentation are MIT licensed.

The extracted Paxel client files are third-party materials from Y Combinator's
published Docker image. This repository does not relicense those files. If YC
publishes an official open-source repository and license, prefer the official
repository and treat this project as obsolete.

## Why The Extracted Source Is Not Committed

The purpose of this project is community safety review, but the inspected image
does not contain a license granting redistribution rights for the Paxel client
source snapshot. Paxel's own Terms also place restrictions on reverse engineering
and extracting underlying systems.

For that reason, this repository publishes the extraction and audit workflow,
not the extracted third-party source. Reviewers can independently pull the
official image, extract the same `/rails` tree locally, generate a hash manifest,
and inspect it without trusting a third-party mirror.

See [Community Audit Workflow](docs/community-audit.md) for the review process.
