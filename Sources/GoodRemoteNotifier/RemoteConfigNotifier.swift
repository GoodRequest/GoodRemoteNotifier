// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

// MARK: - RemoteConfigNotifier Declaration

public actor RemoteConfigNotifier {

    // MARK: Enums

    public enum MessageTrigger: Sendable & CaseIterable {
        case appStart
        case appForegroundEntry
        case networkReached
    }

    // MARK: Properties

    /// Firebase Remote Config instance
    private let remoteClient: RemoteConfigClient
    /// Monitors the network reachability to trigger remote config fetches on connection changes
    private let reachabilityMonitor = NetworkReachabilityManager()
    /// Manages displaying remote messages
    private let messageManager = MessageManager()
    /// JSON decoder for parsing remote messages
    private let decoder = JSONDecoder()
    /// The App Store ID of the app, used for opening the app in the App Store.
    private let appId: String
    /// The topic key used for fetching remote values
    private let keyTopic: String
    /// The type conforming to `RemoteMessage` protocol used for decoding remote JSON payloads.
    private let decoding: RemoteMessage.Type
    /// Closure to determine if the app is running in debug mode
    private let isDebugSession: @Sendable () -> Bool
    /// The set of events that will trigger remote config checks
    private let messageTriggers: Set<MessageTrigger>

    private var mocked: RemoteMessage? = nil

    private let viewProvider: any RemoteMessageViewProvider

    // MARK: Initializers

    /// Initializes a `GoodRemoteNotifier` instance.
    /// - Parameters:
    ///   - appId: The App Store ID of the app for redirection.
    ///   - topic: The topic key for fetching remote messages.
    ///   - remoteConfiguration: The configuration object for initializing the remote config client.
    ///   - decoding: The type implementing the `RemoteMessage` protocol that will be used to decode the remote configuration.
    ///   - eventListeners: The set of event listeners that trigger remote config checks. Defaults to all cases.
    ///   - presentingEffect: Determines how the background of the overlay view will appear. Default is `.blur()`.
    ///   - isDebugSession: A closure that returns `true` if in debug mode, default is `false`.
    public init(
        appId: String,
        topic: String,
        remoteConfiguration: RemoteConfigClient.Configuration?,
        decoding: RemoteMessage.Type,
        messageTriggers: Set<MessageTrigger> = Set(MessageTrigger.allCases),
        isDebugSession: @escaping @Sendable () -> Bool = { false },
        viewProvider: any RemoteMessageViewProvider
    ) throws {
        self.remoteClient = try .init(configuration: remoteConfiguration)

        self.appId = appId
        self.keyTopic = topic
        self.decoding = decoding
        self.messageTriggers = messageTriggers
        self.isDebugSession = isDebugSession
        self.viewProvider = viewProvider

        Task { await startListeningOnEvents() }
    }

    fileprivate init<T: RemoteMessage>(
        mocked: T,
        appId: String,
        messageTriggers: Set<MessageTrigger>,
        viewProvider: any RemoteMessageViewProvider
    ) throws {
        self.remoteClient = try .init(configuration: .init(serviceInfo: .mock))

        self.appId = appId
        self.keyTopic = "mocked"
        self.decoding = T.self
        self.messageTriggers = messageTriggers
        self.isDebugSession = { false }
        self.mocked = mocked
        self.viewProvider = viewProvider

        Task { await startListeningOnEvents() }
    }

    public static func mocked<T: RemoteMessage>(
        _ mocked: T,
        appId: String = "",
        messageTriggers: Set<MessageTrigger> = Set(MessageTrigger.allCases),
        viewProvider: any RemoteMessageViewProvider
    ) throws -> RemoteConfigNotifier? {
        try RemoteConfigNotifier(mocked: mocked, appId: appId, messageTriggers: messageTriggers, viewProvider: viewProvider)
    }

}

// MARK: Event Listening

private extension RemoteConfigNotifier {

    func startListeningOnEvents() {
        for trigger in messageTriggers {
            switch trigger {
            case .appStart: Task { await startListeningOnAppStart() }
            case .appForegroundEntry: Task { await startListeningOnForegroundEntry() }
            case .networkReached: Task { await listenOnNetworkReached() }
            }
        }
    }

    func startListeningOnAppStart() async {
        observeNotification(named: UIApplication.didFinishLaunchingNotification) {
            await self.fetchRemoteValues()
        }
    }

    func listenOnNetworkReached() async {
        for await _ in await reachabilityMonitor.reachabilityStream() {
            await fetchRemoteValues()
        }
    }

    func startListeningOnForegroundEntry() async {
        observeNotification(named: UIApplication.willEnterForegroundNotification) {
            await self.fetchRemoteValues()
        }
    }

}

// MARK: Remote Fetch & Decode

private extension RemoteConfigNotifier {

    /// Fetches remote values from Firebase Remote Config.
    func fetchRemoteValues() async {
        if let mocked {
            await present(response: mocked)
        } else {
            do {
                let fetchedData = try await remoteClient.fetchRemoteConfig(for: keyTopic)
                logMessage("✅ Successfully fetched remote values.")
                await present(response: try decoder.decode(decoding.self, from: fetchedData))
            } catch {
                logMessage("❌ \(error.localizedDescription)")
            }
        }
    }

    func present<T: RemoteMessage>(response: T) async {
        let isDebugSession = isDebugSession()

        if let localizedMessage = await response.localizedMessage(), await response.shouldShowMessage(),
           isDebugSession ? true : messageManager.shouldShowMessage(localizedMessage) {
            if !isDebugSession {
                messageManager.markMessageAsShown(localizedMessage)
            }

            Task { @MainActor in
                let model = RemoteMessageViewProviderModel(
                    appId: appId,
                    localizedMessage: localizedMessage,
                    openInAppStore: { self.openAppStore() },
                    close: { WindowManager.shared.closeNewWindow() }
                )
                let controller = UIHostingController<AnyView>(rootView: viewProvider.makeView(model: model))
                controller.view.backgroundColor = .clear

                WindowManager.shared.showNewWindow(presenting: controller)
            }
        }
    }

    @MainActor
    func openAppStore() {
        if let url = URL(string: "https://apps.apple.com/app/id\(appId)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

}

// MARK: - Helpers

private extension RemoteConfigNotifier {

    /// Logs a message using the configured logger.
    /// - Parameter message: The message to log.
    func logMessage(_ message: String) {
        print(message)
    }

    func observeNotification(
        named name: Notification.Name,
        perform action: @escaping @Sendable () async -> Void
    ) {
        if #available(iOS 15, *) {
            Task {
                for await _ in NotificationCenter.default.notifications(named: name) {
                    await action()
                }
            }
        } else {
            NotificationCenter.default.addObserver(
                forName: name,
                object: nil,
                queue: .main
            ) { _ in
                Task {
                    await action()
                }
            }
        }
    }

}
