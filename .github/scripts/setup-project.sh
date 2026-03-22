#!/usr/bin/env bash
# Setup script for GitHub Project #18
# Uses gh CLI: https://cli.github.com/manual/gh_project
#
# Prerequisites:
#   - gh CLI installed and authenticated (gh auth login)
#   - Token must have 'project' read/write scope
#
# Usage:
#   .github/scripts/setup-project.sh

set -euo pipefail

OWNER="larralapid"
PROJECT_NUMBER=18
REPO="larralapid/grain"

echo "==> Configuring GitHub Project #${PROJECT_NUMBER} for ${REPO}"
echo ""

# ── 1. Custom fields ────────────────────────────────────────────────

echo "── Creating custom fields ──"

echo "  Adding 'Priority' single-select field..."
gh project field-create "$PROJECT_NUMBER" \
  --owner "$OWNER" \
  --name "Priority" \
  --data-type "SINGLE_SELECT" \
  --single-select-options "high,medium,low" 2>/dev/null \
  && echo "    ✓ Priority field created" \
  || echo "    ⚠ Priority field may already exist (skipping)"

echo "  Adding 'Area' single-select field..."
gh project field-create "$PROJECT_NUMBER" \
  --owner "$OWNER" \
  --name "Area" \
  --data-type "SINGLE_SELECT" \
  --single-select-options "scanning,analytics,export,integrations,design" 2>/dev/null \
  && echo "    ✓ Area field created" \
  || echo "    ⚠ Area field may already exist (skipping)"

echo "  Adding 'Sprint' iteration field..."
gh project field-create "$PROJECT_NUMBER" \
  --owner "$OWNER" \
  --name "Sprint" \
  --data-type "ITERATION" \
  --iteration-duration 14 2>/dev/null \
  && echo "    ✓ Sprint field created" \
  || echo "    ⚠ Sprint field may already exist (skipping)"

echo ""

# ── 2. Add existing issues ──────────────────────────────────────────

echo "── Adding existing issues to project ──"

ISSUES=$(gh issue list --repo "$REPO" --state all --json number --jq '.[].number')
for ISSUE_NUM in $ISSUES; do
  ISSUE_URL="https://github.com/${REPO}/issues/${ISSUE_NUM}"
  gh project item-add "$PROJECT_NUMBER" \
    --owner "$OWNER" \
    --url "$ISSUE_URL" 2>/dev/null \
    && echo "  ✓ Added issue #${ISSUE_NUM}" \
    || echo "  ⚠ Issue #${ISSUE_NUM} may already be in project (skipping)"
done

echo ""

# ── 3. Link project to repository ───────────────────────────────────

echo "── Linking project to repository ──"

gh project link "$PROJECT_NUMBER" \
  --owner "$OWNER" \
  --repo "$REPO" 2>/dev/null \
  && echo "  ✓ Project linked to ${REPO}" \
  || echo "  ⚠ Project may already be linked (skipping)"

echo ""

# ── 4. Add planning docs as draft items ─────────────────────────────

echo "── Adding planning docs to project ──"

echo "  Adding workflow reference..."
gh project item-create "$PROJECT_NUMBER" \
  --owner "$OWNER" \
  --title "📋 Workflow" \
  --body "New issues auto-added to Backlog via .github/workflows/add-to-project.yml.
During planning, move to Ready → In Progress. Closed issues move to Done automatically." \
  2>/dev/null \
  && echo "    ✓ Workflow note added" \
  || echo "    ⚠ Could not add workflow note"

echo "  Adding recommended views reference..."
gh project item-create "$PROJECT_NUMBER" \
  --owner "$OWNER" \
  --title "📋 Recommended Views" \
  --body "| View | Layout | Group by |
|------|--------|----------|
| Kanban | Board | Status |
| By Priority | Table | Priority |
| By Area | Table | Area |

gh CLI does not support creating views — add these manually via the project UI." \
  2>/dev/null \
  && echo "    ✓ Recommended views note added" \
  || echo "    ⚠ Could not add views note"

echo "  Adding custom fields reference..."
gh project item-create "$PROJECT_NUMBER" \
  --owner "$OWNER" \
  --title "📋 Custom Fields" \
  --body "| Field | Type | Values |
|-------|------|--------|
| Priority | Single select | high, medium, low |
| Area | Single select | scanning, analytics, export, integrations, design |
| Sprint | Iteration | 2-week cycles |

These are created automatically by this setup script." \
  2>/dev/null \
  && echo "    ✓ Custom fields note added" \
  || echo "    ⚠ Could not add fields note"

echo ""

# ── 5. Views (manual — not supported by gh CLI) ─────────────────────

echo "── Creating project views ──"
echo "  Note: gh CLI does not yet support creating views programmatically."
echo "  Please create these views manually in the project settings:"
echo ""
echo "  ┌──────────────┬────────┬───────────────┐"
echo "  │ View         │ Layout │ Group by      │"
echo "  ├──────────────┼────────┼───────────────┤"
echo "  │ Kanban       │ Board  │ Status        │"
echo "  │ By Priority  │ Table  │ Priority      │"
echo "  │ By Area      │ Table  │ Area          │"
echo "  └──────────────┴────────┴───────────────┘"
echo ""
echo "  Open the project at:"
echo "  https://github.com/users/${OWNER}/projects/${PROJECT_NUMBER}/views"
echo ""

# ── 6. Repo variable for automation workflow ─────────────────────────

echo "── Setting PROJECT_URL repository variable ──"

gh variable set PROJECT_URL \
  --repo "$REPO" \
  --body "https://github.com/users/${OWNER}/projects/${PROJECT_NUMBER}" 2>/dev/null \
  && echo "  ✓ PROJECT_URL variable set" \
  || echo "  ⚠ Could not set PROJECT_URL (set it manually in repo Settings → Variables)"

echo ""
echo "==> Done! Remaining manual steps:"
echo "  1. Create the three views listed above in the project UI"
echo "  2. Add ADD_TO_PROJECT_PAT secret (fine-grained PAT with project r/w scope)"
echo "     → Settings → Secrets and variables → Actions → New repository secret"
