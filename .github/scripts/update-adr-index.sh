#!/usr/bin/env bash
# Regenerates the ADR index in docs/adr/README.md using adr-tools and adr-log.
#
# adr-tools (npryce/adr-tools) generates the list of ADRs via `adr generate toc`.
# adr-log injects the generated list between the <!-- adrlog --> / <!-- adrlogstop -->
# markers in docs/adr/README.md.
#
# Prerequisites (installed automatically by CI; for local use):
#   adr-tools: download from https://github.com/npryce/adr-tools/releases
#              and add the src/ dir to your PATH.
#   adr-log:   npm install -g adr-log
set -euo pipefail

if ! command -v adr &>/dev/null; then
  echo "adr (adr-tools) not found."
  echo "Install from https://github.com/npryce/adr-tools/releases and add src/ to PATH."
  exit 1
fi

if ! command -v adr-log &>/dev/null; then
  echo "adr-log not found. Install it with: npm install -g adr-log"
  exit 1
fi

# Verify the ADR directory is configured
adr_dir=$(adr list 2>/dev/null | head -1 | xargs dirname 2>/dev/null || true)
if [ -z "$adr_dir" ]; then
  echo "No ADRs found. Ensure .adr-dir exists and ADR files follow the NNNN-title.md naming convention."
  exit 1
fi

# Generate the list of ADRs and inject it into the README index via adr-log.
# adr-log updates the content between <!-- adrlog --> and <!-- adrlogstop --> markers.
cd "$adr_dir"
adr-log -d . -i README.md -e README.md
cd - > /dev/null

echo "ADR index updated."
