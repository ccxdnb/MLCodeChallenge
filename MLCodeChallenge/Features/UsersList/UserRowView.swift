//
//  UserRowView.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//

import SwiftUI

struct UserRowView: View {
    let user: User
    let coordinator: AppCoordinatorProtocol

    var body: some View {
        HStack(spacing: 12) {
            // User info section
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)

                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(user.company.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Action buttons
            HStack(spacing: 8) {
                // Phone button
                if let phoneURL = URL(string: "tel:\(user.phone)") {
                    Link(destination: phoneURL) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(red: 0.2, green: 0.78, blue: 0.35), Color(red: 0.18, green: 0.7, blue: 0.32)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color: Color(red: 0.2, green: 0.78, blue: 0.35).opacity(0.3), radius: 4, x: 0, y: 2)
                            )
                    }
                    .buttonStyle(.plain)
                } else {
                    VStack {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(
                                .gray
                            )
                    }
                    .buttonStyle(.plain)
                }

                // Email button
                if let mailURL = URL(string: "mailto:\(user.email)") {
                    Link(destination: mailURL) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(red: 0.0, green: 0.48, blue: 1.0), Color(red: 0.0, green: 0.42, blue: 0.9)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color: Color(red: 0.0, green: 0.48, blue: 1.0).opacity(0.3), radius: 4, x: 0, y: 2)
                            )
                    }
                    .buttonStyle(.plain)
                } else {
                    VStack {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(
                                .gray
                            )
                    }
                    .buttonStyle(.plain)
                }

                // Map button
                Button {
                    coordinator.pushTo(.map(user))
                } label: {
                    Image(systemName: "map.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 1.0, green: 0.58, blue: 0.0), Color(red: 0.95, green: 0.52, blue: 0.0)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: Color(red: 1.0, green: 0.58, blue: 0.0).opacity(0.3), radius: 4, x: 0, y: 2)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

#Preview {
    UserRowView(user: .stub, coordinator: AppCoordinator())
}
