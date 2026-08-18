//
//  EmptyStateView.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//
import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        ContentUnavailableView(
            "No Data",
            systemImage: "tray",
            description: Text("There's nothing to show here")
        )
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .padding()
    }
}

#Preview {
    EmptyStateView()
}
