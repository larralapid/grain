
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
<table>
<tbody><tr valign="top">
<td width="35%" align="center">

<br>
<animated-image data-catalyst="" style="width: 140px;"><a target="_blank" rel="noopener noreferrer" href="/larralapid/grain/blob/copilot/update-readme-dashboard-layout/screenshots/09-launch-screen.gif" data-target="animated-image.originalLink"><img src="/larralapid/grain/raw/copilot/update-readme-dashboard-layout/screenshots/09-launch-screen.gif" alt="grain launch screen" style="max-width: 100%; display: inline-block;" data-target="animated-image.originalImage"></a>
      <span class="AnimatedImagePlayer" data-target="animated-image.player" hidden="">
        <a data-target="animated-image.replacedLink" class="AnimatedImagePlayer-images" href="https://github.com/larralapid/grain/blob/copilot/update-readme-dashboard-layout/screenshots/09-launch-screen.gif" target="_blank">
          
        <span data-target="animated-image.imageContainer">
            <img data-target="animated-image.replacedImage" alt="grain launch screen" class="AnimatedImagePlayer-animatedImage" src="https://github.com/larralapid/grain/raw/copilot/update-readme-dashboard-layout/screenshots/09-launch-screen.gif" style="display: block; opacity: 1;">
          <canvas class="AnimatedImagePlayer-stillImage" aria-hidden="true" width="140" height="304"></canvas></span></a>
        <button data-target="animated-image.imageButton" class="AnimatedImagePlayer-images" tabindex="-1" aria-label="Play grain launch screen" hidden=""></button>
        <span class="AnimatedImagePlayer-controls" data-target="animated-image.controls" hidden="">
          <button data-target="animated-image.playButton" class="AnimatedImagePlayer-button" aria-label="Play grain launch screen">
            <svg aria-hidden="true" focusable="false" class="octicon icon-play" width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M4 13.5427V2.45734C4 1.82607 4.69692 1.4435 5.2295 1.78241L13.9394 7.32507C14.4334 7.63943 14.4334 8.36057 13.9394 8.67493L5.2295 14.2176C4.69692 14.5565 4 14.1739 4 13.5427Z">
            </path></svg>
            <svg aria-hidden="true" focusable="false" class="octicon icon-pause" width="16" height="16" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg">
              <rect x="4" y="2" width="3" height="12" rx="1"></rect>
              <rect x="9" y="2" width="3" height="12" rx="1"></rect>
            </svg>
          </button>
          <a data-target="animated-image.openButton" aria-label="Open grain launch screen in new window" class="AnimatedImagePlayer-button" href="https://github.com/larralapid/grain/blob/copilot/update-readme-dashboard-layout/screenshots/09-launch-screen.gif" target="_blank">
            <svg aria-hidden="true" class="octicon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" width="16" height="16">
              <path fill-rule="evenodd" d="M10.604 1h4.146a.25.25 0 01.25.25v4.146a.25.25 0 01-.427.177L13.03 4.03 9.28 7.78a.75.75 0 01-1.06-1.06l3.75-3.75-1.543-1.543A.25.25 0 0110.604 1zM3.75 2A1.75 1.75 0 002 3.75v8.5c0 .966.784 1.75 1.75 1.75h8.5A1.75 1.75 0 0014 12.25v-3.5a.75.75 0 00-1.5 0v3.5a.25.25 0 01-.25.25h-8.5a.25.25 0 01-.25-.25v-8.5a.25.25 0 01.25-.25h3.5a.75.75 0 000-1.5h-3.5z"></path>
            </svg>
          </a>
        </span>
      </span></animated-image>
<p dir="auto"><br><br></p>

<br>
<details>
<summary><sup>v0.1.0 · poc</sup></summary>
<br>
<samp>
scan → ocr → parse<br>
save → browse → analyze<br>
local-only · no cloud<br>
</samp>
</details>


</td>
<td width="65%">
<table width="100%">
<tbody>
<tr><td colspan="2" align="center"><blockquote>GRAIN · receipt scanner + expense tracker for iOS</blockquote></td></tr>
<tr>
<td width="50%" valign="top">
<table width="100%"><tbody><tr><td><b><samp>D O C S</samp></b></td></tr></tbody></table>
| - <a href="/larralapid/grain/blob/copilot/update-readme-dashboard-layout/docs/Current-State.md">current state</a><br>
| - <a href="/larralapid/grain/blob/copilot/update-readme-dashboard-layout/docs/Redesign-Spec.md">redesign spec</a><br>
| - <a href="/larralapid/grain/blob/copilot/update-readme-dashboard-layout/docs/adr/README.md#index">ADRs</a><br>
| - <a href="/larralapid/grain/blob/copilot/update-readme-dashboard-layout/CHANGELOG.md">changelog</a><br>
</td>
<td width="50%" valign="top">
| - <a href="#what-it-does">what it does</a><br>
| - <a href="#screens">screens</a><br>
| - <a href="#poc-details">poc details</a><br>
| - <a href="#run-locally">run locally</a><br>

<tr><td colspan="2" align="center"><b><samp>D O C S</samp></b></td></tr>
<tr>
<td valign="top">
<samp>→ </samp><a href="./docs/Current-State.md"><samp>current state</samp></a><br>
<sup>mvp delta · parser · errors · images · edit</sup>
</td>
<td valign="top">
<samp>→ </samp><a href="./docs/adr/README.md#index"><samp>adrs</samp></a><br>
<sup>architecture decisions · 5 adrs</sup>
</td>
</tr>
<tr>
<td valign="top">
<samp>→ </samp><a href="./CHANGELOG.md"><samp>changelog</samp></a><br>
<sup>v0.1.0 · poc · notifications</sup>
</td>
<td valign="top">
<samp>→ </samp><a href="./docs/Redesign-Spec.md"><samp>redesign spec</samp></a><br>
<sup>typography · tokens · wireframes</sup>
</td>
</tr>
</tbody></table>
</td>
</tr>
</tbody></table>
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

## ◈ RUN LOCALLY

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
