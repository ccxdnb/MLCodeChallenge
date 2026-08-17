//
//  Address.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//
import Foundation

struct Address: Codable, Sendable {
    let street: String
    let suite: String
    let city: String
    let zipcode: String
    let geo: Geo
}
