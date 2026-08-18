//
//  GoogleMapView.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/18/26.
//
import SwiftUI
import GoogleMaps

struct GoogleMapView: UIViewRepresentable {
    let coordinate: CLLocationCoordinate2D
    let title: String
    let snippet: String?
    var zoom: MapZoom = .continent

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> GMSMapView {
        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition(target: coordinate, zoom: zoom.rawValue)

        let mapView = GMSMapView(options: options)
        mapView.isMyLocationEnabled = false
        mapView.settings.compassButton = true

        let marker = GMSMarker(position: coordinate)
        marker.title = title
        marker.snippet = snippet
        marker.map = mapView

        context.coordinator.marker = marker
        context.coordinator.lastCoordinate = coordinate

        mapView.selectedMarker = marker

        return mapView
    }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        guard context.coordinator.lastCoordinate?.latitude != coordinate.latitude,
        context.coordinator.lastCoordinate?.longitude != coordinate.longitude else { return }

        context.coordinator.marker?.position = coordinate
        context.coordinator.marker?.title = title
        context.coordinator.marker?.snippet = snippet
        context.coordinator.lastCoordinate = coordinate

        mapView.animate(to: GMSCameraPosition(target: coordinate, zoom: zoom.rawValue))
    }

    final class Coordinator {
        var marker: GMSMarker?
        var lastCoordinate: CLLocationCoordinate2D?
    }
}

import Foundation

/// Semantic zoom levels for `GoogleMapView`.
enum MapZoom: Float {
    /// Entire globe. Useful for conveying that a coordinate is far from
    /// anything recognizable.
    case world = 2

    /// Continental scale.
    case continent = 4

    /// Country outline.
    case country = 6

    /// Metropolitan area.
    case region = 9

    /// City with major streets.
    case city = 12

    /// Neighborhood — the default for pinpointing a single location.
    case neighborhood = 15

    /// Street level with building footprints.
    case street = 18
}
