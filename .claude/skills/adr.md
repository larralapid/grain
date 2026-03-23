---
name: adr
description: Create or update Architecture Decision Records for grain
user_invocable: true
---

# ADR Skill

When invoked, create a new Architecture Decision Record in `docs/adr/`.

## Steps

1. Determine the next ADR number by reading `docs/adr/README.md` index table
2. Ask the user for: title, context, and decision (if not provided)
3. Create the ADR file at `docs/adr/ADR-{NNNN}-{slug}.md` with this format:

```markdown
# ADR-{NNNN}: {Title}

**Status**: Proposed
**Date**: {today's date}

## Context

{What situation or problem prompted this decision}

## Decision

{What was decided}

## Consequences

### Easier
- {What becomes easier}

### Harder
- {What becomes harder}
```

4. Add a row to the index table in `docs/adr/README.md`
5. Mention the ADR in the PR description if one is being created
