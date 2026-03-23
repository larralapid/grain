# ADR-0006: Add Launch Experience to Mask Cold Start

**Status**: Proposed
**Date**: 2026-03-23

## Context

The app initializes a SwiftData `ModelContainer` with 7 model types synchronously at launch. While actual init time is <2s, the blank white/black screen during setup creates a poor first impression. Users perceive the app as slow.

Three proof-of-concept approaches were evaluated:
1. **Splash Animation** — Async init + branded receipt-themed animation
2. **Skeleton UI** — Show tab structure immediately with shimmer placeholders
3. **Notifications Preview** — Branded animation + contextual cards (recent activity for returning users, onboarding tips for new users)

## Decision

Evaluate all three POCs and select based on user testing. POC 3 (Notifications Preview) is the recommended default — it provides the richest experience and surfaces useful information during the wait.

## Consequences

### Easier
- Users perceive instant app launch
- Returning users get immediate context about recent activity
- New users get guided onboarding during natural wait time
- Branded experience reinforces design identity

### Harder
- Additional view code to maintain
- Need to fetch recent activity data for notification cards
- Animation timing must be tuned to actual load time (not hardcoded delays)
- Must test across device generations for performance parity
