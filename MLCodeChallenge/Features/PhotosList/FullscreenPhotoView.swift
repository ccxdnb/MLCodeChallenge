//
//  FullscreenPhotoView.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/18/26.
//
import SwiftUI

struct FullscreenPhotoView: View {
    let photo: Photo
    let imageLoader: ImageLoader
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            CachedAsyncImage(
                url: photo.fullSizeURL,
                targetSize: CGSize(width: 1920, height: 1080),
                imageLoader: imageLoader
            ) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(magnificationGesture.simultaneously(with: dragGesture))
                    .onTapGesture(count: 2) {
                        withAnimation(.spring(response: 0.3)) {
                            if scale > 1.0 {
                                resetZoom()
                            } else {
                                scale = 2.0
                                lastScale = 2.0
                            }
                        }
                    }
            } placeholder: {
                ProgressView()
                    .tint(.white)
            }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        onDismiss()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white.opacity(0.8))
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = lastScale * value
            }
            .onEnded { _ in
                lastScale = scale
                withAnimation {
                    validateScaleAndOffset()
                }
            }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if scale > 1.0 {
                    offset = CGSize(
                        width: lastOffset.width + value.translation.width,
                        height: lastOffset.height + value.translation.height
                    )
                }
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }

    private func validateScaleAndOffset() {
        let minScale: CGFloat = 1.0
        let maxScale: CGFloat = 5.0

        if scale < minScale {
            scale = minScale
            lastScale = minScale
            offset = .zero
            lastOffset = .zero
        } else if scale > maxScale {
            scale = maxScale
            lastScale = maxScale
        }
    }

    private func resetZoom() {
        scale = 1.0
        lastScale = 1.0
        offset = .zero
        lastOffset = .zero
    }
}
