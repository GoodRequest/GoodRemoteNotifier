# GoodRemoteNotifier

GoodRemoteNotifier is a Swift package that lets you display remote, localized notifications and announcements in your app—fetching their content dynamically from Firebase Remote Config. Use it for update alerts, feature announcements, or any message—fully supporting multiple languages, frequency options, and custom UI.

---

## Features

- 🔄 Fetches message data from Firebase Remote Config using your topic key
- 🌐 Multi-language support: All text fields can be localized
- 🎨 Customizable UI via your own SwiftUI view using `RemoteMessageViewProvider`
- 🕒 Frequency options: Show messages once, daily, weekly, monthly, or always
- 🔍 Debug/mocked mode for instant testing during development
- 🧩 Extensible: Use your own model by conforming to `RemoteMessage`
- ✅ Works everywhere: Usable from UIKit or SwiftUI apps

---

## Installation

Add GoodRemoteNotifier via Swift Package Manager:

```swift
dependencies = [
    .package(url: "https://github.com/yourusername/GoodRemoteNotifier.git", from: "1.0.0")
]
```

Then add `GoodRemoteNotifier` to your app target dependencies.

---

## Firebase setup
- Add `GoogleService-Info.plist` to your app target.
- Ensure your topic parameter value in Remote Config is a valid JSON string.

---

## Usage

Two common ways to integrate:

### 1) Quick start (mocked message)
Great for local testing without Firebase.

```swift
import GoodRemoteNotifier

@main
struct YourApp: App {
    var notifier: RemoteConfigNotifier?

    init() {
        notifier = try? RemoteConfigNotifier.mocked(
            MockedRemoteMessage.sample,                    // any `RemoteMessage`
            messageTriggers: [.appForegroundEntry],        // when to check/present
            viewProvider: ViewProvider()                   // your SwiftUI view provider
        )
    }

    var body: some Scene { WindowGroup { ContentView() } }
}
```

Use the sample implementation at `GoodRemoteNotifier-Sample/GoodRemoteNotifier-Sample/Models/MockedRemoteMessage.swift` as a reference.
Also see `GoodRemoteNotifier-Sample/GoodRemoteNotifier-Sample/Application/Views/ViewProvider.swift` and `GoodRemoteNotifier-Sample/GoodRemoteNotifier-Sample/Application/Views/RemoteMessageView.swift` for a simple custom UI.

### 2) Production (Firebase Remote Config)
Provide your App Store ID, topic (Remote Config parameter name), configuration, your model type, and a view provider.

```swift
import GoodRemoteNotifier

@main
struct YourApp: App {
    var notifier: RemoteConfigNotifier?

    init() {
        notifier = try? RemoteConfigNotifier(
            appId: "1234567890",                                     // App Store ID for update button
            topic: "remote_message_topic",                           // Remote Config parameter key
            remoteConfiguration: .init(serviceInfo: .load(),          // requires GoogleService-Info.plist
                                        fetchInterval: 43_200),      // optional throttling (seconds)
            decoding: YourRemoteMessage.self,                         // your `RemoteMessage` type
            messageTriggers: [.appStart, .appForegroundEntry],        // when to fetch/present
            isDebugSession: { false },                                // set { true } to bypass frequency cache
            viewProvider: ViewProvider()                              // your SwiftUI view provider
        )
    }

    var body: some Scene { WindowGroup { ContentView() } }
}
```

---

## Define your `RemoteMessage`
Conform to `RemoteMessage` to bridge your Remote Config JSON to a presentable `LocalizedRemoteMessage`.

- Implement `localizedMessage()` to return a localized `LocalizedRemoteMessage` (or `nil` to skip).
- Optionally override `shouldShowMessage()` (defaults to `true`).

Key types:
- `Sources/GoodRemoteNotifier/Models/RemoteMessage.swift`
- `Sources/GoodRemoteNotifier/Models/LocalizedRemoteMessage.swift`
- `Sources/GoodRemoteNotifier/Models/MessageFrequency.swift` (`once`, `daily`, `weekly`, `monthly`, `always`)

See the sample `MockedRemoteMessage` for a multi-language mapping strategy.

---

## Triggers (when messages are checked/presented)
Configure with `Set<RemoteConfigNotifier.MessageTrigger>`:
- `appStart`
- `appForegroundEntry`
- `networkReached`

The notifier observes these and fetches/presents accordingly. Implementation: `Sources/GoodRemoteNotifier/RemoteConfigNotifier.swift`.

---

## View customization
Provide your own SwiftUI view via a type conforming to `RemoteMessageViewProvider`.

- Implement `makeView(model:)` and return any SwiftUI view wrapped in `AnyView`.
- Use `RemoteMessageViewProviderModel` data: `appId`, `localizedMessage`, `openInAppStore()`, `close()`.

Example:
```swift
import GoodRemoteNotifier
import SwiftUI

struct ViewProvider: RemoteMessageViewProvider {
    @MainActor
    func makeView(model: RemoteMessageViewProviderModel) -> AnyView {
        AnyView(YourCustomMessageView(model: model))
    }
}
```
See sample UI in:
- `GoodRemoteNotifier-Sample/GoodRemoteNotifier-Sample/Application/Views/ViewProvider.swift`
- `GoodRemoteNotifier-Sample/GoodRemoteNotifier-Sample/Application/Views/RemoteMessageView.swift`

---

## Debug and testing
- Use `RemoteConfigNotifier.mocked(...)` for rapid iteration without Firebase.
- In production setup, pass `isDebugSession: { true }` to bypass frequency caching so the message can reappear.
- Frequency logic is handled by `MessageManager` via `UserDefaults` in `Sources/GoodRemoteNotifier/Managers/MessageManager.swift`.

---

## Sample project
Open the sample Xcode project:
`GoodRemoteNotifier-Sample/GoodRemoteNotifier-Sample.xcodeproj`

---

## License
MIT License. See `LICENSE`.
