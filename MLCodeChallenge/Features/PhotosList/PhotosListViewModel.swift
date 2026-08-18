//
//  PhotosListViewModel.swift
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
    private var initialLoadTask: Task<Void, Never>?
    private var paginationTask: Task<Void, Never>?
    private let dependencies: Dependencies
    private let pageSize = 20

    var selectedPhoto: Photo?

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    deinit {
        initialLoadTask?.cancel()
        paginationTask?.cancel()
    }

    func loadInitial() async {
        initialLoadTask?.cancel()

        state = .loading

        initialLoadTask = Task {
            await fetchPage(1)
        }

        await initialLoadTask?.value
        initialLoadTask = nil
    }

    func refresh() async {
        initialLoadTask?.cancel()

        // If state is not .loaded, treat refresh like initial load
        if case .loaded = state {
            initialLoadTask = Task {
                await fetchPage(1)
            }
            await initialLoadTask?.value
            initialLoadTask = nil
        } else {
            await loadInitial()
        }
    }

    func loadNextPageIfNeeded() {
        // Ignore pagination requests while initial load is in flight
        guard initialLoadTask == nil else {
            return
        }
        
        guard case .loaded(var paginationState) = state,
              !paginationState.isLoadingMore,
              !paginationState.hasReachedEnd else {
            return
        }

        paginationTask?.cancel()
        
        // Set isLoadingMore synchronously BEFORE the Task suspension point
        // to prevent race condition from duplicate calls
        paginationState.isLoadingMore = true
        state = .loaded(paginationState)
        let nextPage = paginationState.currentPage + 1

        paginationTask = Task {
            await fetchPage(nextPage)
        }
    }

    private func fetchPage(_ page: Int) async {
        // Only reset state to empty if this is initial load (state is .loading)
        // For refresh (state is .loaded), keep existing photos visible
        if page == 1, case .loading = state {
            var newState = PaginationState()
            newState.currentPage = 1
            state = .loaded(newState)
        }
        // Note: For pagination (page > 1), isLoadingMore is already
        // set synchronously in loadNextPageIfNeeded() before this method runs

        do {
            let photos = try await dependencies.photosService.photos(
                albumID: dependencies.albumID,
                page: page,
                limit: pageSize
            )

            guard case .loaded(var paginationState) = state else { return }

            if page == 1 {
                // Reset to page 1: replace photos and reset pagination state
                paginationState.photos = photos
                paginationState.currentPage = 1
                paginationState.hasReachedEnd = photos.count < pageSize
            } else {
                // Append for pagination
                paginationState.photos.append(contentsOf: photos)
                paginationState.currentPage = page
                paginationState.hasReachedEnd = photos.count < pageSize
            }

            paginationState.isLoadingMore = false

            if page == 1 && photos.isEmpty {
                state = .empty
            } else {
                state = .loaded(paginationState)
            }
        } catch APIError.cancelled {
            return
        } catch let error as APIError {
            handleError(forPage: page, error: error)
        } catch {
            handleError(forPage: page, error: nil)
        }
    }

    private func handleError(forPage page: Int, error: APIError?) {
        if page == 1 {
            // Initial load or refresh failed - show error state
            let message = error?.errorDescription ?? "Unexpected error"
            state = .failed(message)
        } else {
            // Pagination failed - keep current data and clear loading state
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
