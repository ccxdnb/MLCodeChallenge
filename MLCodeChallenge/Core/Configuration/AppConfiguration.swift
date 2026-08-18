//
//  AppConfiguration.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/18/26.
//
import Foundation

nonisolated enum AppConfiguration {
    static let apiBaseURL: URL = {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com") else {
            preconditionFailure("Invalid base URL literal")
        }
        return url
    }()

    /// Google Maps SDK API key.
    ///
    /// This key is intentionally committed to the repository. Client-side API keys
    /// ship inside the app binary regardless of how they are stored, so obscuring
    /// them provides no real protection — anyone can extract them from an IPA.
    /// The effective safeguard is the restriction configured in Google Cloud
    /// Console: this key is limited to the `JWilson.MLCodeChallenge` bundle
    /// identifier and to the Maps SDK for iOS, making it unusable elsewhere.
    ///
    /// In production — with multiple environments and rotation requirements — this
    /// value would be injected through an `.xcconfig` file kept out of version
    /// control, and exposed via the Info.plist at build time.
    static let googleMapsAPIKey = "AIzaSyCOWr-QOaIzQoui7Yx-J2lu5QzSnj9ZaD0"
}
