//
//  User.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/14/26.
//

import Foundation

nonisolated struct User: Codable, Sendable, Equatable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let address: Address
    let phone: String
    let website: String
    let company: Company
}
