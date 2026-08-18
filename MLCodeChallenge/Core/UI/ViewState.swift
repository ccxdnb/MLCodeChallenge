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
}
