//
//  ViewExtensions.swift
//  GoodRemoteNotifier
//
//  Created by Marek Vríčan on 30/07/2025.
//

import SwiftUI

extension View {

    @ViewBuilder
    func styledForeground(_ color: Color) -> some View {
        if #available(iOS 15, *) {
            self.foregroundStyle(color)
        } else {
            self.foregroundColor(color)
        }
    }

    @ViewBuilder
    func applySafeAreaIgnoring(_ edges: Edge.Set = .all) -> some View {
        if #available(iOS 14.0, *) {
            self.ignoresSafeArea(.container, edges: edges)
        } else {
            self
        }
    }

    @ViewBuilder
    func alignedOverlay<Overlay: View>(
        alignment: Alignment = .center,
        @ViewBuilder content: () -> Overlay
    ) -> some View {
        if #available(iOS 15.0, *) {
            self.overlay(alignment: alignment, content: content)
        } else {
            ZStack(alignment: alignment) {
                self
                content()
            }
        }
    }

}
