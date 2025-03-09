//
//  RemoteMessageView.swift
//  GoodRemoteNotifier
//
//  Created by Marek Vríčan on 05/03/2025.
//

import SwiftUI

public struct RemoteMessageAppearance: Sendable {

    let appLogoSize: CGFloat?
    let titleFont: Font
    let titleColor: Color
    let messageFont: Font
    let messageColor: Color
    let backgroundColor: Color
    let primaryButtonStyle: RemoteMessageButtonAppearance
    let secondaryButtonStyle: RemoteMessageButtonAppearance
    let cornerRadius: CGFloat
    let contentAlignment: Alignment

    public init(
        appLogoSize: CGFloat? = 46,
        titleFont: Font,
        titleColor: Color,
        messageFont: Font,
        messageColor: Color,
        backgroundColor: Color,
        primaryButtonStyle: RemoteMessageButtonAppearance = .primary,
        secondaryButtonStyle: RemoteMessageButtonAppearance = .secondary,
        cornerRadius: CGFloat = 16,
        contentAlignment: Alignment = .leading
    ) {
        self.appLogoSize = appLogoSize
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.messageFont = messageFont
        self.messageColor = messageColor
        self.backgroundColor = backgroundColor
        self.primaryButtonStyle = primaryButtonStyle
        self.secondaryButtonStyle = secondaryButtonStyle
        self.cornerRadius = cornerRadius
        self.contentAlignment = contentAlignment
    }

    public static let `default`: RemoteMessageAppearance = RemoteMessageAppearance(
        titleFont: .title3.bold(),
        titleColor: .black,
        messageFont: .footnote,
        messageColor: .black.opacity(0.8),
        backgroundColor: .white,
        primaryButtonStyle: .primary,
        secondaryButtonStyle: .secondary
    )
}

public struct RemoteMessageButtonAppearance: Sendable {

    let backgroundColor: Color
    let foregroundColor: Color
    let font: Font
    let cornerRadius: CGFloat

    public init(backgroundColor: Color, foregroundColor: Color, font: Font, cornerRadius: CGFloat = 8) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.font = font
        self.cornerRadius = cornerRadius
    }

    public static let primary: RemoteMessageButtonAppearance = RemoteMessageButtonAppearance(
        backgroundColor: .accentColor,
        foregroundColor: .white,
        font: .body
    )

    public static let secondary: RemoteMessageButtonAppearance = RemoteMessageButtonAppearance(
        backgroundColor: .gray.opacity(0.4),
        foregroundColor: .accentColor,
        font: .body
    )

}
