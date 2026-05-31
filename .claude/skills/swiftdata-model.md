---
name: swiftdata-model
description: Add or modify a SwiftData @Model in grain following project conventions
user_invocable: true
---

# SwiftData Model Skill

Conventions for `@Model` types in `grain/Models/`. Mirrors the existing models
(`Receipt`, `ReceiptItem`, `Product`, `PricePoint`, `Brand`).

## Template

```swift
import Foundation
import SwiftData

@Model
final class {ModelName} {
    var id: UUID
    // money is always Decimal, never Double
    var amount: Decimal
    // declare delete behavior on every to-many relationship
    @Relationship(deleteRule: .cascade) var children: [{Child}]
    var createdAt: Date
    var updatedAt: Date

    init(amount: Decimal) {
        self.id = UUID()
        self.amount = amount
        self.children = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
```

## Rules

1. `final class`, `@Model`, with a `UUID id` and `createdAt` / `updatedAt` timestamps.
2. **Currency is `Decimal`** — never `Double`/`Float`.
3. **Declare `@Relationship(deleteRule:)` on every to-many** so deletes don't orphan rows
   (`.cascade` for owned children like `Receipt.items`, `.nullify` for shared refs).
4. Register the new type in **three** places, or it won't persist / preview:
   - `grain/grainApp.swift` → the `Schema([...])` array
   - `grain/Services/DemoDataSeeder.swift` → `makePreviewContainer()` schema
   - any `#Preview` using `.modelContainer(for: [...])`
5. Derived/aggregate data (e.g. `SpendingAnalytics`) should be a **plain struct**, not a
   persisted `@Model`.
6. When inserting a parent with children, mirror `DemoDataSeeder`: set both sides of the
   relationship (`child.parent = parent` + `parent.children.append(child)`) and
   `modelContext.insert(...)` each, then `try modelContext.save()`.
