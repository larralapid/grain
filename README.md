
```
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
                                             
  GRAIN  ·  receipt scanner + expense tracker for iOS
                                             
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
```



<!-- dashboard-start -->
<table width="100%">
<tr valign="top">

<td width="35%" align="center">

<table width="100%"><tr><td bgcolor="000000" align="center"><b><samp><font color="white">g&thinsp;r&thinsp;a&thinsp;i&thinsp;n</font></samp></b></td></tr></table>

<br />

<img src="screenshots/09-launch-screen.gif" width="140" alt="grain launch screen" />

<br /><br />

[![Build](https://github.com/larralapid/grain/actions/workflows/build.yml/badge.svg)](https://github.com/larralapid/grain/actions/workflows/build.yml)<br />
![iOS 17+](https://img.shields.io/badge/iOS-17%2B-000000?style=flat-square&logo=apple&logoColor=white)<br />
![Swift](https://img.shields.io/badge/Swift-5.9-F05138?style=flat-square&logo=swift&logoColor=white)<br />
![License](https://img.shields.io/badge/license-proprietary-333333?style=flat-square)<br />

<br />

<details>
<summary><sup>v0.1.0 · poc</sup></summary>
<br />
<samp>
scan → ocr → parse<br />
save → browse → analyze<br />
local-only · no cloud<br />
</samp>
</details>


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
</td>

<td width="65%">

<table width="100%">

<tr><td colspan="2" bgcolor="000000" align="center"><b><samp><font color="white">F&thinsp;L&thinsp;O&thinsp;W</font></samp></b></td></tr>
<tr><td colspan="2" align="center"><br /><samp><font color="888888">scan&thinsp;→&thinsp;ocr&thinsp;→&thinsp;parse&thinsp;→&thinsp;save&thinsp;→&thinsp;browse&thinsp;→&thinsp;analyze</font></samp><br /><br /></td></tr>

<tr>
<td width="50%" valign="top" bgcolor="0d0d0d">
<table width="100%"><tr><td bgcolor="000000"><b><samp><font color="white">D&thinsp;O&thinsp;C&thinsp;S</font></samp></b></td></tr></table>
|&thinsp;- <a href="docs/Current-State.md">current state</a><br />
|&thinsp;- <a href="docs/Redesign-Spec.md">redesign spec</a><br />
|&thinsp;- <a href="docs/adr/README.md#index">ADRs</a><br />
|&thinsp;- <a href="CHANGELOG.md">changelog</a><br />
</td>
<td width="50%" valign="top" bgcolor="0d0d0d">
<table width="100%"><tr><td bgcolor="000000"><b><samp><font color="white">N&thinsp;A&thinsp;V</font></samp></b></td></tr></table>
|&thinsp;- <a href="#what-it-does">what it does</a><br />
|&thinsp;- <a href="#stack">stack</a><br />
|&thinsp;- <a href="#run-locally">run locally</a><br />
|&thinsp;- <a href="#status">status</a><br />
</td>
</tr>

<tr><td colspan="2" bgcolor="000000" align="center"><b><samp><font color="white">N&thinsp;O&thinsp;T&thinsp;E&thinsp;S</font></samp></b></td></tr>

<tr>
<td bgcolor="0d0d0d" valign="top">
<samp><font color="555555">→&thinsp;</font></samp><a href="docs/Current-State.md"><samp>mvp delta</samp></a><br />
<sup><font color="555555">parser · errors · images · edit</font></sup>
</td>
<td bgcolor="0d0d0d" valign="top">
<samp><font color="555555">→&thinsp;</font></samp><a href="docs/adr/README.md#index"><samp>arch decisions</samp></a><br />
<sup><font color="555555">5 adrs · zero deps · local-only</font></sup>
</td>
</tr>
<tr>
<td bgcolor="0d0d0d" valign="top">
<samp><font color="555555">→&thinsp;</font></samp><a href="CHANGELOG.md"><samp>changelog</samp></a><br />
<sup><font color="555555">v0.1.0 · poc · notifications</font></sup>
</td>
<td bgcolor="0d0d0d" valign="top">
<samp><font color="555555">→&thinsp;</font></samp><a href="docs/Redesign-Spec.md"><samp>redesign spec</samp></a><br />
<sup><font color="555555">typography · tokens · wireframes</font></sup>
</td>
</tr>

</table>

</td>

</tr>
</table>
<!-- dashboard-end -->

***

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
│  ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄    │   │  Olive Oil       $12.49 │
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

Build the `grain` target in Xcode and run on an iOS 17+ simulator or device.

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

## ◈ LICENSE

All rights reserved. See [LICENSE](LICENSE).
