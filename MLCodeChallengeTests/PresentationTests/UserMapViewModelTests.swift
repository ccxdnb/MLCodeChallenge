//
//  UserMapViewModelTests.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//

import Testing
import Foundation
import CoreLocation
@testable import MLCodeChallenge

@MainActor
@Suite
struct UserMapViewModelTests {
    @Test
    @MainActor
    func coordinateIsDerivedFromUserGeo() {
        let user = User.stub
        let viewModel = makeViewModel(user: user)

        #expect(viewModel.coordinate.latitude == user.address.geo.latitude)
        #expect(viewModel.coordinate.longitude == user.address.geo.longitude)
    }

    @Test
    @MainActor
    func fullAddressFormatsCorrectly() {
        let user = User.stub
        let viewModel = makeViewModel(user: user)

        let expected = "\(user.address.street), \(user.address.suite)\n\(user.address.city), \(user.address.zipcode)"
        #expect(viewModel.fullAddress == expected)
    }

    @Test
    @MainActor
    func coordinateStringFormatsCorrectly() {
        let user = User(
            id: 1,
            name: "Test",
            username: "test",
            email: "test@example.com",
            address: .init(
                street: "Street",
                suite: "Suite",
                city: "City",
                zipcode: "12345",
                geo: .init(latitude: 12.3456, longitude: -98.7654)
            ),
            phone: "123",
            website: "example.com",
            company: .init(name: "Co", catchPhrase: "Phrase", bs: "BS")
        )
        let viewModel = makeViewModel(user: user)

        #expect(viewModel.coordinateString == "12.3456, -98.7654")
    }

    @Test
    func mapsURLIsWellFormed() {
        let user = User(
            id: 1,
            name: "Test",
            username: "test",
            email: "test@example.com",
            address: .init(
                street: "Street",
                suite: "Suite",
                city: "City",
                zipcode: "12345",
                geo: .init(latitude: 37.7749, longitude: -122.4194)
            ),
            phone: "123",
            website: "example.com",
            company: .init(name: "Co", catchPhrase: "Phrase", bs: "BS")
        )
        let viewModel = makeViewModel(user: user)

        guard let url = viewModel.mapsURL else {
            Issue.record("mapsURL should not be nil")
            return
        }

        #expect(url.scheme == "https")
        #expect(url.host == "www.google.com")
        #expect(url.path == "/maps/search")

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []

        let apiItem = queryItems.first { $0.name == "api" }
        #expect(apiItem?.value == "1")

        let queryItem = queryItems.first { $0.name == "query" }
        #expect(queryItem?.value == "37.7749,-122.4194")
    }

    private func makeViewModel(
        user: User = .stub
    ) -> UserMapViewModel {
        UserMapViewModel(dependencies: .init(
            user: user
        ))
    }
}
