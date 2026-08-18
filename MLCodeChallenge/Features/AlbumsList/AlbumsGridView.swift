//
//  AlbumsListView.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/18/26.
//
import SwiftUI

struct AlbumsGridView: View {
    @Bindable var viewModel: AlbumsGridViewModel

    init(viewModel: AlbumsGridViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        contentView
            .appBackground()
            .navigationTitle("Albums")
            .task {
                if case .idle = viewModel.state {
                    await viewModel.load()
                }
            }
            .refreshable { await viewModel.refresh() }
    }
}

extension AlbumsGridView {
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

            case .loaded(let albums):
                albumsList(albums)
                    .transition(.opacity)

            case .idle:
                Color.clear

            case .empty:
                EmptyStateView()
                    .transition(.opacity)

            case let .failed(message):
                FailedStateView(message: message) {
                    Task { await viewModel.load() }
                }
            }
        }.animation(.smooth(duration: 0.3), value: viewModel.state.caseID)
    }

    @ViewBuilder
    private func albumsList(_ albums: [Album]) -> some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(Array(albums.enumerated()), id: \.element.id) { index, album in
                    AlbumCardItem(
                        album: album,
                        coverPhoto: viewModel.albumCovers[album.id],
                        viewModel: viewModel
                    )
                    .onTapGesture {
                        viewModel.didSelect(album)
                    }
                    .transition(.scale(scale: 0.95).combined(with: .opacity))
                    .animation(.smooth(duration: 0.25).delay(Double(index) * 0.05), value: viewModel.albumCovers[album.id])
                }
            }
            .padding(16)
        }
    }
}

#Preview {
    AlbumsGridView(
        viewModel: .init(dependencies:
                .init(albumsService: PreviewAlbumsService(),
                      photosService: PreviewPhotosService(),
                      imageLoader: ImageLoader(cache: ImageCache()),
                      coordinator: AppCoordinator(),
                      userID: 1)
        )
    )
}
