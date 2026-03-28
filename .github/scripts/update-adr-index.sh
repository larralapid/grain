#!/usr/bin/env bash
# Regenerates the ADR index table in docs/adr/README.md from the actual ADR files.
set -euo pipefail

ADR_DIR="docs/adr"
INDEX_FILE="$ADR_DIR/README.md"

python3 - "$ADR_DIR" "$INDEX_FILE" <<'PYTHON'
import os
import re
import sys

adr_dir = sys.argv[1]
index_file = sys.argv[2]

rows = []
for fname in sorted(os.listdir(adr_dir)):
    if not re.match(r'^ADR-\d+.*\.md$', fname):
        continue
    fpath = os.path.join(adr_dir, fname)
    with open(fpath) as f:
        content = f.read()

    # Extract ADR number + title from first heading: # ADR-XXXX: Title
    m = re.search(r'^# (ADR-\d+): (.+)$', content, re.MULTILINE)
    if not m:
        continue
    adr_ref = m.group(1)
    title = m.group(2).strip()

    # Extract Status
    sm = re.search(r'^\*\*Status\*\*:\s*(.+)$', content, re.MULTILINE)
    status = sm.group(1).strip() if sm else "Unknown"

    # Extract Date
    dm = re.search(r'^\*\*Date\*\*:\s*(.+)$', content, re.MULTILINE)
    date = dm.group(1).strip() if dm else "Unknown"

    rows.append(f"| [{adr_ref}]({fname}) | {title} | {status} | {date} |")

with open(index_file) as f:
    original = f.read()

# Replace the table body (keep header + separator, replace all data rows)
table_header = "| ADR | Title | Status | Date |"
sep = "|-----|-------|--------|------|"
new_table = table_header + "\n" + sep + "\n" + "\n".join(rows) + "\n"

# Separator pattern is flexible to allow varying dash counts and alignment colons
pattern = r'\| ADR \| Title \| Status \| Date \|\n\|[ :\-|]+\|\n(?:\|.*\|\n)*'
updated = re.sub(pattern, new_table, original)

if updated != original:
    with open(index_file, "w") as f:
        f.write(updated)
    print("ADR index updated.")
else:
    print("ADR index is already up to date.")
PYTHON
