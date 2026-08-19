//
//  PhotoTests.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//

import Testing
import Foundation
@testable import MLCodeChallenge

@Suite
struct PhotoTests {
    @Test
    func decodePhoto() throws {
        let json = """
        {
            "id": 1,
            "albumId": 1,
            "title": "accusamus beatae ad facilis cum similique qui sunt",
            "url": "https://via.placeholder.com/600/92c952",
            "thumbnailUrl": "https://via.placeholder.com/150/92c952"
        }
        """

        let data = try #require(json.data(using: .utf8))
        let photo = try JSONDecoder().decode(Photo.self, from: data)

        #expect(photo.id == 1)
        #expect(photo.albumId == 1)
        #expect(photo.title == "accusamus beatae ad facilis cum similique qui sunt")
        #expect(photo.url == "https://via.placeholder.com/600/92c952")
        #expect(photo.thumbnailUrl == "https://via.placeholder.com/150/92c952")
    }

    @Test
    func thumbnailURLUsesPicsumPhotos() {
        let photo = Photo(
            id: 42,
            albumId: 1,
            title: "Test",
            url: "https://via.placeholder.com/600/92c952",
            thumbnailUrl: "https://via.placeholder.com/150/92c952"
        )

        let expectedURL = URL(string: "https://picsum.photos/seed/photo-42/150/150")!
        #expect(photo.thumbnailURL == expectedURL)
    }

    @Test
    func fullSizeURLUsesPicsumPhotos() {
        let photo = Photo(
            id: 99,
            albumId: 1,
            title: "Test",
            url: "https://via.placeholder.com/600/92c952",
            thumbnailUrl: "https://via.placeholder.com/150/92c952"
        )

        let expectedURL = URL(string: "https://picsum.photos/seed/photo-99/1920/1080")!
        #expect(photo.fullSizeURL == expectedURL)
    }

    @Test
    func photoConformsToIdentifiable() {
        let photo = Photo(
            id: 5,
            albumId: 1,
            title: "Test",
            url: "url",
            thumbnailUrl: "thumb"
        )
        #expect(photo.id == 5)
    }

    @Test
    func photoConformsToHashable() {
        let photo1 = Photo(id: 1, albumId: 1, title: "A", url: "u", thumbnailUrl: "t")
        let photo2 = Photo(id: 1, albumId: 1, title: "A", url: "u", thumbnailUrl: "t")
        let photo3 = Photo(id: 2, albumId: 1, title: "B", url: "u2", thumbnailUrl: "t2")

        #expect(photo1 == photo2)
        #expect(photo1 != photo3)
    }
}
