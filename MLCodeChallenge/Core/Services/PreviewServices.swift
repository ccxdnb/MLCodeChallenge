//
//  PreviewServices.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/18/26.
//

#if DEBUG
import Foundation

/// Lightweight preview stub for PhotosService that returns sample data without network calls
final class PreviewPhotosService: PhotosServiceProtocol {
    func photos(albumID: Int, page: Int, limit: Int) async throws -> [Photo] {
        // Return a small set of sample photos for preview purposes
        let startID = (page - 1) * limit + 1
        return (startID..<min(startID + limit, startID + 5)).map { id in
            Photo(
                id: id,
                albumId: albumID,
                title: "Sample Photo \(id)",
                url: "https://via.placeholder.com/600/\(id)",
                thumbnailUrl: "https://via.placeholder.com/150/\(id)"
            )
        }
    }
}

/// Lightweight preview stub for AlbumsService that returns sample data without network calls
final class PreviewAlbumsService: AlbumsServiceProtocol {
    func albums(userID: Int) async throws -> [Album] {
        // Return a small set of sample albums for preview purposes
        return (1...6).map { id in
            Album(
                id: id,
                userId: userID,
                title: "Sample Album \(id)"
            )
        }
    }
}

/// Lightweight preview stub for UsersService that returns sample data without network calls
final class PreviewUsersService: UsersServiceProtocol {
    func users() async throws -> [User] {
        // Return a small set of sample users for preview purposes
        return (1...3).map { id in
            User(
                id: id,
                name: "Sample User \(id)",
                username: "user\(id)",
                email: "user\(id)@example.com",
                address: Address(
                    street: "Sample Street",
                    suite: "Apt. \(id)",
                    city: "Sample City",
                    zipcode: "12345",
                    geo: Geo(latitude: 0.0, longitude: 0.0)
                ),
                phone: "555-1234",
                website: "example.com",
                company: Company(
                    name: "Sample Company",
                    catchPhrase: "Sample catchphrase",
                    bs: "Sample bs"
                )
            )
        }
    }

    func deleteUser(userId: Int) async throws {}
}
#endif
