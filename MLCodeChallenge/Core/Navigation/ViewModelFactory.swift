//
//  ViewModelFactory.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//

import Foundation

final class ViewModelFactory {
    private let usersService: UsersServiceProtocol
    private let coordinator: AppCoordinatorProtocol

    private var usersListViewModel: UsersListViewModel?

    init(usersService: UsersServiceProtocol, coordinator: AppCoordinatorProtocol) {
        self.usersService = usersService
        self.coordinator = coordinator
    }

    func makeUsersListViewModel() -> UsersListViewModel {
        if let existing = usersListViewModel {
            return existing
        }

        let viewModel = UsersListViewModel(
            dependencies: .init(usersService: usersService, coordinator: coordinator)
        )
        usersListViewModel = viewModel
        return viewModel
    }
}
