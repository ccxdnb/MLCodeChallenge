//
//  AppRootView.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//

import SwiftUI

import OSLog
private nonisolated let logger = Logger(subsystem: "com.jwilson.MLCodeChallenge", category: "AppRootView")

struct AppRootView: View {
    @State private var coordinator = AppCoordinator()
    @State private var factory: ViewModelFactory
    @State private var showClearCacheConfirmation = false
    private let imageLoader: ImageLoader

    init(
        usersService: UsersServiceProtocol,
        albumsService: AlbumsServiceProtocol,
        photosService: PhotosServiceProtocol,
        imageLoader: ImageLoader
    ) {
        let coordinator = AppCoordinator()
        _coordinator = State(initialValue: coordinator)
        _factory = State(initialValue: ViewModelFactory(
            usersService: usersService,
            albumsService: albumsService,
            photosService: photosService,
            imageLoader: imageLoader,
            coordinator: coordinator
        ))
        self.imageLoader = imageLoader
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            UsersListView(viewModel: factory.makeUsersListViewModel())
                .navigationDestination(for: Route.self) { route in
                    self.destinationFor(route)
                }
        }
        .onShake {
            showClearCacheConfirmation = true
        }
        .alert("Clear Image Cache", isPresented: $showClearCacheConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                Task {
                    await imageLoader.flush()
                }
            }
        } message: {
            Text("Are you sure you want to clear the image cache? This will remove all cached images.")
        }
        .onReceive(NotificationCenter.default.publisher(
            for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
                logger.debug("Memory warning received via NotificationCenter!")
                Task {
                    await imageLoader.flush()
                }
                URLCache.shared.removeAllCachedResponses()
        }
    }
}

extension AppRootView {
    @ViewBuilder
    func destinationFor(_ route: Route) -> some View {
        switch route {
        case .map(let user):
            UserMapView(user: user)

        case let .userDetail(user):
            UserDetailView(viewModel: factory.makeUserDetailViewModel(user: user))

        case .albums(let user):
            AlbumsGridView(viewModel: factory.makeAlbumsListViewModel(userID: user.id))

        case .photos(let album):
            PhotosListView(
                viewModel: factory.makePhotosGridViewModel(album: album),
                imageLoader: imageLoader
            )
        }
    }
}

#Preview {
    let client = HTTPClient()
    return AppRootView(
        usersService: UsersService(client: client),
        albumsService: AlbumsService(client: client),
        photosService: PhotosService(client: client),
        imageLoader: ImageLoader(cache: ImageCache())
    )
}
