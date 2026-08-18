//
//  MLCodeChallengeTests.swift
//  MLCodeChallengeTests
//
//  Created by Joaquin Wilson on 8/14/26.
//

import Testing
import Foundation
@testable import MLCodeChallenge

@Suite("Geo")
struct GeoTests {
    @Test("Decodes string coordinates into Double")
    func decodesValidCoordinates() throws {
        let geo = try JSONDecoder().decode(
            Geo.self,
            from: Data(#"{"lat": "1.1234", "lng": "-2.4321"}"#.utf8)
        )
        #expect(geo.latitude == 1.1234)
        #expect(geo.longitude == -2.4321)
    }

    @Test("Throws on non-numeric coordinates", arguments: [
        #"{"lat": "wrong", "lng": "-74.0060"}"#,
        #"{"lat": "40.7128", "lng": "wrong"}"#,
        #"{"lat": "", "lng": "-74.0060"}"#
    ])
    func throwsOnInvalidCoordinates(json: String) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(Geo.self, from: Data(json.utf8))
        }
    }

    @Test("Throws when a coordinate key is missing")
    func throwsOnMissingKey() {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(Geo.self, from: Data(#"{"lng": "-74.0060"}"#.utf8))
        }
    }
}
