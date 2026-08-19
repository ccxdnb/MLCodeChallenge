//
//  AlbumCardItem.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/18/26.
//
import SwiftUI

struct AlbumCardItem: View {
    let album: Album
    let coverPhoto: Photo?
    let viewModel: AlbumsGridViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Background image
            if let photo = coverPhoto {
                CachedAsyncImage(
                    url: photo.thumbnailURL,
                    targetSize: CGSize(width: 250, height: 250),
                    imageLoader: viewModel.getImageLoader()
                ) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    placeholderView
                }
            } else {
                placeholderView
            }
        }
        .frame(height: 160)
        .overlay(alignment: .bottom) {
            // Glass container for text
            Text(album.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.regularMaterial)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        .accessibilityLabel("Album: \(album.title). Tap to view photos.")
        .accessibilityAddTraits(.isButton)
        .task {
            await viewModel.fetchFirstPhoto(for: album)
        }
    }

    @ViewBuilder
    private var placeholderView: some View {
        ZStack {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
