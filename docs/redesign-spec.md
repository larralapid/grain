# Grain Redesign Spec

*Based on analysis of [Making Software](https://www.makingsoftware.com/) and [The HTML Review 04](https://thehtml.review/04/)*

---

## 1. Inspiration Analysis

### Making Software — Dan Hollick

A single-page reference manual for how software works. The entire site is one long scroll — no navigation menu, no sidebar, no hamburger. You just read.

**What it actually does:**

- **Pixel-grid display font** for the title "MAKING SOFTWARE" — blocky, retro, immediately distinctive. Not a system font, not a Google Font. It looks like it was drawn on graph paper.
- **Two-column editorial layout** — body text on the left, technical diagrams on the right. The columns aren't rigid; they breathe and overlap. Figures are labeled with vertical sidebar text like `FIG.001`, `FIG.002` in small monospace, rotated 90 degrees.
- **Single accent color: blue** — a soft, technical blue (roughly `#4A6FA5`) used exclusively for diagram lines, interactive elements, and annotation text. Everything else is near-black on off-white.
- **Serif body text** with justified alignment — reads like a printed manual, not a website. Drop caps on opening paragraphs. The font choice is deliberate: it says "reference material," not "app marketing."
- **Technical diagrams are the hero** — exploded isometric views of hardware (floppy disks, CRT tubes, touch screens). Each diagram has labeled callout lines in monospace. The illustrations are hand-drawn-feeling but precise, using the same blue accent.
- **Decorative separators** — rows of small repeating glyphs (`▓▓▓▓▓▓▓`) between sections instead of horizontal rules.
- **No interactivity except one email signup** at the bottom. No buttons, no modals, no animations competing with the reading experience.

**What to take from it:** Typography and diagrams do 100% of the work. No chrome, no UI widgets, no competing surfaces. One color. Trust the content.

### The HTML Review, Issue 04

A literary journal for the browser. Each piece is an HTML artwork. The index page is itself a gallery.

**What it actually does:**

- **Each article is a framed card** — literally drawn with CSS borders that look like thin architectural lines. Title top-left with a dotted underline. Author name rotated vertically on the right edge. The frame is the UI.
- **Massive whitespace** — each card is centered on the page with huge margins above and below. The page scrolls slowly through pieces one at a time. No grid. No density. One thing, then the next.
- **Monospace typography throughout** — `"ISSUE 04, SPRING 2025"` in small caps, article titles in a serif-looking monospace. The hierarchy is created by size, not weight or color.
- **Muted, archival palette** — off-white background (`~#F5F0EB`), dark maroon/burgundy for text (`~#4A2028`), thin hairline borders in the same maroon. The only high-saturation element: yellow (`#FFFF00`) highlight on the CTA buttons ("ASCII Bedroom Memoir ⇢").
- **Mixed media inside cards** — ASCII art, photography, generative patterns, all treated equally. The frame normalizes everything into the same editorial context.
- **Vertical text for attribution** — author names run along the right edge of each card, rotated 90 degrees. This is a strong visual signature.
- **Minimal navigation** — just "about," "archive," and "top" in the footer. No header nav until you scroll past the masthead.

**What to take from it:** Framing creates hierarchy without heavy UI. Whitespace is structural, not decorative. One accent color used sparingly for actions. Vertical text as a design motif.

---

## 2. Design Principles for Grain

Extracted from both references, adapted for a receipt-tracking iOS app:

1. **One surface at a time.** Both references show one piece of content, then the next. No dashboard grids. No competing cards. Each screen should have one primary focus.

2. **Typography is the interface.** Large type for amounts. Small monospace for dates and metadata. Serif or serif-adjacent for narrative text. Weight and size create hierarchy — not boxes, shadows, or color blocks.

3. **One accent color.** Making Software uses blue. HTML Review uses maroon + yellow highlights. Grain should pick one and use it only for interactive elements and emphasis.

4. **Frame, don't box.** HTML Review's thin-bordered cards are more elegant than filled rounded rectangles. Use hairline borders and whitespace to define regions, not background fills.

5. **Monospace for data, serif for narrative.** Prices, dates, item counts in monospace. Summaries, categories, descriptions in the body font.

6. **Let the receipt be the hero.** Like Making Software's exploded diagrams, the receipt itself — itemized, annotated — should be the most visually interesting thing in the app.

---

## 3. Visual System

### Typography

| Role | Style | Example |
|------|-------|---------|
| Screen title | Large serif, ~28pt | "March" |
| Primary amount | Large monospace, ~34pt | "$482.14" |
| Merchant name | Medium serif, ~17pt | "Corner Market" |
| Metadata line | Small monospace, ~12pt, secondary color | "Mar 22 · 5 items · groceries" |
| Summary text | Body serif, ~15pt | "Mostly groceries and home." |
| Section label | Small caps monospace, ~11pt, tracked wide | "RECENT RECEIPTS" |
| Tab bar labels | Small monospace, ~10pt | "receipts   scan   analytics" |

### Color

| Token | Value | Usage |
|-------|-------|-------|
| `background` | `#FAF8F5` | Warm paper — not pure white |
| `text.primary` | `#1A1A1A` | Near-black body text |
| `text.secondary` | `#8A8580` | Metadata, timestamps, secondary info |
| `accent` | `#3D5A80` | Interactive elements, chart fills, links |
| `accent.highlight` | `#E8C547` | Sparingly — scan button, save confirmation |
| `border` | `#D4CFC8` | Hairline dividers and card frames |
| `surface` | `#F0EDE8` | Subtle section differentiation |

### Spacing

- 24pt between sections (generous vertical rhythm)
- 16pt internal padding
- Hairline borders (`0.5pt`) instead of cards with background fills
- Full-width content — no narrow centered columns on a phone screen

---

## 4. Screen-by-Screen Direction

### Receipts (Home)

Current: Dense list with search bar and category filter chips at top.

Redesign: Journal-style. Open with a monthly summary block — the month name large, the total in oversized monospace, one sentence of narrative summary below. Then a section-labeled list grouped by date. Each receipt row: merchant left-aligned, amount right-aligned, metadata line below in small monospace. Thin hairline between entries.

No category filter chips at top. Move filtering to a simple sheet triggered by a small filter icon.

### Scan

Current: Camera view with toolbar buttons.

Redesign: Full-bleed camera with minimal overlay. One capture button centered at bottom. After capture, show the receipt as a "proof sheet" — the extracted data presented in the same typography system as the rest of the app, with the original image small in the corner. Save is the primary action; Edit is secondary text below.

### Receipt Detail

Current: Sections with headers for items, financials, OCR text.

Redesign: Treat like Making Software's exploded diagrams. The receipt is the artifact. Show it as a single flowing document: merchant and date at top (large), items listed below with subtle alternating line spacing, subtotal/tax/total at the bottom in monospace right-aligned with hairline rules above and below. Annotations (category, notes) in small italic serif in the margin or below the receipt body.

### Analytics

Current: Four equal KPI cards + three bar charts.

Redesign: Lead with one number. The total spent, big. Below it, one sentence: "Up 12% from February. Groceries drove most of the increase." Then supporting charts — but simpler. One bar chart for categories, one for brands. Use the accent color for bars, muted gray for grid lines. Captions below each chart explaining the takeaway, not just axis labels.

### Products & Brands

Current: Segmented picker toggling between two list views.

Redesign: A reference index. Products listed alphabetically with their average price in monospace right-aligned. Group by first letter with large letter headers. Brand view: each brand as a framed card (HTML Review style) — brand name top-left, total spent top-right, product count and average transaction below in metadata style.

### Settings

Current: Four "coming soon" rows.

Redesign: Keep it minimal and text-first. Each setting is a label with a description below in secondary text. No icons. When settings are eventually implemented, use full-screen sheets, not inline toggles.

---

## 5. Wireframe Variations

### Variation A — Ledger

Structured, utility-forward. Receipts as entries in an accounting ledger. Best for users who open the app to find a specific receipt quickly.

```
┌─────────────────────────────────────┐
│                                     │
│  March                              │
│  ─────────────────────────────────  │
│  $482.14              12 receipts   │
│                                     │
│                                     │
│  SATURDAY, MAR 22                   │
│  ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄  │
│  Corner Market              $42.90  │
│  5 items · groceries                │
│                                     │
│  CVS Pharmacy              $18.12   │
│  2 items · health                   │
│                                     │
│  THURSDAY, MAR 20                   │
│  ┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄  │
│  Whole Foods               $67.34   │
│  11 items · groceries               │
│                                     │
│  ═══════════════════════════════════ │
│  receipts    scan    analytics      │
└─────────────────────────────────────┘
```

- Date groups as section headers in small caps
- Dotted separators between groups, not between individual receipts
- Month name is the screen title, replaces "Receipts"
- Compact but not crowded — whitespace between groups

### Variation B — Journal

Editorial, reflective. Receipts as entries in a spending diary. Best for users who want to understand their habits, not just look up transactions.

```
┌─────────────────────────────────────┐
│                                     │
│  grain                              │
│                                     │
│  March 2026                         │
│                                     │
│          $482.14                    │
│                                     │
│  Mostly groceries and home.         │
│  You spent 12% more than            │
│  February.                          │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  RECENT                             │
│                                     │
│  Corner Market              $42.90  │
│  yesterday · 5 items                │
│                                     │
│  CVS Pharmacy              $18.12   │
│  yesterday · 2 items                │
│                                     │
│  Whole Foods               $67.34   │
│  thursday · 11 items                │
│                                     │
│  ═══════════════════════════════════ │
│  receipts    scan    analytics      │
└─────────────────────────────────────┘
```

- Opens with narrative summary, not a list
- Total is oversized and centered — the emotional anchor
- Relative dates ("yesterday," "thursday") instead of absolute
- Summary sentence generated from analytics data
- Scroll past the summary to reach the receipt list

### Variation C — Catalog

Product-centric. The receipt fades into the background; what you bought is the focus. Best for users who care about price tracking, brand loyalty, and shopping patterns.

```
┌─────────────────────────────────────┐
│                                     │
│  grain                              │
│  your purchase record               │
│                                     │
│  ┌─────────────────────────────────┐│
│  │ Groceries            72% spent  ││
│  │ $347.18 · 8 receipts           ││
│  └─────────────────────────────────┘│
│  ┌─────────────────────────────────┐│
│  │ Health               11% spent  ││
│  │ $53.40 · 3 receipts            ││
│  └─────────────────────────────────┘│
│                                     │
│  PRICE WATCH                        │
│                                     │
│  Oat Milk                           │
│  avg $4.50 · last $4.79 ↑          │
│  8 purchases                        │
│                                     │
│  Paper Towels                       │
│  avg $7.80 · last $8.29 ↑          │
│  3 purchases                        │
│                                     │
│  ═══════════════════════════════════ │
│  catalog    scan    trends          │
└─────────────────────────────────────┘
```

- Categories as framed cards (HTML Review style — thin border, no fill)
- "Price Watch" section surfaces products with notable price changes
- Tab bar renames: "catalog" instead of "products," "trends" instead of "analytics"
- Receipt list is secondary — accessed through category drill-down

---

## 6. Recommendation

**Start with Variation B (Journal)** as the primary direction. It's the strongest differentiation from generic expense apps — most competitors are Ledger-style by default.

Borrow from the other two:
- **From Ledger:** the date-grouped receipt list structure (used when scrolling past the Journal summary)
- **From Catalog:** the "Price Watch" concept (surface it in the Analytics tab instead of making it the home screen)

Implementation order:
1. Establish the typography and color system in a SwiftUI `Theme` — this affects every screen
2. Redesign ReceiptListView with the Journal header + Ledger-style list below
3. Redesign ReceiptDetailView as the "artifact" view
4. Redesign AnalyticsView with narrative hierarchy + Price Watch
5. Simplify ProductsView into reference index layout
6. Polish ReceiptScannerView last (it's functional, just needs visual alignment)
