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
                    url: photo.fullSizeURL,
                    targetSize: CGSize(width: 500, height: 500),
                    imageLoader: imageLoader
                ) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay {
                            ProgressView()
                        }
                        .frame(minHeight: 400)
                }
                .onTapGesture(perform: onTap)
            }
        }
    }
}
