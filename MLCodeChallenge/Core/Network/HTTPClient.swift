//
//  HTTPClient.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//
import Foundation
import OSLog

private nonisolated let logger = Logger(subsystem: "com.jwilson.MLCodeChallenge", category: "HTTPClient")

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
}

protocol HTTPClientProtocol: Sendable {
    func execute<T: Decodable>(_ endpoint: EndpointType) async throws -> T
    func execute(_ endpoint: EndpointType) async throws
}

final class HTTPClient: HTTPClientProtocol, Sendable {
    private let session: URLSession
    private let decoder: JSONDecoder

    nonisolated init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    nonisolated func execute<T: Decodable>(_ endpoint: EndpointType) async throws -> T {
        let data = try await perform(endpoint)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            logger.error("Decoding \(String(describing: T.self)) failed: \(error.localizedDescription)")
            throw APIError.decoding
        }
    }

    nonisolated func execute(_ endpoint: EndpointType) async throws {
        _ = try await perform(endpoint)
    }

    /// Sends the request and validates the response. Returns the raw body so
    /// callers decide whether to decode it or discard it.
    private nonisolated func perform(_ endpoint: EndpointType) async throws -> Data {
        let request = try endpoint.urlRequest()
        logger.debug("→ \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            logger.error("Network failure: \(error.code.rawValue)")
            throw error.asAPIError
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        logger.debug("← \(http.statusCode) \(request.url?.path ?? "")")

        guard (200...299).contains(http.statusCode) else {
            throw APIError.from(statusCode: http.statusCode)
        }

        return data
    }
}

private extension URLError {
    var asAPIError: APIError {
        switch code {
        case .notConnectedToInternet, .networkConnectionLost: .noConnection
        case .timedOut: .timeout
        case .cancelled: .cancelled
        default: .unknown
        }
    }
}
