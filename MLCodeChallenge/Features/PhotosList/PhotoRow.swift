//
//  PhotoRow.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/18/26.
//
import SwiftUI

struct PhotoRow: View {
    let photo: Photo
    let imageLoader: ImageLoader
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                CachedAsyncImage(
                    url: photo.bannerURL,
                    targetSize: CGSize(width: 533, height: 300),
                    imageLoader: imageLoader
                ) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                } placeholder: {
                    Rectangle()
                        .fill(Color.clear)
                        .overlay {
                            ProgressView()
                        }
                        .frame(height: 300)
                }
                .frame(height: 300)
                .clipped()
                .onTapGesture(perform: onTap)
            }
        }
        .id(photo.id)
    }
}
