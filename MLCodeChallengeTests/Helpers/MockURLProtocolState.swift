//
//  MockURLProtocolState.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//
import Foundation

actor MockURLProtocolState {
    var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    func setHandler(_ handler: @escaping (URLRequest) throws -> (HTTPURLResponse, Data)) {
        self.handler = handler
    }

    func clearHandler() {
        self.handler = nil
    }

    func executeHandler(for request: URLRequest) throws -> (HTTPURLResponse, Data) {
        guard let handler else {
            throw NSError(
                domain: "MockURLProtocol",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "No handler set"]
            )
        }
        return try handler(request)
    }
}
