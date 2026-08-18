import Foundation

protocol PhotosServiceProtocol {
    func photos(albumID: Int, page: Int, limit: Int) async throws -> [Photo]
}

final class PhotosService: PhotosServiceProtocol, Sendable {
    private let client: HTTPClientProtocol

    init(client: HTTPClientProtocol) {
        self.client = client
    }

    func photos(albumID: Int, page: Int, limit: Int) async throws -> [Photo] {
        try await client.execute(UsersAPI.photos(albumID: albumID, page: page, limit: limit))
    }
}
