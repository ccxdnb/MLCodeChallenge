//
//  ShakeGestureViewModifier.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/18/26.
//

import SwiftUI

/// ViewModifier that detects device shake gestures
struct ShakeGestureViewModifier: ViewModifier {
    let onShake: () -> Void

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                onShake()
            }
    }
}

extension View {
    /// Adds a shake gesture handler to the view
    func onShake(perform action: @escaping () -> Void) -> some View {
        modifier(ShakeGestureViewModifier(onShake: action))
    }
}

// MARK: - UIDevice Extension for Shake Detection

extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name("deviceDidShakeNotification")
}

// MARK: - UIWindow Extension to Detect Shake

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}
