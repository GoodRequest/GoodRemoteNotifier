//
//  RemoteMessageViewProvider.swift
//  GoodRemoteNotifier
//
//  Created by Marek Vríčan on 17/04/2025.
//

import SwiftUI

public protocol RemoteMessageViewProvider: Sendable {

    @MainActor
    func makeView(model: RemoteMessageViewProviderModel) -> AnyView
    
}

public struct RemoteMessageViewProviderModel {

    public let appId: String
    public let localizedMessage: LocalizedRemoteMessage
    public let openInAppStore: () -> Void
    public let close: () -> Void

    public init(
            appId: String,
            localizedMessage: LocalizedRemoteMessage,
            openInAppStore: @escaping () -> Void,
            close: @escaping () -> Void
        ) {
            self.appId = appId
            self.localizedMessage = localizedMessage
            self.openInAppStore = openInAppStore
            self.close = close
        }

}
