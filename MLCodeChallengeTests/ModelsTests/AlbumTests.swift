//
//  AlbumTests.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//

import Testing
import Foundation
@testable import MLCodeChallenge

@Suite
struct AlbumTests {
    @Test
    func decodeAlbum() throws {
        let json = """
        {
            "id": 1,
            "userId": 10,
            "title": "quidem molestiae enim"
        }
        """

        let data = try #require(json.data(using: .utf8))
        let album = try JSONDecoder().decode(Album.self, from: data)

        #expect(album.id == 1)
        #expect(album.userId == 10)
        #expect(album.title == "quidem molestiae enim")
    }

    @Test
    func albumConformsToIdentifiable() {
        let album = Album(id: 5, userId: 1, title: "Test")
        #expect(album.id == 5)
    }

    @Test
    func albumConformsToHashable() {
        let album1 = Album(id: 1, userId: 1, title: "Test")
        let album2 = Album(id: 1, userId: 1, title: "Test")
        let album3 = Album(id: 2, userId: 1, title: "Different")

        #expect(album1 == album2)
        #expect(album1 != album3)
    }
}
