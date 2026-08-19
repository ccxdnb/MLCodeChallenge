//
//  ServiceFactory.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//
import Foundation

@MainActor
final class ServiceFactory {
    let usersService: UsersServiceProtocol
    let albumsService: AlbumsServiceProtocol
    let photosService: PhotosServiceProtocol

    init(
        client: HTTPClientProtocol,
    ) {
        self.usersService = UsersService(client: client)
        self.albumsService = AlbumsService(client: client)
        self.photosService = PhotosService(client: client)
    }
}
