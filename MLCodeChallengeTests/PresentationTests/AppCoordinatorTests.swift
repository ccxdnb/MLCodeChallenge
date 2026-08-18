//
//  AppCoordinatorTests.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//
import Foundation
import Testing
@testable import MLCodeChallenge

@Suite("AppCoordinator")
@MainActor
struct AppCoordinatorTests {

    @Test("Starts with an empty path")
    func startsEmpty() {
        let sut = AppCoordinator()
        #expect(sut.path.isEmpty)
    }

    @Test("Pushing a map route appends to path")
    func pushToAppendsRoute() {
        let sut = AppCoordinator()

        sut.pushTo(.map(.stub))

        #expect(sut.path == [.map(.stub)])
    }

    @Test("Pushing multiple routes stacks them")
    func stacksMultipleRoutes() {
        let sut = AppCoordinator()

        sut.pushTo(.map(.stub))
        sut.pushTo(.map(.anotherStub))

        #expect(sut.path.count == 2)
    }

    @Test("Presenting a route sets presentedSheet")
    func presentSetsSheet() {
        let sut = AppCoordinator()

        sut.present(.map(.stub))

        #expect(sut.presentedSheet == .map(.stub))
    }

    @Test("Dismissing sheet clears presentedSheet")
    func dismissSheetClearsSheet() {
        let sut = AppCoordinator()
        sut.present(.map(.stub))

        sut.dismissSheet()

        #expect(sut.presentedSheet == nil)
    }

    @Test("Returns the same view model instance on repeated calls")
    func cachesViewModel() {
        let sut = ViewModelFactory(
            usersService: UsersServiceMock(),
            albumsService: AlbumsServiceMock(),
            photosService: PhotosServiceMock(),
            imageLoader: ImageLoader(cache: ImageCache()),
            coordinator: AppCoordinatorSpy()
        )

        let first = sut.makeUsersListViewModel()
        let second = sut.makeUsersListViewModel()

        #expect(first === second)
    }
}
