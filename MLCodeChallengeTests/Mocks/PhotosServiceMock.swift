import Foundation
@testable import MLCodeChallenge

final class PhotosServiceMock: PhotosServiceProtocol {
    var result: Result<[Photo], Error> = .success([])
    private(set) var callCount = 0
    private(set) var lastAlbumID: Int?
    private(set) var lastPage: Int?
    private(set) var lastLimit: Int?

    func photos(albumID: Int, page: Int, limit: Int) async throws -> [Photo] {
        callCount += 1
        lastAlbumID = albumID
        lastPage = page
        lastLimit = limit
        return try result.get()
    }
}
