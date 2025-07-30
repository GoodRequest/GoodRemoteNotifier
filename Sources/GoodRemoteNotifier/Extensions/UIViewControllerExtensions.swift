//
//  UIViewControllerExtensions.swift
//  GoodRemoteNotifier
//
//  Created by Marek Vríčan on 06/03/2025.
//

import UIKit

internal extension UIViewController {

    func addBackgroundEffect(_ effect: PresentingEffect, completion: @escaping () -> Void) {
        let backgroundView: UIView

        switch effect {
        case .blur(let style):
            let blur = UIBlurEffect(style: style)
            backgroundView = UIVisualEffectView(effect: blur)

        case .dim(let opacity):
            let dimView = UIView()
            dimView.backgroundColor = UIColor.black.withAlphaComponent(opacity)
            backgroundView = dimView
        }

        backgroundView.frame = view.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.alpha = 0
        view.addSubview(backgroundView)

        UIView.animate(withDuration: 0.2, animations: {
            backgroundView.alpha = 1
        }, completion: { _ in
            completion()
        })
    }

    func removeBlurEffect(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.subviews.forEach {
                if $0 is UIVisualEffectView || $0.backgroundColor?.cgColor.alpha ?? 0 > 0 {
                    $0.alpha = 0
                }
            }
        }, completion: { _ in
            self.view.subviews.forEach {
                if $0 is UIVisualEffectView || $0.backgroundColor?.cgColor.alpha ?? 0 > 0 {
                    $0.removeFromSuperview()
                }
            }
            completion()
        })
    }

}
