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
    var deleteError: String?

    var filteredUsers: [User] {
        guard case .loaded(let users) = state else { return [] }
        guard !searchText.isEmpty else { return users }

        return users.filter { user in
            user.name.localizedCaseInsensitiveContains(searchText) ||
            user.address.city.localizedCaseInsensitiveContains(searchText)
        }
    }

    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func load() async {
         state = .loading
         await fetch()
     }

     func refresh() async {
         await fetch()
     }

    private func fetch() async {
        do {
            let users = try await dependencies.usersService.users()
            state = users.isEmpty ? .empty : .loaded(users)
        } catch APIError.cancelled {
            // we dont react to cancelations
            return
        } catch let error as APIError {
            state = .failed(error.errorDescription ?? "Unexpected error")
        } catch {
            state = .failed("Unexpected error")
        }
    }

    func showMap(for user: User) {
        dependencies.coordinator.pushTo(.map(user))
    }

    func showDetail(for user: User) {
        dependencies.coordinator.pushTo(.userDetail(user))
    }

    func deleteUser(_ user: User) async {
        guard case .loaded(let original) = state else { return }

        let remaining = original.filter { $0.id != user.id }
        state = remaining.isEmpty ? .empty : .loaded(remaining)

        do {
            try await dependencies.usersService.deleteUser(userID: user.id)
        } catch APIError.cancelled {
            return
        } catch {
            state = .loaded(original)
            deleteError = (error as? APIError)?.errorDescription ?? "Failed to delete user"
        }
    }
}
