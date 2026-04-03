
```
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
  PROOF-OF-CONCEPT
  core scan + display flow: working
  tech debt + next steps: docs/Current-State.md
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
```

grain — local-first iOS receipt scanner. scan · parse · track · analyze.

<!-- dashboard-start -->
<table width="100%">
<tr valign="top">

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
- **Stay local-first** — all storage and processing on device. No cloud, no accounts.

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

## Status

Proof of concept. The core loop exists: scan, OCR, parse, save, browse, and analyze.

Biggest gaps to close for MVP: manual receipt entry, full edit flow from scan proof, receipt image persistence, stronger parser reliability, and better user-facing error states.

See [docs/Current-State.md](docs/Current-State.md) for the full assessment and MVP delta.

## Docs

- [Current State](docs/Current-State.md)
- [Redesign Spec](docs/Redesign-Spec.md)
- [Architecture Decisions](docs/adr/README.md)
- [Changelog](CHANGELOG.md)

## License

All rights reserved. See [LICENSE](LICENSE).
