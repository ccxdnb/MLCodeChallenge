//
//  HTTPMethod.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//
import Foundation

public enum BodyParameter {
    case data(Data)
    case dictionary([String: Any], options: JSONSerialization.WritingOptions = [])
    case encodable(Encodable, encoder: JSONEncoder = .init())
}

nonisolated public protocol EndpointType {
    var baseURL: URL? { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }
}

nonisolated extension EndpointType {
    var baseURL: URL? { AppConfiguration.apiBaseURL }
    var queryItems: [URLQueryItem]? { nil }
    var headers: [String: String]? { nil }

    func urlRequest() throws -> URLRequest {
        guard let base = baseURL, var components = URLComponents(
            url: base.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        ) else {
            throw APIError.invalidURL
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        return request
    }
}
