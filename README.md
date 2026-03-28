# FFormkit iOS SDK

Native Swift SDK for collecting in-app feedback. Drop a fully themed feedback form into your iOS or macOS app in minutes — no configuration required, customized from your dashboard.

- Zero dependencies
- SwiftUI and UIKit support
- Fully customizable from your [fformkit.com](https://fformkit.com) dashboard
- Collects message, star rating, screenshot, and email (each toggleable)
- Device info captured automatically

**Requirements:** iOS 16+ / macOS 13+ · Swift 5.9+ · Xcode 15+

---

## Installation

### Swift Package Manager (Xcode)

1. In Xcode, go to **File → Add Package Dependencies**
2. Enter the repository URL:
   ```
   https://github.com/fformkit/fformkit-ios
   ```
3. Select **Up to Next Major Version** from `1.0.0`
4. Add **FFormkit** to your target

### Swift Package Manager (Package.swift)

```swift
dependencies: [
    .package(url: "https://github.com/fformkit/fformkit-ios", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: ["FFormkit"]
    )
]
```

---

## Usage

Get your API key from the [fformkit.com](https://fformkit.com) dashboard.

### SwiftUI — Sheet (recommended)

```swift
import SwiftUI
import FFormkit

struct ContentView: View {
    @State private var showFeedback = false

    var body: some View {
        Button("Send Feedback") {
            showFeedback = true
        }
        .fformkitSheet(apiKey: "fb_live_...", isPresented: $showFeedback)
    }
}
```

### SwiftUI — Inline View

```swift
import FFormkit

FFormkitView(apiKey: "fb_live_...")
```

### UIKit

```swift
import FFormkit

FFormkit.present(from: self, apiKey: "fb_live_...")
```

---

## Callbacks

```swift
.fformkitSheet(
    apiKey: "fb_live_...",
    isPresented: $showFeedback,
    onSubmit: { submissionID in
        print("Feedback submitted:", submissionID)
    },
    onError: { error in
        print("Error:", error)
    }
)
```

The same `onSubmit` and `onError` callbacks are available on `FFormkitView` and `FFormkit.present(from:apiKey:onSubmit:onError:)`.

---

## Customization

Everything visual is controlled from your dashboard — colors, labels, placeholders, border radius, and which fields are shown. Changes apply instantly without shipping an app update.

---

## License

MIT
