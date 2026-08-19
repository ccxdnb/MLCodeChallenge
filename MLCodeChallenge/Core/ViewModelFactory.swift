//
//  ViewModelFactory.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//

import Foundation
import OSLog

private let logger = Logger(subsystem: "com.jwilson.MLCodeChallenge", category: "ViewModelFactory")

@MainActor
final class ViewModelFactory {
    private let usersService: UsersServiceProtocol
    private let albumsService: AlbumsServiceProtocol
    private let photosService: PhotosServiceProtocol
    private let imageLoader: ImageLoader
    private let coordinator: AppCoordinatorProtocol

    /// The root view model lives outside the route cache
    private var usersListViewModel: UsersListViewModel?
    private var routeViewModels: [Route.ID: AnyObject] = [:]

        init(
            usersService: UsersServiceProtocol,
            albumsService: AlbumsServiceProtocol,
            photosService: PhotosServiceProtocol,
            imageLoader: ImageLoader,
            coordinator: AppCoordinatorProtocol,
        ) {
            self.usersService = usersService
            self.albumsService = albumsService
            self.photosService = photosService
            self.imageLoader = imageLoader
            self.coordinator = coordinator
            logger.debug("ViewModelFactory initialized")
        }

    func makeUsersListViewModel() -> UsersListViewModel {
        if let existing = usersListViewModel {
            logger.debug("Returning cached UsersListViewModel")
            return existing
        }
        logger.debug("Creating new UsersListViewModel")
        let viewModel = UsersListViewModel(
            dependencies: .init(usersService: usersService, coordinator: coordinator)
        )
        usersListViewModel = viewModel
        return viewModel
    }

    func makeAlbumsListViewModel(user: User) -> AlbumsGridViewModel {
        logger.debug("makeAlbumsListViewModel called for user: \(user.id)")
        return cached(for: .albums(user)) {
            logger.debug("Creating new AlbumsGridViewModel for user: \(user.id)")
            return AlbumsGridViewModel(dependencies: .init(
                albumsService: albumsService,
                photosService: photosService,
                imageLoader: imageLoader,
                coordinator: coordinator,
                userID: user.id
            ))
        }
    }

    func makePhotosListViewModel(album: Album) -> PhotosListViewModel {
        logger.debug("makePhotosListViewModel called for album: \(album.id)")
        return cached(for: .photos(album)) {
            logger.debug("Creating new PhotosListViewModel for album: \(album.id)")
            return PhotosListViewModel(dependencies: .init(
                photosService: photosService,
                imageLoader: imageLoader,
                albumID: album.id
            ))
        }
    }

    func makeUserDetailViewModel(user: User) -> UserDetailViewModel {
        logger.debug("makeUserDetailViewModel called for user: \(user.id)")
        return cached(for: .userDetail(user)) {
            logger.debug("Creating new UserDetailViewModel for user: \(user.id)")
            return UserDetailViewModel(dependencies: .init(coordinator: coordinator, user: user))
        }
    }

    func makeUserMapViewModel(user: User) -> UserMapViewModel {
        logger.debug("makeUserMapViewModel called for user: \(user.id)")
        return cached(for: .map(user)) {
            logger.debug("Creating new UserMapViewModel for user: \(user.id)")
            return UserMapViewModel(dependencies: .init(user: user))
        }
    }

    /// Discards the view models whose route is no longer on the navigation stack
    func prune(keeping path: [Route]) {
        let live = Set(path.map(\.id))
        let beforeCount = routeViewModels.count
        routeViewModels = routeViewModels.filter { live.contains($0.key) }
        let afterCount = routeViewModels.count
        let pruned = beforeCount - afterCount

        if pruned > 0 {
            logger.debug("Pruned \(pruned) view models. Cache size: \(beforeCount) -> \(afterCount)")
        }
    }

    private func cached<ViewModel: AnyObject>(
        for route: Route,
        make: () -> ViewModel
    ) -> ViewModel {
        if let existing = routeViewModels[route.id] as? ViewModel {
            logger.debug("Returning cached view model for route: \(route.id)")
            return existing
        }

        logger.debug("Cache miss for route: \(route.id), creating new view model")
        let viewModel = make()
        routeViewModels[route.id] = viewModel
        logger.debug("Cached view model for route: \(route.id). Total cached: \(self.routeViewModels.count)")
        return viewModel
    }
}
