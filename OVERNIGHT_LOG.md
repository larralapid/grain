# Overnight Autonomous Session — 2026-05-30

Branch: `auto/overnight-2026-05-30` (off `main` @ `cc8b1d2`). Driver: Claude (Opus 4.8), orchestrating builder / tester / reviewer / designer subagents while the user sleeps.

## Operating rules
- **Branch-only.** All work commits to `auto/overnight-2026-05-30`. No push, no PRs, no changes to `main` without explicit authorization.
- **Atomic commits.** One backlog item per commit, each independently revertible.
- **Verify before commit.** Every code item must `BUILD SUCCEEDED` + unit tests green, and pass a review pass, before it's committed.
- **Safe scope.** Local, additive, demo-strengthening work only. No backend, no destructive ops, no secrets. Skip or defer anything risky and log it.
- **Dispatch.** Milestone updates sent via PushNotification (phone). This log is the durable record.

## Backlog (prioritized)
| # | Item | Issue | Owner | Status |
|---|------|-------|-------|--------|
| 1 | Manual receipt entry — wire "+" on receipts list to a form | #58 #3 | builder | done |
| 2 | Data export (CSV) from Settings → share sheet | #5 #26 | builder | pending |
| 3 | Replace `print()` error-swallowing with user-facing alerts | #58 | builder | pending |
| 4 | "Flagged for review" badge in ReceiptDetailView | review | inline | pending |
| 5 | Remove unused template files (ContentView/Item) | hygiene | inline | done — files already absent |
| 6 | Info.plist `ITSAppUsesNonExemptEncryption = NO` (TestFlight) | follow-up | inline | pending |
| 7 | AnalyticsService + parser regression tests | #58 | builder | pending |
| 8 | CONTRIBUTING.md + docs/context.md | #43 #44 | inline | done |
| 9 | Targeted UI polish + pitch screenshots | #7 | designer | pending |
| 10 | Attach sample images to seeded demo receipts (split-view demo) | demo | builder | pending |

## Progress log
- **start** — committed session work to `main` (`cc8b1d2`: hybrid AI extraction, split proof view, correction flow). Branched, wrote this plan.
- **item 5 (done)** — verified `ContentView.swift`/`Item.swift` no longer exist; nothing to remove.
- **item 1 (done)** — manual receipt entry: `+ add` in the receipts header opens `ManualReceiptEntryView` (Form, line items, totals); `extractionSource="manual"`. Build green.
- **item 8 (done)** — wrote `CONTRIBUTING.md` (#43) and `docs/context.md` (#44) in parallel while builder #1 ran.
- **process** — added `docs/ROADMAP.md` (plan of record + backlog + parking lot). Discoveries captured there, not acted on out of scope.
- **B2 (done)** — CSV data export: `CSVExporter` (RFC-4180 escaping, locale-independent money/dates) + Settings `ShareLink` row. Build green.
- **design plan (received)** — designer subagent returned a prioritized UI-polish plan; captured in ROADMAP. Implementing the **Top 5** next (contrast/hierarchy, flag marker, proof-view discoverability); rest parked.
- **B6 (done)** — UI polish Top 5: hero-total weight, dark-mode contrast (textSecondary 0.48 / dateHeader 0.34), greys→tokens, `needs review` markers, "proof" promoted to first menu item. Build green. Logged BUG-2 (analytics placeholders) + scrim-token idea.
- **bug/arch audit** — confirmed BUG-1 (no product indexing on real saves) + found BUG-3..7, A6..A10. SpendingAnalytics suspected then cleared (the verify gate caught a wrong hypothesis).
- **stall (~18h)** — an `xcodebuild test` run deadlocked building the UI-test bundle and hung ~17.75h, blocking the loop; killed on resume (this was the "1065 min" task).
- **BUG-1 + BUG-3 (fixed)** — `ProductIndexer` indexes products/brands/price-points at every save site; scan save prefers proof-sheet values (no `$0`); dead code removed. Compile-verified; indexer unit tests added (fixed an insert-order test-helper crash).
- **resume (2026-05-30)** — re-established baseline (`BUILD SUCCEEDED`), wrote + got approval on a plan for the remaining queue (BUG-4, BUG-7, B9, B3, A7, A8/A9, B5; A1/A6/A10 deferred as schema-risky).
- **BUG-4 (fixed)** — unified all three analytics breakdowns onto one itemized (pre-tax) basis so the category/store charts reconcile; brand breakdown keys off the indexed `item.product?.brand` identity. Headline total stays money-out (incl. tax). Build green.
- **BUG-7 (fixed)** — `ProductIndexer.deindex` reverses indexing on delete (removes the item's PricePoint, recomputes the product average, rolls back Brand stats); wired into both delete sites in `ReceiptDetailView`. Code-only (A6/A10 cascade+migration stay deferred). Build green. A11 dug into: file-backed test store clears the container trap but the relationship insert still traps the test host (same ops work in-app), so verified via build+review+app, not unit tests.
- **B9 (done)** — `grain/Info.plist` now sets `ITSAppUsesNonExemptEncryption = false`, removing the encryption-compliance prompt on every TestFlight upload. Build green.
- **B3 (done — save paths)** — manual entry + receipt edit now surface save failures via an alert and keep the form open (no more silent `print()` + phantom dismiss); the Export row reports a write failure honestly. Remaining `print()`s are the AnalyticsService fetch paths (degraded display, parked). Build green.
- **A7 (done)** — `KeychainStore` checks `OSStatus` + sets `kSecAttrAccessibleAfterFirstUnlock`, returns `Bool`; `AIConfig.setClaudeAPIKey` propagates it; Settings shows an inline keychain-save-failure note. Build green.
- **A8 + A9 (done)** — extracted `RegexReceiptParser` (nonisolated, single source of truth); `RegexReceiptExtractor` now calls it directly (dropped the `MainActor.run` hop + service instantiation) and `DocumentScanProcessor.parseBasicFields` reuses it (no duplicate regex). Build green; OCR-parser + extraction tests pass (5/5, no ModelContainer so no A11 trap).
- **B5 (done)** — added container-free regression tests (5/5 pass): `AnalyticsService` breakdown consistency + brand keying (BUG-4), `RegexReceiptParser` SUBTOTAL/`\bTAX\b`/TOTAL (BUG-5), `CSVExporter` UTC date (BUG-6). Made the breakdown helpers `static` for testability. Dodges A11 by never inserting into a `ModelContainer`. A3 partially addressed.
- **B8 (done)** — new `ReceiptImageRenderer` renders each seeded demo receipt to a thermal-slip JPEG (`ImageRenderer`, monospace black-on-white, no bundled assets) and `DemoDataSeeder` sets `imageData`. The proof / split / scan-overlay views now show a real image for demo data, and because the render is clean text Vision re-OCRs it so the split-view line cursor works. DEBUG-only seeding, so Release/TestFlight is unaffected. Build green.
- **resume session complete (initial 7)** — 7 commits landed (BUG-4, BUG-7, B9, B3, A7, A8+A9, B5); branch now 19 ahead of `main`. Final gate: full `grainTests` suite green (34 passed / 0 failed / 3 skipped = the A11-blocked indexer tests). **Deferred (documented):** A1 (`SpendingAnalytics`→struct), A6 + A10 (relationship delete-rules + schema migration) — all schema-touching, need a launch test; B7/B8 (demo screenshots + sample images) need the user. No push, no PR — awaiting review.
