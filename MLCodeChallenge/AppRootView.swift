//
//  AppRootView.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//

import SwiftUI

struct AppRootView: View {
    @State private var coordinator = AppCoordinator()

    private let usersService: UsersServiceProtocol

    init(usersService: UsersServiceProtocol) {
        self.usersService = usersService
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            UsersListView(
                viewModel: UsersListViewModel(
                    dependencies: .init(
                        usersService: usersService,
                        coordinator: coordinator
                    )
                )
            )
            .navigationDestination(for: Route.self) { route in
                self.destinationFor(route)
            }
        }
    }
}

extension AppRootView {
    @ViewBuilder
    func destinationFor(_ route: Route) -> some View {
        switch route {
        case .map(let user):
            UserMapView()

        case let .userDetail(user):
            EmptyView()
        }
    }
}

#Preview {
    AppRootView(usersService: UsersService(client: HTTPClient()))
}
