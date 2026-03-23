---
name: backlog
description: Review and prioritize the grain project backlog
user_invocable: true
---

# Backlog Review Skill

Review the current state of the grain project backlog.

## Steps

1. List all open issues: `gh issue list --state open --json number,title,labels,assignees`
2. Check the GitHub Project board: `gh project item-list`
3. Cross-reference with `CHANGELOG.md` [Unreleased] section
4. Cross-reference with `docs/Current-State.md` known issues
5. Present a priority-ranked summary:

| Priority | Issue | Type | Status | Blocking |
|----------|-------|------|--------|----------|

6. Flag any gaps — items in docs/changelog that don't have issues
7. Flag any stale issues that may no longer be relevant
8. Suggest what to work on next based on dependencies and impact
