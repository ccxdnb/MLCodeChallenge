//
//  FullscreenPhotoView.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/18/26.
//
import SwiftUI

struct PhotosListView: View {
    @State var viewModel: PhotosListViewModel
    let imageLoader: ImageLoader
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init(dependencies: PhotosListViewModel.Dependencies) {
        self.imageLoader = dependencies.imageLoader
        _viewModel = .init(wrappedValue: .init(dependencies: dependencies))
    }

    var body: some View {
        contentView
            .appBackground()
            .navigationTitle("Photos")
            .task {
                if case .idle = viewModel.state {
                    await viewModel.loadInitial()
                }
            }
            .refreshable { await viewModel.refresh() }
            .fullScreenCover(item: $viewModel.selectedPhoto) { photo in
                FullscreenPhotoView(
                    photo: photo,
                    imageLoader: imageLoader,
                    onDismiss: { viewModel.dismissPhoto() }
                )
            }
    }
}

extension PhotosListView {
    @ViewBuilder
    private var contentView: some View {
        Group {
            switch viewModel.state {
            case .loading:
                VStack {
                    ProgressView()
                    Text("Loading...")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)

            case .loaded(let paginationState):
                photosGrid(paginationState)
                    .transition(.opacity)

            case .idle:
                Color.clear

            case .empty:
                EmptyStateView()
                    .transition(.opacity)

            case let .failed(message):
                FailedStateView(message: message) {
                    Task { await viewModel.loadInitial() }
                }
            }
        }.animation(.smooth(duration: 0.3), value: viewModel.state.caseID)
    }

    @ViewBuilder
    private func photosGrid(_ paginationState: PhotosListViewModel.PaginationState) -> some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 8) {
                ForEach(Array(paginationState.photos.enumerated()), id: \.element.id) { index, photo in
                    PhotoGridCell(
                        photo: photo,
                        imageLoader: imageLoader,
                        onTap: { viewModel.didSelectPhoto(photo) }
                    )
                    .onAppear {
                        prefetchNearbyPhotos(currentIndex: index, photos: paginationState.photos)
                    }
                }

                if !paginationState.hasReachedEnd {
                    GridRow {
                        Color.clear
                            .frame(height: 20)
                            .gridCellColumns(gridColumns.count)
                            .onAppear {
                                viewModel.loadNextPageIfNeeded()
                            }
                    }
                }

                if paginationState.isLoadingMore {
                    GridRow {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .gridCellColumns(gridColumns.count)
                            .padding()
                    }
                }
            }
            .readableContentWidth()
            .padding(16)
        }
    }

    /// Prefetch some images ahead of the current visible photo
    private func prefetchNearbyPhotos(currentIndex: Int, photos: [Photo]) {
        let prefetchCount = horizontalSizeClass == .compact ? 5 : 12

        let startIndex = currentIndex + 1
        let endIndex = min(currentIndex + prefetchCount, photos.count - 1)

        guard startIndex <= endIndex else { return }

        for currentIndex in startIndex...endIndex {
            let photo = photos[currentIndex]
            Task {
                // Prefetch at the same size used for display
                _ = try? await imageLoader.loadImage(
                    from: photo.bannerURL,
                    targetSize: CGSize(width: 400, height: 400),
                    scale: 1.0
                )
            }
        }
    }

    private var gridColumns: [GridItem] {
        if horizontalSizeClass == .compact {
            // iPhone: 1 column
            [GridItem(.flexible(), spacing: 8)]
        } else {
            // iPad: adaptive columns
            [GridItem(.adaptive(minimum: 150, maximum: 400), spacing: 8)]
        }
    }
}

#Preview {
    let imageLoader = ImageLoader(cache: ImageCache())
    return PhotosListView(dependencies:
                .init(photosService: PreviewPhotosService(),
                      imageLoader: imageLoader,
                      albumID: 1)
    )
}
