//
//  RemoteMessageView.swift
//  GoodRemoteNotifier
//
//  Created by Marek Vríčan on 17/04/2025.
//

import SwiftUI

internal struct RemoteMessageView: View {

    // MARK: - Properties

    let localizedMessage: LocalizedRemoteMessage
    let appId: String
    let appearance: RemoteMessageAppearance
    @State private var isMessageVisible: Bool = false

    var multilineTextAlignment: TextAlignment {
        switch appearance.contentAlignment {
        case .leading: .leading
        case .trailing: .trailing
        default: .center

        }
    }

    // MARK: - Body

    var body: some View {
        Color.clear
            .ignoresSafeArea()
            .overlay(alignment: .center) {
                VStack(spacing: 16) {
                    appIcon()
                    remoteMessage
                    bottomButtonsView
                }
                .padding(16)
                .background(appearance.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(24)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 4, y: 4)
                .scaleEffect(isMessageVisible ? 1 : 0.7)
                .opacity(isMessageVisible ? 1 : 0)
                .onAppear {
                    withAnimation(.bouncy(duration: 0.4).delay(0.3)) {
                        isMessageVisible.toggle()
                    }
                }
            }
    }

}

// MARK: - Components

private extension RemoteMessageView {

    @ViewBuilder
    func appIcon() -> some View {
        if let iconSize = appearance.appLogoSize {
            Bundle.main.iconFileName
                .flatMap { UIImage(named: $0) }
                .map { Image(uiImage: $0) }?
                .resizable()
                .frame(width: iconSize, height: iconSize)
                .clipShape(RoundedRectangle(cornerRadius: iconSize * 0.2))
                .frame(maxWidth: .infinity, alignment: appearance.contentAlignment)
        }
    }

    var remoteMessage: some View {
        VStack(spacing: 16) {
            Group {
                Text(localizedMessage.title)
                    .foregroundStyle(appearance.titleColor)
                    .font(appearance.titleFont)

                Text(localizedMessage.message)
                    .foregroundStyle(appearance.messageColor)
                    .font(appearance.messageFont)
                    .fixedSizeScroll()
            }
            .frame(maxWidth: .infinity, alignment: appearance.contentAlignment)
            .multilineTextAlignment(multilineTextAlignment)
        }
        .padding(.bottom, 16)
    }

    var bottomButtonsView: some View {
        VStack {
            if let updateButtonTitle = localizedMessage.updateButton {
                Button(updateButtonTitle) {
                    openAppInAppStore()
                    if localizedMessage.closeButton != nil {
                        close()
                    }
                }
                .buttonStyle(MessageButtonStyle(appearance: appearance.primaryButtonStyle))
            }

            if let closeButtonTitle = localizedMessage.closeButton {
                Button(closeButtonTitle) {
                    close()
                }
                .buttonStyle(MessageButtonStyle(appearance: appearance.secondaryButtonStyle))
            }
        }
    }

}

// MARK: - Button handlers

private extension RemoteMessageView {

    func openAppInAppStore() {
        if let url = URL(string: "https://apps.apple.com/app/id\(appId)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func close() {
        Task {
            Task {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isMessageVisible = false

                }
                try? await Task.sleep(for: .seconds(0.4))

                WindowManager.shared.closeNewWindow()
            }
        }
    }

}
