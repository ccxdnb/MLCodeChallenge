//
//  APIError.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//
import Foundation

enum APIError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case unauthorized
    case notFound
    case server(statusCode: Int)
    case decoding
    case noConnection
    case timeout
    case cancelled
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL, .invalidResponse, .decoding, .unknown:
            "Something went wrong. Please try again."
        case .unauthorized:
            "You are not authorized to perform this action."
        case .notFound:
            "The requested resource was not found."
        case .server(let code):
            "Server error (\(code)). Please try again later."
        case .noConnection:
            "No internet connection."
        case .timeout:
            "The request timed out."
        case .cancelled:
            nil
        }
    }

    static func from(statusCode: Int) -> APIError {
        switch statusCode {
        case 401, 403: .unauthorized
        case 404:      .notFound
        case 500...599: .server(statusCode: statusCode)
        default:       .unknown
        }
    }
}
