#!/usr/bin/env bash
# Regenerates the ADR index in docs/adr/README.md using adr-log.
# adr-log updates the list between <!-- adrlog --> and <!-- adrlogstop --> markers.
# Install: npm install -g adr-log  (done automatically in CI by docs.yml)
set -euo pipefail

if ! command -v adr-log &>/dev/null; then
  echo "adr-log not found. Install it with: npm install -g adr-log"
  exit 1
fi

# Run from the ADR directory so that adr-log produces correct relative links
cd docs/adr
adr-log -d . -i README.md -e README.md
cd - > /dev/null

echo "ADR index updated."
