# Grain — Granular Expense Tracking (Context)

This document explains *what makes grain different* and the data model that supports it — long-term context for contributors and agents.

## The core idea

Most expense trackers stop at the transaction: "$84.21 at Costco." Grain goes one level deeper — it captures **what was actually bought**, at the **individual product and brand level**, straight from the receipt. That granularity is the product's reason to exist. It enables questions like:

- "How much did I spend on oat milk this year?"
- "Is Trader Joe's or Whole Foods cheaper for the same items?"
- "What's the price history of this specific product across stores?"

## How data flows

1. **Capture** — a receipt is scanned (VisionKit document camera / photo import) or entered manually.
2. **Recognize** — Apple Vision OCR turns the image into text lines.
3. **Extract** — the text (+ image) becomes a structured `Receipt` with line items, via a tiered extractor: on-device Foundation Models by default, an opt-in Claude tier, regex fallback ([ADR-0007](adr/0007-hybrid-ai-extraction.md)).
4. **Index** — each `ReceiptItem` is associated with a `Product` and `Brand`; each purchase appends a `PricePoint` to that product's price history.
5. **Analyze** — `AnalyticsService` aggregates spending by category, brand, and merchant, and surfaces per-product price trends.

## The data model (granularity lives here)

- **Receipt** — one purchase: merchant, date, subtotal/tax/total, the scanned image + OCR text, and a `[ReceiptItem]` (cascade-deleted with the receipt).
- **ReceiptItem** — one line on a receipt: name, quantity, unit/total price, optional brand/category. Links back to its `Receipt` and (when indexed) to a `Product`.
- **Product** — a distinct item identity (name + brand + category) with a `priceHistory: [PricePoint]` and a rolling average price. This is what lets grain track the *same* product over time and across stores.
- **PricePoint** — a single observed price for a product (price, date, merchant), linked to the `ReceiptItem` it came from.
- **Brand** — aggregate spend and transaction stats per brand, plus its products.
- **BankTransaction** — model present; import/matching flow not yet built — intended for reconciling receipts against bank activity.

## Why it's built this way

- **On-device & private by default** (ADR-0001/0002/0005): scanning, OCR, and the baseline AI extraction all run locally; receipt data does not leave the device unless the user opts into the Claude tier with their own API key.
- **The product / price-history layer is the moat.** Value compounds as more receipts are scanned — price trends, cross-store comparisons, and brand-level insight all derive from accumulating `PricePoint`s against stable `Product` identities.
- **Correction feeds improvement.** Users can flag and correct mis-extracted receipts; the pre-correction extraction is retained as an eval/regression corpus to improve accuracy over time.
