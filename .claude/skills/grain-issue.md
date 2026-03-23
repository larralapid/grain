---
name: grain-issue
description: Create a well-structured GitHub issue for grain with labels and project linkage
user_invocable: true
---

# Grain Issue Skill

Create GitHub issues following grain's conventions.

## Steps

1. Determine issue type: `feature`, `bug`, `enhancement`, `tech-debt`, `backend`
2. Create the issue with `gh` CLI:

```bash
export PATH="/opt/homebrew/bin:$PATH"
gh issue create \
  --title "{concise title}" \
  --label "{type}" \
  --body "$(cat <<'EOF'
## Summary
{1-2 sentence description}

## Context
{Why this matters, what it unblocks}

## Acceptance Criteria
- [ ] {Criterion 1}
- [ ] {Criterion 2}

## Technical Notes
{Implementation hints, relevant files, ADR references}

## Design
{If UI work — reference design system tokens, wireframes, or inspiration}
EOF
)"
```

3. Add to GitHub Project if one exists
4. Reference related ADRs where applicable
