# ADR-0007: Hybrid AI receipt extraction (on-device default, opt-in Claude)

**Date**: 2026-05-30  
**Status**: Accepted (amends ADR-0003 and ADR-0005)

## Context

The regex receipt parser is proof-of-concept quality and frequently mis-parses real receipts. The failure is in **parsing** (turning OCR text into structured fields), not in Vision text recognition. We need (a) materially better extraction and (b) a user-facing way to report and correct errors that also feeds future improvement.

Three credible directions for the engine were considered:

- **On-device Foundation Models (iOS 26 / Apple Intelligence)** — structured guided generation, no key, no cost, fully private.
- **Cloud LLM (Anthropic Claude)** — highest accuracy, but adds a network/service dependency and data egress.
- **Hardened regex** — incremental, lowest effort.

A hard constraint shaped the design: **Anthropic prohibits third-party apps from using a user's Claude Pro/Max/Free _subscription_ (OAuth)** — it is a Consumer Terms of Service violation and is actively enforced. The only supported way for a third-party app to call Claude is an **API key** (Anthropic Console) or a supported cloud provider. A "Connect your Claude subscription" flow is therefore not viable.

ADR-0003 (zero external dependencies) and ADR-0005 (local-only storage) both assume nothing leaves the device.

## Decision

Adopt a **hybrid, on-device-first** strategy. A runtime coordinator (`ExtractorCoordinator`) selects the best available tier per user settings and device capability:

1. **Claude** (`ClaudeReceiptExtractor`) — only when the user has opted in *and* supplied **their own API key** (stored in the Keychain). Sends the receipt image + OCR text to the Anthropic Messages API using forced tool-use for structured output, with prompt caching.
2. **On-device** (`OnDeviceReceiptExtractor`) — the default on iOS 26 + Apple Intelligence, via Foundation Models guided generation (`@Generable`). No key, no cost, nothing leaves the device.
3. **Regex** (`RegexReceiptExtractor`) — universal fallback (older OS, model unavailable, offline, or API error).

A **Flag → Review Queue** flow lets users mark a receipt incorrect and edit every field — merchant, totals, and line items. The pre-edit extraction is stored (`Receipt.originalExtractionJSON`, `extractionSource`) so corrections can later seed regression tests and few-shot examples — the improvement loop.

## Consequences

**Easier**
- Far better extraction than regex, with the default tier staying fully on-device (no key, no cost, private).
- The baseline path still honors ADR-0003 and ADR-0005; only the opt-in Claude tier changes that, and only with the user's own key + consent.
- A genuine feedback/improvement loop (corrections → corpus).

**Harder**
- The Claude tier adds a network/service dependency and **data egress** of receipt image + text. Mitigated: opt-in only, the user's own key, regex fallback when off, and Anthropic does not train on API inputs.
- Shipping a provider key in an App Store binary is unsafe; the PoC uses a user-supplied key. Production should move to a backend proxy.
- Foundation Models requires iOS 26 + an Apple Intelligence-capable device; gated with `#available` + availability checks.

## Amends

- **ADR-0003 (zero external dependencies)** — still no SwiftPM packages, but the optional Claude tier adds an external *service* dependency.
- **ADR-0005 (local-only storage)** — local-only remains the default; the opt-in Claude tier sends data off-device with consent.

## Future

- Replace the BYO-key model with a backend proxy (grain-funded tier) for a frictionless default.
- Use captured corrections as a regression corpus + few-shot examples; track extraction accuracy as a metric.
