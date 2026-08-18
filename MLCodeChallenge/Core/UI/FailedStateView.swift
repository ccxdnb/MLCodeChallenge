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
        VStack {
            Label("Error", systemImage: "exclamationmark.triangle")

            Text(message)

            Button("Retry") {
                retryAction()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .padding()
    }
}

#Preview {
    FailedStateView(message: "Failed to load data") {
        print("Retry tapped")
    }
}
