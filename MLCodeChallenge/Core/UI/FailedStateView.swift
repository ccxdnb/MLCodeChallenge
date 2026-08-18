//
//  FailedStateView.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//
import SwiftUI

struct FailedStateView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Label("Error", systemImage: "exclamationmark.triangle")
                .font(.title2)
                .foregroundStyle(.red)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Retry") {
                retryAction()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    FailedStateView(message: "Failed to load data") {
        print("Retry tapped")
    }
}
