//
//  UsersServiceMock.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//
import Foundation
@testable import MLCodeChallenge

final class UsersServiceMock: UsersServiceProtocol {
    var result: Result<[User], Error> = .success([])
    var deleteResult: Result<Void, Error> = .success(())
    private(set) var callCount = 0
    private(set) var deleteCallCount = 0
    private(set) var lastDeletedUserID: Int?

    func users() async throws -> [User] {
        callCount += 1
        return try result.get()
    }

    func deleteUser(userID: Int) async throws {
        deleteCallCount += 1
        lastDeletedUserID = userID
        try deleteResult.get()
    }
}
