//
//  UsersService.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//
import Foundation

protocol UsersServiceProtocol {
    func users() async throws -> [User]
    func deleteUser(userId: Int) async throws
}

final class UsersService: UsersServiceProtocol {
    private let client: HTTPClientProtocol

    init(client: HTTPClientProtocol) {
        self.client = client
    }

    func users() async throws -> [User] {
        try await client.execute(UsersAPI.users)
    }

    func deleteUser(userId: Int) async throws {
        try await client.execute(UsersAPI.deleteUser(userID: userId))
    }
}
