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
- Demo data carries sample images (so split-view / scan-overlay demo well) — ✅ (B8: `ReceiptImageRenderer` renders a thermal slip per seeded receipt)
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
| B3 | Replace `print()` error-swallowing with user-facing alerts | quality | High | #58 | done (save paths) |
| B4 | "Flagged for review" badge in ReceiptDetailView | correction | Med | review | todo |
| B5 | AnalyticsService + parser regression tests | quality | Med | #58 | done |
| B6 | Targeted UI polish — designer plan Top 5 | design | High | #7 | done |
| B7 | Pitch screenshots / demo capture | design | Med | demo | done (refresh set) |
| B8 | Attach sample images to seeded demo receipts | demo | Med | discovered | done |
| B9 | Info.plist `ITSAppUsesNonExemptEncryption = NO` | infra | Low | TestFlight | done |
| B10 | CONTRIBUTING.md + docs/context.md | docs | Med | #43 #44 | done |
| B11 | docs/ROADMAP.md (this file) | docs | Med | process | done |

## Bugs (log + fix — priority over features)
_When a bug is found, log it here AND fix it._
- **BUG-1 (FIXED)** — Real scans/manual entry now populate the product index: `ProductIndexer.index(receipt:in:)` fetch-or-creates `Product`/`Brand` and appends `PricePoint`s on save, called from all 3 save sites. Index tab + price history work for real data. Compile-verified; unit tests added.
- **BUG-2 (FIXED)** — `AnalyticsView` now shows the real current month, a real month-over-month % change, and Item Watch driven by actual `Product` price history (`@Query` + `PricePoint`s). Hardcoded "MAR 2026" / "+12%" / sample rows removed; empty state added.
- **BUG-3 (FIXED)** — Scan save now prefers the proof-sheet `processor.total`/`merchantName` when the extractor returns empty/zero, preventing `$0.00`/UNKNOWN saves on regex fallback. Dead `DocumentScanProcessor.makeReceipt`/`decimal(from:)` removed.
- **BUG-4 (FIXED)** — All three `AnalyticsService` breakdowns now share one itemized (pre-tax) basis (`Σ item.totalPrice` grouped by category / brand / merchant), so they reconcile with each other; the headline `totalSpent` stays money-out (incl. tax), differing only by tax. `brandBreakdown` now keys off the indexed `item.product?.brand` identity, not free-text `item.brand`. Build-verified.
- **BUG-5 (FIXED)** — Regex parser now checks SUBTOTAL before TOTAL and matches `\bTAX\b` on a word boundary, so `SUBTOTAL`/`TAXI`/`GALAXY` no longer misclassify amounts.
- **BUG-6 (FIXED)** — `CSVExporter.isoDate` now uses UTC, matching its tz-independent contract.
- **BUG-7 (FIXED)** — `ProductIndexer.deindex(item:in:)` / `deindex(receipt:in:)` reverse `index(...)`: they delete the item's `PricePoint`s (no longer orphaned), recompute `Product.averagePrice`, and roll back `Brand.totalSpent`/`transactionCount`/`averageTransactionAmount` (clamped ≥ 0). Called before `modelContext.delete` at both delete sites (`ReceiptDetailView` `saveChanges` item-removal + whole-receipt delete). Code-only — the proper cascade/inverse (A6) + migration (A10) stay deferred. Build-verified; runtime-verified via the app path (unit test blocked by A11). _Out of scope (parking lot):_ a price/qty edit still doesn't update the existing `PricePoint`, and `brand.products` membership isn't pruned on delete.
- _Investigated, NOT a bug:_ audit claimed the Claude key is never persisted — false positive; `SettingsView.aiSection` calls `AIConfig.setClaudeAPIKey` in the key field's `.onChange`.

