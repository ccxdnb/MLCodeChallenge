//
//  ViewState.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//

/// Model destinated to handle view states
enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case empty
    case failed(String)

    /// Stable discriminator for animating between states without requiring
    /// the payload to be Equatable.
    var caseID: String {
        switch self {
        case .idle: "idle"
        case .loading: "loading"
        case .loaded: "loaded"
        case .empty: "empty"
        case .failed: "failed"
        }
    }
}
