# GRAIN

[![Build](https://github.com/larralapid/grain/actions/workflows/build.yml/badge.svg)](https://github.com/larralapid/grain/actions/workflows/build.yml)

```
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
  GRAIN  ·  receipt scanner + expense tracker for iOS
  on-device OCR  ·  zero dependencies  ·  local-only storage
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
```

---

## ◈ WHAT IT DOES

```
┌──────────────────────────────────────────────────────────────┐
│  SCAN      photograph a receipt → extract merchant,          │
│            items, prices, tax via Vision OCR.                │
│            all processing on-device.                         │
├──────────────────────────────────────────────────────────────┤
│  TRACK     monthly totals, category breakdowns               │
│            (groceries · home · health · dining · transport)  │
│            and store-level spend.                            │
├──────────────────────────────────────────────────────────────┤
│  WATCH     price history and trends for individual           │
│            products across every purchase.                   │
├──────────────────────────────────────────────────────────────┤
│  INDEX     browse all products, brands, and retailers        │
│            extracted from your receipts.                     │
└──────────────────────────────────────────────────────────────┘
```

---

## ◈ STACK

| LAYER        | TECH                                          |
|--------------|-----------------------------------------------|
| UI           | SwiftUI · monospace brutalist (`GrainTheme`)  |
| DATA         | SwiftData — 7 model types                     |
| OCR          | Apple Vision framework                        |
| CHARTS       | Swift Charts                                  |
| STORAGE      | Local-only · on-device                        |
| DEPENDENCIES | Zero — Apple frameworks only                  |

`iOS 17.0+` · `Swift 5.9+` · `Xcode 15+`

---

## ◈ SCREENS

```
┌─────────────────────────┐   ┌─────────────────────────┐
│  HOME                   │   │  DETAIL                 │
│  ─────────────────────  │   │  ─────────────────────  │
│  March 2026             │   │  Corner Market          │
│                         │   │  Mar 22, 2026           │
│         $482.14         │   │                         │
│                         │   │  Oat Milk         $4.79 │
│  RECENT                 │   │  Paper Towels     $8.29 │
│  ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄  │   │  Olive Oil       $12.49 │
│  Corner Market  $42.90  │   │  ────────────────────── │
│  CVS Pharmacy   $18.12  │   │  SUBTOTAL        $25.57 │
│  Whole Foods    $67.34  │   │  TAX              $2.05 │
│                         │   │  TOTAL           $27.62 │
│  receipts  scan  index  │   │                         │
└─────────────────────────┘   └─────────────────────────┘

┌─────────────────────────┐   ┌─────────────────────────┐
│  SCAN                   │   │  ANALYTICS              │
│  ─────────────────────  │   │  ─────────────────────  │
│                         │   │  $482.14                │
│   ┌───────────────────┐ │   │  this month             │
│   │                   │ │   │                         │
│   │   [ receipt  ]    │ │   │  groceries  ████░  72%  │
│   │                   │ │   │  health     ██░░░  11%  │
│   └───────────────────┘ │   │  home       █░░░░   9%  │
│                         │   │  dining     █░░░░   8%  │
│         [ SCAN ]        │   │                         │
│                         │   │  PRICE WATCH            │
│                         │   │  Oat Milk    avg $4.50↑ │
└─────────────────────────┘   └─────────────────────────┘
```

| #  | SCREEN                                          | DESCRIPTION                                     |
|----|------------------------------------------------|--------------------------------------------------|
| 01 | [Home](screenshots/01-home.png)                | Receipt list with monthly spending summary       |
| 02 | [Detail](screenshots/02-detail.png)            | Receipt breakdown: items, brands, totals         |
| 03 | [Scan](screenshots/03-scan.png)                | Camera viewfinder with alignment guide           |
| 04 | [Proof](screenshots/04-proof.png)              | Thermal receipt preview after OCR                |
| 05 | [Spending](screenshots/05-analytics.png)       | Category and store spending charts               |
| 06 | [Item Watch](screenshots/06-itemwatch.png)     | Price tracking across purchases                  |
| 07 | [Index](screenshots/07-index.png)              | Product catalog with average prices              |
| 08 | [Retailers](screenshots/08-retailers.png)      | Retailer directory by total spend                |

---

## ◈ RUN

```sh
open grain.xcodeproj
```

Build target `grain`, run on simulator or device.

---

## ◈ DOCS

```
┌──────────────────────────────────────────────────────────────┐
│  docs/Current-State.md      architecture audit               │
│  docs/Redesign-Spec.md      design system + wireframes       │
│  docs/adr/README.md         architecture decision records    │
│  CHANGELOG.md               release history                  │
└──────────────────────────────────────────────────────────────┘
```

- [Current State](docs/Current-State.md)
- [Redesign Spec](docs/Redesign-Spec.md)
- [Architecture Decisions](docs/adr/README.md)
- [Changelog](CHANGELOG.md)

---

## ◈ STATUS

```
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
  PROOF-OF-CONCEPT
  core scan + display flow: working
  tech debt + next steps: docs/Current-State.md
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
```

---

## ◈ LICENSE

All rights reserved. See [LICENSE](LICENSE).
