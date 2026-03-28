# FFormkit iOS SDK

Native Swift SDK for [FFormkit](https://fformkit.com) — collect in-app feedback from your iOS and macOS apps with a fully themed, zero-dependency feedback form.

## Requirements

- iOS 16+ / macOS 13+
- Swift 5.9+
- Xcode 15+

## Installation

### Swift Package Manager (Xcode)

1. In Xcode, go to **File → Add Package Dependencies**
2. Paste the URL: `https://github.com/fformkit/fformkit-ios`
3. Select **Up to Next Major Version** from `1.0.0`
4. Add **FeedbackKit** to your target

### Swift Package Manager (Package.swift)

```swift
dependencies: [
    .package(url: "https://github.com/fformkit/fformkit-ios", from: "1.0.0")
],
targets: [
    .target(dependencies: ["FeedbackKit"])
]
```

## Usage

Get your API key from the [FFormkit dashboard](https://fformkit.com) under **Install SDK**.

### SwiftUI

The easiest way — attach `.feedbackSheet()` to any view:

```swift
import SwiftUI
import FeedbackKit

struct ContentView: View {
    @State private var showFeedback = false

    var body: some View {
        Button("Send Feedback") { showFeedback = true }
            .feedbackSheet(
                apiKey: "fb_live_...",
                isPresented: $showFeedback
            )
    }
}
```

With callbacks:

```swift
.feedbackSheet(
    apiKey: "fb_live_...",
    isPresented: $showFeedback,
    onSubmit: { id in print("Submitted:", id) },
    onError: { error in print("Error:", error) }
)
```

You can also embed `FeedbackView` inline anywhere in your view hierarchy:

```swift
FeedbackView(apiKey: "fb_live_...")
```

### UIKit

```swift
import UIKit
import FeedbackKit

class MyViewController: UIViewController {
    @IBAction func feedbackTapped(_ sender: Any) {
        FeedbackKit.present(
            from: self,
            apiKey: "fb_live_..."
        ) { id in
            print("Submitted:", id)
        }
    }
}
```

## What gets collected

The form collects the following — all fields except **message** are optional and can be toggled in your FFormkit dashboard:

| Field | Description |
|-------|-------------|
| Message | User's feedback text (required) |
| Rating | 1–5 star rating |
| Email | User's email address |
| Screenshot | Photo from the user's library |
| Device info | Model, OS version, screen size (sent automatically) |

## Customization

All colors, labels, and feature toggles are configured in the **FFormkit dashboard** under your project's **Form Config** — changes apply instantly without an app update.

You can customize:
- Primary color, background, text colors
- Button label, form title, placeholder text, success message
- Show/hide rating, screenshot, and email fields
- Border radius and light/dark theme

## License

MIT
