//
//  UserMapViewModel.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/19/26.
//

import Foundation
import Observation
import CoreLocation

@Observable
final class UserMapViewModel {
    struct Dependencies {
        let user: User
    }

    let user: User
    private let dependencies: Dependencies

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: user.address.geo.latitude,
            longitude: user.address.geo.longitude
        )
    }

    var fullAddress: String {
        "\(user.address.street), \(user.address.suite)\n\(user.address.city), \(user.address.zipcode)"
    }

    var coordinateString: String {
        String(format: "%.4f, %.4f", coordinate.latitude, coordinate.longitude)
    }

    var mapsURL: URL? {
        var components = URLComponents(string: "https://www.google.com/maps/search/")
        components?.queryItems = [
            URLQueryItem(name: "api", value: "1"),
            URLQueryItem(name: "query", value: "\(coordinate.latitude),\(coordinate.longitude)")
        ]
        return components?.url
    }

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        self.user = dependencies.user
    }

}
