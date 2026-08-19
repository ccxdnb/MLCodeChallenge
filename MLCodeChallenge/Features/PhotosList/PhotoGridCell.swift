//
//  PhotoGridCell.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/18/26.
//
import SwiftUI

struct PhotoGridCell: View {
    let photo: Photo
    let imageLoader: ImageLoader
    let onTap: () -> Void

    var body: some View {
        CachedAsyncImage(
            url: photo.bannerURL,
            targetSize: CGSize(width: 400, height: 400),
            imageLoader: imageLoader
        ) { image in
            image
                .resizable()
                .aspectRatio(1.0, contentMode: .fill)
        } placeholder: {
            Rectangle()
                .fill(Color(.systemGray5))
                .overlay {
                    ProgressView()
                }
        }
        .aspectRatio(1.0, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onTapGesture(perform: onTap)
        .id(photo.id)
    }
}
