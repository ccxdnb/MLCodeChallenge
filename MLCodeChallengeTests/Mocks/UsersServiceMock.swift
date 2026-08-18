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
    private(set) var callCount = 0

    func users() async throws -> [User] {
        callCount += 1
        return try result.get()
    }
}
