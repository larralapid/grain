# Grain — Roadmap & Backlog

The durable plan of record. Goal: a polished, working proof of concept that demonstrates **granular** (product/brand-level) expense tracking with private, on-device-first AI extraction. See [context.md](context.md).

**How to use this file**
- Anything noticed mid-work (by Claude or a subagent) gets **captured in the Backlog or Parking Lot** — don't act on it out of scope. Scope discipline > momentum.
- Items flow: Parking Lot → Backlog (prioritized) → in progress → done. Reference the GitHub issue where one exists.
- **Bugs are logged AND fixed** (Bugs section below) — they take **priority over new features**. Don't ship around a bug.
- **Clean architecture is a standing bar** — fix smells (Architecture section), don't accumulate them.
- `OVERNIGHT_LOG.md` is the dated work journal; **this** file is the plan of record.
- **Orchestration & quality gate:** every code item runs builder → independent review + build/test → commit only on green + clean (gate calibrated to risk: heavy for logic/data changes, light for UI tweaks). Read-only analyses (audit, design, coverage) run in parallel continuously. Genuinely independent items are parallelized in isolated worktrees; writers to the shared tree stay non-concurrent to avoid conflicts. Optimize for effective output, not raw agent count.

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
| B2 | CSV data export | export | High | #5 #26 | done |
| B3 | Replace `print()` error-swallowing with user-facing alerts | quality | High | #58 | todo |
| B4 | "Flagged for review" badge in ReceiptDetailView | correction | Med | review | todo |
| B5 | AnalyticsService + parser regression tests | quality | Med | #58 | todo |
| B6 | Targeted UI polish — designer plan Top 5 | design | High | #7 | done |
| B7 | Pitch screenshots / demo capture | design | Med | demo | todo |
| B8 | Attach sample images to seeded demo receipts | demo | Med | discovered | todo |
| B9 | Info.plist `ITSAppUsesNonExemptEncryption = NO` | infra | Low | TestFlight | todo |
| B10 | CONTRIBUTING.md + docs/context.md | docs | Med | #43 #44 | done |
| B11 | docs/ROADMAP.md (this file) | docs | Med | process | done |

## Bugs (log + fix — priority over features)
_When a bug is found, log it here AND fix it._
- **BUG-1 (suspected, high)** — Real scans likely populate only `Receipt` + `ReceiptItem`, not `Product` / `Brand` / `PricePoint`. Only `DemoDataSeeder` links those today, so the **product index + price history (the core granular feature) are empty for actually-scanned receipts**. Verify in `ExtractedReceipt.makeReceipt` / the scan-save path; if confirmed, fix by indexing products/brands/price-points on save (mirror `DemoDataSeeder` linking). Audit running to confirm.
- **BUG-2 (high)** — `AnalyticsView` shows hardcoded placeholder copy ("MAR 2026", "+12% from feb…") and static `itemWatchPage` sample rows instead of real computed values (flagged by the polish builder). Displays fake data in a demo screen. Verify against `AnalyticsService` and wire to real output; remove placeholders.

## Architecture / cleanliness (standing bar)
- **A1** `SpendingAnalytics` is a persisted `@Model` but is derived data → make it a plain `struct` returned by `AnalyticsService`.
- **A2** Errors swallowed with `print()` across services/views → user-facing alerts (= B3).
- **A3** OCR parser internals untested + no regression corpus (= B5).
- **A4** O(n) analytics aggregation + per-render recompute (`ReceiptListView.groupedReceipts`, `ItemAnalyticsView`) → cache / SwiftData predicate.
- **A5** Dead code: `DocumentScanProcessor.makeReceipt` + `decimal(from:)` in `ScanPOC_DocumentScanner` are superseded by `ExtractorCoordinator` — remove.
- _(more from the running audit)_

## Design polish (from designer review, 2026-05-30)
Implementing the **Top 5** now (high-impact, low-risk, GrainTheme-consistent); the rest are backlog. Headline risk: dark-mode contrast — hero totals and metadata recede on near-black (visible in screenshots).
- **[now] D1** Hero totals too thin on dark → bump to `.regular` weight (ReceiptListView header; AnalyticsView totals).
- **[now] D2** Lift dark-mode `textSecondary` ~0.48 and `dateHeader` ~0.34 in GrainTheme — one edit that fixes collapsed hierarchy app-wide.
- **[now] D3** Replace hardcoded greys (`Color(white:)`, `.gray`, `Color.white.opacity`) with tokens in AnalyticsView + ReceiptDetailView — light-mode safety.
- **[now] D4** Visible `needs review` marker on flagged receipts (ReceiptDetailView header + ReceiptListView row) — surfaces the flag→review loop (= B4).
- **[now] D5** Promote the "proof"/split view out of the `···` overflow menu (rename, make prominent) — surface the most impressive screen.
- [backlog] M2 Unify manual-entry/edit `Form`s with the design language (mono font, accent tint, lowercase headers).
- [backlog] M4 Tappable empty states (home, products) with a bordered CTA.
- [backlog] M5 Tighten Settings AI-extraction section hierarchy + add a one-line description.
- [backlog] L1 ScanPOC proof-sheet `.gray` → tokens · L2 Analytics page-dots token-ize + enlarge · L4 alt-row striping (2% white) — make perceptible or remove.

## Discoveries / Parking Lot
_Capture here; do not act out of scope. Promote to Backlog when prioritized._
- CSV export regenerates the file on every Settings render (computed `exportCSVURL`) — generate on-demand/cache instead. Minor; fine at demo scale.
- Mockup `screenshots/01-home.png` shows a top-right "filter" control not present in code (ghost affordance) — build it or drop it (designer M3).
- Scan-overlay lightbox (ReceiptDetailView) uses raw scrim/white colors — consider a `GrainTheme.scrim` token rather than a blind swap (polish builder note).
- Add a `ReceiptDetailView` #Preview with `needsReview = true` for visual QA of the flag marker.
- Split view: let the first/last line center via half-viewport insets (review Med finding).
- Split view: persist OCR line bounding boxes at scan time so the view needn't re-run Vision.
- `SpendingAnalytics` is a persisted `@Model` but behaves like derived data → make it a plain `struct` (data-model hygiene).
- Verify real scans create `Product` / `Brand` / `PricePoint` (confirmed only for `DemoDataSeeder`); if not, wire product/brand indexing on save — this is core to the "granular" value prop.
- Improve OCR (#4) is largely addressed by the hybrid extractor — review and rescope/close the issue.
- Repo-config issues (#41, #42) partially addressed (.mcp.json, skills, CONTRIBUTING) — reconcile/close.
