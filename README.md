# GoodRemoteNotifier

GoodRemoteNotifier is a Swift package that lets you display remote, localized notifications and announcements in your app—fetching their content dynamically from Firebase Remote Config. Use it for update alerts, feature announcements, or any message—fully supporting multiple languages, frequency options, and custom UI.

---

## Features

- 🔄 Fetches message data from Firebase Remote Config using your topic key
- 🌐 Multi-language support: All text fields can be localized
- 🎨 Customizable UI: Control look, feel, and background effect
- 🕒 Frequency options: Show messages once, daily, weekly, monthly, or always
- 🔍 Debug/mocked mode for instant testing during development
- 🧩 Extensible: Use your own model by conforming to `RemoteMessage`
- ✅ Works everywhere: Usable from UIKit or SwiftUI apps

---

## Installation

Add GoodRemoteNotifier via Swift Package Manager:

```swift
.dependencies = [
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
            appearance: .default,                          // or custom appearance
            messageTriggers: [.appForegroundEntry]         // when to check/present
        )
    }

    var body: some Scene { WindowGroup { ContentView() } }
}
```

Use the sample implementation at `GoodRemoteNotifier-Sample/GoodRemoteNotifier-Sample/Models/MockedRemoteMessage.swift` as a reference.

### 2) Production (Firebase Remote Config)
Provide your App Store ID, topic (Remote Config parameter name), configuration, and your model type.

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
            appearance: .default,                                     // or custom appearance
            messageTriggers: [.appStart, .appForegroundEntry],        // when to fetch/present
            presentingEffect: .blur(style: .systemThickMaterialDark), // overlay background effect
            isDebugSession: { false }                                 // set { true } to bypass frequency cache
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

## Appearance customization
Style the overlay with `RemoteMessageAppearance` and button styles with `RemoteMessageButtonAppearance`.

```swift
let appearance = RemoteMessageAppearance(
    appLogoSize: 46,
    titleFont: .system(size: 20, weight: .bold),
    titleColor: .black,
    messageFont: .footnote,
    messageColor: .black.opacity(0.8),
    backgroundColor: .white,
    primaryButtonStyle: .primary,
    secondaryButtonStyle: .secondary,
    cornerRadius: 16,
    contentAlignment: .leading
)

notifier?.updateAppearance(appearance)
```

The default view is `Sources/GoodRemoteNotifier/Views/RemoteMessageView.swift`. It supports showing:
- App icon (optional)
- Title and message
- Update button (opens App Store using `appId`)
- Close button

---

## Debug and testing
- Use `RemoteConfigNotifier.mocked(...)` for rapid iteration without Firebase.
- Pass `isDebugSession: { true }` to bypass frequency caching so the message can reappear.
- Frequency logic is handled by `MessageManager` via `UserDefaults` in `Sources/GoodRemoteNotifier/Managers/MessageManager.swift`.

---

## Sample project
Open the sample Xcode project:
`GoodRemoteNotifier-Sample/GoodRemoteNotifier-Sample.xcodeproj`

---

## License
MIT License. See `LICENSE`.
