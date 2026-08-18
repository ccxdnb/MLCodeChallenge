//
//  UsersAPI.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//
import Foundation

nonisolated enum UsersAPI: EndpointType {
    case users
    case deleteUser(userID: Int)
    case albums(userID: Int)
    case photos(albumID: Int, page: Int, limit: Int)

    var httpMethod: HTTPMethod {
        switch self {
        case .users, .albums, .photos:
                .get
        case .deleteUser:
                .delete
        }
    }

    var path: String {
        switch self {
        case .users:
            "/users"
        case .albums:
            "/albums"
        case .photos:
            "/photos"
        case let .deleteUser(userId):
            "/users/\(userId)"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .users, .deleteUser:
            nil
        case .albums(let userID):
            [URLQueryItem(name: "userId", value: String(userID))]
        case .photos(let albumID, let page, let limit):
            [
                URLQueryItem(name: "albumId", value: String(albumID)),
                URLQueryItem(name: "_page", value: String(page)),
                URLQueryItem(name: "_limit", value: String(limit))
            ]
        }
    }
}
