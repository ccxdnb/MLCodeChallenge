//
//  UserDetailView.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/18/26.
//

import SwiftUI

struct UserDetailView: View {
    @Bindable var viewModel: UserDetailViewModel

    init(viewModel: UserDetailViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    header
                    contactSection
                    companySection
                    addressSection
                    albumsButton
                }
                .readableContentWidth()
                .padding()
            }
            .appBackground()
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 6) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)

            Text(viewModel.user.name)
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)

            Text("@\(viewModel.user.username)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private var contactSection: some View {
        DetailSection(title: "Contact") {
            DetailRow(icon: "envelope.fill", value: viewModel.user.email)
            DetailRow(icon: "phone.fill", value: viewModel.user.phone)
            DetailRow(icon: "globe", value: viewModel.user.website)
        }
    }

    private var companySection: some View {
        DetailSection(title: "Company") {
            DetailRow(icon: "building.2.fill", value: viewModel.user.company.name)
            DetailRow(icon: "quote.opening", value: viewModel.user.company.catchPhrase)
        }
    }

    private var addressSection: some View {
        DetailSection(title: "Address") {
            DetailRow(
                icon: "mappin.and.ellipse",
                value: "\(viewModel.user.address.street), \(viewModel.user.address.suite)"
            )
            DetailRow(icon: "building.fill", value: viewModel.user.address.city)
            DetailRow(icon: "number", value: viewModel.user.address.zipcode)

        }.frame(maxWidth: .infinity)
    }

    private var albumsButton: some View {
        Button(action: viewModel.didTapViewAlbums) {
            HStack {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.body.weight(.medium))

                Text("View albums")
                    .font(.body.weight(.medium))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
            }
            .foregroundStyle(.primary)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
            )
        }
    }
}

// MARK: - Building blocks

private struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            VStack(alignment: .leading, spacing: 12) {
                content
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
            )
        }.frame(maxWidth: .infinity)
    }
}

private struct DetailRow: View {
    let icon: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.subheadline)
                    .textSelection(.enabled)
            }
            Spacer()
        }.frame(maxWidth: .infinity)
    }
}

#Preview {
    UserDetailView(
        viewModel: .init(dependencies: .init(
            coordinator: AppCoordinator(),
            user: .stub
        ))
    )
}
