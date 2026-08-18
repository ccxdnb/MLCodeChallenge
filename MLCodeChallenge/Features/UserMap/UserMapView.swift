//
//  UserMapView.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//

import SwiftUI
import GoogleMaps

struct UserMapView: View {
    let user: User

    var body: some View {
        GoogleMapView(
            coordinate: CLLocationCoordinate2D(
                latitude: user.address.geo.latitude,
                longitude: user.address.geo.longitude
            ),
            title: user.name,
            snippet: user.address.city
        )
        .ignoresSafeArea()
    }
}

#Preview {
    UserMapView(user: .stub)
}
