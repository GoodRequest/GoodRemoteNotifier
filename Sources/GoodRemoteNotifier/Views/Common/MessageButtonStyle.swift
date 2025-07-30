//
//  MessageButtonStyle.swift
//  GoodRemoteNotifier
//
//  Created by Marek Vríčan on 17/04/2025.
//

import SwiftUI

internal struct MessageButtonStyle: ButtonStyle {

    let appearance: RemoteMessageButtonAppearance

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(appearance.font)
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .center)
            .styledForeground(appearance.foregroundColor)
            .background(appearance.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: appearance.cornerRadius))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.snappy, value: configuration.isPressed)
    }

}
