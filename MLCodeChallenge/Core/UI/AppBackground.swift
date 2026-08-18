//
//  AppBackground.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//
import SwiftUI

struct AppBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                MeshGradient(
                    width: 3,
                    height: 3,
                    points: [
                        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                        [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                    ],
                    colors: [
                        .indigo.opacity(0.15), .blue.opacity(0.1), .cyan.opacity(0.12),
                        .blue.opacity(0.08), .clear, .indigo.opacity(0.08),
                        .clear, .clear, .clear
                    ]
                )
                .ignoresSafeArea()

            }
    }
}

extension View {
    func appBackground() -> some View { modifier(AppBackground()) }
}
