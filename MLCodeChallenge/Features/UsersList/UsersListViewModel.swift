//
//  UsersListViewModel.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//
import Foundation
import Observation

@Observable
final class UsersListViewModel {
    struct Dependencies {
        let usersService: UsersServiceProtocol
        let coordinator: AppCoordinatorProtocol
    }

    private(set) var state: ViewState<[User]> = .idle
    var searchText: String = ""
    
    var filteredUsers: [User] {
        guard case .loaded(let users) = state else { return [] }
        guard !searchText.isEmpty else { return users }
        
        return users.filter { user in
            user.name.localizedCaseInsensitiveContains(searchText) ||
            user.address.city.localizedCaseInsensitiveContains(searchText)
        }
    }

    private let dependencies: Dependencies
    
    var coordinator: AppCoordinatorProtocol {
        dependencies.coordinator
    }

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func load() async {
         state = .loading
         await fetch()
     }

     func refresh() async {
         // no toca el estado: la lista sigue en pantalla
         await fetch()
     }

    func fetch() async {
        do {
            let users = try await dependencies.usersService.users()
            state = users.isEmpty ? .empty : .loaded(users)
        } catch let error as APIError {
            state = .failed(error.errorDescription ?? "Unexpected error")
        } catch {
            state = .failed("Unexpected error")
        }
    }

    func didSelect(_ user: User) {
        dependencies.coordinator.pushTo(.map(user))
    }
}
