//
//  UserDetailViewModel.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//

import Foundation
import Observation

@Observable
final class UserDetailViewModel {
    struct Dependencies {
        let coordinator: AppCoordinatorProtocol
        let user: User
    }

    let user: User
    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.user = dependencies.user
    }

    func didTapViewAlbums() {
        dependencies.coordinator.pushTo(.albums(user))
    }
}
