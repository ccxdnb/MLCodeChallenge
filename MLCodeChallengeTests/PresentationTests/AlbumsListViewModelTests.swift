import Testing
import Foundation
@testable import MLCodeChallenge

@MainActor
@Suite
struct AlbumsListViewModelTests {
    @Test
    func loadSuccess() async {
        let albums = [
            Album(id: 1, userId: 1, title: "Album 1"),
            Album(id: 2, userId: 1, title: "Album 2")
        ]
        let service = AlbumsServiceMock()
        service.result = .success(albums)

        let viewModel = makeViewModel(service: service, userID: 1)

        await viewModel.load()

        guard case .loaded(let loadedAlbums) = viewModel.state else {
            Issue.record("Expected .loaded state")
            return
        }

        #expect(loadedAlbums == albums)
        #expect(service.callCount == 1)
        #expect(service.lastUserID == 1)
    }

    @Test
    func loadEmpty() async {
        let service = AlbumsServiceMock()
        service.result = .success([])

        let viewModel = makeViewModel(service: service, userID: 1)

        await viewModel.load()

        guard case .empty = viewModel.state else {
            Issue.record("Expected .empty state")
            return
        }
    }

    @Test
    func loadFailure() async {
        let service = AlbumsServiceMock()
        service.result = .failure(APIError.invalidResponse)

        let viewModel = makeViewModel(service: service, userID: 1)

        await viewModel.load()

        guard case .failed(let message) = viewModel.state else {
            Issue.record("Expected .failed state")
            return
        }

        #expect(message == "Something went wrong. Please try again.")
    }

    @Test
    func loadCancelled_doesNotChangeState() async {
        let service = AlbumsServiceMock()
        service.result = .failure(APIError.cancelled)

        let viewModel = makeViewModel(service: service, userID: 1)

        await viewModel.load()

        guard case .loading = viewModel.state else {
            Issue.record("Expected state to remain .loading on cancellation")
            return
        }
    }

    @Test
    func refresh() async {
        let albums = [Album(id: 1, userId: 1, title: "Album 1")]
        let service = AlbumsServiceMock()
        service.result = .success(albums)

        let viewModel = makeViewModel(service: service, userID: 1)

        await viewModel.refresh()

        guard case .loaded(let loadedAlbums) = viewModel.state else {
            Issue.record("Expected .loaded state")
            return
        }

        #expect(loadedAlbums == albums)
    }

    @Test
    func didSelectNavigatesToPhotos() {
        let album = Album(id: 5, userId: 1, title: "Test")
        let coordinator = AppCoordinatorSpy()
        let viewModel = makeViewModel(coordinator: coordinator, userID: 1)

        viewModel.didSelect(album)

        #expect(coordinator.pushToCalls.count == 1)
        guard case .photos(let pushedAlbum) = coordinator.pushToCalls.first else {
            Issue.record("Expected .photos route")
            return
        }
        #expect(pushedAlbum == album)
    }

    @Test
    func fetchFirstPhotoSuccess() async {
        let album = Album(id: 10, userId: 1, title: "Album")
        let photo = Photo(id: 100, albumId: 10, title: "Photo", url: "thumbnailUrl", thumbnailUrl: "thumbnailUrl")
        let photosService = PhotosServiceMock()
        photosService.result = .success([photo])

        let viewModel = makeViewModel(photosService: photosService, userID: 1)

        await viewModel.fetchFirstPhoto(for: album)

        #expect(photosService.callCount == 1)
        #expect(photosService.lastAlbumID == 10)
        #expect(photosService.lastPage == 1)
        #expect(photosService.lastLimit == 1)
        #expect(viewModel.albumCovers[album.id] == photo)
    }

    @Test
    func fetchFirstPhotoEmptyResult() async {
        let album = Album(id: 10, userId: 1, title: "Album")
        let photosService = PhotosServiceMock()
        photosService.result = .success([])

        let viewModel = makeViewModel(photosService: photosService, userID: 1)

        await viewModel.fetchFirstPhoto(for: album)

        #expect(photosService.callCount == 1)
        #expect(viewModel.albumCovers[album.id] == nil)
    }

    @Test
    func fetchFirstPhotoFailure() async {
        let album = Album(id: 10, userId: 1, title: "Album")
        let photosService = PhotosServiceMock()
        photosService.result = .failure(APIError.invalidResponse)

        let viewModel = makeViewModel(photosService: photosService, userID: 1)

        await viewModel.fetchFirstPhoto(for: album)

        #expect(photosService.callCount == 1)
        #expect(viewModel.albumCovers[album.id] == nil)
    }

    @Test
    func fetchFirstPhotoCachesResult() async {
        let album = Album(id: 10, userId: 1, title: "Album")
        let photo = Photo(id: 100, albumId: 10, title: "Photo", url: "thumbnailUrl", thumbnailUrl: "thumbnailUrl")
        let photosService = PhotosServiceMock()
        photosService.result = .success([photo])

        let viewModel = makeViewModel(photosService: photosService, userID: 1)

        await viewModel.fetchFirstPhoto(for: album)
        await viewModel.fetchFirstPhoto(for: album)

        #expect(photosService.callCount == 1)
        #expect(viewModel.albumCovers[album.id] == photo)
    }

    private func makeViewModel(
        service: AlbumsServiceProtocol = AlbumsServiceMock(),
        photosService: PhotosServiceProtocol = PhotosServiceMock(),
        coordinator: AppCoordinatorProtocol = AppCoordinatorSpy(),
        userID: Int = 1
    ) -> AlbumsGridViewModel {
        AlbumsGridViewModel(dependencies: .init(
            albumsService: service,
            photosService: photosService,
            imageLoader: ImageLoader(cache: ImageCache()),
            coordinator: coordinator,
            userID: userID
        ))
    }
}
