# Grain — Roadmap & Backlog

The durable plan of record. Goal: a polished, working proof of concept that demonstrates **granular** (product/brand-level) expense tracking with private, on-device-first AI extraction. See [context.md](context.md).

**How to use this file**
- Anything noticed mid-work (by Claude or a subagent) gets **captured in the Backlog or Parking Lot** — don't act on it out of scope. Scope discipline > momentum.
- Items flow: Parking Lot → Backlog (prioritized) → in progress → done. Reference the GitHub issue where one exists.
- `OVERNIGHT_LOG.md` is the dated work journal; **this** file is the plan of record.

## Vision
Receipts → structured, granular data (item + brand + price history) → insight (per-product / brand / merchant spend, cross-store price comparison). Private by default; improves with use via user corrections.

## Roadmap

### Now — demo readiness (accelerator)
- Happy path: scan / manual → extract → save → list / detail → analytics — ✅ core in place
- Correction loop: flag → review queue → edit → capture — ✅
- Hybrid AI extraction (on-device default, opt-in Claude) — ✅ (ADR-0007)
- Data export (CSV) — ⏳
- Targeted UI polish + pitch screenshots — ⏳
- User-facing errors (replace `print()`) — ⏳

### Next — robustness & insight
- Parser / extraction regression corpus + `AnalyticsService` tests
- Product / brand indexing from real scans (not just demo data) + price-history surfacing
- Demo data carries sample images (so split-view / scan-overlay demo well)
- Cold start < 200ms (#46)

### Later — platform (deferred; ADR-gated)
- BankTransaction import + matching (#1, #26)
- CloudKit sync (ADR-0005)
- Backend / server-side options (auth, server OCR) — out of current scope

## Backlog (prioritized)
| ID | Item | Area | Pri | Source | Status |
|----|------|------|-----|--------|--------|
| B1 | Manual receipt entry | capture | High | #58 | done |
| B2 | CSV data export | export | High | #5 #26 | in progress |
| B3 | Replace `print()` error-swallowing with user-facing alerts | quality | High | #58 | todo |
| B4 | "Flagged for review" badge in ReceiptDetailView | correction | Med | review | todo |
| B5 | AnalyticsService + parser regression tests | quality | Med | #58 | todo |
| B6 | Targeted UI polish (from designer plan) | design | High | #7 | in progress (plan) |
| B7 | Pitch screenshots / demo capture | design | Med | demo | todo |
| B8 | Attach sample images to seeded demo receipts | demo | Med | discovered | todo |
| B9 | Info.plist `ITSAppUsesNonExemptEncryption = NO` | infra | Low | TestFlight | todo |
| B10 | CONTRIBUTING.md + docs/context.md | docs | Med | #43 #44 | done |
| B11 | docs/ROADMAP.md (this file) | docs | Med | process | done |

## Discoveries / Parking Lot
_Capture here; do not act out of scope. Promote to Backlog when prioritized._
- Split view: let the first/last line center via half-viewport insets (review Med finding).
- Split view: persist OCR line bounding boxes at scan time so the view needn't re-run Vision.
- `SpendingAnalytics` is a persisted `@Model` but behaves like derived data → make it a plain `struct` (data-model hygiene).
- Verify real scans create `Product` / `Brand` / `PricePoint` (confirmed only for `DemoDataSeeder`); if not, wire product/brand indexing on save — this is core to the "granular" value prop.
- Improve OCR (#4) is largely addressed by the hybrid extractor — review and rescope/close the issue.
- Repo-config issues (#41, #42) partially addressed (.mcp.json, skills, CONTRIBUTING) — reconcile/close.
