//
//  RemoteMessageTheme.swift
//  GoodRemoteNotifier-Sample
//
//  Created by Marek Vríčan on 26/09/2025.
//

import GoodRemoteNotifier
import SwiftUI

public enum RemoteMessageTheme: String, Codable, CaseIterable {

    case classic
    case modern
    case dark

    public var appearance: RemoteMessageAppearance {
        switch self {
        case .classic:
            return RemoteMessageAppearance(
                titleFont: .system(size: 20, weight: .bold),
                titleColor: .black,
                messageFont: .footnote,
                messageColor: .black.opacity(0.8),
                backgroundColor: .white,
                primaryButtonStyle: .primary,
                secondaryButtonStyle: .secondary,
                cornerRadius: 12,
                contentAlignment: .leading
            )

        case .modern:
            return RemoteMessageAppearance(
                appLogoSize: 60,
                titleFont: .system(size: 22, weight: .semibold, design: .rounded),
                titleColor: .blue,
                messageFont: .callout,
                messageColor: .gray,
                backgroundColor: Color(UIColor.systemGray6),
                primaryButtonStyle: RemoteMessageButtonAppearance(
                    backgroundColor: .blue,
                    foregroundColor: .white,
                    font: .headline,
                    cornerRadius: 12
                ),
                secondaryButtonStyle: RemoteMessageButtonAppearance(
                    backgroundColor: .clear,
                    foregroundColor: .blue,
                    font: .headline,
                    cornerRadius: 12
                ),
                cornerRadius: 24,
                contentAlignment: .center
            )

        case .dark:
            return RemoteMessageAppearance(
                titleFont: .system(size: 20, weight: .bold),
                titleColor: .white,
                messageFont: .footnote,
                messageColor: .white.opacity(0.8),
                backgroundColor: .black,
                primaryButtonStyle: RemoteMessageButtonAppearance(
                    backgroundColor: .white,
                    foregroundColor: .black,
                    font: .body,
                    cornerRadius: 8
                ),
                secondaryButtonStyle: RemoteMessageButtonAppearance(
                    backgroundColor: .gray.opacity(0.6),
                    foregroundColor: .white,
                    font: .body,
                    cornerRadius: 8
                ),
                cornerRadius: 16,
                contentAlignment: .leading
            )
        }
    }
    
}
