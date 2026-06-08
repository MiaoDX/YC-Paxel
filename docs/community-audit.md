# Community Audit Workflow

This project does not redistribute the extracted Paxel client source snapshot.
Instead, it lets each reviewer independently pull the official container image,
extract the client files locally, and audit the same shipped implementation.

## Steps

1. Pull and extract the official image:

   ```bash
   ./scripts/extract-client-source.sh
   ```

2. Generate a file hash manifest:

   ```bash
   ./scripts/generate-source-manifest.sh
   ```

3. Run the audit summary:

   ```bash
   ./scripts/audit-client-source.sh | tee tmp/audit.txt
   ```

4. Inspect high-risk areas manually:

   ```bash
   sed -n '1,120p' extracted/paxel-client/rails/bin/client-entrypoint
   sed -n '1,260p' extracted/paxel-client/rails/lib/tasks/analyze_local.rake
   rg -n 'YC_LLM_PROXY_URL|YC_RESULTS_ENDPOINT|upload_results|package_results' \
     extracted/paxel-client/rails/app/services/client_pipeline.rb
   rg -n 'Faraday|Net::HTTP|Sentry|x-api-key|X-YC-Token' \
     extracted/paxel-client/rails/app extracted/paxel-client/rails/lib
   ```

## Suggested Review Questions

- What host paths are mounted into the container?
- Which mounted paths are read-only and which are writable?
- What data is sent to the YC LLM proxy?
- What data is sent to `/api/v1/results`?
- What is cached locally?
- What is retained in `~/.paxel/data` if upload fails?
- Does redaction happen before upload boundaries?
- Are source file bodies sent anywhere, or only used locally for deterministic
  metrics?
- What telemetry/Sentry data can leave the container?

## Sharing Findings Without Redistributing Source

When sharing findings publicly, prefer:

- Image digest and client version.
- File path and line number references from a locally extracted copy.
- Hash manifest snippets.
- Short excerpts only when necessary.
- Reproduction commands.

Avoid publishing the full extracted tree unless YC provides an explicit license
or other redistribution permission.

