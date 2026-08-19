//
//  AlbumsServiceMock.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//

import Foundation
@testable import MLCodeChallenge

final class AlbumsServiceMock: AlbumsServiceProtocol {
    var result: Result<[Album], Error> = .success([])
    private(set) var callCount = 0
    private(set) var lastUserID: Int?

    func albums(userID: Int) async throws -> [Album] {
        callCount += 1
        lastUserID = userID
        return try result.get()
    }
}
