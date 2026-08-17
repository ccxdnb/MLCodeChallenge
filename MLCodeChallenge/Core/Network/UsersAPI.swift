//
//  UsersAPI.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//
import Foundation

nonisolated enum UsersAPI: EndpointType {
    case users
    case albums(userID: Int)
    case photos(albumID: Int, page: Int, limit: Int)

    var baseUrl: URL? { AppConfiguration.apiBaseURL }
    var httpMethod: HTTPMethod { .get }
    var urlQueries: [String: String]? { nil }

    var path: String {
        switch self {
        case .users:
            "/users"
        case .albums:
            "/albums"
        case .photos:
            "/photos"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .users:
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
