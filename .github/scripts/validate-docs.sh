#!/usr/bin/env bash
# Validates project documentation:
#   1. Every docs/adr/ADR-*.md file is listed in the ADR index.
#   2. CHANGELOG.md has an [Unreleased] section.
#   3. Internal markdown links resolve to existing files.
set -euo pipefail

errors=0

# ── 1. ADR index completeness ────────────────────────────────────────────────
echo "=== Checking ADR index completeness ==="
ADR_DIR="docs/adr"
INDEX_FILE="$ADR_DIR/README.md"

for adr_file in "$ADR_DIR"/ADR-*.md; do
    filename=$(basename "$adr_file")
    if ! grep -qF "$filename" "$INDEX_FILE"; then
        echo "ERROR: $filename is not listed in $INDEX_FILE"
        errors=$((errors + 1))
    fi
done
echo "Done."

# ── 2. CHANGELOG [Unreleased] section ────────────────────────────────────────
echo "=== Checking CHANGELOG has [Unreleased] section ==="
if ! grep -q "\[Unreleased\]" CHANGELOG.md; then
    echo "ERROR: CHANGELOG.md is missing an [Unreleased] section"
    errors=$((errors + 1))
fi
echo "Done."

# ── 3. Internal markdown link resolution ─────────────────────────────────────
echo "=== Checking internal markdown links ==="

while IFS= read -r mdfile; do
    dir=$(dirname "$mdfile")
    # Extract link targets from [text](target) syntax
    while IFS= read -r link; do
        # Strip fragment anchor (#section)
        path="${link%%#*}"
        [ -z "$path" ] && continue
        # Skip external URLs
        [[ "$path" == http* ]] && continue
        # Resolve relative to the markdown file's directory
        resolved="$dir/$path"
        if [ ! -e "$resolved" ]; then
            echo "ERROR: Broken link in $mdfile: $link (resolved: $resolved)"
            errors=$((errors + 1))
        fi
    done < <(grep -oE '\[([^]]*)\]\(([^)]+)\)' "$mdfile" \
             | grep -oE '\(([^)]+)\)' \
             | tr -d '()')
done < <(find . -name "*.md" -not -path "./.git/*")
echo "Done."

# ─────────────────────────────────────────────────────────────────────────────
if [ "$errors" -gt 0 ]; then
    echo ""
    echo "Documentation validation FAILED with $errors error(s)."
    exit 1
else
    echo ""
    echo "All documentation checks passed."
fi
