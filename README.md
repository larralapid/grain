# grain

**who gets paid when you buy things.**

Receipt scanner and expense tracker for iOS. Scans paper receipts with on-device OCR, tracks spending at the product and brand level, and shows you where your money actually goes.

<p align="center">
  <img src="screenshots/01-home.png" width="180" />
  <img src="screenshots/02-detail.png" width="180" />
  <img src="screenshots/03-scan.png" width="180" />
  <img src="screenshots/05-analytics.png" width="180" />
</p>

## What it does

- **Scan receipts** — photograph a paper receipt and extract merchant, items, prices, tax via Vision framework OCR. All processing on-device.
- **Track spending** — monthly totals, category breakdowns (groceries, home, health, dining, transport), and store-level spend.
- **Watch item prices** — see price history and trends for individual products across purchases.
- **Index everything** — browse all products, brands, and retailers extracted from your receipts.

## Stack

| Layer | Tech |
|-------|------|
| UI | SwiftUI, monospace brutalist design system (`GrainTheme`) |
| Data | SwiftData (7 model types) |
| OCR | Apple Vision framework |
| Charts | Swift Charts |
| Storage | Local-only, on-device |
| Dependencies | Zero — Apple frameworks only |

iOS 17.0+ &middot; Swift 5.9+ &middot; Xcode 15+

## Run

```
open grain.xcodeproj
```

Build target `grain`, run on simulator or device.

## Screens

| # | Screen | Description |
|---|--------|-------------|
| 01 | [Home](screenshots/01-home.png) | Receipt list with monthly spending summary |
| 02 | [Detail](screenshots/02-detail.png) | Receipt breakdown: items, brands, totals |
| 03 | [Scan](screenshots/03-scan.png) | Camera viewfinder with alignment guide |
| 04 | [Proof](screenshots/04-proof.png) | Thermal receipt preview after OCR |
| 05 | [Spending](screenshots/05-analytics.png) | Category and store spending charts |
| 06 | [Item Watch](screenshots/06-itemwatch.png) | Price tracking across purchases |
| 07 | [Index](screenshots/07-index.png) | Product catalog with average prices |
| 08 | [Retailers](screenshots/08-retailers.png) | Retailer directory by total spend |

## Docs

- [Current State](docs/Current-State.md) — architecture audit
- [Redesign Spec](docs/Redesign-Spec.md) — design system and wireframes
- [Architecture Decisions](docs/adr/README.md) — ADR index
- [Changelog](CHANGELOG.md)

## Status

Proof-of-concept. Core scanning and display flow works. See [Current State](docs/Current-State.md) for known tech debt and next steps.

## License

All rights reserved. See [LICENSE](LICENSE).
