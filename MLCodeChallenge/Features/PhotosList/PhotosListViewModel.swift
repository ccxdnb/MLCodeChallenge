//
//  FullscreenPhotoView.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/18/26.
//

import Foundation
import Observation

@Observable
final class PhotosListViewModel {
    struct Dependencies {
        let photosService: PhotosServiceProtocol
        let imageLoader: ImageLoader
        let albumID: Int
    }

    struct PaginationState {
        var photos: [Photo] = []
        var currentPage: Int = 1
        var isLoadingMore: Bool = false
        var hasReachedEnd: Bool = false
    }

    private(set) var state: ViewState<PaginationState> = .idle
    private var loadTask: Task<Void, Never>?
    let dependencies: Dependencies
    private let pageSize = 20

    var selectedPhoto: Photo?

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    deinit {
        loadTask?.cancel()
    }

    func loadInitial() async {
        loadTask?.cancel()

        state = .loading

        loadTask = Task {
            await fetchPage(1, isInitial: true)
        }

        await loadTask?.value
    }

    func refresh() async {
        loadTask?.cancel()

        loadTask = Task {
            await fetchPage(1, isInitial: true)
        }

        await loadTask?.value
    }

    func loadNextPageIfNeeded() {
        guard case .loaded(let paginationState) = state,
              !paginationState.isLoadingMore,
              !paginationState.hasReachedEnd else {
            return
        }

        loadTask?.cancel()

        loadTask = Task {
            await fetchPage(paginationState.currentPage + 1, isInitial: false)
        }
    }

    private func fetchPage(_ page: Int, isInitial: Bool) async {
        if isInitial {
            var newState = PaginationState()
            newState.currentPage = 1
            state = .loaded(newState)
        } else {
            guard case .loaded(var paginationState) = state else { return }
            paginationState.isLoadingMore = true
            state = .loaded(paginationState)
        }

        do {
            let photos = try await dependencies.photosService.photos(
                albumID: dependencies.albumID,
                page: page,
                limit: pageSize
            )

            guard case .loaded(var paginationState) = state else { return }

            if isInitial {
                paginationState.photos = photos
                paginationState.currentPage = 1
            } else {
                paginationState.photos.append(contentsOf: photos)
                paginationState.currentPage = page
            }

            paginationState.isLoadingMore = false
            paginationState.hasReachedEnd = photos.count < pageSize

            if isInitial && photos.isEmpty {
                state = .empty
            } else {
                state = .loaded(paginationState)
            }
        } catch APIError.cancelled {
            return
        } catch let error as APIError {
            handle(isInitial, error: error)
        } catch {
            if isInitial {
                state = .failed("Unexpected error")
            } else {
                guard case .loaded(var paginationState) = state else { return }
                paginationState.isLoadingMore = false
                state = .loaded(paginationState)
            }
        }
    }

    func handle(_ isInitial: Bool, error: APIError) {
        if isInitial {
            state = .failed(error.errorDescription ?? "Unexpected error")
        } else {
            guard case .loaded(var paginationState) = state else { return }
            paginationState.isLoadingMore = false
            state = .loaded(paginationState)
        }
    }

    func didSelectPhoto(_ photo: Photo) {
        selectedPhoto = photo
    }

    func dismissPhoto() {
        selectedPhoto = nil
    }
}
