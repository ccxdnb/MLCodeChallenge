//
//  ReadableContentWidth.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/18/26.
//

import SwiftUI

/// View modifier that constrains content to a readable maximum width on larger screens
/// while preserving full width on compact size classes.
struct ReadableContentWidth: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var maxWidth: CGFloat {
        horizontalSizeClass == .regular ? 700 : .infinity
    }

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: maxWidth)
            .frame(maxWidth: .infinity)
    }
}

extension View {
    /// Constrains the view to a readable maximum width on larger screens.
    /// On compact size classes (iPhone), content uses full width.
    /// On regular size classes (iPad), content is limited to 700pt and centered.
    func readableContentWidth() -> some View {
        modifier(ReadableContentWidth())
    }
}
