import Foundation

nonisolated struct Album: Decodable, Identifiable, Hashable {
    let id: Int
    let userId: Int
    let title: String
}
