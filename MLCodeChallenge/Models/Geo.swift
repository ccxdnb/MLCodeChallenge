//
//  Geo.swift
//  MLCodeChallenge
//
//  Created by Joaquin Wilson on 8/17/26.
//
import Foundation

struct Geo: Codable, Equatable, Sendable {
    let latitude: Double
    let longitude: Double

    private enum CodingKeys: String, CodingKey {
        case lat, lng
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latString = try container.decode(String.self, forKey: .lat)
        let lngString = try container.decode(String.self, forKey: .lng)

        guard let lat = Double(latString), let lng = Double(lngString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .lat, in: container,
                debugDescription: "not valid a number"
            )
        }

        self.latitude = lat
        self.longitude = lng
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(String(latitude), forKey: .lat)
        try container.encode(String(longitude), forKey: .lng)
    }
}
