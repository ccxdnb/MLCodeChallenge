import Testing
import Foundation
@testable import MLCodeChallenge

@MainActor
@Suite
struct PhotosGridViewModelTests {
    @Test
    func loadInitialSuccess() async {
        let photos = makePhotos(count: 20)
        let service = PhotosServiceMock()
        service.result = .success(photos)

        let viewModel = makeViewModel(service: service, albumID: 1)

        await viewModel.loadInitial()

        guard case .loaded(let state) = viewModel.state else {
            Issue.record("Expected .loaded state")
            return
        }

        #expect(state.photos == photos)
        #expect(state.currentPage == 1)
        #expect(state.isLoadingMore == false)
        #expect(state.hasReachedEnd == false)
        #expect(service.callCount == 1)
        #expect(service.lastAlbumID == 1)
        #expect(service.lastPage == 1)
        #expect(service.lastLimit == 20)
    }

    @Test
    func loadInitialEmpty() async {
        let service = PhotosServiceMock()
        service.result = .success([])

        let viewModel = makeViewModel(service: service, albumID: 1)

        await viewModel.loadInitial()

        guard case .empty = viewModel.state else {
            Issue.record("Expected .empty state")
            return
        }
    }

    @Test
    func loadInitialFailure() async {
        let service = PhotosServiceMock()
        service.result = .failure(APIError.invalidResponse)

        let viewModel = makeViewModel(service: service, albumID: 1)

        await viewModel.loadInitial()

        guard case .failed(let message) = viewModel.state else {
            Issue.record("Expected .failed state")
            return
        }

        #expect(message == "Something went wrong. Please try again.")
    }

    @Test
    func loadInitialCancelled_doesNotChangeState() async {
        let service = PhotosServiceMock()
        service.result = .failure(APIError.cancelled)

        let viewModel = makeViewModel(service: service, albumID: 1)

        await viewModel.loadInitial()

        guard case .loaded(let state) = viewModel.state else {
            Issue.record("Expected .loaded state after cancellation")
            return
        }

        #expect(state.photos.isEmpty)
    }

    @Test
    func loadNextPageAppendsPhotos() async {
        let firstPage = makePhotos(count: 20, startID: 1)
        let secondPage = makePhotos(count: 20, startID: 21)

        let service = PhotosServiceMock()
        service.result = .success(firstPage)

        let viewModel = makeViewModel(service: service, albumID: 1)
        await viewModel.loadInitial()

        service.result = .success(secondPage)
        viewModel.loadNextPageIfNeeded()

        try? await Task.sleep(for: .milliseconds(100))

        guard case .loaded(let state) = viewModel.state else {
            Issue.record("Expected .loaded state")
            return
        }

        #expect(state.photos.count == 40)
        #expect(state.photos == firstPage + secondPage)
        #expect(state.currentPage == 2)
        #expect(service.callCount == 2)
        #expect(service.lastPage == 2)
    }

    @Test
    func hasReachedEndWhenPageIncomplete() async {
        let partialPage = makePhotos(count: 15)
        let service = PhotosServiceMock()
        service.result = .success(partialPage)

        let viewModel = makeViewModel(service: service, albumID: 1)

        await viewModel.loadInitial()

        guard case .loaded(let state) = viewModel.state else {
            Issue.record("Expected .loaded state")
            return
        }

        #expect(state.hasReachedEnd == true)
    }

    @Test
    func doesNotLoadNextPageWhenReachedEnd() async {
        let photos = makePhotos(count: 15)
        let service = PhotosServiceMock()
        service.result = .success(photos)

        let viewModel = makeViewModel(service: service, albumID: 1)
        await viewModel.loadInitial()

        guard case .loaded(let state) = viewModel.state else {
            Issue.record("Expected .loaded state")
            return
        }

        #expect(state.hasReachedEnd == true)

        viewModel.loadNextPageIfNeeded()

        try? await Task.sleep(for: .milliseconds(50))

        #expect(service.callCount == 1)
    }

    @Test
    func refresh() async {
        let firstLoad = makePhotos(count: 20, startID: 1)
        let refreshedPhotos = makePhotos(count: 20, startID: 100)

        let service = PhotosServiceMock()
        service.result = .success(firstLoad)

        let viewModel = makeViewModel(service: service, albumID: 1)
        await viewModel.loadInitial()

        service.result = .success(refreshedPhotos)
        await viewModel.refresh()

        guard case .loaded(let state) = viewModel.state else {
            Issue.record("Expected .loaded state")
            return
        }

        #expect(state.photos == refreshedPhotos)
        #expect(state.currentPage == 1)
        #expect(service.callCount == 2)
    }

    @Test
    func loadNextPageFailure_keepsExistingPhotos() async {
        let firstPage = makePhotos(count: 20)
        let service = PhotosServiceMock()
        service.result = .success(firstPage)

        let viewModel = makeViewModel(service: service, albumID: 1)
        await viewModel.loadInitial()

        service.result = .failure(APIError.timeout)
        viewModel.loadNextPageIfNeeded()

        try? await Task.sleep(for: .milliseconds(100))

        guard case .loaded(let state) = viewModel.state else {
            Issue.record("Expected .loaded state")
            return
        }

        #expect(state.photos == firstPage)
        #expect(state.currentPage == 1)
        #expect(state.isLoadingMore == false)
    }

    private func makeViewModel(
        service: PhotosServiceProtocol = PhotosServiceMock(),
        albumID: Int = 1
    ) -> PhotosListViewModel {
        PhotosListViewModel(dependencies: .init(
            photosService: service,
            imageLoader: ImageLoader(cache: ImageCache()),
            albumID: albumID
        ))
    }

    private func makePhotos(count: Int, startID: Int = 1) -> [Photo] {
        (startID..<(startID + count)).map { id in
            Photo(
                id: id,
                albumId: 1,
                title: "Photo \(id)",
                url: "https://via.placeholder.com/600/\(id)",
                thumbnailUrl: "https://via.placeholder.com/150/\(id)"
            )
        }
    }
}
