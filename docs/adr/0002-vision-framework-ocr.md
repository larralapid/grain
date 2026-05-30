# ADR-0002: Use Apple Vision framework for on-device OCR

**Date**: 2025  
**Status**: Accepted

## Context

Receipt scanning requires converting a photo of a receipt into structured data (merchant, date, line items, totals). The main approaches considered:

- **Apple Vision + VisionKit** — on-device, free, private, no network required
- **Google Cloud Vision / AWS Textract** — high-accuracy server-side OCR, paid, requires network
- **OpenAI Vision API** — LLM-powered structured extraction, higher quality, paid, requires network
- **Tesseract (open source)** — self-hosted OCR, free, would add an external dependency

Privacy is a core product value ("all data stored locally"). Sending receipt photos to a third-party server conflicts with that value and adds cost and latency.

## Decision

Use **Apple Vision** (`VNRecognizeTextRequest`) for text extraction and implement a custom regex-based parser (`ReceiptScannerService`) to structure the raw text into receipt fields.

## Consequences

**Easier**
- Fully on-device — no network, no cost, no privacy concerns.
- Works offline.
- Zero external dependencies maintained.

**Harder**
- Vision produces raw text blocks; the structuring logic (regex parser) is entirely custom and fragile.
- Accuracy on low-quality photos or unusual receipt layouts will be lower than cloud alternatives.
- Complex receipt formats (weight-based items, multi-currency, tips, BOGO) require significant parser investment.
- No semantic understanding of receipt structure — the parser cannot reason about context.

## Notes

The current `parseReceiptFromText()` implementation is a proof-of-concept. A future ADR should address whether to replace or augment it with `DataScannerViewController` (Live Text) or a local ML model.
