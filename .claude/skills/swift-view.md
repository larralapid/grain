---
name: swift-view
description: Create a new SwiftUI view following grain conventions
user_invocable: true
---

# Swift View Skill

When creating a new SwiftUI view for grain, follow these conventions:

## Template

```swift
import SwiftUI

struct {ViewName}: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var appearance = AppearanceManager.shared

    var body: some View {
        ZStack {
            GrainTheme.bg.ignoresSafeArea()

            // View content here
        }
    }
}

#Preview {
    {ViewName}()
        .modelContainer(for: [Receipt.self, ReceiptItem.self, Product.self, Brand.self], inMemory: true)
}
```

## Rules

1. **Always** use `GrainTheme` tokens — never hardcode colors or fonts
2. Use `GrainTheme.mono()` for all text
3. Apply `.grainScreen()` modifier or use `GrainTheme.bg.ignoresSafeArea()` for backgrounds
4. Include a `#Preview` block with in-memory model container
5. Place the file in `grain/Views/`
6. Use monospace, brutalist aesthetic — minimal chrome, data-forward
