//
//  HTTPClientProtocol.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//
import Foundation
import OSLog

private nonisolated let logger = Logger(subsystem: "com.jwilson.MLCodeChallenge", category: "HTTPClient")

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

protocol HTTPClientProtocol: Sendable {
    func execute<T: Decodable>(_ endpoint: EndpointType) async throws -> T
}

actor HTTPClient: HTTPClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func execute<T: Decodable>(_ endpoint: EndpointType) async throws -> T {
        let request = try await endpoint.urlRequest()
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

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            logger.error("Decoding \(String(describing: T.self)) failed: \(error.localizedDescription)")
            throw APIError.decoding
        }
    }
}

private extension URLError {
    var asAPIError: APIError {
        switch code {
        case .notConnectedToInternet, .networkConnectionLost: .noConnection
        case .timedOut: .timeout
        default: .unknown
        }
    }
}

nonisolated enum AppConfiguration {
    static let apiBaseURL: URL = {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com") else {
            preconditionFailure("Invalid base URL literal")
        }
        return url
    }()
}
