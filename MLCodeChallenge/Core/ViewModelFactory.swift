//
//  ViewModelFactory.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//

import Foundation

final class ViewModelFactory {
    private let usersService: UsersServiceProtocol
    private let albumsService: AlbumsServiceProtocol
    private let photosService: PhotosServiceProtocol
    private let imageLoader: ImageLoader
    private let coordinator: AppCoordinatorProtocol

    private var usersListViewModel: UsersListViewModel?
    private var albumsListViewModels: [Int: AlbumsGridViewModel] = [:]
    private var photosGridViewModels: [Int: PhotosListViewModel] = [:]
    private var userDetailViewModels: [Int: UserDetailViewModel] = [:]

    init(
        usersService: UsersServiceProtocol,
        albumsService: AlbumsServiceProtocol,
        photosService: PhotosServiceProtocol,
        imageLoader: ImageLoader,
        coordinator: AppCoordinatorProtocol
    ) {
        self.usersService = usersService
        self.albumsService = albumsService
        self.photosService = photosService
        self.imageLoader = imageLoader
        self.coordinator = coordinator
    }

    func makeUsersListViewModel() -> UsersListViewModel {
        if let existing = usersListViewModel {
            return existing
        }

        let viewModel = UsersListViewModel(
            dependencies: .init(usersService: usersService, coordinator: coordinator)
        )
        usersListViewModel = viewModel
        return viewModel
    }

    func makeAlbumsListViewModel(userID: Int) -> AlbumsGridViewModel {
        if let existing = albumsListViewModels[userID] {
            return existing
        }

        let viewModel = AlbumsGridViewModel(
            dependencies: .init(
                albumsService: albumsService,
                photosService: photosService,
                imageLoader: imageLoader,
                coordinator: coordinator,
                userID: userID
            )
        )
        albumsListViewModels[userID] = viewModel
        return viewModel
    }

    func makePhotosGridViewModel(album: Album) -> PhotosListViewModel {
        if let existing = photosGridViewModels[album.id] {
            return existing
        }

        let viewModel = PhotosListViewModel(
            dependencies: .init(
                photosService: photosService,
                imageLoader: imageLoader,
                albumID: album.id
            )
        )
        photosGridViewModels[album.id] = viewModel
        return viewModel
    }

    func makeUserDetailViewModel(user: User) -> UserDetailViewModel {
        if let existing = userDetailViewModels[user.id] {
            return existing
        }

        let viewModel = UserDetailViewModel(
            dependencies: .init(coordinator: coordinator, user: user)
        )
        userDetailViewModels[user.id] = viewModel
        return viewModel
    }
}
