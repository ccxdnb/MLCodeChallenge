//
//  UserMapView.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//

import SwiftUI
import GoogleMaps
import CoreLocation

struct UserMapView: View {
    @Bindable var viewModel: UserMapViewModel
    @State private var recenterTrigger = false

    var body: some View {
        ZStack(alignment: .bottom) {
            GoogleMapView(
                coordinate: viewModel.coordinate,
                title: viewModel.user.name,
                snippet: viewModel.user.address.city,
                accessibilityLabel: "Map showing \(viewModel.user.name)'s location at \(viewModel.coordinateString)",
                recenterTrigger: recenterTrigger
            )
            .ignoresSafeArea()
            .navigationTitle(viewModel.user.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)

            VStack {
                recenterButton
                infoCard
            }
            .padding()
            .readableContentWidth()
        }
    }

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            locationSection
            actionsSection
        }
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: 16.0))
    }

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            LocationRow(
                icon: "mappin.circle.fill",
                label: "API Address",
                value: viewModel.fullAddress
            )

            LocationRow(
                icon: "location.fill",
                label: "Coordinates",
                value: viewModel.coordinateString
            )
        }
    }

    private var recenterButton: some View {
        HStack {
            Spacer()
            Button {
                recenterTrigger.toggle()
            } label: {
                Image(systemName: "mappin")
                    .font(.title)
                    .foregroundStyle(Color.red)
                    .frame(width: 44, height: 44)
                    .glassEffect(.clear, in: .circle)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var actionsSection: some View {
        HStack(spacing: 12) {
            if let mapsURL = viewModel.mapsURL {
                Button {
                    UIApplication.shared.open(mapsURL)
                } label: {
                    HStack {
                        Image(systemName: "map.fill")
                        Text("Open in Maps")
                            .font(.footnote.weight(.medium))
                    }
                    .foregroundStyle(.white)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.accentColor)
                    )
                }
            }

            ShareLink(
                item: viewModel.coordinateString,
                subject: Text("\(viewModel.user.name)'s location"),
                message: Text("Location: \(viewModel.coordinateString)")
            ) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                        .font(.footnote.weight(.medium))
                }
                .foregroundStyle(.primary)
                .padding(14)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.tertiarySystemGroupedBackground))
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        UserMapView(
            viewModel: .init(dependencies: .init(
                user: .stub
            ))
        )
    }
}
