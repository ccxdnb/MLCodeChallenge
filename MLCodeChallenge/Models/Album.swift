//
//  Album.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//

import Foundation

nonisolated struct Album: Decodable, Identifiable, Hashable {
    let id: Int
    let userId: Int
    let title: String
}
