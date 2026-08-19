import Testing
import Foundation
@testable import MLCodeChallenge

@MainActor
@Suite
struct UserDetailViewModelTests {
    @Test
    @MainActor
    func didTapViewAlbumsNavigatesToAlbums() {
        let user = User.stub
        let coordinator = AppCoordinatorSpy()
        let viewModel = makeViewModel(coordinator: coordinator, user: user)

        viewModel.didTapViewAlbums()

        #expect(coordinator.pushToCalls.count == 1)
        guard case .albums(let pushedUser) = coordinator.pushToCalls.first else {
            Issue.record("Expected .albums route")
            return
        }
        #expect(pushedUser == user)
    }

    @Test

    func exposesUser() {
        let user = User.stub
        let viewModel = makeViewModel(user: user)

        #expect(viewModel.user == user)
    }

    private func makeViewModel(
        coordinator: AppCoordinatorProtocol = AppCoordinatorSpy(),
        user: User = .stub
    ) -> UserDetailViewModel {
        UserDetailViewModel(dependencies: .init(
            coordinator: coordinator,
            user: user
        ))
    }
}
