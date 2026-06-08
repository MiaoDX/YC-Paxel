# License Boundary

This repository contains original documentation and scripts for local inspection
of the Paxel client Docker image.

The MIT license in this repository applies only to those original files.

It does not apply to:

- The Paxel Docker image.
- The Rails client app extracted from `/rails` inside that image.
- Any Y Combinator or Paxel service code, prompts, model-routing code, assets, or
  server-side systems.

## Why Extracted Source Is Not Committed

The inspected client image did not include a project license file under `/rails`.
The image labels point to `https://github.com/yc-software/paxel`, but that source
repository was not publicly accessible during inspection.

Because there is no explicit permission to redistribute or relicense the Paxel
client snapshot, this repository keeps extracted files out of git. The extraction
script writes them into `extracted/`, which is ignored.

## Official Links

- Paxel: https://paxel.ycombinator.com/
- Data handling: https://paxel.ycombinator.com/data-handling
- Terms: https://paxel.ycombinator.com/terms
- Upload script: https://paxel.ycombinator.com/upload.sh
- Container package: https://github.com/orgs/yc-software/packages/container/package/paxel-client

