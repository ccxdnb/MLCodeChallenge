import Testing
import Foundation
@testable import MLCodeChallenge

@MainActor
@Suite
struct PhotosListViewModelTests {
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
    func paginationDoesNotCancelInitialLoad() async {
        // Create a slow mock that delays the initial load
        let initialPhotos = makePhotos(count: 20, startID: 1)
        let slowService = SlowPhotosServiceMock(
            result: .success(initialPhotos),
            delay: .milliseconds(200)
        )

        let viewModel = makeViewModel(service: slowService, albumID: 1)

        // Start initial load (it will take 200ms)
        async let initialLoad: Void = viewModel.loadInitial()

        // Wait a bit, then trigger pagination while initial load is in flight
        try? await Task.sleep(for: .milliseconds(50))
        viewModel.loadNextPageIfNeeded()

        // Wait for initial load to complete
        await initialLoad

        // Verify initial load completed successfully with its photos
        guard case .loaded(let state) = viewModel.state else {
            Issue.record("Expected .loaded state after initial load")
            return
        }

        #expect(state.photos == initialPhotos)
        #expect(state.currentPage == 1)
        #expect(slowService.callCount == 1)
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

    @Test
    func rapidPaginationCalls_preventRaceCondition() async {
        // This test verifies that calling loadNextPageIfNeeded() twice in
        // immediate succession does not trigger duplicate page loads.
        // The guard should be effective before any suspension point.

        let firstPage = makePhotos(count: 20, startID: 1)
        let secondPage = makePhotos(count: 20, startID: 21)

        // Use a slow mock to simulate network delay and create a race window
        let slowService = SlowPhotosServiceMock(
            result: .success(firstPage),
            delay: .milliseconds(100)
        )

        let viewModel = makeViewModel(service: slowService, albumID: 1)
        await viewModel.loadInitial()

        // Setup for second page load
        slowService.result = .success(secondPage)

        // Call loadNextPageIfNeeded() twice in immediate succession
        // Without proper synchronous guard, both calls would pass the check
        viewModel.loadNextPageIfNeeded()
        viewModel.loadNextPageIfNeeded()

        // Wait for the async operations to complete
        try? await Task.sleep(for: .milliseconds(200))

        // The service should have been called exactly twice total:
        // once for initial load, once for pagination (not twice for pagination)
        #expect(slowService.callCount == 2)

        guard case .loaded(let state) = viewModel.state else {
            Issue.record("Expected .loaded state")
            return
        }

        // Should have exactly 40 photos (20 from initial + 20 from one page load)
        #expect(state.photos.count == 40)
        #expect(state.currentPage == 2)
    }

    @Test
    func refreshKeepsPhotosVisibleWhileRequestInFlight() async {
        // This test verifies that refresh keeps the current photos visible
        // until the new page arrives, preventing the list from going empty

        let originalPhotos = makePhotos(count: 20, startID: 1)
        let refreshedPhotos = makePhotos(count: 20, startID: 100)

        // Use a slow mock to simulate network delay during refresh
        let slowService = SlowPhotosServiceMock(
            result: .success(originalPhotos),
            delay: .milliseconds(100)
        )

        let viewModel = makeViewModel(service: slowService, albumID: 1)
        await viewModel.loadInitial()

        // Verify initial state
        guard case .loaded(let initialState) = viewModel.state else {
            Issue.record("Expected .loaded state after initial load")
            return
        }
        #expect(initialState.photos == originalPhotos)

        // Setup for refresh with a delay
        slowService.result = .success(refreshedPhotos)

        // Start refresh without awaiting
        async let refreshTask: Void = viewModel.refresh()

        // Wait a bit to ensure the request is in flight
        try? await Task.sleep(for: .milliseconds(50))

        // While refresh is in flight, verify original photos are still visible
        guard case .loaded(let duringRefreshState) = viewModel.state else {
            Issue.record("Expected .loaded state during refresh")
            return
        }
        #expect(duringRefreshState.photos == originalPhotos, "Photos should remain visible during refresh")

        // Wait for refresh to complete
        await refreshTask

        // Verify refresh completed with new photos
        guard case .loaded(let finalState) = viewModel.state else {
            Issue.record("Expected .loaded state after refresh")
            return
        }
        #expect(finalState.photos == refreshedPhotos)
        #expect(finalState.currentPage == 1)
        #expect(finalState.hasReachedEnd == false)
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
// Mock service that introduces a delay to simulate slow network
final class SlowPhotosServiceMock: PhotosServiceProtocol {
    var result: Result<[Photo], Error>
    let delay: Duration
    private(set) var callCount = 0

    init(result: Result<[Photo], Error>, delay: Duration) {
        self.result = result
        self.delay = delay
    }

    func photos(albumID: Int, page: Int, limit: Int) async throws -> [Photo] {
        callCount += 1
        try? await Task.sleep(for: delay)
        return try result.get()
    }
}
