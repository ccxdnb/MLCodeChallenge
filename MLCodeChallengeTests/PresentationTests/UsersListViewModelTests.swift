//
//  UsersListViewModelTests.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//
import Foundation
import Testing
@testable import MLCodeChallenge

@Suite("UsersListViewModel")
@MainActor
struct UsersListViewModelTests {
    private struct SUTResponse {
        let usersListViewModel: UsersListViewModel
        let usersServiceMock: UsersServiceMock
        let appCoordinatorSpy: AppCoordinatorSpy
    }

    private func makeSUT(result: Result<[User], Error>) -> SUTResponse {
        let service = UsersServiceMock()
        let spy = AppCoordinatorSpy()
        service.result = result
        let sut = UsersListViewModel(
            dependencies: .init(
                usersService: service,
                coordinator: spy
            )
        )
        return SUTResponse(
            usersListViewModel: sut,
            usersServiceMock: service,
            appCoordinatorSpy: spy
        )
    }

    @Test("Starts in idle")
    func startsIdle() {
        let response = makeSUT(result: .success([]))
        guard case .idle = response.usersListViewModel.state else {
            Issue.record("Expected .idle, got \(response.usersListViewModel.state)")
            return
        }
    }

    @Test("Loads users into loaded")
    func loadsUsers() async {
        let response = makeSUT(result: .success([.stub]))
        await response.usersListViewModel.load()

        guard case .loaded(let users) = response.usersListViewModel.state else {
            Issue.record("Expected .loaded, got \(response.usersListViewModel.state)")
            return
        }
        #expect(users.count == 1)
        #expect(response.usersServiceMock.callCount == 1)
    }

    @Test("Empty response produces empty state")
    func emptyResponse() async {
        let response = makeSUT(result: .success([]))
        await response.usersListViewModel.load()

        guard case .empty = response.usersListViewModel.state else {
            Issue.record("Expected .empty, got \(response.usersListViewModel.state)")
            return
        }
    }

    @Test("API error surfaces its message")
    func apiErrorMessage() async {
        let response = makeSUT(result: .failure(APIError.notFound))
        await response.usersListViewModel.load()

        guard case .failed(let message) = response.usersListViewModel.state else {
            Issue.record("Expected .failed, got \(response.usersListViewModel.state)")
            return
        }
        #expect(message == APIError.notFound.errorDescription)
    }

    @Test("Unknown error falls back to generic message")
    func unknownError() async {
        struct SomeError: Error {}
        let response = makeSUT(result: .failure(SomeError()))
        await response.usersListViewModel.load()

        guard case .failed = response.usersListViewModel.state else {
            Issue.record("Expected .failed, got \(response.usersListViewModel.state)")
            return
        }
    }

    @Test("Refresh refetches without clearing loaded state")
    func refreshRefetches() async {
        let response = makeSUT(result: .success([.stub]))
        await response.usersListViewModel.load()

        response.usersServiceMock.result = .success([.stub, .anotherStub])
        await response.usersListViewModel.refresh()

        guard case .loaded(let users) = response.usersListViewModel.state else {
            Issue.record("Expected .loaded, got \(response.usersListViewModel.state)")
            return
        }
        #expect(users.count == 2)
        #expect(response.usersServiceMock.callCount == 2)
    }

    // MARK: - Navigation Tests

    @Test("Selecting user triggers coordinator pushTo")
    func selectUserTriggersNavigation() {
        let response = makeSUT(result: .success([]))
        let user = User.stub

        response.usersListViewModel.didSelect(user)

        #expect(response.appCoordinatorSpy.pushToCalls.count == 1)
        #expect(response.appCoordinatorSpy.pushToCalls.first == .map(user))
    }

    // MARK: - Search Tests

    @Test("Empty search returns all users")
    func emptySearchReturnsAll() async {
        let response = makeSUT(result: .success([.stub, .anotherStub]))
        await response.usersListViewModel.load()

        response.usersListViewModel.searchText = ""

        #expect(response.usersListViewModel.filteredUsers.count == 2)
    }

    @Test("Search by name matches case-insensitively")
    func searchByName() async {
        let response = makeSUT(result: .success([.stub, .anotherStub]))
        await response.usersListViewModel.load()

        response.usersListViewModel.searchText = "leanne"

        #expect(response.usersListViewModel.filteredUsers.count == 1)
        #expect(response.usersListViewModel.filteredUsers.first?.name == "Leanne Graham")
    }

    @Test("Search by city matches case-insensitively")
    func searchByCity() async {
        let response = makeSUT(result: .success([.stub, .citySearchStub]))
        await response.usersListViewModel.load()

        response.usersListViewModel.searchText = "springfield"

        #expect(response.usersListViewModel.filteredUsers.count == 1)
        #expect(response.usersListViewModel.filteredUsers.first?.address.city == "Springfield")
    }

