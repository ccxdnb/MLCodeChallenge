//
//  AppRootView.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//

import SwiftUI

struct AppRootView: View {
    @State private var coordinator = AppCoordinator()
    @State private var factory: ViewModelFactory

    init(usersService: UsersServiceProtocol) {
        let coordinator = AppCoordinator()
        _coordinator = State(initialValue: coordinator)
        _factory = State(initialValue: ViewModelFactory(
            usersService: usersService,
            coordinator: coordinator
        ))
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            UsersListView(viewModel: factory.makeUsersListViewModel())
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
            UserMapView(user: user)

        case let .userDetail(user):
            EmptyView()
        }
    }
}

#Preview {
    AppRootView(usersService: UsersService(client: HTTPClient()))
}
