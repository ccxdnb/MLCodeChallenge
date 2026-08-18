//
//  Route.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//
import Foundation

enum Route: Hashable, Identifiable {
    case map(User)
    case userDetail(User)
    case albums(User)
    case photos(Album)

    var id: String {
        switch self {
        case .map(let user): "map-\(user.id)"
        case .userDetail(let user): "detail-\(user.id)"
        case .albums(let user): "albums-\(user.id)"
        case .photos(let album): "photos-\(album.id)"
        }
    }
}
