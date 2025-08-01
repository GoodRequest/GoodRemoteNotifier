# GoodRemoteNotifier

`GoodRemoteNotifier` is a Swift package designed to fetch and display remote notifications based on a JSON template. It allows you to integrate messages, titles, and buttons for different languages, all fetched from Firebase Remote Config.

This package is useful for applications that need to display localized messages and UI elements like update notifications, with multiple language capabilities and appearance customization.

## Features

- Fetches remote configuration based on a given topic.
- Supports multi-language messages for app notifications (e.g., update alerts).
- Displays customizable messages, titles, and buttons based on the selected language.
- Supports debug mode for easier testing.
- Allows customization of the appearance of messages.
- Supports different message frequencies (once, daily, weekly, monthly, always).
- Flexible message decoding through the RemoteMessage protocol.

## Installation

You can install `GoodRemoteNotifier` via Swift Package Manager by adding it to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/GoodRemoteNotifier.git", from: "1.0.0")
]
```

## Configuration Data

The remote configuration is fetched from Firebase Remote Config in JSON format. The JSON template for the configuration should follow this structure:

- **frequency** (optional): Defines how often the notification should appear (e.g., once, daily, weekly, monthly, always). If not defined, the default value is `once`.
- **title**: Localized titles for the notification. These will be displayed based on the user's selected language.
- **message**: Localized messages containing the content of the notification. These messages explain what's new in the app or what the user should do.
- **updateButton** (optional): Localized text for the action button, used for opening the app in the app store.
- **closeButton** (optional): Localized text for the close button, used for dismissing the notification. If not defined, the message is not dismissible.

> **⚠️ Important**: If the `frequency`, `title`, or `message` values change for the specified language, the notification will be treated as a new message.

```JSON
{
  "frequency": "daily",
  "title": {
    "en": "An Update is Available!",
    "de": "Ein Update ist verfügbar!"
  },
  "message": {
    "en": "The new version of the app is here...",
    "de": "Die neue Version der App ist da..."
  },
  "updateButton": {
    "en": "Update Now",
    "de": "Jetzt aktualisieren"
  },
  "closeButton": {
    "en": "Close",
    "de": "Schließen"
  }
}
```

## Usage

Make sure that you have imported the `GoogleService-Info.plist` file into your project. 
Additionally, ensure that `Firebase.configure()` is called before initializing the RemoteConfigNotifier.

Initialize the notifier in `AppDelegate` or in the `@main` App struct for SwiftUI. It will automatically listen for the selected topic and display notifications based on the chosen frequency.

```Swift
import GoodRemoteNotifier

let notifier = RemoteConfigNotifier(
    appId: "123456789", // The App Store ID of the app for redirection.
    topic: "update", // Firebase remote config parameter key
    decoding: YourRemoteMessageType.self, // Your implementation of RemoteMessage protocol
    appearance: RemoteMessageAppearance.default, // Configuration for how remote messages should be displayed.
    presentingEffect: .blur(), // Visual effect for the background (options: .blur() or .dim())
    isDebugSession: { false } // If true, disables caching and sets the minimum fetching interval to 0.
)
```

### Implementing the RemoteMessage Protocol

To use RemoteConfigNotifier, you need to implement the `RemoteMessage` protocol for your custom message type:

```Swift
struct YourRemoteMessageType: RemoteMessage {
    // Your properties based on your JSON structure
    
    func localizedMessage() async -> LocalizedRemoteMessage? {
        // Return a localized message based on your implementation
        return LocalizedRemoteMessage(
            title: "Your title",
            message: "Your message",
            updateButton: "Update",
            closeButton: "Close",
            frequency: .once
        )
    }
    
    // Optional: Override shouldShowMessage if needed
    func shouldShowMessage() async -> Bool {
        // Custom logic to determine if message should be shown
        return true
    }
}
```

## License

`GoodRemoteNotifier` is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
