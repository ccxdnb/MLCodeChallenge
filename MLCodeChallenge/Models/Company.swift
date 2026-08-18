//
//  Company.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//
import Foundation

nonisolated struct Company: Codable, Sendable, Equatable, Hashable {
    let name: String
    let catchPhrase: String
    let bs: String
}
