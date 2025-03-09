// The Swift Programming Language
// https://docs.swift.org/swift-book

import Firebase
import FirebaseRemoteConfig
import GoodLogger
import SwiftUI

/// A class responsible for handling remote notifications using Firebase Remote Config.
/// It listens for updates and displays messages accordingly.
public final class GoodRemoteNotifier: @unchecked Sendable {

    /// Firebase Remote Config instance
    private let remoteConfig = RemoteConfig.remoteConfig()
    /// Manages displaying remote messages
    private let messageManager = MessageManager()
    /// JSON decoder for parsing remote messages
    private let decoder = JSONDecoder()

    /// Logger instance used for debugging and error reporting
    private var logger: GoodLogger {
        if #available(iOS 14, *) {
            return OSLogLogger()
        } else {
            return PrintLogger()
        }
    }

    /// The App Store ID of the app, used for opening the app in the App Store.
    private let appId: String
    /// The topic key used for fetching remote values
    private let keyTopic: String
    /// Closure to determine the selected language
    private let selectedLanguage: @Sendable () -> String
    /// Appearance configuration for remote messages
    private let appearance: RemoteMessageAppearance
    /// Closure to determine if the app is running in debug mode
    private let isDebugSession: @Sendable () -> Bool

    /// Initializes a `GoodRemoteNotifier` instance.
    /// - Parameters:
    ///   - appId: The App Store ID of the app for redirection.
    ///   - topic: The topic key for fetching remote messages.
    ///   - selectedLanguage: A closure returning the user's selected language.
    ///   - appearance: Configuration for how remote messages should be displayed.
    ///   - isDebugSession: A closure that returns `true` if in debug mode, default is `false`.
    public init(
        appId: String,
        topic: String,
        selectedLanguage: @escaping @Sendable () -> String,
        appearance: RemoteMessageAppearance,
        isDebugSession: @escaping @Sendable () -> Bool = { false }
    ) {
        self.appId = appId
        self.keyTopic = topic
        self.selectedLanguage = selectedLanguage
        self.appearance = appearance
        self.isDebugSession = isDebugSession

        setupConfig()
        startListeningOnEvents()
    }

}

private extension GoodRemoteNotifier {

    /// Starts listening for multiple app events: foreground entry, app updates, and app start.
    func startListeningOnEvents() {
        Task { await startListeningOnForegroundEntry() }
        Task { await startListeningOnUpdate() }
        Task { await startListeningOnAppStart() }
    }

    /// Configures Firebase Remote Config settings.
    /// Adjusts the fetch interval based on debug mode.
    func setupConfig() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = isDebugSession() ? 0 : 43200
        remoteConfig.configSettings = settings
    }

    /// Listens for the `UIApplication.didFinishLaunchingNotification` and calls `fetchRemoteValues` when the app finishes launching.
    func startListeningOnAppStart() async {
        let didFinishLaunchingNotification = NotificationCenter.default
            .notifications(named: UIApplication.didFinishLaunchingNotification)

        for await _ in didFinishLaunchingNotification {
            await fetchRemoteValues()
        }
    }

    /// Starts listening for app foreground entry events.
    /// Fetches remote values when the app becomes active.
    func startListeningOnForegroundEntry() async {
        let willEnterForegroundNotifications = NotificationCenter.default
            .notifications(named: UIApplication.willEnterForegroundNotification)

        for await _ in willEnterForegroundNotifications {
            try? await Task.sleep(for: .seconds(0.3))
            await fetchRemoteValues()
        }
    }

    /// Starts listening for updates to remote config values.
    func startListeningOnUpdate() async {
        for await updatedKeys in updatedKeys() {
            guard updatedKeys.contains(keyTopic) else { return }

            await fetchRemoteValues()
        }
    }

    /// Creates an async stream that listens for remote config updates.
    /// - Returns: An `AsyncStream` of updated config keys.
    func updatedKeys() -> AsyncStream<Set<String>> {
        AsyncStream<Set<String>> { continuation in
            remoteConfig.addOnConfigUpdateListener { update, error in
                guard let update, error == nil else {
                    if let error {
                        self.logMessage("❌ \(error.localizedDescription)")
                    }
                    return
                }

                continuation.yield(update.updatedKeys)
            }

            continuation.onTermination = { reason in
                print("\(reason)")
            }
        }
    }

    /// Decodes and displays the remote message if applicable.
    func decodeRemote() async {
        guard let data = remoteConfig.configValue(forKey: keyTopic).stringValue.data(using: .utf8) else {
            return
        }
        let isDebugSession = isDebugSession()
        do {
            if let localizedMessage = try decoder.decode(RemoteMessage.self, from: data).localizedMessage(languageCode: selectedLanguage()),
               isDebugSession ? true : messageManager.shouldShowMessage(localizedMessage) {
                if !isDebugSession {
                    messageManager.markMessageAsShown(localizedMessage)
                }

                Task { @MainActor in
                    let controller = UIHostingController(
                        rootView: RemoteMessageView(
                            localizedMessage: localizedMessage,
                            appId: appId,
                            appearance: appearance)
                    )
                    controller.view.backgroundColor = .clear

                    WindowManager.shared.showNewWindow(presenting: controller)
                }
            }
        } catch {
            logMessage("❌ an error during decoding: \(error.localizedDescription)")
        }
    }

    /// Fetches remote values from Firebase Remote Config.
    func fetchRemoteValues() async {
        do {
            switch try await remoteConfig.fetchAndActivate() {
            case .successFetchedFromRemote, .successUsingPreFetchedData:
                logMessage("✅ Successfully fetched remote values.")
                await decodeRemote()

            case .error:
                logMessage("❌ Failed to fetch remote values.")

            default:
                logMessage("⚠️ Unexpected remote config state.")
            }
        } catch {
            logMessage("❌ \(error.localizedDescription)")
        }
    }

    /// Logs a message using the configured logger.
    /// - Parameter message: The message to log.
    func logMessage(_ message: String) {
        //logger.log(message: "RemoteNotifier: \(message)", level: .debug, privacy: .auto)
    }

}