    @Test("No matches returns empty array")
    func noMatches() async {
        let response = makeSUT(result: .success([.stub, .anotherStub]))
        await response.usersListViewModel.load()

        response.usersListViewModel.searchText = "nonexistent"

        #expect(response.usersListViewModel.filteredUsers.isEmpty)
    }

    @Test("Non-loaded state returns empty array")
    func nonLoadedStateReturnsEmpty() {
        let response = makeSUT(result: .success([.stub]))

        response.usersListViewModel.searchText = "Leanne"

        #expect(response.usersListViewModel.filteredUsers.isEmpty)
    }

    // MARK: - Delete Tests

    @Test("Delete user removes it from loaded state")
    func deleteUserRemovesFromState() async {
        let response = makeSUT(result: .success([.stub, .anotherStub]))
        await response.usersListViewModel.load()

        response.usersServiceMock.deleteResult = .success(())
        await response.usersListViewModel.deleteUser(.stub)

        guard case .loaded(let users) = response.usersListViewModel.state else {
            Issue.record("Expected .loaded, got \(response.usersListViewModel.state)")
            return
        }
        #expect(users.count == 1)
        #expect(users.first?.id == User.anotherStub.id)
        #expect(response.usersServiceMock.deleteCallCount == 1)
        #expect(response.usersServiceMock.lastDeletedUserId == User.stub.id)
    }

    @Test("Delete user failure restores the user and surfaces the error")
    func deleteUserFailureRestoresUser() async {
        let response = makeSUT(result: .success([.stub, .anotherStub]))
        await response.usersListViewModel.load()

        response.usersServiceMock.deleteResult = .failure(APIError.server(statusCode: 500))
        await response.usersListViewModel.deleteUser(.stub)

        guard case .loaded(let users) = response.usersListViewModel.state else {
            Issue.record("Expected .loaded, got \(response.usersListViewModel.state)")
            return
        }
        #expect(users.count == 2)
        #expect(users.contains { $0.id == User.stub.id })
        #expect(response.usersListViewModel.deleteError == APIError.server(statusCode: 500).errorDescription)
    }

    @Test("Delete does not call the service when state is not loaded")
    func deleteWithoutLoadedStateDoesNothing() async {
        let response = makeSUT(result: .success([]))

        await response.usersListViewModel.deleteUser(.stub)

        #expect(response.usersServiceMock.deleteCallCount == 0)
    }

    // MARK: - Cancellation

    @Test("Cancelled error leaves the previous state untouched")
    func cancelledErrorDoesNotChangeState() async {
        let response = makeSUT(result: .success([.stub]))
        await response.usersListViewModel.load()

        response.usersServiceMock.result = .failure(APIError.cancelled)
        await response.usersListViewModel.refresh()

        guard case .loaded(let users) = response.usersListViewModel.state else {
            Issue.record("Expected .loaded, got \(response.usersListViewModel.state)")
            return
        }
        #expect(users.count == 1)
    }
}

extension User {
    static let stub = User(
        id: 1,
        name: "Leanne Graham",
        username: "Bret",
        email: "Sincere@april.biz",
        address: .init(
            street: "Kulas Light",
            suite: "Apt. 556",
            city: "Gwenborough",
            zipcode: "92998-3874",
            geo: .init(latitude: -37.3159, longitude: 81.1496)
        ),
        phone: "1-770-736-8031 x56442",
        website: "hildegard.org",
        company: .init(
            name: "Romaguera-Crona",
            catchPhrase: "Multi-layered client-server neural-net",
            bs: "harness real-time e-markets"
        )
    )

    static let anotherStub = User(
        id: 9,
        name: "Glenna Reichert",
        username: "Delphine",
        email: "Chaim_McDermott@dana.io",
        address: .init(
            street: "Dayna Park",
            suite: "Suite 449",
            city: "Bartholomebury",
            zipcode: "76495-3109",
            geo: .init(latitude: 24.6463, longitude: -168.8889)
        ),
        phone: "(775)976-6794 x41206",
        website: "conrad.com",
        company: .init(
            name: "Yost and Sons",
            catchPhrase: "Switchable contextually-based project",
            bs: "aggregate real-time technologies"
        )
    )

    static let citySearchStub = User(
        id: 3,
        name: "Homer Simpson",
        username: "homer",
        email: "homer@springfield.com",
        address: .init(
            street: "742 Evergreen Terrace",
            suite: "",
            city: "Springfield",
            zipcode: "12345",
            geo: .init(latitude: 39.7392, longitude: -104.9903)
        ),
        phone: "555-0100",
        website: "springfield.gov",
        company: .init(
            name: "Springfield Nuclear Power Plant",
            catchPhrase: "Safe and reliable energy",
            bs: "nuclear energy management"
        )
    )
}
