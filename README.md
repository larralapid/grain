# grain

[![Build](https://github.com/larralapid/grain/actions/workflows/build.yml/badge.svg)](https://github.com/larralapid/grain/actions/workflows/build.yml)

grain is a local-first iOS receipt scanner that turns paper receipts into searchable, product-level spending data.

<!-- dashboard-start -->
<table>
<tr valign="top">
<td width="34%">

<b><code>NAV</code></b><br />
|&thinsp;- <a href="#what-it-does">What it does</a><br />
|&thinsp;- <a href="#stack">Stack</a><br />
|&thinsp;- <a href="#run-locally">Run locally</a><br />
|&thinsp;- <a href="#screens">Screens</a><br />
|&thinsp;- <a href="#status">Status</a><br />

<br />

<b><code>DOCS</code></b><br />
|&thinsp;- <a href="docs/Current-State.md">Current state</a><br />
|&thinsp;- <a href="docs/Redesign-Spec.md">Redesign spec</a><br />
|&thinsp;- <a href="docs/adr/README.md#index">ADRs</a><br />
|&thinsp;- <a href="CHANGELOG.md">Changelog</a><br />

</td>
<td width="33%" align="center">
  <a href="#what-it-does"><b><code>PRODUCT</code></b></a><br />
  Scan receipts<br />
  Track spending<br />
  Watch prices
</td>
<td width="33%" align="center">
  <a href="docs/Current-State.md"><b><code>STATE</code></b></a><br />
  POC core working<br />
  MVP gaps tracked<br />
  Next steps documented
</td>
</tr>
<tr>
<td align="center">
  <a href="#run-locally"><b><code>BUILD</code></b></a><br />
  SwiftUI<br />
  SwiftData<br />
  Vision
</td>
<td align="center">
  <a href="#screens"><b><code>SCREENS</code></b></a><br />
  Home<br />
  Scan<br />
  Analytics
</td>
<td align="center">
  <a href="docs/adr/README.md#index"><b><code>ARCH</code></b></a><br />
  ADRs<br />
  Local-only storage<br />
  Apple frameworks only
</td>
</tr>
</table>
<!-- dashboard-end -->

***

## What it does

- **Scan receipts** — photograph a paper receipt and extract merchant, items, prices, and tax with Apple Vision OCR.
- **Track spending** — view totals and breakdowns by category, merchant, and brand.
- **Watch prices** — see item-level price history across purchases.
- **Index entities** — browse products, brands, and retailers pulled from receipt data.
- **Stay local-first** — keep storage and processing on device.

## Stack

| Layer | Tech |
|---|---|
| UI | SwiftUI |
| Data | SwiftData |
| OCR | Apple Vision |
| Charts | Swift Charts |
| Storage | Local-only |
| Dependencies | Apple frameworks only |

iOS 17+ · Swift 5.9+ · Xcode 15+

## Run locally

```bash
git clone https://github.com/larralapid/grain.git
cd grain
open grain.xcodeproj
```

Build the `grain` target in Xcode and run on an iOS 17+ simulator or device.

## Screens

| # | Screen | Description |
|---|---|---|
| 01 | [Home](screenshots/01-home.png) | Receipt list with monthly spend summary |
| 02 | [Detail](screenshots/02-detail.png) | Receipt breakdown: items, brands, totals |
| 03 | [Scan](screenshots/03-scan.png) | Camera viewfinder with alignment guide |
| 04 | [Proof](screenshots/04-proof.png) | Thermal receipt preview after OCR |
| 05 | [Spending](screenshots/05-analytics.png) | Category and store charts |
| 06 | [Item Watch](screenshots/06-itemwatch.png) | Product price tracking |
| 07 | [Index](screenshots/07-index.png) | Product catalog |
| 08 | [Retailers](screenshots/08-retailers.png) | Retailer directory by spend |

## Status

Proof of concept.

The core loop exists: scan, OCR, parse, save, browse, and analyze. The biggest gaps to close for MVP are manual receipt entry, full edit flow from scan proof, receipt image persistence, stronger parser reliability, and better user-facing error states.

See [docs/Current-State.md](docs/Current-State.md) for the full assessment and MVP delta.

## Docs

- [Current State](docs/Current-State.md)
- [Redesign Spec](docs/Redesign-Spec.md)
- [Architecture Decisions](docs/adr/README.md)
- [Changelog](CHANGELOG.md)

## License

All rights reserved. See [LICENSE](LICENSE).
