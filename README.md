# grain

[![Build](https://github.com/larralapid/grain/actions/workflows/build.yml/badge.svg)](https://github.com/larralapid/grain/actions/workflows/build.yml)

**who gets paid when you buy things.**

grain is a native iOS receipt scanner and expense tracker that turns paper receipts into searchable, product-level spending data. It scans receipts with on-device OCR, tracks spend by store, brand, category, and product, and surfaces price history across purchases.

<!-- dashboard-start -->
<table><tr valign="top">
<td width="38%">

<details><summary><ins><b>P&thinsp;r&thinsp;o&thinsp;d&thinsp;u&thinsp;c&thinsp;t&thinsp;&amp;&thinsp;F&thinsp;l&thinsp;o&thinsp;w&thinsp;s</b></ins></summary>

|&thinsp;-&thinsp; <a href="screenshots/01-home.png">Receipt&thinsp;home</a><br />
|&thinsp;-&thinsp; <a href="screenshots/04-proof.png">Scan&thinsp;proof</a><br />
|&thinsp;-&thinsp; <a href="screenshots/05-analytics.png">Analytics</a><br />
|&thinsp;-&thinsp; <a href="screenshots/07-index.png">Product&thinsp;index</a><br />

</details>

<details><summary><ins><b>D&thinsp;o&thinsp;c&thinsp;s&thinsp;&amp;&thinsp;A&thinsp;r&thinsp;c&thinsp;h</b></ins></summary>

|&thinsp;-&thinsp; <a href="docs/Current-State.md">Current&thinsp;state</a><br />
|&thinsp;-&thinsp; <a href="docs/Redesign-Spec.md">Redesign&thinsp;spec</a><br />
|&thinsp;-&thinsp; <a href="docs/adr/README.md#index">ADRs</a><br />
|&thinsp;-&thinsp; <a href="CHANGELOG.md">Changelog</a><br />

</details>

◾ <b><samp>B&thinsp;u&thinsp;i&thinsp;l&thinsp;d&thinsp;&amp;&thinsp;Q&thinsp;u&thinsp;a&thinsp;l&thinsp;i&thinsp;t&thinsp;y</samp></b><br />
|&thinsp;- <a href="#run-locally">Run&thinsp;locally</a><br />
|&thinsp;- <a href="https://github.com/larralapid/grain/actions/workflows/build.yml">CI&thinsp;workflow</a><br />
|&thinsp;- <a href="#stack">Stack</a><br />
|&thinsp;- <a href="#status">Status</a><br />

</td>
<td width="62%">

<table>
<tr align="center">
<td>
  <a href="screenshots/01-home.png">
    <img src="screenshots/01-home.png" alt="Home — receipt list with monthly summary" width="200" />
    <br /><b>H&thinsp;O&thinsp;M&thinsp;E</b>
  </a>
</td>
<td>
  <a href="screenshots/03-scan.png">
    <img src="screenshots/03-scan.png" alt="Scan — camera viewfinder with alignment guide" width="200" />
    <br /><b>S&thinsp;C&thinsp;A&thinsp;N</b>
  </a>
</td>
</tr>
<tr></tr>
<tr align="center">
<td>
  <a href="screenshots/05-analytics.png">
    <img src="screenshots/05-analytics.png" alt="Analytics — category and store spending charts" width="200" />
    <br /><b>A&thinsp;N&thinsp;A&thinsp;L&thinsp;Y&thinsp;T&thinsp;I&thinsp;C&thinsp;S</b>
  </a>
</td>
<td>
  <a href="screenshots/07-index.png">
    <img src="screenshots/07-index.png" alt="Index — product catalog with average prices" width="200" />
    <br /><b>I&thinsp;N&thinsp;D&thinsp;E&thinsp;X</b>
  </a>
</td>
</tr>
</table>

</td>
</tr></table>
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
