//
//  GoodRemoteNotifierSampleApp.swift
//
//  Created by Marek Vríčan on 26/09/2025.
//

import SwiftUI
import GoodRemoteNotifier

@main
struct GoodRemoteNotifierSampleApp: App {

    var remoteConfigNotifier: RemoteConfigNotifier?

    init() {
        /// Just a mocked message, open **MockedRemoteMessage.swift** to find out more
        remoteConfigNotifier = try? RemoteConfigNotifier.mocked(
            MockedRemoteMessage.sample,
            appearance: RemoteMessageTheme.dark.appearance,
            messageTriggers: [.appForegroundEntry])

        /// To use remote config, please copy **GoogleService-Info.plist** to the project
//        remoteConfigNotifier = try? RemoteConfigNotifier(
//            appId: <#T##String#>, // App Id in the appStore
//            topic: <#T##String#>, // Parameter name in the Remote Config that will be fetched
//            remoteConfiguration: <#T##RemoteConfigClient.Configuration?#>,
//            decoding: <#T##any RemoteMessage.Type#>, // Your implementation of RemoteMessage
//            appearance: <#T##RemoteMessageAppearance#>, // Can use .default or create one to your needs
//            messageTriggers: <#T##Set<RemoteConfigNotifier.EventListener>#> // Set of triggers to show the message
//        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

}
