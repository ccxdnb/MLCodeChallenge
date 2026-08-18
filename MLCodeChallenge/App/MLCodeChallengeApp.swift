//
//  MLCodeChallengeApp.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/14/26.
//

import SwiftUI
import GoogleMaps

@main
struct MLCodeChallengeApp: App {
    private let usersService: UsersService
    private let albumsService: AlbumsService
    private let photosService: PhotosService
    private let imageLoader: ImageLoader

    /// Perform one-time app initialization here
    init() {
        let client = HTTPClient()
        self.usersService = UsersService(client: client)
        self.albumsService = AlbumsService(client: client)
        self.photosService = PhotosService(client: client)
        self.imageLoader = ImageLoader(cache: ImageCache())

        GMSServices.provideAPIKey(AppConfiguration.googleMapsAPIKey)
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(
                usersService: usersService,
                albumsService: albumsService,
                photosService: photosService,
                imageLoader: imageLoader
            )
        }
    }
}
