//
//  MockURLProtocol.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//
import Foundation
@testable import MLCodeChallenge

/// A custom URLProtocol that intercepts network requests for testing purposes.
///
/// This mock protocol prevents actual HTTP calls from being made during tests by
/// intercepting URLSession requests and returning programmatically configured responses.
/// While HTTPClient logs will show URLs and status codes as if real requests were made,
/// no network traffic actually occurs.
///
/// Usage:
/// ```swift
/// let client = makeTestHTTPClient()
///
/// await MockURLProtocol.state.setHandler { request in
///     let response = HTTPURLResponse(url: request.url!, statusCode: 200, ...)
///     return (response, mockData)
/// }
///
/// let result: User = try await client.execute(endpoint)
/// ```
final class MockURLProtocol: URLProtocol {
    static let state = MockURLProtocolState()
    private var loadingTask: Task<Void, Never>?

    override static func canInit(with request: URLRequest) -> Bool {
        true
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        loadingTask = Task {
            do {
                let (response, data) = try await Self.state.executeHandler(for: request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
    }

    override func stopLoading() {
        loadingTask?.cancel()
        loadingTask = nil
    }
}

/// Creates an HTTPClient configured to use MockURLProtocol for testing.
///
/// Returns an HTTPClient with a custom URLSession that intercepts all network
/// requests and routes them through MockURLProtocol instead of making real HTTP calls.
/// Uses ephemeral configuration to prevent cache storage during tests.
///
/// - Returns: An HTTPClient instance suitable for unit testing
func makeTestHTTPClient() -> HTTPClient {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    let session = URLSession(configuration: config)
    return HTTPClient(session: session)
}
