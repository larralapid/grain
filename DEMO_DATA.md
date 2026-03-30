# Demo Data

`DemoDataSeeder` populates the app with 10 recent receipts when the SwiftData store is empty. The fixtures are intentionally centralized so app startup, previews, and tests all use the same dataset.

## Current state

These receipts are placeholder fixtures. This coding session could not access your Apple Photos library directly, so the seed data was added from in-repo templates rather than your last 10 receipt screenshots.

## Where it lives

- App seeding: `grain/Services/DemoDataSeeder.swift`
- Startup hook: `grain/Views/MainTabView.swift`
- Preview hook: `grain/Views/ReceiptListView.swift`
- Tests: `grainTests/grainTests.swift`

## Refresh with your real screenshots

1. Export the 10 receipt screenshots from Photos into the repo, for example under `grain/Fixtures/Receipts/`.
2. Replace the sample templates in `DemoReceiptTemplate.samples(referenceDate:)` with the real merchant, item, subtotal, tax, and total values from those screenshots.
3. If you want scan-regression coverage, keep the screenshot text in `ocrText` so parser and UI tests can assert against a known source document.
4. Run tests again to confirm the seeded count and fixture integrity still hold.
