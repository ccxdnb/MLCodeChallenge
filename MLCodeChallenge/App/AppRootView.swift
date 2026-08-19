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
    @State private var coordinator: AppCoordinator
    @State private var factory: ServiceFactory
    @State private var imageLoader: ImageLoader

    init(
        client: HTTPClientProtocol
    ) {
        _factory = .init(initialValue: .init(client: client))
        _coordinator = .init(initialValue: AppCoordinator())
        _imageLoader = .init(initialValue: .init(cache: ImageCache()))
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            UsersListView(dependencies: .init(
                usersService: self.factory.usersService,
                coordinator: self.coordinator)
            )
            .navigationDestination(for: Route.self) { route in
                self.destinationFor(route)
            }
        }

        .onReceive(NotificationCenter.default.publisher(
            for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
                logger.debug("Memory warning received via NotificationCenter!")
                Task {
                    await imageLoader.removeAll()
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
            UserMapView(dependencies: .init(user: user))

        case let .userDetail(user):
            UserDetailView(dependencies: .init(coordinator: coordinator, user: user))

        case .albums(let user):
            AlbumsGridView(dependencies: .init(
                albumsService: self.factory.albumsService,
                photosService: self.factory.photosService,
                imageLoader: self.imageLoader,
                coordinator: self.coordinator,
                userID: user.id))

        case .photos(let album):
            PhotosListView(dependencies: .init(
                photosService: self.factory.photosService,
                imageLoader: self.imageLoader,
                albumID: album.id)

            )
        }
    }
}

#Preview {
    let client = HTTPClient()
    return AppRootView(client: client)
}
