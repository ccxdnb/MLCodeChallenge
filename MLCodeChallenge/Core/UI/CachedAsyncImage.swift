import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let targetSize: CGSize
    let content: (Image) -> Content
    let placeholder: () -> Placeholder

    @State private var phase: CachedAsyncImagePhase = .empty

    private let imageLoader: ImageLoader

    init(
        url: URL?,
        targetSize: CGSize,
        imageLoader: ImageLoader,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.targetSize = targetSize
        self.imageLoader = imageLoader
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            switch phase {
            case .empty:
                placeholder()
            case .success(let image):
                content(image)
            case .failure:
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                            .font(.largeTitle)
                    }
            @unknown default:
                placeholder()
            }
        }
        .task(id: url) {
            await loadImage()
        }
    }

    @MainActor
    private func loadImage() async {
        guard let url = url else {
            phase = .empty
            return
        }

        // Only reset to empty if we don't already have a success state
        if case .success = phase {
            // Keep the current image while loading
        } else {
            phase = .empty
        }

        let scale = UITraitCollection.current.displayScale

        do {
            let uiImage = try await imageLoader.loadImage(from: url, targetSize: targetSize, scale: scale)

            guard !Task.isCancelled else { return }

            phase = .success(Image(uiImage: uiImage))
        } catch {
            guard !Task.isCancelled else { return }
            phase = .failure(error)
        }
    }
}

extension CachedAsyncImage where Content == Image, Placeholder == Color {
    init(
        url: URL?,
        targetSize: CGSize,
        imageLoader: ImageLoader
    ) {
        self.init(
            url: url,
            targetSize: targetSize,
            imageLoader: imageLoader,
            content: { $0 },
            placeholder: { Color.gray.opacity(0.3) }
        )
    }
}

enum CachedAsyncImagePhase {
    case empty
    case success(Image)
    case failure(Error)
}
