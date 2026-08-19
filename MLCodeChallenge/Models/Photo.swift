//
//  Photo.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//

import Foundation

nonisolated struct Photo: Decodable, Identifiable, Hashable {
    let id: Int
    let albumId: Int
    let title: String
    let url: String
    let thumbnailUrl: String

    /// The URLs provided by JSONPlaceholder point to via.placeholder.com,
    /// which is no longer active. Used picsum api to get images based on JSONPlaceholder photos ids for testing this code challenge.
    private enum ImageHost {
        static let base: URL = {
            guard let url = URL(string: "https://picsum.photos") else {
                preconditionFailure("Invalid image host literal")
            }
            return url
        }()
    }

    var thumbnailURL: URL {
        ImageHost.base.appending(path: "seed/photo-\(id)/150/150")
    }

    var bannerURL: URL {
        ImageHost.base.appending(path: "seed/photo-\(id)/400/400")
    }

    var fullSizeURL: URL {
        ImageHost.base.appending(path: "seed/photo-\(id)/1920/1080")
    }
}
