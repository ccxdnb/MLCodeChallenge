//
//  User.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/14/26.
//
import Foundation

nonisolated struct User: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let address: Address
    let phone: String
    let website: String
    let company: Company
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
}
