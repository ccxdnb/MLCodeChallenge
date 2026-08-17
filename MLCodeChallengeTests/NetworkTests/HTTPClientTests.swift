//
//  HTTPClientTests.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//
import Foundation
import Testing
@testable import MLCodeChallenge

@Suite("HTTPClient Tests", .serialized)
struct HTTPClientTests {
    let json = """
    {
        "id": 1,
        "name": "Leanne Graham",
        "username": "Bret",
        "email": "Sincere@april.biz",
        "address": {
            "street": "Kulas Light",
            "suite": "Apt. 556",
            "city": "Gwenborough",
            "zipcode": "92998-3874",
            "geo": {
                "lat": "-37.3159",
                "lng": "81.1496"
            }
        },
        "phone": "1-770-736-8031 x56442",
        "website": "hildegard.org",
        "company": {
            "name": "Romaguera-Crona",
            "catchPhrase": "Multi-layered client-server neural-net",
            "bs": "harness real-time e-markets"
        }
    }
    """

    @Test("Successful response with valid JSON decodes model")
    func successfulResponseDecodesModel() async throws {
        let client = makeTestHTTPClient()
        let expectedUser = User(
            id: 1,
            name: "Leanne Graham",
            username: "Bret",
            email: "Sincere@april.biz",
            address: Address(
                street: "Kulas Light",
                suite: "Apt. 556",
                city: "Gwenborough",
                zipcode: "92998-3874",
                geo: Geo(latitude: -37.3159, longitude: 81.1496)
            ),
            phone: "1-770-736-8031 x56442",
            website: "hildegard.org",
            company: Company(
                name: "Romaguera-Crona",
                catchPhrase: "Multi-layered client-server neural-net",
                bs: "harness real-time e-markets"
            )
        )

        await MockURLProtocol.state.setHandler { request in
            guard let url = request.url else {
                throw APIError.invalidURL
            }
            guard let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ) else {
                throw APIError.invalidResponse
            }
            return (response, Data(json.utf8))
        }

        let result: User = try await client.execute(UsersAPI.users)

        #expect(result == expectedUser)

        await MockURLProtocol.state.clearHandler()
    }

    @Test("Not found status code throws notFound error")
    func notFoundStatusThrowsNotFoundError() async throws {
        let client = makeTestHTTPClient()

        await MockURLProtocol.state.setHandler { request in
            guard let url = request.url else {
                throw APIError.invalidURL
            }
            guard let response = HTTPURLResponse(
                url: url,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            ) else {
                throw APIError.invalidResponse
            }
            return (response, Data())
        }

        await #expect(throws: APIError.notFound) {
            let _: User = try await client.execute(UsersAPI.users)
        }

        await MockURLProtocol.state.clearHandler()
    }

    @Test("Server error status code throws server error")
    func serverErrorStatusThrowsServerError() async throws {
        let client = makeTestHTTPClient()

        await MockURLProtocol.state.setHandler { request in
            guard let url = request.url else {
                throw APIError.invalidURL
            }
            guard let response = HTTPURLResponse(
                url: url,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            ) else {
                throw APIError.invalidResponse
            }
            return (response, Data())
        }

        await #expect(throws: APIError.server(statusCode: 500)) {
            let _: User = try await client.execute(UsersAPI.users)
        }

        await MockURLProtocol.state.clearHandler()
    }

    @Test("Unauthorized status code throws unauthorized error")
    func unauthorizedStatusThrowsUnauthorizedError() async throws {
        let client = makeTestHTTPClient()

        await MockURLProtocol.state.setHandler { request in
            guard let url = request.url else {
                throw APIError.invalidURL
            }
            guard let response = HTTPURLResponse(
                url: url,
                statusCode: 401,
                httpVersion: nil,
                headerFields: nil
            ) else {
                throw APIError.invalidResponse
            }
            return (response, Data())
        }

        await #expect(throws: APIError.unauthorized) {
            let _: User = try await client.execute(UsersAPI.users)
        }

        await MockURLProtocol.state.clearHandler()
    }

    @Test("Malformed JSON with success status throws decoding error")
    func malformedJSONThrowsDecodingError() async throws {
        let client = makeTestHTTPClient()

        await MockURLProtocol.state.setHandler { request in
            guard let url = request.url else {
                throw APIError.invalidURL
            }
            guard let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ) else {
                throw APIError.invalidResponse
            }
            let invalidJSON = Data("{ invalid json".utf8)
            return (response, invalidJSON)
        }

        await #expect(throws: APIError.decoding) {
            let _: User = try await client.execute(UsersAPI.users)
        }

        await MockURLProtocol.state.clearHandler()
    }

    @Test("Not connected to internet throws noConnection error")
    func notConnectedToInternetThrowsNoConnectionError() async throws {
        let client = makeTestHTTPClient()

        await MockURLProtocol.state.setHandler { _ in
            throw URLError(.notConnectedToInternet)
        }

        await #expect(throws: APIError.noConnection) {
            let _: User = try await client.execute(UsersAPI.users)
        }

        await MockURLProtocol.state.clearHandler()
    }

    @Test("Timed out request throws timeout error")
    func timedOutRequestThrowsTimeoutError() async throws {
        let client = makeTestHTTPClient()

        await MockURLProtocol.state.setHandler { _ in
            throw URLError(.timedOut)
        }

        await #expect(throws: APIError.timeout) {
            let _: User = try await client.execute(UsersAPI.users)
        }

        await MockURLProtocol.state.clearHandler()
    }

    @Test("Photos endpoint URL includes albumId, page and limit query parameters")
    func photosEndpointIncludesCorrectQueryParameters() async throws {
        let client = makeTestHTTPClient()
        var capturedRequest: URLRequest?

        await MockURLProtocol.state.setHandler { request in
            capturedRequest = request
            guard let url = request.url else {
                throw APIError.invalidURL
            }
            guard let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ) else {
                throw APIError.invalidResponse
            }
            let json = Data("[]".utf8)
            return (response, json)
        }

        struct Photo: Decodable {}
        let _: [Photo] = try await client.execute(UsersAPI.photos(albumID: 42, page: 3, limit: 10))

        let url = try #require(capturedRequest?.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let queryItems = try #require(components.queryItems)

        #expect(queryItems.contains(URLQueryItem(name: "albumId", value: "42")))
        #expect(queryItems.contains(URLQueryItem(name: "_page", value: "3")))
        #expect(queryItems.contains(URLQueryItem(name: "_limit", value: "10")))

        await MockURLProtocol.state.clearHandler()
    }
}
