//
//  MLCodeChallengeTests.swift
//  MLCodeChallengeTests
//
//  Created by Joaquin Wilson on 8/14/26.
//

import Testing
import Foundation
@testable import MLCodeChallenge

struct GeoTests {
    @Test("Decodes string coordinates into Double")
    func decodesValidCoordinates() throws {
        let geo = try JSONDecoder().decode(
            Geo.self,
            from: Data(#"{"lat": "40.7128", "lng": "-74.0060"}"#.utf8)
        )
        #expect(geo.latitude == 40.7128)
        #expect(geo.longitude == -74.0060)
    }

    @Test("Throws on non-numeric coordinates", arguments: [
        #"{"lat": "invalid", "lng": "-74.0060"}"#,
        #"{"lat": "40.7128", "lng": "not-a-number"}"#,
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
