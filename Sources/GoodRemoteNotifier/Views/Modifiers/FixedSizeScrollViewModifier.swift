//
//  FixedSizeScrollView.swift
//  GoodRemoteNotifier
//
//  Created by Marek Vríčan on 17/04/2025.
//

import SwiftUI

/// A view modifier that adds a fixed-size scroll view to content, scrolling along the specified axis when needed.
///
/// - Parameters:
///   - axis: The scroll direction. Can be `.horizontal`, `.vertical`, or `.both`. Default is `.vertical`.
/// - Returns: A view that may scroll if content doesn't fit within available space.
public struct FixedSizeScrollViewModifier: ViewModifier {

    let axis: Axis.Set

    public func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            ViewThatFits(in: axis) {
                content
                ScrollView(axis) {
                    content
                }
                .scrollIndicators(.hidden)
            }
        } else {
            ScrollView {
                content
            }
        }
    }
}

extension View {

    /// Applies the `FixedSizeScrollViewModifier`, enabling scrolling on content.
    ///
    /// - Parameter axis: The scroll direction. Default is `.vertical`.
    /// - Returns: A view with scroll behavior applied.
    public func fixedSizeScroll(_ axis: Axis.Set = .vertical) -> some View {
        modifier(FixedSizeScrollViewModifier(axis: axis))
    }
    
}
