//
//  UserRowView.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//

import SwiftUI

struct UserRowView: View {
    let user: User
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
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

            actionButtons
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }

    @ViewBuilder
    private var actionButtons: some View {
        HStack(spacing: 8) {
            if let phoneURL = URL(string: "tel:\(user.phone)") {
                Link(destination: phoneURL) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color.green)
                                .shadow(color: Color.green.opacity(0.3), radius: 4, x: 0, y: 2)
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

            if let mailURL = URL(string: "mailto:\(user.email)") {
                Link(destination: mailURL) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color.indigo)
                                .shadow(color: Color.indigo.opacity(0.3), radius: 4, x: 0, y: 2)
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

            Button {
                onTap()
            } label: {
                Image(systemName: "map.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color.orange)
                            .shadow(color: Color.orange.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    UserRowView(user: .stub, onTap: { })
}
