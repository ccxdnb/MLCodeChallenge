//
//  MLCodeChallengeApp.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/14/26.
//

import SwiftUI

@main
struct MLCodeChallengeApp: App {
    private let usersService = UsersService(client: HTTPClient())

    var body: some Scene {
        WindowGroup {
            AppRootView(usersService: usersService)
        }
    }
}
