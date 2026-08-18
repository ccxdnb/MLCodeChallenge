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

    var id: String {
        switch self {
        case .map(let user): "map-\(user.id)"
        case .userDetail(let user): "detail-\(user.id)"
        }
    }
}
