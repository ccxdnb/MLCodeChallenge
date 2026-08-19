//
//  AlbumsGridViewModel.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/18/26.
//
import Foundation
import Observation

@Observable
final class AlbumsGridViewModel {
    struct Dependencies {
        let albumsService: AlbumsServiceProtocol
        let photosService: PhotosServiceProtocol
        let imageLoader: ImageLoader
        let coordinator: AppCoordinatorProtocol
        let userID: Int
    }

    private(set) var state: ViewState<[Album]> = .idle
    private(set) var albumCovers: [Int: Photo] = [:]

    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func load() async {
        state = .loading
        await fetch()
    }

    func refresh() async {
        await fetch()
    }

    func getImageLoader() -> ImageLoader {
        return self.dependencies.imageLoader
    }

    private func fetch() async {
        do {
            let albums = try await dependencies.albumsService.albums(userID: dependencies.userID)
            state = albums.isEmpty ? .empty : .loaded(albums)
        } catch APIError.cancelled {
            return
        } catch let error as APIError {
            state = .failed(error.errorDescription ?? "Unexpected error")
        } catch {
            state = .failed("Unexpected error")
        }
    }

    func fetchFirstPhoto(for album: Album) async {
        guard albumCovers[album.id] == nil else { return }

        do {
            let photos = try await dependencies.photosService.photos(albumID: album.id, page: 1, limit: 1)
            if let firstPhoto = photos.first {
                albumCovers[album.id] = firstPhoto
            }
        } catch {
            // Silently fail, card will show placeholder
        }
    }

    func didSelect(_ album: Album) {
        dependencies.coordinator.pushTo(.photos(album))
    }
}