## Architecture / cleanliness (standing bar)
- **A1** `SpendingAnalytics` is a persisted `@Model` but is derived data → make it a plain `struct` returned by `AnalyticsService`.
- **A2** Errors swallowed with `print()` across services/views → user-facing alerts (= B3).
- **A3 (PARTIAL)** — `RegexReceiptParser` now has regression tests (SUBTOTAL / `\bTAX\b` / TOTAL — BUG-5), plus `AnalyticsService` breakdown-consistency tests (BUG-4) and a CSV UTC test (BUG-6); all container-free to dodge the A11 trap. A broader real-receipt corpus is still future.
- **A4** O(n) analytics aggregation + per-render recompute (`ReceiptListView.groupedReceipts`, `ItemAnalyticsView`) → cache / SwiftData predicate.
- **A5** Dead code: `DocumentScanProcessor.makeReceipt` + `decimal(from:)` in `ScanPOC_DocumentScanner` are superseded by `ExtractorCoordinator` — remove (folding into the BUG-3 fix).
- **A6** SwiftData relationships missing inverses/delete rules on `Product.priceHistory`, `Brand.products`, `PricePoint.*`, `ReceiptItem.product`, `BankTransaction.receipt` → orphans. Declare carefully (schema change → launch-test, likely needs A10).
- **A7 (FIXED)** — `KeychainStore.set`/`delete` now check `SecItem*` `OSStatus` and return `Bool`, and set `kSecAttrAccessibleAfterFirstUnlock` on write. `AIConfig.setClaudeAPIKey` propagates the result; Settings shows an inline "couldn't save the key" note on failure instead of dropping it silently.
- **A8 (FIXED)** — the canonical parse logic now lives in one place, `RegexReceiptParser`; `DocumentScanProcessor.parseBasicFields` and `RegexReceiptExtractor` both call it, so the proof preview reflects what's saved and there's no divergent total/price regex copy.
- **A9 (FIXED)** — parse logic extracted to the `nonisolated enum RegexReceiptParser`; `RegexReceiptExtractor` calls it directly (no more `await MainActor.run { ReceiptScannerService()... }`). `ReceiptScannerService` keeps a thin `nonisolated` shim plus its `@Published`/Vision surface as the only `@MainActor` parts.
- **A10** No `VersionedSchema`/migration plan (`grainApp` uses a bare `Schema`) — introduce before the A6 relationship changes and before real user data.
- **A11** The 3 `ProductIndexer` unit tests crash (signal trap) under the test host on SwiftData insert — a harness incompatibility, not a logic bug (the app + `DemoDataSeeder` run the same wire-before-insert ops fine). Disabled with a pointer. _Investigated on resume (2026-05-30):_ XCTest traps too (not Swift-Testing-specific); a **file-backed** temp store clears the *container-creation* trap, but the `ReceiptItem` relationship insert still traps in the test host. So the indexer + the BUG-7 de-index path are verified via build + review + the running app, not unit tests. **Web search (2026-05-31) — two leads for the proper fix (don't re-walk the brute-force path):** (a) a SwiftData/CoreData-reserved property/relationship name (the app already renames `description`→`productDescription`; check for another); (b) `@Model` insert running off the main actor under the test host — the app works because its container + inserts are main-actor on a real (non-memory) store. Quick next step: confirm the `grainTests` `TEST_HOST`/host-app setting and main-actor execution, or try the Swift Testing `.serialized` trait. **Also verify ProductIndexer dedup on a real device.**

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
- ✅ CSV export no longer regenerates per render — `SettingsView` caches the URL in `@State`, rebuilt only on appear / receipt-count change via `.task(id:)`. [Copilot review, PR #63]
- Mockup `screenshots/01-home.png` shows a top-right "filter" control not present in code (ghost affordance) — build it or drop it (designer M3).
- Scan-overlay lightbox (ReceiptDetailView) uses raw scrim/white colors — consider a `GrainTheme.scrim` token rather than a blind swap (polish builder note).
- Add a `ReceiptDetailView` #Preview with `needsReview = true` for visual QA of the flag marker.
- ✅ Editing an item now keeps the index in sync — `EditReceiptView.saveChanges` de-indexes any changed item and lets the trailing `index(...)` re-index it, so the `PricePoint` / `Brand` totals track price/qty/name/brand edits and the product re-resolves on rename. [Copilot review, PR #63]
- ✅ `ManualReceiptEntryView` (and `EditReceiptView`) now have per-item brand + category fields, so manual entries populate the Brands index and category analytics. [Copilot review, PR #63]
- Split view: let the first/last line center via half-viewport insets (review Med finding).
- Split view: persist OCR line bounding boxes at scan time so the view needn't re-run Vision.
- `SpendingAnalytics` is a persisted `@Model` but behaves like derived data → make it a plain `struct` (data-model hygiene).
- Verify real scans create `Product` / `Brand` / `PricePoint` (confirmed only for `DemoDataSeeder`); if not, wire product/brand indexing on save — this is core to the "granular" value prop.
- Remaining B3 scope: `AnalyticsService` fetch `catch`es still `print()` + return empty (degraded display, not data loss) — surface via a Result/throwing API + an error state in `AnalyticsView`. Also the CSV-export `try?` only shows a disabled-row reason; a tap-to-export flow with a modal alert would be better (ties to the computed-`exportCSVURL`-regenerates-every-render note above).
- Improve OCR (#4) is largely addressed by the hybrid extractor — review and rescope/close the issue.
- Repo-config issues (#41, #42) partially addressed (.mcp.json, skills, CONTRIBUTING) — reconcile/close.
