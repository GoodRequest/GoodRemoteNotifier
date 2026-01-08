//
//  ViewProvider.swift
//  GoodRemoteNotifier-Sample
//
//  Created by Marek Vríčan on 20/10/2025.
//

import GoodRemoteNotifier
import SwiftUI

struct ViewProvider: RemoteMessageViewProvider {

    @MainActor
    func makeView(model: RemoteMessageViewProviderModel) -> AnyView {
        AnyView(RemoteMessageView(model: model))
    }

}
