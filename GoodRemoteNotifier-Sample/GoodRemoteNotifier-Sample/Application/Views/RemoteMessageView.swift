//
//  RemoteMessageView.swift
//  GoodRemoteNotifier-Sample
//
//  Created by Marek Vríčan on 20/10/2025.
//

import SwiftUI
import GoodRemoteNotifier

struct RemoteMessageView: View {

    // MARK: - Properties

    let model: RemoteMessageViewProviderModel
    @State private var isMessageVisible: Bool = false

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 16) {
            appIcon()
            remoteMessage
            bottomButtonsView
        }
        .padding(16)
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(24)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 4, y: 4)
        .scaleEffect(isMessageVisible ? 1 : 0.7)
        .opacity(isMessageVisible ? 1 : 0)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background{
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .opacity(isMessageVisible ? 1 : 0)
                .animation(.linear(duration: 0.2).delay(!isMessageVisible ? 0.5 : 0), value: isMessageVisible)
        }
        .onAppear {
            withAnimation(.bouncy(duration: 0.3).delay(0.3)) {
                isMessageVisible.toggle()
            }
        }
    }

}

// MARK: - Components

private extension RemoteMessageView {

    @ViewBuilder
    func appIcon() -> some View {
        Image.appIcon?
            .resizable()
            .frame(width: 40, height: 40)
            .clipShape(RoundedRectangle(cornerRadius: 40 * 0.2))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    var remoteMessage: some View {
        VStack(spacing: 16) {
            Group {
                Text(model.localizedMessage.title)
                    .foregroundStyle(.white)
                    .font(.title.bold())

                Text(model.localizedMessage.message)
                    .foregroundStyle(.white.opacity(0.8))
                    .font(.body)
                    .fixedSizeScroll()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
        }
        .padding(.bottom, 16)
    }

    var bottomButtonsView: some View {
        VStack {
            if let updateButtonTitle = model.localizedMessage.updateButton {
                Button(updateButtonTitle) {
                    model.openInAppStore()
                    if model.localizedMessage.closeButton != nil || model.localizedMessage.frequency != .always {
                        close()
                    }
                }
                .buttonStyle(MessageButtonStyle(isPrimary: true))
            }

            if let closeButtonTitle = model.localizedMessage.closeButton {
                Button(closeButtonTitle) {
                    close()
                }
                .buttonStyle(MessageButtonStyle(isPrimary: false))
            }
        }
    }

}

// MARK: - Button handlers

private extension RemoteMessageView {

    func close() {
        Task {
            Task {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isMessageVisible = false
                }
                try? await Task.sleep(nanoseconds: 800_000_000)

                model.close()
            }
        }
    }

    struct MessageButtonStyle: ButtonStyle {

        let isPrimary: Bool

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.body)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(isPrimary ? .white : .white )
                .background(isPrimary ? Color.accentColor : Color.gray.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .scaleEffect(configuration.isPressed ? 0.98 : 1)
                .animation(.snappy, value: configuration.isPressed)
        }

    }

}
