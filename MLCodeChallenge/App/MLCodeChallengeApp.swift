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
    private let client: HTTPClientProtocol

    /// Perform one-time app initialization here
    init() {
        self.client = HTTPClient()
        GMSServices.provideAPIKey(AppConfiguration.googleMapsAPIKey)
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(client: client)
        }
    }
}
