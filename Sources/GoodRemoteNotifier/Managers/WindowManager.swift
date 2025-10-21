//
//  WindowManager.swift
//  GoodRemoteNotifier
//
//  Created by Marek Vríčan on 06/03/2025.
//

import SwiftUI

/// A singleton class responsible for managing the presentation of a new window overlay.
@MainActor
internal final class WindowManager {

    /// The shared instance of `WindowManager`.
    internal static let shared = WindowManager()

    /// The reference to the newly created window.
    private var newWindow: UIWindow?

    /// Private initializer to enforce singleton usage.
    private init() {}

    /// Displays a new window and presents the given overlay view controller.
    /// - Parameter overlayController: The `UIViewController` to be presented in the new window.
    internal func showNewWindow(presenting overlayController: UIViewController) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              newWindow == nil else { return }

        let parentInterfaceStyle = scene.windows
            .first { $0.isKeyWindow }?
            .traitCollection
            .userInterfaceStyle ?? .unspecified

        let window = UIWindow(windowScene: scene)
        let presentingController = createPresentingController()

        window.overrideUserInterfaceStyle = parentInterfaceStyle
        window.rootViewController = presentingController
        window.windowLevel = .alert + 1
        window.makeKeyAndVisible()

        overlayController.modalPresentationStyle = .overFullScreen
        presentingController.present(overlayController, animated: false)

        self.newWindow = window
    }

    /// Closes the currently displayed window by removing its blur effect and hiding it.
    internal func closeNewWindow() {
        self.newWindow?.isHidden = true
        self.newWindow = nil
    }

    /// Creates a transparent `UIViewController` to act as the presenting controller for the new window.
    /// - Returns: A new `UIViewController` with a clear background.
    private func createPresentingController() -> UIViewController {
        let controller = UIViewController()
        return controller
    }

}
