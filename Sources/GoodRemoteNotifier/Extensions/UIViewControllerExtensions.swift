//
//  UIViewControllerExtensions.swift
//  GoodRemoteNotifier
//
//  Created by Marek Vríčan on 06/03/2025.
//

import UIKit

internal extension UIViewController {

    /// Adds a blur effect to the view with an animation.
    /// - Parameters:
    ///   - duration: The duration of the blur effect animation. Default is `0.2` seconds.
    ///   - completion: An optional closure that is called after the animation completes.
    func addBlurEffect(duration: TimeInterval = 0.2, completion: (() -> Void)? = nil) {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        blurView.layer.opacity = 0
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurView)

        UIView.animate(withDuration: duration) {
            blurView.layer.opacity = 1
        } completion: { _ in completion?() }
    }


    /// Removes the blur effect from the view with an animation.
    /// - Parameters:
    ///   - duration: The duration of the blur effect removal animation. Default is `0.2` seconds.
    ///   - completion: An optional closure that is called after the animation completes.
    func removeBlurEffect(duration: TimeInterval = 0.2, completion: (() -> Void)? = nil) {
        guard let blurView = view.subviews.first(where: { $0 is UIVisualEffectView }) else { return }

        UIView.animate(withDuration: duration) {
            blurView.layer.opacity = 0
        } completion: { _ in completion?() }
    }

}
