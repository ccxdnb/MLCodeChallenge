import Foundation

protocol AlbumsServiceProtocol {
    func albums(userID: Int) async throws -> [Album]
}

final class AlbumsService: AlbumsServiceProtocol, Sendable {
    private let client: HTTPClientProtocol

    init(client: HTTPClientProtocol) {
        self.client = client
    }

    func albums(userID: Int) async throws -> [Album] {
        try await client.execute(UsersAPI.albums(userID: userID))
    }
}
