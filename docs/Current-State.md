# Grain Current State Assessment

Audited on 2026-04-01 against local branch main.

## Executive Snapshot

Grain has a healthy proof-of-concept core: scan receipts, parse text, store receipts, browse details, and view analytics.

The main project risk is not architecture. The main risk is product completeness and scope discipline for MVP.

## Confirmed Current State

| Area | Current Status | Notes |
|------|----------------|------|
| Platform and stack | iOS 17+, SwiftUI, SwiftData, Vision, Swift Charts | Aligned with ADRs |
| Dependencies | Apple frameworks only | Aligned with ADR-0003 |
| Storage strategy | Local only | Aligned with ADR-0005 |
| Core flow | Scan -> OCR -> parse -> save -> list/detail | Working at POC quality |
| Analytics | Receipt/category/merchant aggregations and charts | Working |
| Product index | Product and brand indexing from receipt items | Working |
| CI workflow | Build + test workflow exists | Present in .github/workflows/build.yml |

## Gaps and Product Debt

### UX and flow gaps

- Receipt list plus button is still a TODO (manual receipt entry not wired).
- Scan proof Edit button is still a TODO.
- Settings routes are placeholders (Export, Import, Tax Categories, Deduction Rules).

### Data and feature gaps

- Receipt image persistence is not wired to Receipt.imageData.
- BankTransaction model exists but has no import, matching, or UI flow.
- SpendingAnalytics is persisted as a model even though it behaves like derived data.

### Reliability and quality gaps

- OCR parser is still regex-based and fragile on real receipt variety.
- Service/view errors still rely on print-based handling in key paths.
- Unit tests exist for model coverage, but service/parser regression coverage is still limited.

## Current State vs Ideal MVP

| Capability | Current | Ideal MVP | Delta |
|-----------|---------|-----------|-------|
| Capture and save receipt | Works | Works reliably with image attachment | Persist imageData and add validation |
| Parse receipt content | Works for basic receipts | Robust for grocery, pharmacy, restaurant variants | Add parser test corpus and parser improvements |
| Review and edit scanned receipt | Partial | User can fully correct parsed output | Wire Edit flow from scan proof |
| Manual receipt entry | Missing | Available as fallback | Build minimal manual entry screen |
| Expense analytics | Works | Works with trustworthy totals and period filters | Add validation tests and edge-case handling |
| Error UX | Weak | User-facing recoverable errors | Replace silent catches with alert states |
| CI confidence | Moderate | Green build and test on every PR | Keep workflow healthy and enforce checks |

## PM Assessment

### What is healthy

- Architecture choices are coherent and intentionally constrained.
- Codebase layout is understandable and suitable for iteration.
- Delivery pace is high with active issue and PR throughput.

### What needs immediate management attention

- Backlog contains out-of-scope or conflicting items for current local-only MVP.
- Several old issues are now completed by merged PRs and should be closed.
- MVP definition needs explicit acceptance criteria so feature work does not sprawl.

## Priority Workstream Recommendation

1. Stabilize backlog hygiene:
- Close completed and out-of-scope issues.
- Keep only active MVP issues in the next milestone lane.

2. Close MVP usability gaps:
- Manual entry fallback.
- Scan proof edit flow.
- Receipt image persistence.

3. Improve reliability for real testing:
- Parser regression test set.
- User-facing error states.

4. Delay non-MVP platform expansion:
- Cloud sync, auth, backend API, and server-side OCR stay deferred unless ADR scope changes.
