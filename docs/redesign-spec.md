# Grain Redesign Spec

This document captures a lightweight redesign direction for Grain based on the editorial qualities of [Making Software](https://www.makingsoftware.com/) and [The HTML Review, Issue 04](https://thehtml.review/04/), adapted to the current iOS app structure.

## 1. Inspiration analysis

> Note: the source pages were not directly fetchable in this environment, so the notes below are based on high-level characteristics that are consistently associated with those references and on secondary accessible summaries.

### Making Software

- Strong typographic hierarchy does most of the navigation work.
- Content feels like a reference manual instead of a dashboard.
- Layout is linear, roomy, and quiet rather than densely interactive.
- Diagrams and sectional framing create rhythm without relying on heavy chrome.

### The HTML Review / 04

- The presentation is editorial and literary, with generous margins and slow pacing.
- The interface stays out of the way so the reader can focus on the content itself.
- Whitespace is treated as part of the composition, not empty filler.
- Interactions are restrained and intentional.

### Shared lessons worth bringing into Grain

1. Let typography and spacing create structure before adding visual decoration.
2. Reduce competing UI surfaces so one primary action stands out per screen.
3. Make data feel readable and narrative, not only transactional.
4. Prefer calm, deliberate pacing over dense utility-first layouts.

## 2. Design spec

### Product goal

Reframe Grain from a generic utility app into a calm receipt journal: a place to capture purchases quickly, then review them through readable summaries and lightly editorial analytics.

### Current app surfaces in scope

- `grain/Views/ReceiptListView.swift`
- `grain/Views/ReceiptScannerView.swift`
- `grain/Views/AnalyticsView.swift`
- `grain/Views/ProductsView.swift`
- `grain/Views/MainTabView.swift`

### Core principles

- **Editorial over dashboard**: fewer boxed controls, more readable sections.
- **One primary action per screen**: capture, review, analyze, or browse.
- **Readable density**: large headings, compact metadata, consistent vertical rhythm.
- **Warm utility**: practical information with a softer, more reflective presentation.

### Visual system

#### Typography

- Large serif or serif-adjacent display style for section titles and totals.
- Sans-serif body text for metadata and controls.
- Monospaced numerals for currency, dates, and counts.

#### Color

- Off-white or paper-toned background instead of bright system gray.
- Near-black primary text with muted secondary copy.
- One restrained accent family for interactive states and category highlights.
- Use saturated color mostly for data emphasis, not container backgrounds.

#### Layout

- Favor full-width sections with breathing room between them.
- Replace stacked small cards with fewer, larger groupings.
- Use dividers, captions, and inline labels to separate information.

#### Motion and interaction

- Keep transitions subtle and short.
- Avoid animation that competes with the act of reading.
- Surface actions at natural reading breaks instead of filling every corner.

## 3. Screen-by-screen direction

### Receipts

- Convert the list into a journal-style archive with date groupings.
- Add a prominent monthly summary at the top before the list.
- Keep filters visible as simple inline chips instead of a separate utility block.
- Make each row feel like a receipt excerpt: merchant, date, item count, total.

### Scan

- Treat scanning as a focused capture moment with minimal chrome.
- Keep the instruction copy short and confidence-building.
- When OCR completes, present the result as a clean proof sheet before saving.
- Move secondary actions like editing below the main save decision.

### Analytics

- Lead with one primary insight block, then supporting charts.
- Replace equal-weight cards with a narrative hierarchy:
  1. total spent,
  2. strongest trend,
  3. supporting breakdowns.
- Use captions to explain why a chart matters, not only what it measures.

### Products & Brands

- Present products as a reference index with better scanning rhythm.
- Use clearer separation between product identity and price history.
- Consider a shelf/catalog feeling rather than a dense admin list.

### Navigation

- Keep the tab bar, but visually simplify the screen interiors.
- Use larger in-view titles so tabs feel like entry points, not the whole identity.
- If the app adds Settings later, keep it intentionally sparse and text-first.

## 4. Mockup and wireframe variations

Each variation keeps the current feature set and tab architecture, but changes emphasis and tone.

### Variation A: Ledger

Best for users who want trustworthy structure and quick scanning.

```text
┌──────────────────────────────┐
│ Grain                        │
│ March ledger                 │
│ $482.14 spent · 12 receipts  │
├──────────────────────────────┤
│ All   Grocery   Home   Work  │
├──────────────────────────────┤
│ Mar 22                       │
│ Corner Market         $42.90 │
│ 5 items · groceries         │
│                              │
│ Mar 20                       │
│ Central Pharmacy      $18.12 │
│ 2 items · health            │
├──────────────────────────────┤
│ Receipts  Scan  Analytics    │
└──────────────────────────────┘
```

- Dense enough to feel useful, but still calmer than the current utility layout.
- Best fit if Grain should feel practical first and editorial second.

### Variation B: Journal

Best for users who want a calmer, more reflective reading experience.

```text
┌──────────────────────────────┐
│ Grain                        │
│ a record of everyday spending│
│                              │
│ This month                   │
│ $482.14                      │
│ Mostly groceries and home.   │
│                              │
│ Recent receipts              │
│ Corner Market         $42.90 │
│ Mar 22 · 5 items             │
│                              │
│ Central Pharmacy      $18.12 │
│ Mar 20 · 2 items             │
├──────────────────────────────┤
│ Receipts  Scan  Analytics    │
└──────────────────────────────┘
```

- Closest to the editorial inspiration.
- Encourages narrative summaries and strong typography.

### Variation C: Shelf

Best for emphasizing products, brands, and collectible price memory.

```text
┌──────────────────────────────┐
│ Grain                        │
│ pantry + purchases           │
├──────────────────────────────┤
│ Featured categories          │
│ [ Groceries ] [ Household ]  │
│ [ Pharmacy  ] [ Work ]       │
│                              │
│ Recent finds                 │
│ Oat milk            avg $4.5 │
│ 8 purchases                  │
│                              │
│ Paper towels        avg $7.8 │
│ 3 purchases                  │
├──────────────────────────────┤
│ Products  Brands  Analytics  │
└──────────────────────────────┘
```

- Best if Grain should differentiate itself through product-level memory.
- More tactile and collection-oriented than the other directions.

## 5. Recommended direction

Choose **Variation B: Journal** as the primary redesign direction, with two borrowings:

- take the tidy information density of **Ledger** for lists and filters;
- take the category/product merchandising idea from **Shelf** for Products & Brands.

This combination aligns best with the current app promise: fast capture, readable review, and thoughtful analysis without turning Grain into an overly busy finance dashboard.
