//
//  FullscreenPhotoView.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/18/26.
//
import SwiftUI

struct PhotosListView: View {
    @Bindable var viewModel: PhotosListViewModel
    let imageLoader: ImageLoader

    init(viewModel: PhotosListViewModel, imageLoader: ImageLoader) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
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
            .sheet(item: $viewModel.selectedPhoto) { photo in
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
            LazyVStack(spacing: 0) {
                ForEach(paginationState.photos) { photo in
                    PhotoRow(
                        photo: photo,
                        imageLoader: imageLoader,
                        onTap: { viewModel.didSelectPhoto(photo) }
                    )
                    .onAppear {
                        if photo.id == paginationState.photos.last?.id {
                            viewModel.loadNextPageIfNeeded()
                        }
                    }
                }

                if paginationState.isLoadingMore {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
        }
    }
}

#Preview {
    let imageLoader = ImageLoader(cache: ImageCache())
    return PhotosListView(
        viewModel: .init(dependencies:
                .init(photosService: PreviewPhotosService(),
                      imageLoader: imageLoader,
                      albumID: 1)
        ),
        imageLoader: imageLoader
    )
}
