//
//  UsersListView.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//

import SwiftUI

struct UsersListView: View {
    @State private var viewModel: UsersListViewModel

    init(viewModel: UsersListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        contentView
            .appBackground()
            .navigationTitle("Users")
            .searchable(text: $viewModel.searchText, prompt: "Search by name or city")
            .searchToolbarBehavior(.minimize)
            .task { await viewModel.load() }
            .refreshable { await viewModel.refresh() }
    }
}

extension UsersListView {
    @ViewBuilder
    private var contentView: some View {
        VStack(spacing: 0) {
            switch viewModel.state {
            case .loading:
                VStack {
                    ProgressView()
                    Text("Loading...")
                }.frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded:
                if viewModel.filteredUsers.isEmpty && !viewModel.searchText.isEmpty {
                    ContentUnavailableView.search(text: viewModel.searchText)
                } else {
                    userListView(users: viewModel.filteredUsers)
                }

            case .idle:
                Text("Idle")

            case .empty:
                EmptyStateView()

            case let .failed(message):
                FailedStateView(message: message) {
                    Task { await viewModel.load() }
                }
            }
        }
    }

    @ViewBuilder
    private func userListView(users: [User]) -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(users, id: \.hashValue) { user in
                    UserRowView(user: user, coordinator: viewModel.coordinator)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    UsersListView(
        viewModel: .init(dependencies:
                .init(usersService: UsersService(client: HTTPClient()),
                      coordinator: AppCoordinator())
        )
    )
}
