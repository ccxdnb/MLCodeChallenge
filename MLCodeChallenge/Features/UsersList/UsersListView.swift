//
//  UsersListView.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//

import SwiftUI

struct UsersListView: View {
    @Bindable var viewModel: UsersListViewModel

    init(viewModel: UsersListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        contentView
            .appBackground()
            .navigationTitle("Users")
            .searchable(text: $viewModel.searchText, prompt: "Search by name or city")
            .searchToolbarBehavior(.minimize)
            .task {
                if case .idle = viewModel.state {
                    await viewModel.load()
                }
            }
            .refreshable { await viewModel.refresh() }
            .alert("Delete Failed", isPresented: .init(
                get: { viewModel.deleteError != nil },
                set: { if !$0 { viewModel.deleteError = nil } }
            )) {
                Button("OK", role: .cancel) {
                    viewModel.deleteError = nil
                }
            } message: {
                if let error = viewModel.deleteError {
                    Text(error)
                }
            }
    }
}

extension UsersListView {
    @ViewBuilder
    private var contentView: some View {
        Group {
            switch viewModel.state {
            case .loading:
                VStack {
                    ProgressView()
                    Text("Loading...")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)

            case .loaded:
                loadedContent
                    .transition(.opacity)

            case .idle:
                Color.clear

            case .empty:
                EmptyStateView()
                    .transition(.opacity)

            case let .failed(message):
                FailedStateView(message: message) {
                    Task { await viewModel.load() }
                }
            }
        }.animation(.smooth(duration: 0.3), value: viewModel.state.caseID)
    }

    @ViewBuilder
    private var loadedContent: some View {
        Group {
            if viewModel.filteredUsers.isEmpty && !viewModel.searchText.isEmpty {
                ContentUnavailableView.search(text: viewModel.searchText)
                    .transition(.opacity)
            } else {
                userListView(users: viewModel.filteredUsers)
            }
        }
        .animation(.smooth(duration: 0.25), value: viewModel.filteredUsers.isEmpty)
    }

    @ViewBuilder
    private func userListView(users: [User]) -> some View {
        List {
            ForEach(users) { user in
                UserRowView(user: user) {
                    viewModel.didSelect(user)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .listRowBackground(Color.clear)
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    Task { await viewModel.deleteUser(users[index]) }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .animation(.smooth(duration: 0.25), value: users)
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
